%make_OutpostINItoScript

%compiles 'OutpostINItoScript' by calling "makeExe_general"
%expects user in the compile popups to chose debug
%if compile successful, copies the created .exe to 'C:\Program Files\Outpost\archive\'

fileName = 'OutpostINItoScript';
[err, errMsg, targetDir] = makeExe_general({strcat(fileName,'.m')});
if err
  fprintf('Error: %i %s', err, errMsg);
else
  fromPathName = sprintf('%s%s.exe', endWithBackSlash(targetDir), fileName) ;
  [err, errMsg, presentDrive, fPath] = findOutpostINI;
  toPath = sprintf('%s%sarchive\\', presentDrive, fPath) ;
  [status,msg] = copyfile(fromPathName, toPath);
  if status 
    fprintf('\r\nCopied "%s" to "%s".', fromPathName, toPath);
  else
    fprintf('\r\nError copying "%s" to "%s".', fromPathName, toPath);
    fprintf('\r\nError message: %s.', msg);
  end
end