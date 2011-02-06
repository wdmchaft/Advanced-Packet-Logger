function cleaned = cleanDateTime(origDateTime, logDate);
%Used by displayCounts
%if date is same as date embedded in Log's name, don't
%  display the date
%Time will be 24 hour with no :
%Date when displayed will be Mo/Da - no year
origDateTime = strtrim(origDateTime) ;
if (length(origDateTime) > 5)
  %form date-time may already be in 24 hour mode without the ":" so we'll insert it just for this code
  if ~findstrchr(':',origDateTime) 
    origDateTime = sprintf('%s:%s', origDateTime(1:length(origDateTime)-2), origDateTime(length(origDateTime) + [-2,0]));
  end
  origNum = datenum(origDateTime);
  if (floor(origNum) == logDate)
    %24 hour time only
    cleaned = datestr(origNum, 15);
    % 18:40:03 -> 1840
    cleaned = cleaned([1:2 4:5]) ;
  else
    % date_time = 100126_184003335
    % prettyDateTime = 01/26/10 18:40:03.3350
    [err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(origDateTime) ;
    % cleaned = 01/26 1840
    cleaned = prettyDateTime([(1:5) (9:11) (13:14)]);
  end 
else
  cleaned = origDateTime ;
end
% --------------------------------------------------------------------
