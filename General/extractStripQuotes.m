function [err, errMsg, text] = extractStripQuotes(textLine, commasAt, commaToUse);
[err, errMsg, text] = extractTextFromCSVText(textLine, commasAt, commaToUse) ;
quotesAt = findstrchr('"', text);
if quotesAt(length(quotesAt)) == length(text)
  text = text(1:(length(text)-1));
end
if quotesAt(1) == 1
  text = text(2:length(text));
end
