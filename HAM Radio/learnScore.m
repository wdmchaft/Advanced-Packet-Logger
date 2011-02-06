function [msgsCountStation, newestMessage] = learnScore(byCallsign, foundStation, logged, logDate, Ndx);
%used by "displayScoreboard"
thisNdx = find(ismember(byCallsign, foundStation));
if length(thisNdx)
  msgsCountStation = length(thisNdx);
  Ndx = Ndx(thisNdx);
  [a, b] = sort({logged(Ndx).outpostDTime});
  newestMessage = {cleanDateTime(char(logged(Ndx(b(length(b)))).outpostDTime), logDate)};
else
  msgsCountStation = 0;
  newestMessage = {''};
end
% ---------------------------------------
