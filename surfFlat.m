function [hTop] = surfFlat(x_border, y_border, height, heightColor)
%function [hTop] = surfFlat(x_border, y_border, height[, heightColor[, topImage]])
holdOn = 0;
if nargin < 4
  heightColor = height;
end
%drawn the top
%if height
  %if nargin < 4
  z_border(1:length(x_border)) = height;
  %else
  %     X = [1:size(topImage,2)];
  %     Y = [1:size(topImage,1)];
  %     IN = inpolygon(X,Y,x_border, y_border)
  %end
  if height | any(heightColor)
    hTop = patch(x_border, y_border, z_border, heightColor);
    % hTop = patch(x_border, y_border, z_border, heightColor, 'EraseMode', 'xor');
  else
    hTop = patch(x_border, y_border, z_border, 'FaceColor', [1 1 1]);
  end
  hold on
  holdOn = 1;
  %end
%draw the edges
z = 0;

for itemp = 1:length(x_border)-1
  x(1) = x_border(itemp);
  y(1) = y_border(itemp);
  x(2) = x(1);
  y(2) = y(1);
  z(1) = 0;
  z(2) = height;
  x(3) = x_border(itemp+1);
  y(3) = y_border(itemp+1);
  x(4) = x(3);
  y(4) = y(3);
  z(3) = height;
  z(4) = 0;
  patch(x, y, z, heightColor);%,'EdgeColor','none')
  if ~holdOn
    hold on
    holdOn = 1;
  end
end
