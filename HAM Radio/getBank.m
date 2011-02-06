function [err, errMsg, inBank] = getBank(textLine, commasAt, thisComma);
[err, errMsg, inBank] = extractTextFromCSVText(textLine, commasAt, thisComma);

a = find(ismember({'off','on'},lower(inBank)));
if ~a
  inBank = 'Off';
end % if a else
