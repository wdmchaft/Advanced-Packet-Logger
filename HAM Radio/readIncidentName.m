function [incidentName, incidentDate] = readIncidentName(PathScripts);
incidentFile = sprintf('%sincidentName.txt', PathScripts);
incidentName = '';
fid = fopen(incidentFile, 'r');
if fid > 0
  incidentName = fgetl(fid) ;
  fclose(fid);
end %if fid > 0
if ~length(incidentName)
  [err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
  a = findstrchr(':', prettyDateTime);
  incidentName = sprintf('Normal Operation %s', prettyDateTime(1:(a(2)-1)) );
  writeIncidentName(incidentName, PathScripts);
end %if ~length(incidentName)
a = dir(incidentFile);
if length(a)
  incidentDate = a.date;
else
  incidentDate = 'unknown';
end
