function [err, errMsg, tone] = getCTCSSTone(textLine, commasAt, ToneComma);
%tone is returned as text
%strip the "Hz" suffix
[err, errMsg, tone] = extractTextFromCSVText(textLine, commasAt, ToneComma);

a = findstrchr('Hz', tone);
if a
  tone = tone(1:a-1);
end
tone = str2num(tone);
% if non-zero
if tone
  tone = sprintf('%.1f', tone);
else
  tone = '';
end
  