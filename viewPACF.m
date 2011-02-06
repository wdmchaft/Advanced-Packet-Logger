function [err, errMsg] = viewPACF(DirPF, DirAddOnsPrgms, msgPathName);
%function [err, errMsg] = viewPACF(DirPF, DirAddOnsPrgms, msgPathName);
% Opens the specified text file of a PacFORM in a browser
% * copies the text file from <msgPathName> to the "dataInPath" listed
%   pac-read.ini
% * calls pac-read to reverse read the Outpost message into the proper
%   PacFORM html file.
% * Opens the browser as specified in pac-read.ini.  If none, let's the
%   system open in the default browser
% INPUTS
%   DirPF: path to PacForms' top directory (\exec, \data are in this directory)
%     used to locate \exec\pac-read.ini
%   DirAddOnsPrgms: where the batch file created & called by this routine will be located
%   msgPathName: full path & name of the text file containing the message in Outpost
%     form.
%Used by displayCounts
 
err = 0;
errMsg = '';

batchName = sprintf('%sdispPACF.bat', DirAddOnsPrgms);
[pathstr,name,ext,versn] = fileparts(msgPathName);
pathName = strcat(endWithBackSlash(pathstr), name);

% need to read the browser path from pac-read.ini
browserPathName = '';
%initialize variable
readerNPath = '' ;
dataInPath = '' ;
dataOutPath = '' ;

fid = fopen(sprintf('%sexec\\pac-read.ini', DirPF),'r');
if (fid > 1)
  [browserPathName, foundFlg] = findSpaceNextract('BROWSER', 0, 0, fid);
  [readerNPath, foundFlg] = findSpaceNextract('READER', 0, 0, fid);
  [dataInPath, foundFlg] = findSpaceNextract('DATAIN', 0, 0, fid);
  [dataOutPath, foundFlg] = findSpaceNextract('DATAOUT', 0, 0, fid);
  % findSpaceNextract
  fclose(fid);
end % if (fid > 1)
if length(readerNPath)
  readerNPath = endWithBackSlash(readerNPath);
else %if length(readerNPath)
  readerNPath = sprintf('%sexec\\', DirPF);
end % if length(readerNPath) else
if length(dataInPath)
  dataInPath = endWithBackSlash(dataInPath);
else % if length(dataInPath)
  dataInPath = sprintf('%sdata\\received\\', DirPF)
end % if length(dataInPath) else
if length(dataOutPath)
  dataOutPath = endWithBackSlash(dataOutPath);
else % if length(dataOutPath)
  dataOutPath = sprintf('%sdata\\sent\\', DirPF)
end %if length(dataOutPath) else

fid = fopen(batchName, 'w');
if (fid > 0)
  % fprintf(fid,'@echo off\r\n');
  pacfTemp = sprintf('%s%s', dataInPath, name);
  %we may have previously opened this form...
  a = dir(strcat(pacfTemp,'.*'));
  if length(a)
    % .... it may or may not have been
    % opened with the current version of pac-read or specific PacFORM
    %*** note: because pac-read is slow, a more elegant and probably faster method of processing
    %   would be if the .html is detected to decide if pac-read and the specific PacFORM are newer
    fprintf(fid,'del "%s.*"\r\n', pacfTemp);
  end
  fprintf(fid,'copy "%s" "%s%s_pacf"\r\n', msgPathName, pacfTemp, ext);
  % %     fprintf(fid,'copy "%s" "%s_pacf"\r\n', msgPathName, msgPathName);
  % %     fprintf(fid,'"%sexec\\pac-read.exe" $1 INI "%s%s_pacf"\r\n', DirPF, pacfTemp, ext);
  %pac-read doesn't properly pass a quoted path to the browser:
  %  1 of 2) tell pac-read to not open a browser - preface the file name with "$"
  fprintf(fid,'"%spac-read.exe" $1 INI $"%s%s_pacf"\r\n', readerNPath, pacfTemp, ext);
  %  2 of 2) explicitly open the browser & properly pass the path to the file
  if length(browserPathName)
    fprintf(fid,'rem Browser per "pac-read.ini"\r\n');
    fprintf(fid,'start "%s" "%s.html"\r\n', browserPathName, pacfTemp);
  else
    %use the default browser whatever it is
    fprintf(fid,'rem Browser not found in "pac-read.ini" - using default\r\n');
    fprintf(fid,'"%s.html"\r\n', pacfTemp);
  end
  % pull the "." from ext: pac-read.exe's rename creates a prefix for the extension
  % %     fprintf(fid,'del "%s.*%s_pacf"\r\n', pathName, ext(2:length(ext)));
  % %     fprintf(fid,'del "%s.html"', pathName);
  fprintf(fid,'rem not good because deletion is occuring before pacf has processed! del "%s.*%s_pacf"\r\n', pacfTemp, ext(2:length(ext)));
  fprintf(fid,'rem not good because deletion is occuring before pacf has processed! del "%s.html"', pacfTemp);
  fclose(fid);
  dos(sprintf('"%s"', batchName));
else
  err = 1;
  errMsg = sprintf('>%s: unable open "%s" view in browser "%s"', mfilename, batchName, msgPathName);
end %if fid > 0
