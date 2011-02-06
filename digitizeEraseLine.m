function digitizeEraseLine(thisFig, thisPoint)
%erases line from main figure & line & marker from magnified figure
%does not remove nor affect the data points, just erases the line
%The figure is switched to "figsUsed(thisFig)"
global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed
global initialized pH plotPtH
global mouseXYZ %from cameraTrack with the form:

figure(figsUsed(thisFig))
%if we've all ready drawn a line to the mouse, erase
if (size(pH,1) >= thisPoint) & (size(pH,2) >= thisFig) & (size(pH, 3) >= currentGroup)
  if pH(thisPoint, thisFig, currentGroup)
    delete(pH(thisPoint, thisFig, currentGroup))
    pH(thisPoint, thisFig, currentGroup) = 0;
  end %if pH(thisPoint, thisFig, currentGroup)
end %if size(pH,2) >= thisFig
if thisFig > 1
  if (size(plotPtH, 2) >= thisFig) & (size(plotPtH, 1) >= thisPoint) & (size(plotPtH, 3) >= currentGroup)
    if plotPtH(thisPoint, thisFig, currentGroup)
      delete(plotPtH(thisPoint, thisFig, currentGroup))
      plotPtH(thisPoint, thisFig, currentGroup) = 0;
    end
  end
end %if thisFig > 2
