function [outStr] = strNumAddCommas(inputData);
%takes a given input string presumed to be a number and inserts commas
%VSS revision   $Revision: 2 $
%Last checkin   $Date: 10/11/07 10:43a $
%Last modify    $Modtime: 10/10/07 6:27p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

%locate the decimal point 
if isnumeric(inputData)
  inStr = num2str(inputData);
else
  inStr = inputData;
end
  
decimalAt = findstrchr('.', inStr);
if ~decimalAt
  decimalAt = length(inStr) + 1;
end
if decimalAt < 5
  outStr = inStr;
  return
end

outStr = '';
lastPtr = length(inStr);
ptr = decimalAt - 3;
while lastPtr > 0
  if ptr > 1
    outStr = sprintf(',%s%s', inStr(ptr:lastPtr), outStr);
  else
    outStr = sprintf('%s%s', inStr(ptr:lastPtr), outStr);
  end
  lastPtr = ptr - 1;
  ptr = max(1, ptr - 3);
end
  