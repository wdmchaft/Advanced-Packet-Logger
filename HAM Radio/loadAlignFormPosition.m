function [err, errMsg, formField] = loadAlignFormPosition(pathNameMat, calPName, key) ;
%Loads the digitized field locations of the form, loads the alignment information
%  from the alignment file, and coverts the digizited locations to units normalized
%  to the alignment file's units.  If the alignment file is in columns and rows, as it
%  might be for use with a pre-printed form, the returned units are in columns and rows.
%  Similarily, if in pixels, percentage of form size, etc. the return values are in those units
%INPUTS
% pathNameMat: do not include .mat extension.  Path & file name for the digitized
%  information file.
% calPName: name of the alignment file without extension.  Typically "printerAlign_<form name>" or
%     "formAlign_<form name>"
%OUTPUT:
% formField: structure containing the location and names of every field
%     digitizedName
%     PACFormTagPrimary
%     PACFormTagSecondary
%     HorizonJust
%     VertJust
%     lftTopRhtBtm

%locally used global - i.e. with a local sub function
global Col_leftBorder LeftBorder X_range Col_fullScale Yzero Y_range Row_top Row_fullScale


if nargin < 3
  key.left = 'AlignmentBox';
  key.right = 'AlignmentBox'; 
  key.top = 'AlignmentBox';
  key.bot = 'AlignmentBox';
  %   %indices to points of interest after sorting the X data or Y data
  %   key.left_posNdx = [1 2];
  %   key.right_posNdx = [3 4];
  %   key.top_posNdx = [1 2]; %top of the box
  %   key.bot_posNdx = [3 4];
end
err = 0;
%make sure the file exists.
fid = fopen(strcat(pathNameMat,'.mat'),'r');
if fid < 1
  err = 1;
  errMsg = sprintf('>%s: unable to find the form''s digitized location information file "%s.mat".', mfilename, pathNameMat);
end
fcloseIfOpen(fid);
[pathstr,name,ext,versn] = fileparts(calPName);
if ~length(ext)
  calPName = strcat(calPName,'.txt');
end
fid = fopen(calPName,'r');
if fid < 1
  if err
    errMsg = sprintf('%s nor "%s".', errMsg, calPName);
  else
    err = 1;
    errMsg = sprintf('>%s: unable to find the form''s alignment information file "%s".', mfilename, calPName);
  end
end
if err
  formField = '';
  return
end
fcloseIfOpen(fid);
load(pathNameMat);

top_ = 0;
left_ = 0;       
right_ = 0;      
bottom_ = 0;
printerPort = '';
% % % ********************** CALIBRATION **********************  % % %
% % % *************** vvvvvv CALIBRATION vvvvvv ***************  % % %
[top_, left_, right_, bottom_, fromFile] = readFormAlignment(calPName);
% *************** ^^^^^^ CALIBRATION ^^^^^^ ***************  % % %
% ********************** CALIBRATION **********************  % % %

%get the digitized data (in pixels)
[LeftBorder, err, errMsg] = getAvgEdge(key.left, 0, groupName, xOfGroup);
[RightBorder, err, errMsg] = getAvgEdge(key.right, 1, groupName, xOfGroup);
[formTopRef, err, errMsg] = getAvgEdge(key.top, 0, groupName, yOfGroup);
[formBottomRef, err, errMsg] = getAvgEdge(key.bot, 1, groupName, yOfGroup);

%for any X: express as % l-r & then convert
% Xfraction = (Xdigitize - LeftBorder) / X_range
% Col = Col_leftBorder + Xfraction * Col_fullScale
X_range = RightBorder - LeftBorder;

Col_leftBorder = left_;
Col_fullScale = right_ - Col_leftBorder;

Yzero = formTopRef ;
Ymax = formBottomRef ;
Y_range = Ymax - Yzero;
Row_top = top_;
Row_fullScale = bottom_ - Row_top;

fid = fopen(strcat(pathNameMat,'.csv'),'r');
if (fid > 0)
else % if (fid > 0)
  %don't want operator fields for any of these - ignore them
  ignoreList = {'AlignmentBox','Scale','end'};
  %want these to be center justified
  cntrJust = {'A','MsgNo','B','C','Footer','Header'};

  %some housekeeping in case the arrays are not the same size....
  a = size(xOfGroup);
  b = size(yOfGroup);
  a = min(a(2), b(2));
  a = min(length(pointsInGroup), a);
  Ndx = 1:a ;
  groupName = groupName(Ndx);
  pointsInGroup = pointsInGroup(Ndx);
  xOfGroup = xOfGroup(:, Ndx);
  yOfGroup = yOfGroup(:, Ndx);
  
  %regardless of order in which fields were digitized, want
  % everything ordered together
  [a, Ndx] = sort(lower(groupName));
  groupName = groupName(Ndx);
  pointsInGroup = pointsInGroup(Ndx);
  xOfGroup = xOfGroup(:, Ndx);
  yOfGroup = yOfGroup(:, Ndx);
  
  fieldNdx = 0;
  for thisGrp = 1:length(groupName)
    thisName = char(groupName(thisGrp));
    if ~ismember(thisName, ignoreList)
      a = findstrchr('.', thisName);
      if a 
        thisName = thisName(1:a-1);
      end
      fieldNdx = fieldNdx + 1;
      formField(fieldNdx).digitizedName = thisName;
      %if the name includes a ":=", the name is split such the Primary Tag is everything preceeding and the
      %  secondary is everything following. 
      % ex: Method_Amateur Radio -> Primary=Method & Secondary = Amateur Radio
      %The Primary tag is the Field ID for the ASCII coded PACF & the secondary is the content of that
      %  field when the selection is to be marked:
      %   Method: [Amateur Radio] will check the box Named Method_Amateur Radio
      a = findstrchr(':=', thisName);
      if a
        % check box
        a = a(1);
        formField(fieldNdx).PACFormTagPrimary = lower(thisName(1:a-1));
        formField(fieldNdx).PACFormTagSecondary = lower(thisName(a+2:length(thisName)));
      else
        % not a check box
        formField(fieldNdx).PACFormTagPrimary = lower(thisName);
        formField(fieldNdx).PACFormTagSecondary = '';
      end
      if any(ismember(cntrJust, thisName));
        formField(fieldNdx).HorizonJust = 'Hcenter' ;
      else
        formField(fieldNdx).HorizonJust = 'Hleft' ;
      end
      formField(fieldNdx).VertJust = 'Vmiddle' ;
      %Establish the column & row positions that bound this field:
      [lftTopRhtBtm(1), lftTopRhtBtm(2), lftTopRhtBtm(3), lftTopRhtBtm(4)] = cnrvtDigtzToLocation(xOfGroup(:, thisGrp), yOfGroup(:, thisGrp), pointsInGroup(thisGrp));
      formField(fieldNdx).lftTopRhtBtm = lftTopRhtBtm;
    end % if ~ismember(thisName, ignoreList)
  end %for mfilename = 1:length(groupName)
end % if (fid > 0) else

% % confirm all fields from CrossRef file have a corresponding name in digitized list of the points
% for thisGroup = 1:length(field); 
%   %Establish the column & row positions that bound this field:
%   [lftTopRhtBtm(1), lftTopRhtBtm(2), lftTopRhtBtm(3), lftTopRhtBtm(4)] = cnrvtDigtzToLocation(xOfGroup(:, thisGroup), yOfGroup(:, thisGroup), pointsInGroup(thisGroup));
%   field(itemp).lftTopRhtBtm = lftTopRhtBtm;
% end

%----------------------------------------------------------------------
function [val, err, errMsg] = getAvgEdge(text, minMAX, groupName, coordOfGroup)
leftGrpNdx = find(ismember(groupName, text));
if ~length(leftGrpNdx)
  err = 1;
  errMsg = sprintf('>%s(getAvgEdge) unable to find passed in "%s"', text);
  val = -1;
  return
else
  err = 0;
  errMsg = '';
end

Ndx = find(coordOfGroup(:, leftGrpNdx)>0);
% if odd number of points & more than 2 points, we've got a box which means
%   the last point is a duplication of the first point (to close the box).  We
%   do not want to consider that point twice
if mod(length(Ndx),2) & length(Ndx) > 2;
  %remove the last point
  Ndx = Ndx([1:length(Ndx)-1]);
end
newNdx = [];
%need two points to define the edge
while length(newNdx) < 2
  if minMAX
    a = max(coordOfGroup(Ndx, leftGrpNdx));
  else
    a = min(coordOfGroup(Ndx, leftGrpNdx));
  end
  aa = Ndx(find(a==coordOfGroup(Ndx, leftGrpNdx)));
  %remove the indice(s) that contain the min/max
  %  from the next search
  for itemp =1:length(aa)
    Ndx = Ndx(find(Ndx ~= aa(itemp)));
  end
  newNdx = [newNdx aa'];
end
% only want two points but may have found 3 because the code closes
%   the area.
newNdx = sort(newNdx);
if length(newNdx) > 2
  newNdx = newNdx([1:2]);
end
val = 0;
for itemp = 1:length(newNdx)
  val = val + coordOfGroup(newNdx(itemp), leftGrpNdx);
end
val = val/itemp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [left, top, rght, btm] = cnrvtDigtzToLocation(xGroup, yGroup, ptsGroup)
global Col_leftBorder LeftBorder X_range Col_fullScale Yzero Y_range Row_top Row_fullScale

if ~ptsGroup
  left = 0;
  top = 0;
  rght = 0;
  btm = 0;
else %if ~ptsGroup
  Ndx = 1:min(4,ptsGroup);
  if ptsGroup == 2
    left = min(xGroup(Ndx));
    rght = max(xGroup(Ndx));
    top = min(yGroup(Ndx));
    btm = max(yGroup(Ndx));
  else
    if ptsGroup <= 5
      a = sort(xGroup(Ndx));
      left = (a(1) + a(2))/2;
      rght = (a(3) + a(4))/2;
      a = sort(yGroup(Ndx));
      top = (a(1) + a(2))/2;
      btm = (a(3) + a(4))/2;
    end
  end 
  left = Col_leftBorder + (left - LeftBorder) / X_range * Col_fullScale;
  rght = Col_leftBorder + (rght - LeftBorder) / X_range * Col_fullScale;
  top = Row_top + (top - Yzero) / Y_range * Row_fullScale;
  btm = Row_top + (btm - Yzero) / Y_range * Row_fullScale;
end %if ~ptsGroup else
%----------------------------------------------------------------------
