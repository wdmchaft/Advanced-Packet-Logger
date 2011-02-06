function [err, errMsg] = writeRecipients(filePathName, list);
[err, errMsg, fid] = fOpenToWrite(filePathName, 'w', mfilename);
if err
  errMsg = sprintf('>%s%s', mfilename, errMsg);
  return
end
for itemp = 1:length(list)
  fprintf(fid,'%s\r\n', char(list(itemp)));
end
fclose(fid);
