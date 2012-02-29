function [fieldText, fieldID, fieldIDLwr] = extractPACFormField(textLine);
%function [fieldText, fieldID, fieldIDLwr] = extractPACFormField(textLine);
% Where textLine == <fieldID>:[<fieldText>]
%Extracts the field ID, which is everything preceding the colon, and the field contents/text
%  which is the information between the left brace and right brace.
%This routine should be called after "readPACFLine", a routine that
%  will locate the close ] even if multiple lines are invovled.
%OUTPUT:
% "fieldID": leading and trailing spaces removed.
%   if a colon is not located, fieldID will be empty.  This is an unexpected condition &
%   means a valid PACFORM field was not passed in.
% "fieldText": leading and trailing braces removed; unaltered otherwise: if
%      input spanned several lines so will the output, capitalization unchanged.
%      If no right brace is present, will contain everything after the left brace.
%      blank if any of the following
%        empty field such as 1a.: []
%        no left brace
%        no right brace and nothing after the left brace
% "fieldIDLwr": fieldID in lower case 
%
%1a.: [06/20/2009]

colonAt = findstrchr(':', textLine);
leftBracesAt = findstrchr('[', textLine);
rightBracesAt = findstrchr(']', textLine);

if colonAt
  fieldID = strtrim(textLine([1:colonAt(1)-1])) ;
else
  fieldID = '';
end
fieldIDLwr = lower(fieldID);

if leftBracesAt
  a = leftBracesAt(1) ;
  if rightBracesAt
    b = rightBracesAt(length(rightBracesAt)) - 1 ;
    if b > a
      fieldText = strtrim(textLine([a+1:b]));
    else
      fieldText = '';
    end
  else % if rightBracesAt
    if length(textLine) > a
      fieldText = strtrim(textLine([a+1:length(textLine)]));
    else
      fieldText = '';
    end
  end  % if rightBracesAt else
else %if leftBracesAt
  fieldText = '';
end % if leftBracesAt else
