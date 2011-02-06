function [err, errMsg, figToTrack, figMagd, pathNName] = digitizeSelectImage
% get image
% draw in two windows
% zoom in with camera in one, perhaps user controls sets this manually
% activate mouse in first, unzoomed picture
% as mouse is moved in un zoomed, the zoomed picture will pan so its center is where the mouse is
%   in the unzoomed.

global initialized 
persistent imageDir %only used in this routine

err = 0;
errMsg = '';
initialized = 0;
figToTrack = -1;
figMagd = -1;
pathNName = '';

%Note: for a slide from PowerPoint, use PP Save As JPG

%list of all formats supported by "imread"
a = {'*.bmp','Windows Bitmap',...
    '*.cur','Windows Cursor resources',...
    '*.hdf','Hierarchical Data Format',...
    '*.ico','Windows Icon resources',...
    '*.jpg;*.jpeg','Joint Photographic Experts Group',...
    '*.pcx','Windows Paintbrush',...
    '*.png','Portable Network Graphics',...
    '*.tif;*.tiff','Tagged Image File Format',...
    '*.xwd','X Windows Dump' ...
  };
b = char(a(1));
for itemp = 3:2:length(a)
  b = sprintf('%s;%s', b, char(a(itemp)) );
end
fileMask = {b,sprintf('All supported image files (%s)',b)};
for itemp = 1:2:length(a)
  b = size(fileMask,1)+1 ;
  c = char(a(itemp));
  fileMask(b,1) = {sprintf('%s', c) };
  fileMask(b,2) = {sprintf('%s (%s)',char(a(itemp+1)), c) };
end

%   fileMask = {'*.bmp;*.cur;*.hdf;*.ico;*.jpg;*.jpeg;*.pcx;*.png;*.tif;*.tiff;*.xwd','MATLAB Files (*.m,*.fig,*.mat,*.mdl)';...
%               '*.m',  'M-files (*.m)'; ...
%               '*.fig','Figures (*.fig)'; ...
%               '*.mat','MAT-files (*.mat)'; ...
%               '*.mdl','Models (*.mdl)'; ...
%               '*.*',  'All Files (*.*)'} ;% (see help on "uigetfile" for examples)
try
  a= imageDir;
catch
  imageDir = '';
end
if ~length(imageDir)
  imageDir = pwd;
end
origDir = pwd;
cd(imageDir)
[fname,pname] = uigetfile(fileMask);
cd(origDir)
if isnumeric(fname);
  if fname < 1
    return
  end
end
imageDir = pname; 
pathNName = strcat(pname, fname);
if 0
  %A = imread('D:\Cpack200\HP_HOMES\Parks_and_Map\DEIR Appendix pdf pg12 Toll Mayfield.bmp');
  %A = imread('D:\Cpack200\HP_HOMES\Parks_and_Map\Planning Area Boundaries.bmp');
  % % A = imread('D:\Cpack200\HP_HOMES\Parks_and_Map\SiteDetailperDEIRpdfPg42.bmp');
  %A = imread('D:\Cpack200\HP_HOMES\060321_CC_Study_Session\MVCC 3-21-06 study sesion on Mayfield Mall Project26 copy.bmp');
  %A = imread('D:\Cpack200\HP_HOMES\Parks_and_Map\thad_park2.bmp');
  A = imread('f:\AndyMaster.jpg');
else
  A = imread(pathNName);
end
figToTrack = 1;
figMagd = 2;
figure(figToTrack)
clf
imagesc(A)
hold on
set(gca, 'DataAspectRatio',[1,1, 1])
set(gca, 'position',[0 0 1 1], 'visible','off')
set(gcf, 'color',[0 0 0]);

figure(figMagd)
clf
imagesc(A)
hold on
a = get(get(figMagd,'CurrentAxes'),'CameraPosition');
set(get(figMagd,'CurrentAxes'),'CameraViewAngleMode','manual');
set(get(figMagd,'CurrentAxes'),'CameraPosition',[a(1:2) 1.2])
