function verMeetsMin = checkOutpostVersion(currentVer, minVer)
%Supports format of repeating #. followed by space and/or letter and then a whole number <#>.<#>.<#>
% Version=2.4.0 c85
% Version=2.4.0c85
% Version=2.4.0c085
%NOTE c85 is seen the same as c085 -> the number is 85;
%  however c850 is seen as 850
%Limitations:
%  does not test accurately if the number of digit positions is different between the
%  two versions:  2.4 won't test well againstg 2.4.1 -> numeric testing exits on shorter
%   of the two terms: in this example 2.4 is tested versus 2.4

verMeetsMin = 0;
[currentVer_delimAt, currentVer_letterAt] = findPunctuation(currentVer);
[minVer_delimAt, minVer_letterAt] = findPunctuation(minVer);

stCur = 1;
stMin = 1;
for itemp = 1:min(length(currentVer_delimAt), length(minVer_delimAt))
  endCur = currentVer_delimAt(itemp)-1;
  endMin = minVer_delimAt(itemp)-1;
  switch sign(str2num(currentVer(stCur:endCur)) - str2num(minVer(stMin:endMin)))
  case 1 %current is newer
    verMeetsMin = 1;
    return
  case 0 %same
  case -1 %current is older
    return
  end
  stCur = endCur + 2;
  stMin = endMin + 2;
end

for itemp = 1:min(length(currentVer_letterAt), length(minVer_letterAt))
  if (currentVer_letterAt(itemp)) > minVer_letterAt(itemp)
    verMeetsMin = 1;
    return
  end  
end
if str2num(currentVer(currentVer_letterAt(length(currentVer_letterAt))+1:length(currentVer))) >= ...
    str2num(minVer(minVer_letterAt(length(minVer_letterAt))+1:length(minVer)))
  verMeetsMin = 1;
  return
end

%---------------------------------------------------
function [delimAt, letterAt] = findPunctuation(thisVer);
delimAt = find(ismember(thisVer, ' .'));
%                                  establish set of letters A-Z & a-z:
letterAt = find(ismember(thisVer, char([double('A'):double('Z') double('a'):double('z')])));
if letterAt(1) > delimAt(length(delimAt)) + 1;
  delimAt(length(delimAt) + 1) = letterAt(1);
end