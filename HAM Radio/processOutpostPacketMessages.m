function [err, errMsg] = processOutpostPacketMessages(PathToArchive, PathReceived, PathSent)
%[err, errMsg] = processOutpostPacketMessages([PathToArchive[, PathReceived[, PathSent]]])
%
%ACTIONS:  This program is expected to be called from an Outpost script.  That script is
%  expected to perform a SEND/RECEIVE and write each message, sent or received, as a text
%  file in the directory as specified by the script (see below under INPUTS).  Typically
%  the received messages are in ...Outpost\Archive\InTray and the sent in ...Outpost\Archive\SentTray.
%  This program by its very nature does not have a user interface so optional items are
%  controlled by a series of files as explained under INPUT below.
%  
%  This program will perform the following actions:
%  * extract message information and place this information in the Packet Log. Some of the information
%    is from the message itself & some information is developed by Outpost. When the message is a
%    PACForm message, additional information is extracted from within the form.
%   From the Outpost information: bbs, from, to, subject, dateTime, time, form type - "Simple"
%     for Outpost & PACF name as embedded by PACF in the Outpost message.
%   From within a PACF message: senderMsgNum, date, time, comment, subject, replyReq, replyWhen
%    Note that the PACF fields are loaded with different information depending on the actual form
%      and what information is available on that form.  For example, not all PACF contain a message number.
%  * Write three (3) Packet Message logs: a log of 1) messages sent and received, 2) messages received, 
%    & 3) messages sent. The logs are written in CSV format and include headings.
%    The logs all start with the name "packetCommLog_YrMoDa" and will be in outpost.INI's "DirLogs"
%     directory.  As implied by this naming convention, there is one log per day.  Should an Incident
%     run past midnight, there will be one log for every day.
%    The log will insert a line when operational conditions change such as new operator or call sign,
%     change in tactical call sign and/or a change in the usage of tactical call sign (enable or disable)
%    The logs are written by "writePacketLog". Check that file for the most current information but
%    currently lists SENDER MSG NO, BBS, Outpost Time, Time on Form, From, To, Form Type, Subject, Comment, 
%      and Reply Rqd. "Subject" is a composite of Outpost's comment & information from the PACF; "Comment" 
%      is a composition of information from PACF & blank for a "simple" (ie: Outpost only) message.
%    A support file is also written that contains information that may or may not be in the log.  Its
%     main purpose is to facilite program flow without cluttering the log itself.
%  * If the Packet Log monitor program is not running, this program will make copies of the log to all 
%    locations  specified in "ProcessOPM_log.ini" (in Outpost\Archive).  The copies will be made everytime
%    updating of the log itself is completed here. (Old copies are replaced by the latest)
%    When the Packet Log monitor program is running, this program will dependent on that program
%    to make the copies.  Note that the copy locations can include removable drive(s) and networks.
%    Should the location not be accessible, the program will skip that location until it
%    becomes accessible.  (You may want to read the features of the Packet Log monitor program as well
%    especially since it can monitor logs across a network - you do not need to use this program's
%    ability to maintain copies for a "sneaker net" to allow others to observe the log)
%  * If printed is enabled, print the fields on pre-printed ICS-213 forms for any received 
%    or sent PACF "EOC MESSAGE FORM".
%
%INPUTS:
%  PathToArchive[optional]:
%  PathReceived[optional]:
%  PathSent[optional]:
%if any of the above three are not passed in or are null, the following file(s) will be used for that variable
% ini_DirArchive.txt (in Outpost\Scripts\): written by "OutpostINItoScript" - this is the path
%       Outpost.ini lists as the archive directory.
%     if this file is not present, this program will directly access Outpost.ini & determine
%       Outpost's archive directory.
% PathReceived.txt: contains the path to the text files written by the
%     Outpost script, these text files being the messages that have been received.
%      if this file is not present, defaults to Outpost\Archive\InTray\, a directory not created
%        by Outpost but created by this program's installer.
% PathSent.txt: contains the path to the text files written by the
%     Outpost script, these text files being the messages that have been sent.
%      if this file is not present, defaults to Outpost\Archive\SentTray\, a directory not created
%        by Outpost but created by this program's installer.
%
%FILES NEEDED:  unless otherwise noted, files need to be in the folder defined in
%    ...\Outpost\Scripts\\ini_DirArchive.txt; if that file isn't found, default for these
%    files is ...\Outpost\Archive\.
%    NOTE: (program will locate Outpost's drive presuming path is
%        '\Program Files\Outpost\', or 
%        '\Program Files (x86)\Outpost\'
%
% ICS213.mat: required for printing the ICS-213 messages on pre-printed forms.  Contains
%   the digitized locations of the fields on the form.  
%   Not a file to altered by the user.
% ICS213_crossRef.csv: required for printing the ICS-213 messages on pre-printed forms.  Contains
%   the cross reference from the name of the fields when digitized, and the names as transmitted
%   via Outpost.  Also contains the desired vertical and horizontal justifications. 
%   Not a file to altered by the user.
%
% inTray_copies.txt[optional]: names, one per line, for each desired copy of a printed message.
%   The number of entries defines the number of copies.  If this file is not present, will 
%   use the defaults as defined by SCC on their ICS213 form.  
%   Intended for user modification.
% outTray_copies.txt{optional]: names, one per line, for each desired copy of a printed message.  
%   The number of entries defines the number of copies.  If this file is not present, will 
%   use the defaults as defined by SCC on their ICS213 form.  
%   Intended for user modification.
% ProcessOPM_log.ini[optional]: if the operator desires copies of the log to be automatically
%   maintained, this file contains the locations for all desired copies.  Multiple locations
%   are permitted including locations on a network.  See the file for more explanation.
%   If the file is not present, this program will write it & set it to the default values.  
%   This also means if the operator has made changes and wants to revert to the default values,
%   the operator merely needs to erase the file.
%   Intended for user modification.
% ProcessOPM.ini[optional]: a configuration file containing items such as enabling or
%   disabling printing, printing quality to letter or draft, etc.
%   If the file is not present, this program will write it & set it to the default values.  
%   This also means if the operator has made changes and wants to revert to the default values,
%   the operator merely needs to erase the file.
%   Intended for user modification.
%
% incidentName.txt: contains the name of the Incident which will be logged into the Packet Log.  
%   If not present, will be created declaring this a Test Incident.
%       Intended for user modification.
%
%PROGRAM(S) SEMAPHORE FILES
% These files are use to signal status between this program and "displayCounts".  No user
% interaction should occur.
%CREATED/DESTROYED by this program:
% <masterlogPath>'processOPM_run.txt': created when this program starts and destroyed
%   when exited. Placed in same directory as the Packet Log which all instances of the 
%   monitoring program, local and remote/networked, will already be accessing. The purpose
%   is to allow displayCounts to not attempt to create the Log's copy(ies) while this module
%   is still updating the master log.  The problem copying presents is the Copy operation 
%   momentarily blocks updating the log!
%CHECKED/USED by this program:
% <current directory>PkLgMonitor*_on: present while 'displayCounts' is in real-time
%    monitoring mode and will therefore keep the desired copies of the Log (as specified in 
%    "ProcessOPM_log.ini") up-to-date.
% <masterlogPath>PkLgMonitor*_copy.txt: present while 'displayCounts' is actually making
%    copies of the Packet Log.  This program will wait to update the Log until the copying
%    is completed. Destroyed as soon as the copying is completed. Multiple copies of this
%    file may exist if multiple instances of 'displayCounts' are running.  For example, if
%    this Packet Log is being monitored both locally and remotely.  

% o	Printer initialization string
% o	The file
% o	Page eject
% •	Printer definition file
% o	Pitch
% o	Lines per inch
% o	Size of margins (where is top left & bottom right)
% •	Form definition file
% o	Location of each field in inches or mm.
% o	Print style: centered, left justified.

% Need to print non-213 messages
global debug

% \Program Files\Outpost\archive\InTray

[err, errMsg, modName] = initErrModName(mfilename);

debug = 0;

if nargin < 1
  [err, errMsg, presentDrive, DirOutpost] = findOutpostINI;
  fid = fopen(sprintf('%sScripts\\ini_DirArchive.txt', DirOutpost), 'r');
  if fid > 0
    PathToArchive = fgetl(fid);
    if length(PathToArchive)
      PathToArchive = endWithBackSlash(PathToArchive);
    end
  else
    PathToArchive = '';
  end
  fcloseIfOpen(fid);
else % if nargin < 1
  PathToArchive = endWithBackSlash(PathToArchive);
  [err, errMsg, presentDrive, DirOutpost] = findOutpostINI(PathToArchive);
end % if nargin < 1 else

[err, errMsg, outpostNmNValues] = OutpostINItoScript(DirOutpost, modName);
if nargin < 2
  fid = fopen(sprintf('%sPathReceived.txt', PathToArchive), 'r');
  if fid > 0
    PathReceived = fgetl(fid);
  else
    PathReceived = '';
  end
  fcloseIfOpen(fid);
end % if nargin < 2
if nargin < 3
  fid = fopen(sprintf('%sPathSent.txt', PathToArchive), 'r');
  if fid > 0
    PathSent = fgetl(fid);
  else
    PathSent = '';
  end
  fcloseIfOpen(fid);
end

if ~length(PathToArchive)
  PathToArchive = sprintf('%sarchive\\', DirOutpost) ;
end
if ~length(PathReceived)
  PathReceived = sprintf('%sInTray\\', PathToArchive) ;
end
if ~length(PathSent)
  PathSent = sprintf('%sSentTray\\', PathToArchive) ;
end
PathToArchive = includeDrive(PathToArchive, presentDrive);
PathReceived = includeDrive(PathReceived, presentDrive);
PathSent = includeDrive(PathSent, presentDrive);
PathScripts = outpostValByName('DirScripts', outpostNmNValues);

PathConfig = outpostValByName('DirAddOns', outpostNmNValues);
%this is the location of this program - not sure I have to hard code it but it works
workingDir = outpostValByName('DirAddOnsPrgms', outpostNmNValues);
%#IFDEF debugOnly  
% actions in IDE only
debug = 1;
%#ENDIF
fid = fopen(sprintf('%s%s_debug.txt', outpostValByName('DirAddOnsPrgms', outpostNmNValues), mfilename),'r');
if fid > 0
  fprintf('\n Diagnostic outputs enabled.');
  fclose(fid);
  debug = 1;
end

pathDirs.addOns = PathConfig;
pathDirs.addOnsPrgms = workingDir;
pathDirs.DirPF =  outpostValByName('DirPF', outpostNmNValues);

masterlogPath = outpostValByName('DirLogs', outpostNmNValues);

%semaphore file to indicate this program is running
%  ---- this name is expected by "displayCounts", the packet log monitoring program
% We are placing this in the same directory as the Packet Log because all instances 
% of the monitoring program, local and remote/networked, will already be accessing.
%The purpose is to allow displayCounts to not attempt to create the Log's copy(ies) while
% this module is still updating the master log.  The problem copying presents is the Copy operation 
% momentarily blocks updating the log!
prgmIsRunningPathName = strcat(masterlogPath, 'processOPM_run.txt');
fid = fopen(prgmIsRunningPathName,'w');
if (fid > 0)
  fprintf(fid,'This file indicates that "%s" is running - it is created when it starts & deleted when it closes.', mfilename);
  fclose(fid);
end

%read in the name of the incident: (same code as in "displayCounts" - change one, change both)
[err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
a = findstrchr('_', date_time);
packetLogName = sprintf('packetCommLog_%s', date_time(1:a-1) ) ; %just want the date
[incidentName, incidentDate, activationNumber] = readIncidentName(PathScripts);
incidentName = sprintf('%s, %s, %s', incidentName, incidentDate, activationNumber);

processLog = sprintf('%sprocess_%s.log', PathConfig, date_time(1:a-1));
% read the list of messages we've processed today
[trayList] = readProcessLog(processLog);

%read the list created by the Script of messages it has processed
receivedfilesList_new = readMessageList(PathReceived) ;
sentfilesList_new = readMessageList(PathSent) ;

%merge sent & received
filesList_new = [receivedfilesList_new sentfilesList_new] ;
if length(filesList_new)
  % sort merged regardless of sent/received.
  %want to sort on name excluding the first character which
  % indicates whether the message was sent or received
  a = char([filesList_new.name]');
  for itemp=1:size(a,1);
    b(itemp)={a((itemp),2:size(a,2))};
  end
  [B, Ndx] = sort(b);
  filesList_new = filesList_new(Ndx);
end % length(filesList_new)
if debug
  fprintf('\n Length of file list for newly sent & received: %i', length(filesList_new));
end

%read the operator's printing preferences:
[err, errMsg, printer] = readProcessOPM_INI(PathConfig);
%read the locations for the copies of the logs:
[err, errMsg, logPaths] = readProcessOPM_Logs(PathConfig);

masterLogPathName = sprintf('%s%s', masterlogPath, packetLogName);
%Part of the determination of whether this program needs to be making copies 
% of the Packet Log or whether 'displayCounts' will.  The script will start
% 'displayCounts' the first time it is run but 'displayCounts' will not
% know the name of the log until after this program creates it.
if length(logPaths)
  logExisted = exist(strcat(masterLogPathName,'.csv'));
else
  logExisted = 0;
end

%want the log files to be read-only so Excel doesn't take control & lock us out.
%Need to unlock to update & relock after update.
%  Had been doing this immediately around the update but that takes significant
%  time.  Adds up quickly becuase that is twice per message: once for the common
%  log & once for the received/sent log.  On one machine (w7/64 using i7 quad core)
%  this took ~0.6 seconds total.
%Let's do it once for all messages.
a = dir(sprintf('%s*.csv', masterLogPathName));
if length(a)
  dos(sprintf('attrib "%s" -r', sprintf('%s*.csv', masterLogPathName)));
end
%exception handler so a) code continues & b) we restore read-only
try
  %set some values so if the called function triggers the try/catch we'll have values
  new_trayItem = {};
  logUpdated = 0;  
  [trayList, new_trayItem, err, errMsg, logUpdated] = processMessages(filesList_new, {PathSent PathReceived}, trayList, 0, pathDirs, outpostNmNValues, packetLogName, incidentName, printer, logPaths, masterLogPathName, processLog);
catch
  if length(errMsg)
    errMsg = sprintf('%s AND %s', errMsg, lasterr);
  else % if length(errMsg)
    %set error so findNewOutpostMsgs, called from Script, knows & reacts properly on next set
    err = 1;
    errMsg =lasterr;
  end % if length(errMsg) else
  logErr(mfilename, err, errMsg, outpostNmNValues);
end %try/catch
dos(sprintf('attrib "%s" +r', sprintf('%s*.csv', masterLogPathName)));

logUpdate2 = 0 ;
%this is the log for this program.  Tracks what messages we've process and whether logged and printed.
if length(new_trayItem)
  writeProcessLog(0, new_trayItem, '', processLog, mfilename);
end
writeProcLogIfIncomplete(processLog, pathDirs, mfilename);
if err
  if ~length(errMsg)
    errMsg =  sprintf('%s: undescribed error after return from local "processMessages"', modName) ;
    return
  end
end
%this is one of the two methods of creating the Packet Log copies.
%  This one is active & actually copies the master file to all locations
%  iff the packet log monitoring program is not active and monitoring
%  this log (as indicated by 'PkLgMonitor<time>_on.txt')
%  The alternative method is deactivated & in the location function "processMessages"

%if operator wants copies (if not, skip this code for speed)
if length(logPaths)
  % if the Log has been updated and if the Log was not just created
  if (logUpdated | logUpdate2) & logExisted
    logUpdated = 1 ;
    %determine if displayCounts is running & monitoring the current log
    a = dir(strcat(PathConfig, 'PkLgMonitor*_on.txt')) ;
    for itemp = 1:length(a)
      fid = fopen(strcat(PathConfig, a(itemp).name),'r');
      if (fid > 0)
        fprintf('\r\nFound "%s"...', a(itemp).name);
        [var, foundFlg] = findNextract('monitoredLog', 0, 0, fid);
        fclose(fid);
        if foundFlg
          %clear the flag if displayCounts IS monitoring this log & set it if not
          logUpdated = ~strcmp(var, strcat(masterLogPathName,'.csv'));
          if ~logUpdated
            %'this' monitor is local & will be supporting the Log copying from the
            break
          end
        end
      end % if (fid > 0)
    end %for itemp = 1:length(a)
    if logUpdated
      fprintf('\r\nUpdating %i Packet Log copies.', length(logPaths));
    else
      fprintf('\r\nPacket Log monitor is running & will be used to update %i Packet Log copies.', length(logPaths));
    end % if (logUpdated | logUpdate2) & length(logPaths)
    if logUpdated
      %copy to the locations of all the copies
      [err, errMsg] = updateLogCopies(logPaths, masterlogPath, packetLogName, workingDir) ;
    end % if (logUpdated)
  end % if (logUpdated | logUpdate2)
end % if length(logPaths)

%write files so the Outpost Script can report results
% 1) determine the version
[codeVersion, reply] = about_processOutpostPacketMessa;
codeVersion = 1.0 ;
% 2) create a core name for all the files. A different suffix will be added for each file
coreName = sprintf('%s%s_', workingDir, mfilename);
% 3) write the files
codeVersion = num2str(digRound(codeVersion, 12));
writeTxtMsgFile(coreName, 'version', sprintf('Version %s of %s', codeVersion, reply) );
writeTxtMsgFile(coreName, 'err', sprintf('%i', err) );
writeTxtMsgFile(coreName, 'errMsg', errMsg);
writeTxtLstMsgFile(coreName, 'Printed', trayList);
% ^^^^ done write files for Outpost Script ^^^^
fid = fopen(prgmIsRunningPathName, 'r');
if (fid > 0)
  fclose(fid);
  delete (prgmIsRunningPathName);
end
if nargout < 1
  %since no arguments are asked for, null 'em
  clear err
  clear errMsg
end
%%-----------end of main --------
%%-------------------------------
%%-------------------------------
%%-------------------------------
%%-------------------------------
function [thisTrayList, new_trayItem, err, errMsg, logUpdated] = processMessages(fileList, pathFiles, trayList, receivedFlag, ...
  pathDirs, outpostNmNValues, packetLogName, incidentName, printer, logPaths, masterLogPathName, processLog)
%INPUT
%  fileList: list of the files in the directory.
%  pathToFile: path to the files (the directory)
%  trayList: from readProcess log; these are the files of this type (sent/received) that have been processed
%  receivedFlag: type of messages being processed received (1), sent (0), when messages are processed by this
%     module two things are affected by this flag:
%       1) the appropriate log is updated along with the composite log. (_Recvd.csv, verus _Sent.csv)
%       2) when printing the recipient names for the copies vary for received versus sent messages.
%OUTPUT
%  addsTrayList: list of messages determined to be new OR messages that are old
%      but just now printed.  This means a given message could end up in the processLog
%      if the message is not printed initially but is printed later: the first entry is when
%      it was first detected & logging into the Packet Log while the second entry will be the printing
%      information.
%  logUpdated: set if any messages needed to be added to the log.  This is used by the caller to
%      invoke creating/updating any requested copies of the log.
%OPERATION:
%  

global debug

modName = strcat('>',mfilename);
err = 0;
errMsg = '';
logUpdated = 0;

%these are the PACForms files we know how to process.  We use this list to
%determine which processing module to call once we have detected the message
%is a PACForm type.  Currently only an 'EOC MESSAGE FORM' (a.k.a. IC-213) can
%be printed from its module. All in the list can be processed for information
%desired to be placed in the Packet Log.  Should a PACForm be detected that is
%not on this list, the program will report it as "unknown"
% ****** WARNING: DO NOT CHANGE THE ORDER OF THIS LIST because the switchyard  **********
% ****** is based on this order. 

new_trayItem = {};
msg = '';
msgRecv = msg;
msgSent = msg;
thisTrayList = {};

%compare the latest dir of files with the stored list to see if any are new
for filesNdx = 1:length(fileList)

  thisName = char(fileList(filesNdx).name);
  %overwrite any previous file
  write_pOPM_Status(pathDirs, thisName, 'w');
  receivedFlag = findstrchr('R', thisName(1:1) );  
  pathToFile = char(pathFiles(receivedFlag+1) );
  if debug
    fprintf('\r\n"%s"', thisName);
  end
  [form, printed] = clearFormInfo;
  % if any message files have been logged before now . . .
  if length(trayList)
    printMsg = 0; % 0 if printing has been done; 1 if printing needs to be performed
    % logMsg: cleared if Packet Log already has this message; set to 1 or 2 if Packet Log does not have this message
    % Determine if this file has been logged
    %  logMsg = 0 & printMsg = 0: in processLog & printed; means has been processed for the Packet Log and printed.
    %  logMsg = 0 & printMsg = 1: in processLog but not printed; means has only been processed for the Packet Log.
    %  logMsg = 1 & (printMsg = 1): not processLog: needs to be in optionally printed and placed in Packet Log
    %  logMsg = 2 & (printMsg = 1): in processLog but file has a newer date: updated message with the same name; needs 
    %          to be in optionally printed and placed in Packet Log.
    %  %%% new = 2: in log & printed; means has been processed for the Packet Log and printed.
    % Limitation: presummes packet log always successfully written.
    
    %set logMsg if not in processLog: search slightly different depending on length
    if (length(trayList) > 1)
      logMsg = ~any(ismember({trayList.name}, thisName));
    else % if length(trayList) > 1
      logMsg = ~strcmp(trayList.name, thisName);
    end %if length(trayList) > 1 else
    if ~logMsg
      %if in log, compare file date & logged date
      if length(trayList) > 1
        Ndx = find(ismember({trayList.name}, thisName));
        % take the last one: if the same message name has been printed
        %more than once we will have logged it more than once since we want
        %a record of all printing, not just the most recent.
        % However, we only want to compare the date of the most recent printing.
        Ndx = Ndx(length(Ndx));
      else
        Ndx =  1;
      end
      % set logMsg to '2' to indicate this is an update -> same name in log but file's date indicates new
      logMsg = ~strcmp(trayList(Ndx).date, char(fileList(filesNdx).date)) * 2;
      if ~logMsg
        %not a new message nor an updated message: only need to determine if printing is needed
        %set printMsg if not printed which is indicated by an empty .prtDate
        % *********** be sure the following will work with what writeProcLogIfIncomplete writes
        % *********** what that writes we want this code to set printMsg = 0
        printMsg = (length(trayList(Ndx).prtDate) < 1) * printer.printEnable;
        if debug
          if (length(trayList(Ndx).prtDate) < 1)
            fprintf(' Message needs to be printed');
            if printer.printEnable
              fprintf(' and printing is enabled. ');
            else
              fprintf(' but printing is disabled. ');
            end
          end
        end % if debug
      end % if ~logMsg
    else % if ~logMsg 
      %not in log
      printMsg = printer.printEnable ;
    end % if ~logMsg else
  else % if length(trayList)
    logMsg = 1;
    printMsg = printer.printEnable ;
  end % if length(trayList) else
  %
  if debug
    if logMsg
      fprintf('Message needs to be logged. ');
    else
      fprintf('Message has been logged. ');
    end
  end % if debug
  
  if logMsg | printMsg
    %     if findstrchr('R_110522_143144_MLP123P_U~P_LogReq_Milpitas', thisName)
    %       fprintf('\nlsJLASDJKL');  %       printerSetup.printEnable = 0;
    %     end
    [err, errMsg, outpostHdg, printed, form, printerSetup] ...
      = processMessage(pathToFile, thisName, char(fileList(filesNdx).postDateTime), outpostNmNValues, printer, receivedFlag, 1);
    if findstrchr('R_110515_125000', thisName)
      return
    end
    if err
      if printerSetup.printEnable
        a = strcat(pathToFile, thisName);
        if ~length(dir(a))
          [pathstr,name,ext,versn] = fileparts(a);
          a = sprintf('%s%s.mss', endWithBackSlash(pathstr), name);
        end
        [err, errMsg, h_field, formField, printed] = viewToPrintPACF(pathDirs, a, printed, outpostHdg);
      end % if printerSetup.printEnable
    end % if err
    new_trayItem = addTrayItem(new_trayItem, err, thisName, char(fileList(filesNdx).date), printed);
    if ~length(thisTrayList)
      thisTrayList = new_trayItem(length(new_trayItem));
    else
      thisTrayList(length(thisTrayList)+1) = new_trayItem(length(new_trayItem));
    end
    % if write worked...
    if (0 < writeProcessLog(0, new_trayItem, '', processLog, mfilename))
      % clear the list
      new_trayItem = {};
      % indicate that this message has been logged - if this message crashes the code, this
      %   message will not be tried again because it is logged in the process log
      % If this is NOT found in the status file, the routine "writeProcLogIfIncomplete" will catch that
      %  'cause we call it in the try/catch where this sub is called.
      write_pOPM_Status(pathDirs, 'logged - writeProcessLog OK', 'a');
    end 
    if ~err
      if logMsg
        masterlogPath = outpostValByName('DirLogs', outpostNmNValues);
        %  This copy method maintains each copy separately, adding lines as needed.  While
        %this may be the fastest method, each copy will have a unique time stamp & this
        %may cause confusion for the normal user. Additionally there is a bit of complexity
        %in updating a copy on a drive/path that was removed & re-installed.
        if 0 %incremental copy update method
          logPaths = [{masterlogPath} logPaths];
          %if user has specified locations for copies of the log, let's note the date-time of the master
          if (length(logPaths) > 1)
            masterLogPathName = sprintf('%s%s', masterlogPath, packetLogName);
            a = dir(strcat(masterLogPathName,'.csv'));
            if length(a)
              masterLogDateTime = a(1).date;
            else % if length(a)
              masterLogDateTime = '';
            end % if length(a) else
          end % if (length(logPaths) > 1)
          % create the combined log
          for logNdx = 1:length(logPaths)
            logPath =  char(logPaths(logNdx));
            % if we're not processing the master log & that master exists, 
            %      make sure the log we're about to process is not old
            if (logNdx > 1) 
              % check if the path exists:
              b = dir(logPath);
              if ~length(b)
                pathOK = 0;
              else
                pathOK = 1;
              end
              updateCopy = 1;
              if pathOK & (length(masterLogDateTime))
                copyPathName = sprintf('%s%s', logPath, packetLogName);
                %determine the date of the copy
                a = dir(strcat(copyPathName,'.csv')) ;
                %if file doesn't exist...
                if ~length(a)
                  a(1).date = 0;
                end % if length(a)
                if (datenum(a(1).date) < datenum(masterLogDateTime))
                  %the copy is older than the pre-updated master: 
                  %Because we're copy the master log now, it will be up-to-date so
                  % the copy will not need an update:
                  updateCopy = 0;
                  % Several actions required.  To avoid opening a DOS box more than
                  %once, we'll write a batch file containing all the actions
                  batchName = sprintf('%supdateLogCopy.bat', masterlogPath);
                  fidB = fopen(batchName, 'w');
                  if (fidB > 0)
                    fprintf(fidB,'@echo off\r\n');
                    fprintf(fidB,'rem  Temporary file written and used by %s.  Should be automatically deleted after use.\r\n', mfilename);
                    %release the read-only on the copy
                    fprintf(fidB,'attrib "%s*.csv" -r\r\n', copyPathName);                          
                    %copy the masters to the copies
                    fprintf(fidB,'copy "%s.csv" "%s.csv"\r\n', masterLogPathName, copyPathName);                          
                    fprintf(fidB,'copy "%s_Recvd.csv" "%s_Recvd.csv"\r\n', masterLogPathName, copyPathName);                          
                    fprintf(fidB,'copy "%s_Sent.csv" "%s_Sent.csv"\r\n', masterLogPathName, copyPathName);                          
                    %re-invoke the read-only
                    fprintf(fidB,'attrib "%s*.csv" +r\r\n', copyPathName); 
                    %done creating the batch file
                    fcloseIfOpen(fidB);
                    %call the batch file
                    dos(sprintf('"%s"', batchName));
                    %erase the batch file
                    delete(batchName);
                  end % if (fidB > 0)
                end %if datenum(a.date) < datenum(masterLogDateTime)
              end % if pathOK & (length(masterLogDateTime))
              %if the path doesn't exist or if we've just performed the copying, disable the updating.
              if ~pathOK | ~updateCopy
                logPath = '';
              end
            end % if (logNdx > 1)
          end %for logNdx = 1:length(logPaths)
        else % if 0 %incremental copy update method
          %only update the master log.  We'll incrementally update it & after
          % return from this local function we will fully copy the master log files to each copy location.
          logPath = masterlogPath;
        end % if 0 else %incremental copy update method
        if length(logPath)
          logUpdated = 1 ;
          %make sure the Packet Log monitor program isn't updating any copy of the Log - copying can momentarily prevent
          % updating the log.  Although the monitor program will not start copying if this program is running but because
          % copying especially across a network can take time to establish & perform, the copying may have started before
          % this program started.  Note the monitor program normally performs copying after this program has performed
          % an update but it can also start a copy anytime a specified location for a copy becomes accessible after not being
          % accessible.  This second case is the most likely to trigger the delay loop below
          a = dir(strcat(logPath, 'PkLgMonitor*_copy*.txt'));
          if length(a)
            fprintf('\nWaiting to update Packet Log until Copying by the Packet Log monitor program(s) is completed. ');
            fprintf('\n(i.e.: waiting for the deletion of the file "%s".)', strcat(logPath, 'PkLgMonitor*_copy*.txt'));
            while length(a)
              noWait = 1 ; %wait is not needed
              %look inside all 'PkLgMonitor*_copy*.txt' files to see
              % if any are working on THIS log set.  If none, don't wait; if any, wait.
              for itemp = 1:length(a)
                %if the monitor program crashed, the file may be left...
                %  Check the file's age: if older than 15 minutes, assume dead
                % serial date number has day as number & time as fraction of day
                %   15 minutes ir 1/4 hour & 24 hours in day: 15/60 * 1/24 ~= 0.0104
                if ((now-datenum(a(itemp).date)) < 0.0104)
                  fid = fopen(strcat(logPath, a(itemp).name),'r');
                  if (fid > 0)
                    [var, foundFlg] = findNextract('monitoredLog', 0, 0, fid);
                    fclose(fid);
                    if strcmp(var, strcat(masterLogPathName,'.csv'))
                      noWait = 0; %copying THIS log - wait is needed
                    end % if strcmp(var, strcat(masterLogPathName,'.csv'))
                  end % if (fid > 0)
                else % if ((now-datenum(a(1).date)) < 0.0104)
                  fprintf('\nFile #%i (%s) is old - ignored due to age > 15 minutes.', itemp, a(itemp).name);
                end % if ((now-datenum(a(1).date)) < 0.0104) else
              end % for itemp = 1:length(a)
              % if no Monitor was looking at this log, we're done waiting
              if noWait
                break
              end
              % update list 
              a = dir(strcat(logPath, 'PkLgMonitor*_copy*.txt'));
              pause(0.1) %wait 0.1 seconds
              fprintf(' .');
            end
            fprintf('  Copying completed.');
          end %if length(a)
          
          %extension is handled in the function we're calling because we actually write more than one file in the function.
          %    set the flag to clear the history of changes.  Because this call is not for either _Recvd nor _Sent the flag will enable the
          %  testing for changes.
          try
            [err, errMsg, msg] = writePacketLog(sprintf('%s%s', logPath, packetLogName), outpostHdg, form, incidentName, outpostNmNValues, (receivedFlag ==0), '') ;
            if err
              errMsg = sprintf('%s send/recv Log %s', errMsg);
              logErr(mfilename, err, errMsg, outpostNmNValues);
            end
            if length(msg)
              msgRecv = msg;
              msgSent = msg;
            end
            if receivedFlag
              %  NOTE: The subfunction is expected to be called last when receivedFlag is set!
              [err, errMsg] = writePacketLog(sprintf('%s%s_Recvd', logPath, packetLogName), outpostHdg, form, incidentName, outpostNmNValues, receivedFlag, msgRecv) ;
              if err
                errMsg = sprintf('%s recv Log %s', errMsg);
                logErr(mfilename, err, errMsg, outpostNmNValues);
              end
              msgRecv = '' ;
            else
              [err, errMsg] = writePacketLog(sprintf('%s%s_Sent', logPath, packetLogName), outpostHdg, form, incidentName, outpostNmNValues, 0, msgSent) ;
              if err
                errMsg = sprintf('%s sent Log %s', errMsg);
                logErr(mfilename, err, errMsg, outpostNmNValues);
              end
              msgSent = '' ;
            end
            write_pOPM_Status(pathDirs, 'complete.\r\n', 'a');
          catch
            if ~err
              err = 1000;
            end
            if length(errMsg)
              errMsg = sprintf('%s, and try/catch in %s attempting "writePacketLog" on "%s"', errMsg, mfilename, strcat(pathToFile, thisName));
            else
              errMsg = sprintf('error: try/catch in %s attempting "writePacketLog" on "%s"', mfilename, strcat(pathToFile, thisName));
            end
            logErr(mfilename, err, errMsg, outpostNmNValues);
          end %try/catch
        end %if length(logPath)
      end % if logMsg
    end % if ~err
  end % if logMsg | printMsg
end %for filesNdx = 1:length(fileList)

% -------------------------------
function [fullPath] = includeDrive(path, presentDrive);
fullPath = endWithBackSlash(path);
a = findstrchr(':', fullPath);
if (a == 2)
  return
end
a = findstrchr('\\', fullPath);
if ( a == 1 )
  return
end
fullPath = strcat(presentDrive, fullPath);
% -------------------------------
function [content] = pullAfterColon(textLine);
a = findstrchr(':', textLine);
if (a & (a(1) < length(textLine))) 
  content = textLine(a(1)+1:length(textLine));
else
  content = 0 ;
end
% -------------------------------
function writeTxtMsgFile(coreName, thisFname, thisChar);
fid = fopen(sprintf('%s%s.txt', coreName, thisFname),'w');
if fid > 0
  fprintf(fid, '%s', thisChar);
  fcloseIfOpen(fid);
end
% -------------------------------
function writeTxtLstMsgFile(coreName, thisFname, thisList);
fid = fopen(sprintf('%s%s.txt', coreName, thisFname),'w');
if fid > 0
  for itemp = 1:length(thisList)
    fprintf(fid, '%s\r\n', thisList(itemp).name);
  end
  fcloseIfOpen(fid);
end
%--------------------------------
%--------------------------------
%--------------------------------
