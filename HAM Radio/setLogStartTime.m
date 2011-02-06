function startTime = setLogStartTime(startTimeOption, dateTime, PathToScripts, PathToOutpost);
switch startTimeOption
case 1 %(default) All messages from "today"
  startTime = floor(now); %fractional is time = this sets it to midnight at the start of the day
case 2 %all messages since Outpost's DirScripts\IncidentName.txt has changed.
  a = dir(strcat(PathToScripts,'IncidentName.txt'));
  if length(a)
    startTime = datenum(a.date);
  else
    startTime = floor(now); %fractional is time = this sets it to midnight at the start of the day
  end
case 3 % only those message that were transferred during this session of the script
  a = dir(strcat(PathToOutpost,'ini_DirScripts.txt'));
  startTime = datenum(a.date);
case 4 % time specified in the same file that specifies which of these options is active
  startTime = datenum(dateTime);
case 5 % no time filter - any & all messages
  startTime = 0;
otherwise
end % switch startTimeOption
