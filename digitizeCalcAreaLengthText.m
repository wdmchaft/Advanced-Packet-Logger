function [textString, acreage] =  digitizeCalcAreaLengthText(xNow, yNow, thisGrp, verbose);
%function [textString, acreage] =  digitizeCalcAreaLengthText(xNow, yNow[, thisGrp[, verbose]);
% If "thisGrp" isn't passed in, defaults to the global "currentGroup"
global mouseXYZ pH plotPtH lineColor lineColorNdx colorOrder scaleFeetPerPixel h_dispPopupInfo
global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed

if nargin < 3
  thisGrp = currentGroup;
end
if nargin < 4
  verbose = 0;
end
xSum = sum(xOfGroup(2:pointsInGroup(thisGrp), thisGrp)) + xNow - xOfGroup(1, thisGrp);
ySum = sum(yOfGroup(2:pointsInGroup(thisGrp), thisGrp)) + yNow - yOfGroup(1, thisGrp);
lngth = 0;
for itemp = 2:pointsInGroup(thisGrp)
  lngth = lngth + sqrt((xOfGroup(itemp, thisGrp) - xOfGroup(itemp-1, thisGrp))^2 + ...
    (yOfGroup(itemp, thisGrp) - yOfGroup(itemp-1, thisGrp))^2);
end
lngth = lngth + sqrt((xNow - xOfGroup(pointsInGroup(thisGrp), thisGrp))^2 + ...
  (yNow - yOfGroup(pointsInGroup(thisGrp), thisGrp))^2);
%a = sprintf('X:%.1f, Y:%.1f, Both:%.1f', xSum*scaleFeetPerPixel, ySum*scaleFeetPerPixel, lngth*scaleFeetPerPixel);
x = xOfGroup(1:pointsInGroup(thisGrp), thisGrp);
x(length(x)+1) = xNow;
y = yOfGroup(1:pointsInGroup(thisGrp), thisGrp);
y(length(y)+1) = yNow;
ar = polyarea(scaleFeetPerPixel * x, scaleFeetPerPixel * y);
acreage = ar/43560;
if verbose
  if pointsInGroup(thisGrp) > 2
    textString = sprintf('Perimeter Length:%.1f ft, Enclosed area: %.0f ft^2, or %.2f a', lngth*scaleFeetPerPixel, ar, acreage);
  else
    textString = sprintf('Length:%.1f ft', lngth*scaleFeetPerPixel);
  end
else
  if pointsInGroup(thisGrp) > 2
    textString = sprintf('Length:%.1f ft,%.0f ft^2,%.2f a', lngth*scaleFeetPerPixel, ar, acreage);
  else
    textString = sprintf('Length:%.1f ft', lngth*scaleFeetPerPixel);
  end
end