function  [err, errMsg, incidentDate] = writeIncidentName(incidentName, incidentDate, activationNumber, PathScripts);
%writeIncidentName(incidentName, PathScripts);

[err, errMsg, modName] = initErrModName(mfilename);
incidentFile = sprintf('%sincidentName.txt', PathScripts);
[err, errMsg, fid] = fOpenToWrite(incidentFile, 'w');
if (fid > 0)
  if ~length(incidentDate)
    a = dir(incidentFile);
    incidentDate = a.date;
  end
  fprintf(fid,'incidentName = %s\r\n', incidentName);
  fprintf(fid,'activationNumber = %s\r\n', activationNumber);
  fprintf(fid,'incidentDate = %s\r\n', incidentDate);
  fprintf(fid,'  Only the first few of this file are used & contains the information\r\n');
  fprintf(fid,'  about the incident that you want included in the Packet Log header.\r\n');
  fprintf(fid,'  It is best to keep this brief - it is not intended to describe the incident\r\n');
  fprintf(fid,'  but merely identify to which incident the log applies.\r\n');
  [err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now) ;
  fprintf(fid,'  (This file was written by %s at %s.)\r\n', mfilename, prettyDateTime);
  fclose(fid);
else
  errMsg = sprintf('%s%s', modName, errMsg);
end
