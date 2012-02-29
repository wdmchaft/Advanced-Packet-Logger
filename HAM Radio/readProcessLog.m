function [trayList, inTrayList, sentTrayList] = readProcessLog(processLog);
% function [inTrayList, sentTrayList] = readProcessLog(processLog);
%reads the named process log & extracts by InTray or SentTray the name, date, and
% printed date for each entry.
%INPUT
%  processLog: path and name of the process log
%OUTPUT:
%  inTrayList: structure containing fields, .name, .date, & .prtDate
%     for all messages that were from the InTray.  Note that .name may contain
%     repeating names!
%  sentTrayList: same as inTrayList except the source is the SentTray
% See also "readProcessLog"

trayList = {};
inTrayList = {}; %InTray, <path>,<file name>,<file date>, printDateTime
sentTrayList = {};%%OutTray, <path>,<file name>,<file date>, printDateTime

fid = fopen(processLog, 'r');
if fid > 0
  while 1
    textLine = fgetl(fid);
    [commasAt, textFieldQuotesAt, spacesAt] = findValidCommas(textLine);
    if length(textLine)
      a = length(trayList) + 1;
      [err, errMsg, trayList(a).name] = extractTextFromCSVNoQuote(textLine, commasAt, 1);
      [err, errMsg, trayList(a).date] = extractTextFromCSVNoQuote(textLine, commasAt, 2);
      [err, errMsg, trayList(a).prtDate] = extractTextFromCSVNoQuote(textLine, commasAt, 3);
      if (nargout > 1)
        if any(1 == findstrchr('InTray', textLine) )
          a = length(inTrayList) + 1;
          [err, errMsg, inTrayList(a).name] = extractTextFromCSVNoQuote(textLine, commasAt, 1);
          [err, errMsg, inTrayList(a).date] = extractTextFromCSVNoQuote(textLine, commasAt, 2);
          [err, errMsg, inTrayList(a).prtDate] = extractTextFromCSVNoQuote(textLine, commasAt, 3);
        end
      end %       if (nargout > 1)
      if (nargout > 2)
        if any(1 == findstrchr('SentTray', textLine) )
          a = length(sentTrayList) + 1;
          [err, errMsg, sentTrayList(a).name] = extractTextFromCSVNoQuote(textLine, commasAt, 1);
          [err, errMsg, sentTrayList(a).date] = extractTextFromCSVNoQuote(textLine, commasAt, 2);
          [err, errMsg, sentTrayList(a).prtDate] = extractTextFromCSVNoQuote(textLine, commasAt, 3);
        end
      end %if (nargout > 2)
    end %if length(textLine)
    if feof(fid)
      break
    end
  end % while 1
end %if fidLog
