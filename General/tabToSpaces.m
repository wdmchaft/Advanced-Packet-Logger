function  textLine = tabToSpaces(textLine)
%replace each TAB with up to 8 spaces
tabSpace(1:8) = ' ' ;    
a = findstrchr(textLine, char(9));
%12345678
%if tab is in location 
%  , remove tab & insert n spaces
%       mod(tabPos, 8Spaces)
% 1, 8  1
% 2, 7  2
% 3, 6  3
% 4, 5  4
% 5, 4  5
% 6, 3  6
% 7, 2  7
% 8, 1  0

%go from left to right 'cause text is left justified
while (a)
  c = mod(a(1), length(tabSpace));
  if c
    b = length(tabSpace) - c + 1;
  else
    b = 1;
  end
  textLine = sprintf('%s%s%s', textLine(1:(a(1)-1)), tabSpace(1:b), textLine((a(1)+1):length(textLine)) );
  a = findstrchr(textLine, char(9));
end

%test
% for itemp = 0:20
%   textLine = '';
%   if itemp
%     textLine(1:itemp) = ' ';
%   else
%   end
%   tL(itemp+1) = {sprintf('%s%s!', textLine, char(9))};
%   textLine2 = tabToSpaces(tL{itemp+1});
%   fprintf('\n%s,%i', textLine2, itemp);
% end  

