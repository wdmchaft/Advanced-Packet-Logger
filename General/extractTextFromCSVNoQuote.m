function [err, errMsg, unquotedText] = extractTextFromCSVNoQuote(textLine, commasAt, commaToUse);
%function [err, errMsg, unquotedText] = extractTextFromCSVNoQuote(textLine, commasAt, commaToUse);
% Extracts the text from a CSV line and removes any beginning quotes and any ending quotes.
% Leading and trailing quotes are often used for Excel compatability
%  Functions used:
%    * extractTextFromCSVText to extract the field from the line
%    * local lines to detect opening and closing quotes

[err, errMsg, unquotedText] = extractTextFromCSVText(textLine, commasAt, commaToUse);
%pull the beginning and ending quotes if present 
a = findstr(unquotedText, '"');
if length(a)
  if a(1) == 1
    b = 2;
  else
    b = 1;
  end
  c = length(unquotedText);
  if a(length(a)) == c
    c = c - 1;
  end
  unquotedText = unquotedText([b:c]);
end
