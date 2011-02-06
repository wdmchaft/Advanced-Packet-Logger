function [err, errMsg] = renameMsg(pathToFile, modName, fPathName, fPathNameOut);
% Called by addToMsgFile
fPathNameBatch = strcat(pathToFile, 'renameMsg.bat');
[err, errMsg, fidOut] = fOpenToWrite(fPathNameBatch, 'w', modName);
if (err)
  errMsg = sprintf('%s%s', modName, errMsg);
  return
end
if (nargin < 4)
  fPathNameOut = '';
end
fprintf(fidOut,'@echo off\r\n');
fprintf(fidOut,'rem Created & removed by processOutpostPacketMessages'' %s\r\n', mfilename);
fprintf(fidOut,'rem Message file has been updated & needs to be renamed\r\n');
[pathstr,name,ext,versn] = fileparts(fPathName);
if length(fPathNameOut)
  fprintf(fidOut,'del "%s"\r\n', fPathName);
  %just in case we're debugging & running this code a 2nd time & the
  %  re-named file still exists, lets zap it.
  a = sprintf('"%s%s.mss"', endWithBackSlash(pathstr), name);
  fprintf(fidOut,'if exist %s del %s\r\n', a, a);
  %now rename the new file
  fprintf(fidOut,'ren "%s" "%s.mss"\r\n', fPathNameOut, name);
else % if length(fPathNameOut)
  fprintf(fidOut,'ren "%s" "%s.mss"\r\n', fPathName, name);
end % if length(fPathNameOut) else
%done creating the batch file
fcloseIfOpen(fidOut);
%call the batch file
dos(sprintf('"%s"', fPathNameBatch));
%erase the batch file
delete(fPathNameBatch);
