function [text] = endWithBackSlash(text, skipIfNull)
%function [text] = endWithBackSlash(text[, skipIfNull])
%function [text] = endWithBackSlash(text)
%Adds a ending '\' if not present all ready ..
%  unless empty string! in which case the skipIfNull can disable.
%VSS revision   $Revision: 2 $
%Last checkin   $Date: 1/24/03 5:57p $
%Last modify    $Modtime: 1/23/03 7:35p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

if nargin < 2
  skipIfNull = 0;
end
if length(text)
  if (text(length(text)) ~= '\') 
    text = strcat(text, '\');
  end
else
  if skipIfNull <1
    text = '\';
  end
end
