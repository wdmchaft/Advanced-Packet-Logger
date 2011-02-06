function [err, errMsg, step] = getStep(textLine, commasAt, thisComma);
%Appears not to be an option on the FT-8900!  So this is non-functional/never completed
%strip the "Hz" suffix
[err, errMsg, step] = extractTextFromCSVText(textLine, commasAt, thisComma);

a = findstrchr('Hz', step);
if a
  step = step(1:a-1);
end
step = str2num(step);
  