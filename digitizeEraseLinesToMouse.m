function digitizeEraseLinesToMouse
global pointsInGroup currentGroup

thisPoint = pointsInGroup(currentGroup);
if thisPoint
  %erase the 2 lines on each fig associated with the point being deleted
  for thisFig = 2:-1:1
    %erase line from last point to mouse
    digitizeEraseLine(thisFig, thisPoint+1);
    %erase line from mouse to first point
    digitizeEraseLine(thisFig, thisPoint+2);
    %erase line to last point from point before
    digitizeEraseLine(thisFig, thisPoint);
  end %for thisFig = 2:-1:1
end
