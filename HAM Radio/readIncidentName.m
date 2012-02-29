function [incidentName, incidentDate, activationNumber] = readIncidentName(PathScripts);
incidentFile = sprintf('%sincidentName.txt', PathScripts);
incidentName = '';
incidentDate = '';
activationNumber = '' ;
fid = fopen(incidentFile, 'r');
if fid > 0
  [var, foundFlg] = findNextract('incidentName', 0, 0, fid);
  if foundFlg
    incidentName = var;
    [var, foundFlg] = findNextract('activationNumber', 0, 0, fid);
    if foundFlg
      activationNumber = var;
    end
    [var, foundFlg] = findNextract('incidentDate', 0, 0, fid);
    if foundFlg
      incidentDate = var;
    end
  else %if foundFlg <--- first foundFlg
    fseek(fid, 0, 'bof');
    incidentName = fgetl(fid) ;
  end %if foundFlg else
  fclose(fid);
end %if fid > 0
if ~length(incidentName)
  [err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
  a = findstrchr(':', prettyDateTime);
  incidentDate = prettyDateTime(1:(a(2)-1)); 
  incidentName = 'Normal Operation';
  activationNumber = '' ;
  writeIncidentName(incidentName, incidentDate, activationNumber, PathScripts);
end %if ~length(incidentName)
if ~length(incidentDate)
  a = dir(incidentFile);
  if length(a)
    incidentDate = a.date;
  else
    incidentDate = 'unknown';
  end
end % if ~length(incidentDate)