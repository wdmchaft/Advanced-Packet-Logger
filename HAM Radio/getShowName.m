function [err, errMsg, showName] = getShowName(textLine, commasAt, ShowComma);
[err, errMsg, showName] = extractTextFromCSVText(textLine, commasAt, ShowComma);

a = findstrchr(lower(showName),'onoff') ;
switch a
case 1
  showName = 'Name';
case 3
  showName = 'Freq';
otherwise
  showName = 'Name';
end
  function [err, errMsg, showName] = getShowName(textLine, commasAt, ShowComma);
[err, errMsg, showName] = extractTextFromCSVText(textLine, commasAt, ShowComma);
