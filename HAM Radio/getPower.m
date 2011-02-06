function [err, errMsg, power] = getPower(textLine, commasAt, thisComma);
[err, errMsg, power] = extractTextFromCSVText(textLine, commasAt, thisComma);

a = findstrchr(lower(power),'highmediumlow');
switch a
case 0
  power ='High';
case 1  % high - terminology doesn't need change
case 11 % low - terminology doesn't need change
case 5  % medium - let's pick the lower of the two mediums
  power = 'MID2'; 
otherwise
  power ='High';
end
  
%High, Medium, Low