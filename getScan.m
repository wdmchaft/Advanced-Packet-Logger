function [err, errMsg, scan] = getScan(textLine, commasAt, thisComma);
[err, errMsg, scan] = extractTextFromCSVText(textLine, commasAt, thisComma);

a = find(ismember({'off','skip','p scan'},lower(scan)));
if a
  switch a
  case 3
    scan = 'Pref';
  otherwise
  end
else % if a
  scan = 'Off'; %don't skip -> if user didn't inhibit, we'll persume it is to be scanned
end % if a else
