function digitzeModifyGroup(thisGroup)

% Presumed:
%  group has been closed by "digitzeCloseGroup" which only 
%    happens for a group with more than 2 points.
%  thisGroup is a valid group
% Action: reverses the closure of the group and activates the
%  mouse to add the next point.

global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed
global initialized pH plotPtH scaleDistance groupName scaleDistance scaleFeetPerPixel h_dispPopupInfo scaleOrientation scaleOrientationText
global mouseXYZ lineColor lineColorNdx colorOrder pathNName
global projectName

%erase the mouse lines
thisPoint = pointsInGroup(currentGroup);
for thisFig = 2:-1:1
  %erase line from last point to mouse
  digitizeEraseLine(thisFig, thisPoint+1);
  %erase line from mouse to first point
  digitizeEraseLine(thisFig, thisPoint+2);
end
pointsInGroup(currentGroup) = pointsInGroup(currentGroup) - 1;

currentGroup = thisGroup ;
if (pointsInGroup(currentGroup) > 2)
  %erase the line that closed the group
  thisPoint = pointsInGroup(currentGroup);
  for thisFig = 2:-1:1
    %erase line from last point to the next-to-last point
    digitizeEraseLine(thisFig, thisPoint);
  end
  %remove the memory if the last point
  xOfGroup(pointsInGroup(currentGroup), currentGroup) = 0;
  yOfGroup(pointsInGroup(currentGroup), currentGroup) = 0;
  pointsInGroup(currentGroup) = pointsInGroup(currentGroup) - 1 ;
  %connect the group to the current mouse location
end %if (pointsInGroup(currentGroup) > 1)
mouseTrack
