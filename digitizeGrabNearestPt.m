function digitizeGrabNearestPt

global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed
global initialized pH plotPtH
global mouseXYZ lineColor colorOrder

if totalGroups < 2
  errordlg('You have only one group/region.  This feature is only available when more than one group is present.','Grab nearest point')
else %if totalGroups < 2
  %include all groups....
  a = [1:totalGroups];
  %.. except for the current group!
  b = find(a ~= currentGroup);
  groups2check = a(b);
  d_best = 1e6;
  %distance will be to the current mouse location
  x = mouseXYZ(1,1);
  y = mouseXYZ(1,2);
  %to check if visible on magnified figure, we need the boundaries:
  % **** this doesn't work: we are not determining the region that camera sees! *****
  cF = gcf;
  figure(figsUsed(2))
  ax = axis;
  figure(cF);
  %go through all groups other than this one
  for itemp = 1:length(groups2check)
    grp = groups2check(itemp);
    %go through all points within the group being checked
    for jtemp =1:pointsInGroup(grp)
      xT = xOfGroup(jtemp, grp);
      yT = yOfGroup(jtemp, grp);
      %check if visible on magnified figure
      if (xT <= ax(2)) & (xT >= ax(1)) & (yT >= ax(3)) & (yT <= ax(4))
        %distance to another point is sqrt(xDistance^2 + yDistance^2)
        d = sqrt((xT - x)^2 + (yT - y)^2);
        if d < d_best
          d_best = d;
          x_best = xT;
          y_best = yT;
        end
      end %if (xT <= ax(2)) & (xT >= ax(1)) & (yT >= ax(3)) & (yT <= ax(4))
    end %for jtemp =1:pointsInGroup(grp)
  end%for itemp = 1:length(groups2check)
  if d_best < 1e6 %if the value changed from the initial
    %erase the existing lines to the mouse position
    digitizeEraseLinesToMouse
    %add the point
    pointsInGroup(currentGroup) = pointsInGroup(currentGroup) + 1;
    thisPoint = pointsInGroup(currentGroup);
    xOfGroup(thisPoint, currentGroup) = x_best;
    yOfGroup(thisPoint, currentGroup) = y_best;
    %update lines: draw line to new point from last point:
    for thisFig = 2:-1:1
      figure(figsUsed(thisFig))
      if thisPoint > 2
        pH(thisPoint, thisFig, currentGroup) = patch([xOfGroup(thisPoint-1, currentGroup) xOfGroup(thisPoint, currentGroup)],...
          [yOfGroup(thisPoint-1, currentGroup) yOfGroup(thisPoint, currentGroup)], [1 0 0], 'EdgeColor', lineColor);
      end
      if thisFig > 1
        plotPtH(thisPoint, thisFig, currentGroup) = plot(xOfGroup(thisPoint, currentGroup), yOfGroup(thisPoint, currentGroup), '*', 'Color', lineColor);
      end
      drawnow
    end %for fig = 2:-1:1
    %update lines: call procedure that will draw line(s) from new point to mouse
    mouseTrack;
  else %if d_best < 1e6
    errordlg('No valid points found: the desired, all ready existing point must be visible in the magnified figure.','Grab nearest point')
  end %if d_best < 1e6 else
end %if totalGroups < 2
