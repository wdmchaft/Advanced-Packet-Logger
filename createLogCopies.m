function [err, errMsg] = createLogCopies(lgP, masterLogPath, masterName, dir4Batch);
%function [err, errMsg] = createLogCopies(lgP, masterLogPath, masterName, dir4Batch);
% (1) Copies the packet log to all specified locations for the copies. 
% (2) Additionally copies messages listed in the log to sub-directories:
%   1:   ...\<*log name*>.csv
%   2:   ...\<log name>_InTray\<message name>.<message ext>
%   2:   ...\<log name>_SentTray\<message name>.<message ext>
% Calling "validateLogCopyLocations" before this procedure assures only accessible
% locations will be accessed (use "updateLogCopies for this);  example:
%   Ndx = validateLogCopyLocations(logPaths);
%   if length(Ndx)
%     % 2) create the copies in the accessible locations
%     [err, errMsg] = createLogCopies(logPaths(Ndx), masterLogPath, masterName);
%   end
% Copies are made by writing a batch file containing the commands to perform
%  copying all files & then calling that file once.
%INPUT:
% lgP: cell list of all the *valid* locations where the operator wants copies. If empty
%   no action will occur.
% masterLogPath: full path to the master log
% masterName: name but no extension
% dir4Batch: "\" terminated path to location where the (temporary) batch file will be located

% currently (8/8/10) called from  makeLogCopiesCurrent (dCInitCopy,displayCount ); updateLogCopies ( displayCount, processutpostPM)

[err, errMsg, modName] = initErrModName(mfilename);
%if the log is not local
isNetLog = (1 == findstrchr('\\', masterLogPath));
if isNetLog
  a = findstrchr('\', masterLogPath) ;
  netName = sprintf('%s_', masterLogPath((a(2)+1):(a(3)-1)));
else % if isNetLog
  netName = '';
end % if isNetLog else

%determine which messages have not been copied - requires reading the log
% to learn the locations & names of the files-> placed in "logged.fpathName"
[err, errMsg, logged, header, columnHeader] = readPacketLog(sprintf('%s%s.csv',masterLogPath, masterName));
%if any of the copy locations is valid....
if length(lgP)
  outpostFileList = {'message.log'}; % need outpost's location to be passed in! , 'outpost.ini'};
  %embed the path of the source message.log into the name:
  %  pull all ":"
  %  replace all "\" with "_"
  %  replace all " " with "-"
  masterLogPath_bs = endWithBackSlash(masterLogPath);
  a = strrep(masterLogPath_bs, ':','');
  a = strrep(a, '\','_');
  a = strrep(a, ' ','-');
  for itemp = 1:length(outpostFileList)
    %no path, source path as name
    outpostFileListTarget(itemp) = {strcat(a,outpostFileList{itemp})};
    %need source path
    outpostFileList(itemp) = {strcat(masterLogPath_bs,outpostFileList{itemp})};
  end
  if isNetLog
    %more than one log file type exists & need to copy all & add netName as
    % prefix: requires explicit file by file copy command (see below)
    a = sprintf('"%s%s*.csv"', masterLogPath, masterName) ;
    logsToCopyDir = dir(a);
  end %if isNetLog
  % Several actions required.  To avoid opening a DOS box more than
  %once, we'll write a batch file containing all the actions.  We'll delete it when done.
  batchName = sprintf('%supdateLogCopy.bat', dir4Batch);
  [err, errMsg, fidB] = fOpenToWrite(batchName, 'w', mfilename);
  if (fidB > 0)
    dirList = {'InTray','SentTray'};
    fprintf(fidB,'@echo off\r\n');
    fprintf(fidB,'rem  Temporary file written and used by %s.  Should be automatically deleted after use.\r\n', mfilename);
    fprintf(fidB,'echo on\r\n');
    % 2) write a batch file that will actually perform all the copy operations.
    for itemp = 1:length(lgP)
      %these are the core names of the directories at the source.
      %  a) we'll search the file paths in the log for these directories
      %  b) these will form the core of the names on the targets
      for dirListNdx = 1:length(dirList)
        %name will be: <target location><netname><log master name><tray name>
        %  example when <netName> is "radio room_": g:\packet logs\radio room_packetCommLog_100216_InTray\
        %  example for local log: g:\packet logs\packetCommLog_100216_InTray\
        dirToMake = sprintf('%s%s%s_%s\\', char(lgP(itemp)), netName, masterName, char(dirList(dirListNdx))) ;
        b = dir(sprintf('%s*.', dirToMake));
        %if the directory does not exist
        if ~length(b)
          %create it
          fprintf('\r\nCreating directory "%s".', dirToMake);
          [err, errMsg, status, msg] = mkdirExt(dirToMake);
          if err
            fprintf('\r\n%s%s.', modName, errMsg);
          end
          fprintf(' Getting ready to copy %s messages.', char(dirList(dirListNdx)));
          %add a line to batch to copy each & every file
          for msgNdx = 1:length(logged)
            thisFile = char(logged(msgNdx).fpathName);
            %if this logged.fpathName is in the directory we're processing....
            if findstrchr(lower(char(dirList(dirListNdx))), lower(thisFile))
              [pathstr,name,ext,versn] = fileparts(thisFile);
              fprintf(fidB,'copy "%s" "%s%s%s"\r\n', thisFile, dirToMake, name, ext);
            end
          end % for msgNdx = 1:length(logged)
        else %if ~length(b)
          %target directory exists: only need to copy new or altered files
          fprintf('\r\nGetting ready to copy %s messages.', char(dirList(dirListNdx)));
          for msgNdx = 1:length(logged)
            thisFile = char(logged(msgNdx).fpathName);
            needCopy = 0;
            %if this logged.fpathName is in the directory we're processing....
            if findstrchr(lower(char(dirList(dirListNdx))), lower(thisFile))
              [pathstr,name,ext,versn] = fileparts(thisFile);
              %see if the file exists in the target location
              c = dir(sprintf('%s%s%s', dirToMake, name, ext));
              if length(c)
                %exists: check date/time & size
                b = dir(thisFile);
                if (datenum(b.date) > datenum(c.date)) | (b.bytes ~= c.bytes)
                  % source is newer or size is different
                  needCopy = 1;
                end
              else
                %file doesn't exist: copy it
                needCopy = 1;
              end
              if needCopy
                %add a line to batch to copy this file
                fprintf(fidB,'copy "%s" "%s%s%s"\r\n', thisFile, dirToMake, name, ext);
              end % if needCopy
            end % if findstrchr(lower(char(dirList(itemp))), lower(thisFile))
          end % for msgNdx = 1:length(logged)
        end  %if ~length(b) else
      end % for dirListNdx = 1:length(dirList)
      % turn off read-only on the existing copies
      fprintf(fidB,'attrib "%s%s%s*.csv" -r\r\n', char(lgP(itemp)), netName, masterName);
      for oP = 1: length(outpostFileList)
        fprintf(fidB,'attrib "%s%s%s" -r\r\n', char(lgP(itemp)), netName, char(outpostFileListTarget(oP)));
      end
      % copy all the master Log files to this location - 
      %      <masterName>.csv, <masterName>_Recvd.csv, <masterName>_Sent.csv, <masterName>_sprt.csv, 
      if isNetLog
        %Explicit copy command for each file - allows netName to be prefix for each
        for jtemp = 1:length(logsToCopyDir)
          fprintf(fidB,'copy "%s%s.csv" "%s%s%s.csv"\r\n', masterLogPath, logsToCopyDir(jtemp).name, ...
            char(lgP(itemp)), netName, logsToCopyDir(jtemp).name);
        end %for jtemp = 1:length(logsToCopyDir)
      else % if isNetLog
        %no prefix needed: one line with wild cards will copy all
        fprintf(fidB,'copy "%s%s*.csv" "%s*.csv"\r\n', masterLogPath, masterName, char(lgP(itemp)));
      end % if isNetLog else
      for oP = 1: length(outpostFileList)
        % the copy
        fprintf(fidB,'copy "%s" "%s%s%s"\r\n', char(outpostFileList(oP)), ...
          char(lgP(itemp)), netName, char(outpostFileListTarget(oP)));
        % re-enable the read-only
        fprintf(fidB,'attrib "%s%s%s" +r\r\n', char(lgP(itemp)), netName, char(outpostFileListTarget(oP)));
      end
      % turn on read-only for the copies
      fprintf(fidB,'attrib "%s%s*.csv" +r\r\n', char(lgP(itemp)), masterName);
    end % for itemp = 1:length(lgP)
    fclose(fidB);
    %call the batch file
    fprintf('\r\nCreating %i Packet Log copies.', itemp );
    err = dos(sprintf('"%s"', batchName));
    fprintf(' Done.')
    %erase the batch file
    delete(batchName);
    %report any errors with the batch file
    if err
      errMsg = sprintf('%s: error running "%s".', modName, batchName);
    end
  end % if (fidB > 0)
end %if length(lgP)
