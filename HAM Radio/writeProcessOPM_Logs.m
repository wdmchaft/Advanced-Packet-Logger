function [err, errMsg] = writeProcessOPM_Logs(logPaths, pathTo_logsINI, fileName, addCmt);
% function [err, errMsg] = writeProcessOPM_Logs(logPaths, pathTo_logsINI[, fileName[, addCmt]]);
%Writes <pathTo_logsINI>ProcessOPM_logs.ini to establish operator's preferencs
% for the locations of copies of the log.  This is a simple list
% of paths for the copies.  The file includes decriptive comments as an aid for the user.
%INPUT:
% logPaths: cell array containing the paths to the locations. 
%     if an empty array (= {}), no paths are included but the file is written
%     with all the decriptive comments as an aid for the user.
% pathTo_logsINI: typical the archive directory of Outpost
% fileName[optional]: name for the file.  If not present or null, "ProcessOPM_logs.ini"
% addCmt[optional]: if present <addCmt> is inserted as the second comment line.
%OUTPUT:
% err, errMsg
%SEE ALSO
% readProcessOPM_Logs

[err, errMsg, modName] = initErrModName(mfilename) ;

pathTo_logsINI = endWithBackSlash(pathTo_logsINI);
if (nargin < 3)
  fileName = '';
end
if (nargin < 4)
  addCmt = '';
end

[pathstr,name,ext,versn] = fileparts(pathTo_logsINI);
% if filename is empty & no name included as part of the path...
if ~length(fileName) & ~length(name)
  fileName = 'ProcessOPM_logs.ini';
end

fileName = sprintf('%s%s', pathTo_logsINI, fileName);

[err, errMsg, fidLOGS] = fOpenToWrite(fileName,'w');
if err
  errMsg = strcat(modName, errMsg);
  return
end
fprintf(fidLOGS, '%% Use this file to list paths for copies of the Packet Logs created by "processOutpostPacketMessages".\r\n');
if length(addCmt)
  fprintf(fidLOGS, '%% %s\r\n', addCmt);
end %if length(addCmt)
fprintf(fidLOGS, '%%The paths you list must exist - the program will not create them.\r\n');
fprintf(fidLOGS, '%%If a particular path isn''t found when a log is being updated, the program will skip\r\n');
fprintf(fidLOGS, '%%that path & continue.  This could occur if the path is to a removable drive and that\r\n');
fprintf(fidLOGS, '%%drive has been removed.  Note that once the drive (path) re-appears, the most up-to-date\r\n');
fprintf(fidLOGS, '%%logs will be copied to that drive when the next log update occurs, over writing any logs there.\r\n');
fprintf(fidLOGS, '%%The next log update occurs only when new messages are sent or received.\r\n');
fprintf(fidLOGS, '%% The Packet Logs are 3 types: messages sent, messages received, and all messages.\r\n');
fprintf(fidLOGS, '%% The program will maintain copies of the logs in all locations listed in this file.\r\n');
fprintf(fidLOGS, '%%The main Packet Logs are maintained in addition to the locations in this file.\r\n');
fprintf(fidLOGS, '%% Comment lines are any line that do not start with a valid path, i.e. do not start\r\n');
fprintf(fidLOGS, '%% \\\\ or <letter>:  Examples: \\\\laptop\\  C:\\   All comment lines are ignored.\r\n');
fprintf(fidLOGS, '%%The path does not need to end with a \\ but it can.\r\n');
fprintf(fidLOGS, '%%\r\n');
fprintf(fidLOGS, '%%Here are two sample lines that would be active if the "%%" were removed:\r\n');
fprintf(fidLOGS, '%%g:\\packetlog\\\r\n');
fprintf(fidLOGS, '%%\\\\networkLocation\\packetLog\r\n');
if iscell(logPaths)
  for itemp = 1:length(logPaths)
    a = char(logPaths(itemp));
    if length(a)
      fprintf(fidLOGS, '%s\r\n', a);
    end
  end % for itemp = 1:length(logPaths)
else % if iscell(logPaths)
  if length(a)
    fprintf(fidLOGS, '%s\r\n', a);
  end
end % if iscell(logPaths) else
fcloseIfOpen(fidLOGS);
      

