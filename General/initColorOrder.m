function [colorOrder, colorOrderText] = initColorOrder;
%function [colorOrder] = initColorOrder
% * Extends the color order used by Matlab when it is performing
%plots of arrays and is cycling through the available colors
% * Returns the RGB values
% * Returns names for colors which allows programs to
%select color by name
%
% written by Andy Rose (aroseorama@gmail.com)

colorOrder = [
    0      0      1
    0    0.5      0
    1      0      0
    0   0.75   0.75
 0.75      0   0.75
 0.75   0.75      0
 0.25   0.25   0.25
    1      0      1
    0      1      1
  0.5    0.5    0.5
  0.5      0      0
    1   0.62   0.40 
 0.49      1   0.83];

%Some others from the Matlab "help" "3-D Visualization: Creating 3-D Graphs: Colormaps"

colorOrderText = {'blue','dark green','red','dark cyan','purple','mustard',...
 'dark gray','magenta','cyan','gray','dark red','copper','acquamarine'};
%   figure; for itemp=1:size(colorOrder, 1);p(1:10,itemp)=itemp;end;plot(p);ax=axis;ax(3)=0;ax(4)=itemp+1;axis(ax)
set(0,'DefaultAxesColorOrder',colorOrder);
%set(gca,'ColorOrder',colorOrder);
