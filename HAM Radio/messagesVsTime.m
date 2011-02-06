function messagesVsTime(msgTime, fig)
%called by "readXSCdrilApr"
% creates a histogram of number of messages received versus time for the span of time
% specified (hardcoded) below
%UPGRADE: 
% pass in name of data group; 
% add rolling average line to graph using 1 minute increments and a span of dT
% have nicer xaxis, perhaps as exact time.

startHr = 14;
endHr = 16;
%bin size in minutes
dT = 5;


nBin = (endHr-startHr)*60/dT;
%convert to minutes
st = startHr*60;
str = st;
a = 0;
for Ndx = 1:nBin
  a(Ndx) = length(msgTime(find(msgTime>=st+str & msgTime<(str+Ndx*dT))));
  st = Ndx*dT;
end
figure(fig)
clf
bar(dT*[0:length(a)-1],a)
grid
ax = axis;
axis([0 120 ax(3) ax(4)])
a = sprintf('Number of messages received between %s:00 and %s:00, %s minute window', startHr, endHr, dT);
title(a, 'FontSize', fontSize)
xlabel('Minutes', 'FontSize', fontSize)
ylabel('Number of messages', 'FontSize', fontSize)
