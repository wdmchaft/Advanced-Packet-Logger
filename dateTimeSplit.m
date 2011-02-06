function [err, errMsg, date, time24] = dateTimeSplit(dateTime)
% function [err, errMsg, date, time24] = dateTimeSplit(dateTime)
%Decodes two formats of date/time:
%  11/14/2009 @ 0859 ->   date: 11/14/2009, time: 0859
%  11/16/2009 07:04 PM -> date: 11/16/2009, time: 1904
%  11/16/2009 07:04 AM -> date: 11/16/2009, time: 0704
%  11/16/2009 7:04 AM  -> date: 11/16/2009, time: 704
[err, errMsg, modName] = initErrModName(mfilename) ;

at = findstrchr('@', dateTime);
if at
  % format is "[11/14/2009 @ 0859]" & is in 24 hour format
  date = strtrim(dateTime(1:at(1)-1) );
  time24 = strtrim(dateTime(at(1)+1:length(dateTime)) );
else % if at
  % [11/16/2009 07:04 PM]
  spaces = findstrchr(' ', dateTime) ;
  date = strtrim(dateTime(1:spaces(1)-1) );
  time24 = strtrim(dateTime(spaces(1)+1:spaces(2)-1) );
  colon = findstrchr(':', time24) ;
  %if PM, we need to add 24 hours
  if (findstrchr('PM', upper(dateTime)) == spaces(2)+1)
    hr = 12 + str2num(time24(1:colon(1)-1)) ;
    time24 = sprintf('%i%s', hr, time24(colon(1)+1:length(time24)) );
  else
    time24 = sprintf('%s%s', time24(1:(colon(1)-1)), time24((colon(1)+1):length(time24)));
  end % if (findstrchr('PM', dateTime) == spaces(2)+1)
end % if at else

