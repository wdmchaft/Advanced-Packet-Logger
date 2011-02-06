function [err, errMsg, shiftRepeater] = getShiftRepeater(textLine, commasAt, ShiftComma);
[err, errMsg, shiftRepeater] = extractTextFromCSVText(textLine, commasAt, ShiftComma);
% Shift Frequency shift: Simplex, Minus, Plus or Split

if ~findstrchr(shiftRepeater,'SimplexMinusPlusSplit')
  shiftRepeater = '';
end