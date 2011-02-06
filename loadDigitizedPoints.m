function [acreageOfGroup] = loadDigitizedPoints(fileName, figPlotFatLines)
%function loadDigitizedPoints(fileName[, figPlotFatLines])
global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed
global initialized pH plotPtH scaleDistance groupName scaleDistance scaleFeetPerPixel h_dispPopupInfo scaleOrientation scaleOrientationText
global mouseXYZ lineColor lineColorNdx colorOrder
global projectName

a = figsUsed;
% these were added as user options in later versions: preset to the pre-choice settings
%  which will be overwritten in the newer version but unaltered in the old ones.
scaleOrientation = 2; 
scaleOrientationText = 'Horizontal'; %just for the user - not critical
load(fileName)
figsUsed = a;
plotPtH = 0;
pH = 0;
if nargin < 2
  figPlotFatLines = zeros(size(figsUsed));
end
if length(figPlotFatLines) < length(figsUsed)
  figPlotFatLines(length(figsUsed)) = 0;
end
acreageOfGroup = 0;
for thisFig = 1:min(length(figsUsed), 2)
  figure(figsUsed(thisFig));
  for thisGrp = 1:totalGroups
    if pointsInGroup(thisGrp)
      [lineColor, lineStyle, colorOrder] = setColorLine(lineColorNdx(thisGrp));
      if thisFig > 1
        if figPlotFatLines(thisFig)
          plotPtH(1, thisFig, thisGrp) = plot(xOfGroup(1, thisGrp), yOfGroup(1, thisGrp), '*', 'Color', lineColor, 'LineWidth',3);
        else
          plotPtH(1, thisFig, thisGrp) = plot(xOfGroup(1, thisGrp), yOfGroup(1, thisGrp), '*', 'Color', lineColor);
        end
      end
      for pts = 2: pointsInGroup(thisGrp)
        if figPlotFatLines(thisFig)
          pH(pts, thisFig, thisGrp) = patch([xOfGroup(pts-1, thisGrp) xOfGroup(pts, thisGrp)],[yOfGroup(pts-1, thisGrp) yOfGroup(pts, thisGrp)], [1 0 0], 'EdgeColor', lineColor, 'LineWidth',3);
        else
          pH(pts, thisFig, thisGrp) = patch([xOfGroup(pts-1, thisGrp) xOfGroup(pts, thisGrp)],[yOfGroup(pts-1, thisGrp) yOfGroup(pts, thisGrp)], [1 0 0], 'EdgeColor', lineColor);
        end
        if thisFig > 1
          plotPtH(pts, thisFig, thisGrp) = plot(xOfGroup(pts, thisGrp), yOfGroup(pts, thisGrp), '*', 'Color', lineColor);
        end
      end %for pts = 2: pointsInGroup(thisGrp)
      if thisFig < 2
        [a, acreageOfGroup(thisGrp)] = digitizeCalcAreaLengthText(xOfGroup(pointsInGroup(thisGrp), thisGrp), yOfGroup(pointsInGroup(thisGrp), thisGrp), thisGrp, 1);
        fprintf('\n Charted "%s":  %s', char(groupName(thisGrp)), a );
      end
    end
  end %for thisGrp = 1:totalGroups
end %for thisFig = 1:2
digitizerOn = 1;
if scaleFeetPerPixel > 0
  h_dispPopupInfo = dispPopupInfo;
end
      
    
