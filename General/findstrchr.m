function [position] = findstrchr(first, second)
%similar to "findstr" except returns zero if string isn't found
position = findstr(first, second);
if isempty(position)
  position = 0;
end