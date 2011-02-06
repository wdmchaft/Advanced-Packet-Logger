function displayScoreboard(handles, logged, len);
%fill in the scoreboard: for each station, number sent, received, etc.

%need sorted list for fast search - sorting places call signs that are the same
%  in contiguous groups after deleting any blanks (using local function)
[byFromCallsign, fromNdx] = sortClean({logged.from});
[byToCallsign, toNdx] = sortClean({logged.to});

%if the logged date is the same as the date of the log,
% only include the time
%1) get the log's date
% find the location of digits
c = (ismember(handles.logCoreName, '0123456789'));
% find the prefix "_"
aa = findstrchr('_', handles.logCoreName) ;
% find the first prefix that is followed contiguously by 6 digits
found = 0;
for itemp = 1:length(aa)
  if sum(c(aa(itemp)+[1:6])) == 6
    found = 1;
    break
  end
end
if found
  a = handles.logCoreName(aa(itemp)+[1:6]);
  logDate = datenum(sprintf('%s/%s/%s', a((length(a)-3):(length(a)-2)), a((length(a)-1):(length(a))),a(1:(length(a)-4))));
end
  
%build up a master list - add any From that isn't present
byAllCallsign = buildAllCall(byFromCallsign, {});
%...add any To that isn't present
byAllCallsign = buildAllCall(byToCallsign, byAllCallsign);

byAllCallsign = sort(byAllCallsign);

msgsFromStation = 0;
msgsToStation = 0;
lenNewFrom = 0 ;
lenNewTo = 0 ;
% count the messages for each station
for nextStationNdx = 1:length(byAllCallsign)
  foundStation = byAllCallsign(nextStationNdx);
  %find how many times this call sign appears in the From field
  [msgsFromStation(nextStationNdx), newestFromStation(nextStationNdx)] = learnScore(byFromCallsign, foundStation, logged, logDate, fromNdx);
  lenNewFrom = max(length(char(newestFromStation(nextStationNdx))), lenNewFrom);
  [msgsToStation(nextStationNdx), newestToStation(nextStationNdx)] = learnScore(byToCallsign, foundStation, logged, logDate, toNdx);
  lenNewTo = max(length(char(newestToStation(nextStationNdx))), lenNewTo);
end

%create the contents for the pane
spaces(1:100)= ' ';
fromLbl = 'From';
lenFromLbl = length(fromLbl);
toLbl = '  To';
lenToLbl = length(toLbl);
%                02/07 2108
fromLatestLbl = 'Recnt From';
toLatestLbl = 'Recnt To';
if (length(fromLatestLbl) > lenNewFrom)
  fromLatestLbl = 'FNew';
end
if (length(toLatestLbl) > lenNewTo)
  toLatestLbl = 'TNew';
end
lenNewFrom = max(length(fromLatestLbl), lenNewFrom);
lenNewTo = max(length(toLatestLbl), lenNewTo);

textLine = sprintf('Station %s', spaces(1:(len.from-length('Station'))) ); 
textLine = formatLine(lenFromLbl, fromLbl, textLine, spaces);
textLine = formatLine(lenToLbl, toLbl, textLine, spaces);
textLine = formatLine(lenNewFrom, fromLatestLbl, textLine, spaces);
list = {formatLine(lenNewTo, toLatestLbl, textLine, spaces)};

%list = {sprintf('Station%s %s%s%s%s', spaces(1:(len.from-length('Station'))), fromLbl, toLbl, fromLatestLbl, toLatestLbl)};
for itemp = 1:length(byAllCallsign);
  thisStation = char(byAllCallsign(itemp));
  textLine = sprintf('%s %s', thisStation, spaces(1:(len.from-length(thisStation))));
  textLine = formatLine(lenFromLbl, num2str(msgsFromStation(itemp)), textLine, spaces);
  textLine = formatLine(lenToLbl, num2str(msgsToStation(itemp)), textLine, spaces);
  textLine = formatLine(lenNewFrom, newestFromStation{itemp}, textLine, spaces);
  list(itemp+1) = {formatLine(lenNewTo, newestToStation{itemp}, textLine, spaces)};
end
val = min(length(list), max(1, get(handles.listboxScoreboard,'value')));
set(handles.listboxScoreboard,'value', val);
set(handles.listboxScoreboard,'string', list) ;

% ---------------------------------------
% ---------------------------------------
% ---------------------------------------
function [byCallsign, validNdx] = sortClean(listCallsign);
%pull any "from" empties: if any condition changed, we'll have a "from" that is empty in the beginning
[byCallsign, validNdx] = sort(listCallsign);
while ~length(char(byCallsign(1)))
  byCallsign = byCallsign(2:length(byCallsign));
  validNdx = validNdx(2:length(validNdx));
end
% ---------------------------------------
function byAllCallsign = buildAllCall(sourceList, byAllCallsign)
nextStationNdx = 1;
while length(nextStationNdx)
  nextStationNdx = nextStationNdx(1);
  foundStation = sourceList(nextStationNdx);
  if ~any(ismember(byAllCallsign, foundStation)) 
    byAllCallsign(length(byAllCallsign)+1) = foundStation ;
  end
  nextStationNdx = find(~ismember(sourceList(nextStationNdx:length(sourceList)), foundStation)) + nextStationNdx - 1  ;
end  %while length(nextStationNdx)
% ---------------------------------------
function [textLine] = formatLine(hdgLen, newText, textLine, spaces);
b = length(newText);
textLine = sprintf('%s|%s%s', textLine, spaces(1:(hdgLen-b)), newText);
% ---------------------------------------

