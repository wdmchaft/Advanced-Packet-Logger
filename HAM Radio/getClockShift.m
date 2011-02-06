function [err, errMsg, clockShift] = getClockShift(textLine, commasAt, thisComma);
[err, errMsg, clockShift] = extractTextFromCSVText(textLine, commasAt, thisComma);

a = find(ismember({'off','on'},lower(clockShift)));
if ~length(a)
  clockShift = 'Off';
end % if a else
