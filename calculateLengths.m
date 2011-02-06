function thisLengthFeet = calculateLengths
%function thisLengthFeet = calculateLengths
%For the currently loaded set, calculates the lengths of each side of each group
% and displays the results in feet & feet,inches
global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed
global initialized pH plotPtH scaleDistance groupName scaleDistance scaleFeetPerPixel h_dispPopupInfo scaleOrientation scaleOrientationText
global mouseXYZ lineColor lineColorNdx colorOrder
global projectName


for thisGrp = 1:totalGroups
  fprintf('\r\n%s', char(groupName(thisGrp)) );
  for thisSide = 2:pointsInGroup(thisGrp)
    thisLengthFeet(thisSide - 1, thisGrp) = scaleFeetPerPixel * sqrt((xOfGroup(thisSide, thisGrp) - xOfGroup(thisSide-1, thisGrp))^2 + ...
      (yOfGroup(thisSide, thisGrp) - yOfGroup(thisSide-1, thisGrp))^2);
    a = thisLengthFeet(thisSide - 1, thisGrp);
    [ft, inch] = feetToFtInch(a);
    fprintf('\r   %i: %.1f feet (%.0f feet %.0f inch)', thisSide - 1, a, ft, inch);
  end %for thisSide = 2:pointsInGroup
  %if 4 sides there will be 5 points.
  if pointsInGroup(thisGrp) == 5
    %4 sides: average the sides - user may want this
    for itemp = 1:2
      avgSide = (thisLengthFeet(itemp, thisGrp) + thisLengthFeet(itemp+2, thisGrp))/2;
      [ft, inch] = feetToFtInch(avgSide);
      fprintf('\r     average of side %i & %i: %.1f feet (%.0f feet %.0f inch)', itemp, itemp + 2, avgSide, ft, inch);
    end
  end %if pointsInGroup(thisGrp) == 5
end %for thisGrp = 1:totalGroups

function [ft, inch] = feetToFtInch(feet)

ft = floor(feet);
inch = (feet - ft)*12;