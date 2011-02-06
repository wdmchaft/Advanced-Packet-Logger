function [inImage,mouseNowXYZ] = isMouseInAxis(mouseXYZ, xyBoundaries);
%function [inImage,mouseNowXYZ] = isMouseInAxis([mouseXYZ[, xyBoundaries]]);
%Flag, 1 or 0: 1 if within the current displayed axis boundaries or 
%  the optionally passed in boundaries; 0 otherwise
%  When the currently displayed axis boundaries are used, the effects of zooming: 
%  are included: it is the visible region.
%INPUTS:
% mouseXYZ[optional]: if not present, this module will determine where the mouse
%   is within in current figure (using the gcf function).  The values are returned.
%   When present, needs to be in the form
%     [ Xback,  Yback,  Zback
%       Xfront, Yfront, Zfront]
%    For a 2D plot, the X & Y values are the same & Z is +/-1
% xyBoundaries[optional]: if not present, the test is to the limits of the currently 
%   displayed axis.  If present, the mouse position is tested relative to the limits
%   which need to be of the form [Xmin Xmax Ymin Ymax].  NOTE: when present, no
%   test is made to determine if the limits are within the current;y displayed axis
%   limits.  To achieve that, two calls would be necessary:
%         %within visible boundaries? & within special boundaries?
%      if isMouseInAxis(mouseXYZ) & isMouseInAxis(mouseXYZ, xyBoundaries)
%          %do stuff
%      end
%VSS revision   $Revision: 2 $
%Last checkin   $Date: 3/24/06 1:09p $
%Last modify    $Modtime: 3/24/06 12:52p $
%Last changed by$Author: Arose $
%  $NoKeywords: $
if nargin < 1
  mouseNowXYZ = get(get(gcf,'CurrentAxes'), 'CurrentPoint');
else
  mouseNowXYZ = mouseXYZ;
end
%this is obscure: it seems that if you skim the edge of the figure, the "get" 
% above can end up with an empty return to "mouseXYZ"... so
if ~length(mouseNowXYZ) %if no mouse coordinates, report not in image & return
  fprintf('\n Mouse not in figure(%i): appears to have skimmed the edge. %s', gcf, mfilename);
  inImage = 0;
  %%%%%%%%%%%%
  %%%%%%%%%%%%
  return
  %%%%%%%%%%%%
  %%%%%%%%%%%%
end
if nargin < 2
  ax = axis;
else
  ax = xyBoundaries;
end
inImage = 1;
for backFRONT = 1:2
  if mouseNowXYZ(backFRONT,1) < ax(1) | mouseNowXYZ(backFRONT,1) > ax(2)
    inImage = 0;
    break
  end
  if mouseNowXYZ(backFRONT,2) < ax(3) | mouseNowXYZ(backFRONT,2) > ax(4)
    inImage = 0;
    break
  end
  %if a 3D plot, check that too!
  if length(ax) > 4
    if mouseNowXYZ(backFRONT,3) < ax(5) | mouseNowXYZ(backFRONT,3) > ax(6)
      inImage = 0;
      break
    end
  end
end %for backFRONT = 1:2
