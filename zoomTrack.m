% get image
% draw in two windows
% zoom in with camera in one, perhaps user controls sets this manually
% activate mouse in first, unzoomed picture
% as mouse is moved in un zoomed, the zoomed picture will pan so its center is where the mouse is
%   in the unzoomed.

[err, errMgs, figToTrack, figMagd, pathNName] = digitizeSelectImage;

digitizePoints(figToTrack, figMagd, -1, pathNName);
