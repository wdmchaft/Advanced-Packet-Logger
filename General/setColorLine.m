function [colr, lineStyle, colorOrder] = setColorLine(thisPlot);
%function [colr, lineStyle, colorOrder] = setColorLine(thisPlot);
%Establishes the line color and line style for individually
% drawn data sets producing the same as when a multiple variable
% plot is performed.
%VSS revision   $Revision: 3 $
%Last checkin   $Date: 3/13/06 3:46p $
%Last modify    $Modtime: 3/12/06 8:58a $
%Last changed by$Author: Arose $
%  $NoKeywords: $

colorOrder = get(gca,'ColorOrder');
%   blue          0                         0                         1
%   dark green    0                       0.5                         0
%   red           1                         0                         0
%   dark cyan     0                      0.75                      0.75
%   purple     0.75                         0                      0.75
%   mustard    0.75                      0.75                         0
%   dark gray  0.25                      0.25                      0.25
%   figure; for itemp=1:size(colorOrder, 1);p(1:10,itemp)=itemp;end;plot(p);ax=axis;ax(3)=0;ax(4)=itemp+1;axis(ax)
%Some others from the Matlab "help" "3-D Visualization: Creating 3-D Graphs: Colormaps"
%   magenta       1                         0                         1
%   cyan          0                         1                         1
%   gray        0.5                       0.5                       0.5
%   dark red    0.5                         0                         0
%   copper        1                      0.62                      0.40 
%  acquamarine 0.49                         1                      0.83

lineOrder = get(gca,'LineStyleOrder');
%if startup.m doesn't have the additions to define more than one line order
if length(lineOrder) < 2
  lineOrder = {'-',':','-.','--'};
end
sizeColorOrder = size(colorOrder);
a = mod(thisPlot, sizeColorOrder(1)+1);
if ~a
  a = sizeColorOrder(1);
end
colr = colorOrder(a,:);
sz = size(lineOrder,1);
a = mod((thisPlot-1), sz(1));
if ~a
  a = sz(1);
end
lineStyle = char(lineOrder(a)) ;
