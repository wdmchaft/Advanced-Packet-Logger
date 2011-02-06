function [err, errMsg, fields] = loadICS213FormPositions

global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed
global initialized pH plotPtH scaleDistance groupName scaleDistance scaleFeetPerPixel h_dispPopupInfo scaleOrientation scaleOrientationText

global Col_leftBorder LeftBorder X_range Col_fullScale Yzero Y_range Row_top Row_fullScale

load('ICS213.mat')

% inchesPerFoot = 12;
% for thisGroup = 1:totalGroups
%   fprintf('\r\n%s:  ', char(groupName(thisGroup)) )
%   for itemp = 1:size(xOfGroup, 1)
%     if ~xOfGroup(itemp, thisGroup)
%       break
%     end
%     fprintf(' %.2f" X & %.2f" Y,', inchesPerFoot * scaleFeetPerPixel* xOfGroup(itemp, thisGroup),  inchesPerFoot * scaleFeetPerPixel* yOfGroup(itemp, thisGroup));
%   end
% end
% 
% For each entry we want to be able to specify vertical and horizontal justification: left, center, right; bottom, center, top
% We'll do calculations and compare to the values that are currently hard coded

% % % ********************** CALIBRATION **********************  % % %
% % % *************** vvvvvv CALIBRATION vvvvvv ***************  % % %
%"calibration" in terms of Rows & Columns - by inspection of a printout of rows & columns onto a Form
top_fromMsgHdrBtm = 3.5;          % Row
left_fromMsgHdr = 2.5;            % Column
right_fromMsgHdr = 79.75;         % Column
bottom_fromOpratrUseBtm = 52.4;   % Row
% % % *************** ^^^^^^ CALIBRATION ^^^^^^ ***************  % % %
% % % ********************** CALIBRATION **********************  % % %

%get the digitized data (in pixels)
messageBoxNdx = find(ismember(groupName, 'MessageFormHeader_Box'));
%We digitized this as a box & not merely a diagonal
%5 points to close the box but only 4 unique
xSet = xOfGroup(1:4, messageBoxNdx);
ySet = yOfGroup(1:4, messageBoxNdx);
%left & right references
a = sort(xSet);
leftPos = (a(1) + a(2))/2;
rightPos = (a(3) + a(4))/2;
% top reference
a = sort(ySet);
%bottom of MessageForm Header box
formTopRef = (a(3) + a(4))/2; 
%bottom reference
operatorBoxNdx = find(ismember(groupName, 'OperatorUseOnly_Box'));
ySet = yOfGroup(1:4, operatorBoxNdx);
%bottom of OperatorUseOnly box
a = sort(ySet);
formBottomRef = (a(3) + a(4))/2; 


%for any X: express as % l-r & then convert
% Xfraction = (Xdigitize - LeftBorder) / X_range
% Col = Col_leftBorder + Xfraction * Col_fullScale
LeftBorder = leftPos;
RightBorder = rightPos;
X_range = RightBorder - LeftBorder;

Col_leftBorder = left_fromMsgHdr;
Col_fullScale = right_fromMsgHdr - Col_leftBorder;

Yzero = formTopRef ;
Ymax = formBottomRef ;
Y_range = Ymax - Yzero;
Row_top = top_fromMsgHdrBtm;
Row_fullScale = bottom_fromOpratrUseBtm - Row_top;

fprintf('\r\n*************************** Columns & Rows *****************************');
for thisGroup = 1:totalGroups
  fprintf('\r\n%s:  ', char(groupName(thisGroup)) );
  [left, top, rght, btm] = cnrvtDigtzToLocation(xOfGroup(:, thisGroup), yOfGroup(:, thisGroup), pointsInGroup(thisGroup));
  fprintf('Column: left %.2f, right %.2f, Row: top %.2f, bottom %.2f,', left, rght, top, btm);
end

% row

% Each field needs the following characteristics defined:
% 1) how it is identified in a PACForm message
% 2) horizontal justification
% 3) vertical justification
% 4) type of field: check box, one line or shorter text, multiple line text
% and we want the locations of each defined field's edges (below).  Eventually we'll
% convert this to locations either in column/row or if we ever get there in something finer.
% We'll provide this in inches which means it will be converted from pixels per the scale factor
% 5) top
% 6) bottom
% 7) left
% 8) right

[err, errMsg, field] = readICS213crossRef;
% confirm all fields from CrossRef file have a corresponding name in digitized list of the points
for itemp=1:length(field); 
  thisGroup = find(ismember(groupName, char(field(itemp).digitizedName)) );
  if ~any(thisGroup);
    fprintf('\r\nDidn''t find crossRef name "%s" in digitize points list.',char(field(itemp).digitizedName));
  else
    [lftTopRhtBtm(1), lftTopRhtBtm(2), lftTopRhtBtm(3), lftTopRhtBtm(4)] = cnrvtDigtzToLocation(xOfGroup(:, thisGroup), yOfGroup(:, thisGroup), pointsInGroup(thisGroup));
    field(itemp).lftTopRhtBtm = lftTopRhtBtm;
  end;
end
% confirm all names in digitized list have a corresponding name in the CrossRef file
for itemp=1:totalGroups; 
  if ~any(ismember({field.digitizedName}, char(groupName(itemp))));
    if ~findstrchr('scale',lower(char(groupName(itemp))) )
      fprintf('\r\nDidn''t find digitzied point "%s" in crossRef file',char(groupName(itemp)));
    end
  end;
end



% 1) Load files
%   a) digitized locations
%   b) calibration
%   c) xref & character justification
% 2) 
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [left, top, rght, btm] = cnrvtDigtzToLocation(xGroup, yGroup, ptsGroup)
global Col_leftBorder LeftBorder X_range Col_fullScale Yzero Y_range Row_top Row_fullScale

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
