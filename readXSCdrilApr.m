function readXSCdrilApr
fidIn = fopen('\\AROSE_H\f\Program Files\Outpost XSC Apr 2010 drill\drill_100417\packetCommLog_100417_xref.csv','r');
if fidIn < 0
  fidIn = fopen('c:\temp\packetCommLog_100417_xref.csv','r');
end

textLine = lower(fgetl(fidIn));
entryNdx = 0;
while ~findstrchr('logan', textLine)
  textLine = lower(fgetl(fidIn));
  if feof(fidIn)
    fprintf('\nERROR: end of file #1')
    return
  end
end
commasAt = findstrchr(',', textLine);
b = findstrchr('logan', textLine);
for itemp = 1:length(b)
  a = find(commasAt < b(itemp));
  loganAt(itemp) = a(length(a));
end
inOutLogAt = find(commasAt == findstrchr(',in/out log', textLine));

bbsTimeAt = find(commasAt == findstrchr(',bbs', textLine));

outpostTimeAt = find(commasAt == findstrchr(',outpost', textLine));

formTimeAt = find(commasAt == findstrchr(',form', textLine));
localIDAt = find(commasAt == findstrchr(',manual', textLine));

textLine = lower(fgetl(fidIn));
commasAt = findstrchr(',', textLine);
fromAt = find(commasAt == findstrchr(',from,', textLine));
toAt = find(commasAt == findstrchr(',to,', textLine));
subjectAt = find(commasAt == findstrchr(',subject', textLine));

while ~findstrchr('===================================', textLine)
  textLine = lower(fgetl(fidIn));
  if feof(fidIn)
    fprintf('\nERROR: end of file #2')
    return
  end
end
while ~entryNdx
  [textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fidIn);
  [err, errMsg, unquotedText] = extractTextFromCSVNoQuote(textLine, commasAt, loganAt(1));
  if length(unquotedText)
    entryNdx = 1;
    from = {''};
  end
  if feof(fidIn)
    fprintf('\nERROR: end of file #3')
    return
  end
end
while 1 
  [logan(entryNdx), loganTxt(entryNdx)] = extractTime(textLine, commasAt, loganAt(1));
  [loganAdvise(entryNdx), loganAdviseTxt(entryNdx)] = extractTime(textLine, commasAt, loganAt(2));
  [inOutLog(entryNdx), inOutLogTxt(entryNdx)] = extractTime(textLine, commasAt, inOutLogAt);
  [bbsTime(entryNdx), bbsTimeTxt(entryNdx)] = extractTime(textLine, commasAt, bbsTimeAt);
  [outpostTime(entryNdx), outpostTimeTxt(entryNdx)] = extractTime(textLine, commasAt, outpostTimeAt);
  [formTime(entryNdx), formTimeTxt(entryNdx)] = extractTime(textLine, commasAt, formTimeAt);
  
  [err, errMsg, unquotedText] = extractTextFromCSVNoQuote(textLine, commasAt, fromAt);
  from(entryNdx) = {unquotedText};
  [err, errMsg, unquotedText] = extractTextFromCSVNoQuote(textLine, commasAt, toAt);
  to(entryNdx) = {unquotedText};

  [err, errMsg, unquotedText] = extractTextFromCSVNoQuote(textLine, commasAt, localIDAt);
  localID(entryNdx) = {unquotedText};
  [err, errMsg, unquotedText] = extractTextFromCSVNoQuote(textLine, commasAt, subjectAt);
  subject(entryNdx) = {unquotedText};

  if ~length(char(from(entryNdx)))
    break
  end
  [textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fidIn);
  entryNdx = entryNdx + 1;
end %while entryNdx < 2 | length(char(from(entryNdx)))
fcloseIfOpen(fidIn);

fontSize = 14 ;

fig = 1;
figure(fig)
clf
a = find(formTime>0);
b = 0;
b(length(formTime)) = 0;
b(a) = bbsTime(a);
fmt = b -formTime;
plot([1:length(formTime)], fmt)
grid on
hold on
validNdx = find(fmt>0 & fmt<61);
plot(validNdx, fmt(validNdx),'*')
meanFmt = mean(fmt(validNdx));
ax = axis;
plot([ax(1) ax(2)], meanFmt*[1 1],'r')
a = sprintf('Time to Format and Send Message (mean of those less than 61 minutes = %i minutes )', round(meanFmt));
title(a, 'FontSize', fontSize)
ylabel('Minutes', 'FontSize', fontSize)

fig = fig + 1;
figure(fig)
retrieve = outpostTime - bbsTime;
validNdx = find(retrieve>0);
validRetrieve = retrieve(validNdx);
plot([1:length(formTime)], retrieve)
grid on
meanRtr = mean(validRetrieve);
a = sprintf('Time to Retrieve Message from BBS (mean = %i minutes)', round(meanRtr));
title(a)
hold on
plot(validNdx, retrieve(validNdx),'*')
ax = axis;
plot([ax(1) ax(2)], meanRtr*[1 1],'r')
ylabel('Minutes')

fig = fig + 1;
figure(fig)
clf
[n,xout] = hist(validRetrieve, max(validRetrieve)+1)
dX = (xout(2)-xout(1))/2;
bar(xout + dX, n)
xlabel('Time in Minutes');
ylabel('Number of Messages');
a = sprintf('Message Wait Time on BBS(mean = %i minutes, median = %.1f)', round(meanRtr), median(retrieve(find(retrieve>0))));
axis([0 xout(length(xout))+dX 0 max(n)]) 
grid
hold on
plot(meanRtr *[1 1], [0 max(n)],'r')
title(a)

fig = fig + 1;
figure(fig)
clf
a = find(formTime>0);
b = 0;
b(length(formTime)) = 0;
b(a) = outpostTime(a);
formatRetrieve = b -formTime;
plot([1:length(formTime)], formatRetrieve)
grid on
validNdx = find(formatRetrieve>0 & fmt<61);
meanFmtRtr = mean(formatRetrieve(validNdx));
a = sprintf('Time from Message Format until Retrieved (mean of those less than 61 minutes = %i minutes)', round(meanFmtRtr));
title(a)
ylabel('Minutes')
hold on
plot(validNdx, formatRetrieve(validNdx),'*')
ax = axis;
plot([ax(1) ax(2)], meanFmtRtr*[1 1],'r')

fig = fig + 1;
figure(fig)
a = find(inOutLog>0);
b = 0;
b(length(inOutLog)) = 0;
b(a) = outpostTime(a);
retrieveOut = inOutLog - b
bar([1:length(formTime)], retrieveOut)
grid on
meanRetrOut = mean(retrieveOut(find(retrieveOut>0)));
a = sprintf('Time from Retrieve Message to Leave Radio Room (mean = %i minutes)', round(meanRetrOut));
title(a)
ylabel('Minutes')
c = find(retrieveOut <0);
for itemp = 1:length(c)
  fprintf('\n In/Out %s, BBS %s, Outpost %s, %s, %s', char(inOutLogTxt(c(itemp))) , char(bbsTimeTxt(c(itemp))) , char(outpostTimeTxt(c(itemp))) , char(localID(c(itemp))) , char(subject(c(itemp))) )
end

fprintf('\nasdkjashdk');


function [timeVal, timeText] = extractTime(textLine, commasAt, commaToUse)
[err, errMsg, unquotedText] = extractTextFromCSVNoQuote(textLine, commasAt, commaToUse);
if length(unquotedText) < 3
  timeVal = 0;
  timeText = {''};
else
  a = findstrchr(':',unquotedText);
  if a
    hr = str2num(unquotedText(a-2:a-1));
    mn = str2num(unquotedText(a+1:length(unquotedText)));
  else
    a = length(unquotedText) - 1;
    hr = str2num(unquotedText(max(1, a-2):a-1));
    mn = str2num(unquotedText(a:length(unquotedText)));
  end
  timeVal = 60*hr + mn;
  m = num2str(mn);
  if length(m) < 2
    m = strcat('0', m);
  end
  timeText = {sprintf('%i:%s', hr, m)};
end