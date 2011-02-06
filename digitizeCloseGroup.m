function digitizeCloseGroup

global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed
global initialized pH plotPtH lineColor groupName

if (pointsInGroup(currentGroup) > 2)
  %erase the mouse lines
  thisPoint = pointsInGroup(currentGroup);
  for thisFig = 2:-1:1
    %erase line from last point to mouse
    digitizeEraseLine(thisFig, thisPoint+1);
    %erase line from mouse to first point
    digitizeEraseLine(thisFig, thisPoint+2);
  end
  %close the polygon area of the existing group & update the line
  pointsInGroup(currentGroup) = pointsInGroup(currentGroup) + 1;
  xOfGroup(pointsInGroup(currentGroup), currentGroup) = xOfGroup(1, currentGroup);
  yOfGroup(pointsInGroup(currentGroup), currentGroup) = yOfGroup(1, currentGroup);
  for thisFig = 2:-1:1
    figure(figsUsed(thisFig))
    pH(thisPoint, thisFig, currentGroup) = patch([xOfGroup(pointsInGroup(currentGroup)+[-1:0], currentGroup)],...
      [yOfGroup(pointsInGroup(currentGroup)+[-1:0], currentGroup)], [1 0 0], 'EdgeColor', lineColor);
  end
  fprintf('\n Closed "%s" by connecting last digitized point to first:\n  %s', char(groupName(currentGroup)), ...
    digitizeCalcAreaLengthText(xOfGroup(pointsInGroup(currentGroup), currentGroup), yOfGroup(pointsInGroup(currentGroup), currentGroup)))
end %if (pointsInGroup(currentGroup) > 1)
