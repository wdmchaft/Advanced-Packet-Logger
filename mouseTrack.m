function mouseTrack%(fullFig, zoomFig)

global mouseXYZ pH plotPtH lineColor lineColorNdx colorOrder scaleFeetPerPixel h_dispPopupInfo
global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent nextTime lastMouseXYZ round_lastMouseXYZ 

ax = axis;
%turn off responding to the mouse motion until we're done processing this motion
set(gcf,'WindowButtonMotionFcn', '');

mouseXYZ = get(get(figsUsed(1),'CurrentAxes'), 'CurrentPoint');
% fprintf('\n X %.3f, Y %.3f', mouseXYZ(1,1), mouseXYZ(1,2));
% CurrentPoint                 2-by-3 matrix
% 
% Location of last button click, in axes data units. A 2-by-3 matrix containing the coordinates of two points defined by the
% location of the pointer. These two points lie on the line that is perpendicular to the plane of the screen and passes
% through the pointer. The 3-D coordinates are the points, in the axes coordinate system, where this line intersects the
% front and back surfaces of the axes volume (which is defined by the axes x, y, and z limits).
% 
% The returned matrix is of the form:
% [ Xback,  Yback,  Zback
%   Xfront, Yfront, Zfront]
%For a 2D plot, the X & Y values are the same & Z is +/-1

%only act if within the axis
if ~digitizeMouseInImage(mouseXYZ)
  set(gcf,'WindowButtonMotionFcn', 'mouseTrack');
  return
end
%if any points, draw line from last point to mouse position
if pointsInGroup(currentGroup)
  %for both figures
  thisPoint = pointsInGroup(currentGroup) + 1;
  for thisFig = 2:-1:1
    digitizeEraseLine(thisFig, thisPoint);
    pH(thisPoint, thisFig, currentGroup) = patch([xOfGroup(thisPoint-1, currentGroup) mouseXYZ(1,1)],[yOfGroup(thisPoint-1, currentGroup) mouseXYZ(1,2)], [1 0 0], 'EdgeColor', lineColor);
    if thisFig > 1
      plotPtH(thisPoint, thisFig, currentGroup) = plot(mouseXYZ(1,1), mouseXYZ(1,2), '*', 'Color', lineColor);
    end
    %if more than 1 point, draw a line from the mouse to the 1st point in gray
    if pointsInGroup(currentGroup) > 1
      digitizeEraseLine(thisFig, thisPoint+1);
      pH(thisPoint+1, thisFig, currentGroup) = patch([xOfGroup(1, currentGroup) mouseXYZ(1,1)],[yOfGroup(1, currentGroup) mouseXYZ(1,2)], [1 0 0], 'EdgeColor',0.7* [1 1 1]);
    end
    drawnow
  end %for fig = 2:-1:1
  if scaleFeetPerPixel & pointsInGroup(currentGroup)
    dispPopupInfo('text1_Callback', h_dispPopupInfo, [], guidata(h_dispPopupInfo), digitizeCalcAreaLengthText(mouseXYZ(1,1),mouseXYZ(1,2)))
  end
  figure(figsUsed(1))
else%if pointsInGroup(currentGroup) 
  figure(figsUsed(2))
  if (size(plotPtH,1) > 0) & (size(plotPtH,2) > 1) & (size(plotPtH,3) >= currentGroup)
    if plotPtH(1, 2, currentGroup)
      delete(plotPtH(1, 2, currentGroup))
      plotPtH(1, 2, currentGroup) = 0;
    end
  end
  plotPtH(1, 2, currentGroup) = plot(mouseXYZ(1,1), mouseXYZ(1,2), '*', 'Color', lineColor);
  figure(figsUsed(1))
end %if pointsInGroup(currentGroup) else
% %set(gcf,'Pointer','cross');
% %set(gcf,'Pointer','arrow'); %default

c = get(get(figsUsed(2),'CurrentAxes'),'CameraPosition');
c(1:2) = mouseXYZ(1, 1:2);
set(get(figsUsed(2),'CurrentAxes'),'CameraPosition', c, 'CameraTarget',[c(1:2),0.5]);
set(gcf,'WindowButtonMotionFcn', 'mouseTrack');

