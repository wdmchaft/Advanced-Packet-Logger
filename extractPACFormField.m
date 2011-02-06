function [fieldText, fieldID] = extractPACFormField(textLine);
%1a.: [06/20/2009]

colonAt = findstrchr(':', textLine);
leftBracesAt = findstrchr('[', textLine);
rightBracesAt = findstrchr(']', textLine);

if colonAt
  fieldID = strtrim(textLine([1:colonAt(1)-1])) ;
else
  fieldID = '';
end

if leftBracesAt
  a = leftBracesAt(1) ;
  if rightBracesAt
    b = rightBracesAt(length(rightBracesAt)) - 1 ;
    if b > a
      fieldText = strtrim(textLine([a+1:b]));
    else
      fieldText = '';
    end
  else
    if length(textLine) > a
      fieldText = strtrim(textLine([a+1:length(textLine)]));
    else
      fieldText = '';
    end
  end
else
  fieldText = '';
end
