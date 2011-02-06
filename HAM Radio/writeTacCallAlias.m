function [err, errMsg] = writeTacCallAlias(pathToFile, tacAlias, tacCall);
[err, errMsg, modName] = initErrModName(mfilename);

fname = strcat(pathToFile, 'TAC Call Alias.txt');
[err, errMsg, fid] = fOpenToWrite(fname, 'w');
if (fid > 0)
  fprintf(fid,'% Tactical call signs and the long form Identification.\r\n');
  fprintf(fid,'% format:\r\n');
  fprintf(fid,'% <tacCall> <tacAlias>\r\n');
  fprintf(fid,'% Any line starting with a %%, # or any blank line is ignored.\r\n');
  [err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now) ;
  fprintf(fid,'% (This file was written by %s at %s.)\r\n', mfilename, prettyDateTime);
  for tacNdx = 1:min(length(tacAlias), length(tacCall));
    fprintf(fid,'%s %s\r\n', char(tacCall(tacNdx)), char(tacAlias(tacNdx)) );
  end
  fclose(fid);      
else
  errMsg = sprintf('%s%s', modName, errMsg);
end
