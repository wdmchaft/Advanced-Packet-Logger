function summScoreboard(handles, varargin);

textLine = char(varargin{1});
colsAt = findstrchr('|', textLine);
stationID = strtrim(textLine(1:colsAt(1)-1));
a = findstrchr('@', stationID);
if ~a
  a = length(stationID) + 1;
end
stationIDCore = stationID(1:a-1);
a = find(ismember(handles.tacCall, stationIDCore));
clNdx = 1;
if length(a)
  thisAlias = char(handles.tacAlias(a(1)));
  cl(clNdx) = {sprintf('%s <> %s', thisAlias, stationID)};
  clNdx = clNdx + 1;
end
%get the column heading line from the scoreboard
sc = get(handles.listboxScoreboard,'string');
cl(clNdx) = sc(1);
clNdx = clNdx + 1;
cl(clNdx) = {textLine};
clNdx = clNdx + 1;
b(1:length(textLine)) = '=';
cl(clNdx) = {b};
clNdx = clNdx + 1;
[msgList, msgCnt] = formTypeCount(stationID, handles);
a = max(msgCnt(:));
spcLen = max(2, length(sprintf('%i', a)));
spc(1:spcLen) = ' ';
b = sprintf('%sRc| %sSt|   Form type', spc(3:spcLen), spc(3:spcLen));
cl(clNdx) = {b};
for itemp = 1:length(msgList)
  a = sprintf('%i', msgCnt(itemp, 1));
  if length(a) < spcLen
    a = sprintf('%s%s', spc(length(a)+1:spcLen),a);
  end
  b = sprintf('%i', msgCnt(itemp, 2));
  if length(b) < spcLen
    b = sprintf('%s%s', spc(length(b)+1:spcLen),b);
  end
  cl(clNdx+itemp) = {sprintf('%s| %s| %s', a, b, char(msgList(itemp)))};
end
set(handles.listboxScoreboardSumm,'string', cl);
