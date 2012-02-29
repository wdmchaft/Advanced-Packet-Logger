function varargout = showForm(varargin)
% function [err, errMsg, figure1, h_field] = showForm_OpeningFcn(varargin{:})
% SHOWFORM Application M-file for showForm.fig
%    FIG = SHOWFORM launch showForm GUI.
%    SHOWFORM('callback_name', ...) invoke the named callback.
%Typically called from "readPrintCnfg"
% Calling variations:
%  showForm(fPathNameExt, pathAddOns, formField)
%           IDE only: pushes the returned variable to the base of the command window
%             err, errMsg, formField, h_field & includes the "handles" structure.
%  [figure1]                       = showForm(fPathNameExt, pathAddOns, formField[, figPosition])
%  [err, errMsg, h_field]          = showForm(fPathNameExt, pathAddOns, formField[, figPosition])
%  [err, errMsg, h_field, formField] = showForm(fPathNameExt, pathAddOns, formField[, figPosition])
%  [err, errMsg, h_field, formField, figPosition] = showForm(fPathNameExt, pathAddOns, formField[, figPosition])
%              h_field(length(h_field)) == figure1
%INPUTS:
%If all 3 inputs are empty strings (= ''), this function will create a form for a Simple message:
%    ie: nothing is loaded, no external files used.
%  fPathNameExt: path and name with or without extension of image file
%    if multiple page form, this will be a cell of strings with each element being
%     a page and the corresponding fields being accessed via the 2nd dimension of formField
%  pathAddOns: path to alignment file
%  pacfListNdx: form type # from list, number per List in "getPACFType"
%OUTPUTS
%  h_field: handles to all the fields on the form with the last being the 
%     figure's handle.

err = 0;
errMsg = '';
figure1 = 0 ;

if nargin == 0  % LAUNCH GUI
  [varargout{1:nargout}] = showForm_OpeningFcn;
elseif nargin < 4 % LAUNCH GUI and pass path or path\name
  try
    % [err, errMsg, h_field, formField, figPosition] = showForm_OpeningFcn(varargin{:});
    [varargout{1:nargout}] = showForm_OpeningFcn(varargin{:});
  catch
    fid = fopen('C:\ProgramData\SCCo Packet\AddOns\Programs\debug.log', 'a');
    [err_1, errMsg_1, date_time, prettyDateTime, Yr, Mo, Da] = datevec2timeStamp(now);
    fprintf('\r\nshowForm %s error: %s ', date_time, lasterr);
    if fid > 0
      %to file
      fprintf(fid, '\r\nshowForm %s error: %s ', date_time, lasterr);
      fopen(fid);
    else
      fprintf('\nunable to open debug.log');
    end
  end % try/catch
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
  err = 0;
  if findstrchr(varargin{1},'_Callback')
    try
      if (nargout)
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
      else
        feval(varargin{:}); % FEVAL switchyard
      end
    catch
      err = 1;
    end %try
    if findstrchr('Invalid function name', lasterr)
      try
        % [err, errMsg, h_field, formField, figPosition] = showForm_OpeningFcn(varargin{:});
        [varargout{1:nargout}] = showForm_OpeningFcn(varargin{:});
      catch
      end
    end
    %This "if" provides a method of passing parameters to "showForm_OpeningFcn".  It responds
    %  when the program has been called but not in response to a user activity on the GUI.
    if err
      lastErr = lasterr;
      %if the caller was trying to pass parameters, we'll get this error
      % alone.  However a coding error, example with "Ndx" causes "Undefined function or variable 'Ndx'."
      %That is a real error and we do not want to try again!
      f1 = findstr(lastErr,'Undefined function') & ~findstr(lastErr,'or variable');
      %if something, make sure not 0/false
      if ~isempty(f1)
        %if zero, reset to null so tests following operate
        if ~f1
          f1 = [];
        end
      end
      if isempty(f1)
        f1 = findstr(lastErr,'Invalid function');
      end
      if isempty(f1)
        f1 = findstr(lastErr,'Reference to unknown function') & findstr(lastErr,'in stand-alone mode');
      end
      if ~isempty(f1)
        %let's try to set the properties
        try
          %err, errMsg, h_field, formField, figPosition
          % [err, errMsg, h_field, formField, figPosition] = showForm_OpeningFcn(varargin{:}) ;
          [varargout{1:nargout}] = showForm_OpeningFcn(varargin{:}) ;
        catch
          % disp(lasterr);
          fprintf('\r\n%s while attempting showForm_OpeningFcn with %s', lasterr, varargin{1});
        end
      else % if ~isempty(f1)
        %was not the 'Undefined function' error message - report the error
        errMsg = sprintf('%s while attempting %s', lasterr, varargin{1});
        fprintf('\r\n%s', errMsg);
        if nargout > 1
          varargout{2} = errMsg;
        end
      end %if ~isempty(f1)else
    end % if err
  else % if findstrchr(varargin{1},'_Callback')
    [varargout{1:nargout}] = showForm_OpeningFcn(varargin{:}) ;
  end % if findstrchr(varargin{1},'_Callback') else
end % if nargin == 0 elseif ischar(varargin{1})
if varargout{1}
  fprintf('\nErr %i, err msg %s', varargout{1}, varargout{2});
end
switch nargout
case 0
  %#IFDEF debugOnly
  % these only work in IDE... which is also the only time we want them!
  assignin('base', 'err', varargout{1});
  assignin('base', 'errMsg', varargout{2});
  assignin('base', 'h_field', varargout{3});
  assignin('base', 'formField', varargout{4});
  assignin('base', 'handles', guidata(h_field(length(h_field))) );
  %#ENDIF
% case 1
%   varargout{1} = figure1 ;
% case 2
% case 3
%   varargout{1} = err;
%   varargout{2} = errMsg;
%   varargout{3} = h_field ;
% case 4
%   varargout{1} = err;
%   varargout{2} = errMsg;
%   varargout{3} = h_field ;
%   varargout{4} = formField ;
% case 5
%   varargout = {};
%   varargout{1} = err;
%   varargout{2} = errMsg;
%   varargout{3} = h_field ;
%   varargout{4} = formField ;
%   varargout{5} = figPosition;
otherwise
end
% --------------------------------------------------------------------

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

% --------------------------------------------------------------------
function varargout = showForm_OpeningFcn(varargin)

[err, errMsg, modName] = initErrModName(strcat(mfilename, '(showForm_OpeningFcn)'));

fig = openfig(mfilename,'new');

% Use system color scheme for figure:
set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

% Generate a structure of handles to pass to callbacks, and store it. 
handles = guihandles(fig);
guidata(fig, handles);
set(handles.figure1,'units','pixels');
origHidden = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')
figPosition = 0;
if nargin
  %path and name with extension of image file
  fPathNameExt = varargin{1};
  [pathstrImage,name,ext,versn] = fileparts(fPathNameExt);
  if length(name) & ~length(ext)
    ext = '.jpg';
    fPathNameExt = strcat(fPathNameExt,ext);
  end
  pathstrImage = endWithBackSlash(pathstrImage);
  %path to alignment file
  pathAddOns = varargin{2};
  %form type # from list
  formField = varargin{3};
  if nargin > 3
    figPosition = varargin{4};
  end
else
  %   [err, errMsg, outpostNmNValues] = OutpostINItoScript; 
  %   pathPrgms = outpostValByName('DirAddOnsPrgms', outpostNmNValues);
  %   pathAddOns = outpostValByName('DirAddOns', outpostNmNValues);
  %   %file stored in .mat is much faster loading
  %   fPathNameExt = strcat(pathPrgms, 'ICS-213-SCC-Message-Form1 copy.jpg');
  %   
  %   fPathNameExt='F:\Downloads\Ham Radio\Packet_soundcard\Computer screen shoots.jpg';
  %   
  %   fPathNameExt = strcat(pathPrgms, 'ICS-213-SCC-Message-Form 1.jpg');
  %   ext = '.jpg';
  %   pacfListNdx = 3; %development: hard code 
end

handles.dirAddOns = pathAddOns;

% % fPathName = '\\dg60x821\h\ham\forms\go-kit\213';

% % %make sure the jpg isn't newer. . . if it exists at all
% % jpgDir = dir(strcat(fPathName,'.jpg'));
% % needCopy = 0;
% % if length(jpgDir)
% %   matDir = dir(strcat(fPathName,'.mat'));
% %   if length(matDir)
% %     if (datenum(jpgDir.date) > datenum(matDir.date))
% %       % source is newer or size is different
% %       needCopy = 1;
% %     end
% %   else % if length(matDir)
% %     needCopy = 1;
% %   end % if length(matDir) else
% %   if needCopy
% %     formImage = imread(strcat(fPathName,'.jpg'),'jpg');
% % %     formImage = importdata(strcat(fPathName,'.jpg'));
% % %     sourceModule = mfilename;
% % %     save(fPathName,'formImage','sourceModule');
% %   end % if needCopy
% % end % if length(jpgDir)
% % if ~needCopy
% %   load(strcat(fPathName,'.mat'));
% % end

if length(fPathNameExt)
  fid = fopen(fPathNameExt,'r');
  if (fid  < 1)
    errMsg = sprintf('%s: unable to open "%s".', modName, fPathNameExt);
    err = 1;
    delete(handles.figure1)
    varargout{1} = err;
    varargout{2} = errMsg;
    varargout{3} = handles.figure1;
    varargout{4} = 0;
    if nargout > 4
      varargout{5} = 0;
    end
    return
  end
  fclose(fid);
  formImage = imread(fPathNameExt, ext(2:length(ext)));
  %  get "axes1" to fit the full window
  set(handles.axes1,'position', [0 0 1 1])
  sz = size(formImage);
else % if length(fPathNameExt)
  a = get(handles.figure1,'PaperPosition');
  sz = [a(4) a(3)];
  set(handles.axes1,'visible', 'off')
end % if length(fPathNameExt) else

if length(figPosition) < 2
  %attempts to adjust the aspect radio and have the figure fill the screen height and just match the image width
  [figFillPos, figMenuNoBrd, figMenu] = screenSize(handles.figure1);
  %figMenu: fits with borders; (5) = height of menu (pixels; (6):borders/framel,r,b
  %    therefore image width = (3) - 2*(6); height = (4) - (5) - (6)
  
  % % movegui(handles.figure1,'northwest');
  % % a = get(handles.figure1,'position');
  % % top = a(2)+a(4);
  % % 
  % % movegui(handles.figure1,'southeast');
  % % b = get(handles.figure1,'position');
  % % hi = top - b(2) + 1;
  wd = sz(2)/sz(1) * (figMenu(4) - figMenu(5)) ;
  %set left so right just touches edge of screen after resizing
  % % b(1) = b(1) + b(3) - wd;
  %left = rightEdge - width where rightEdge = left+width
  figMenu(1) = figMenu(1) + figMenu(3) - wd;
  set(handles.figure1,'position', [figMenu(1:2) wd figMenu(4)])
else %if length(figPosition) < 2
  set(handles.figure1,'position', figPosition)
end % if length(figPosition) < 2 else

if length(fPathNameExt)
  % MATLAB doesn't tell you statement requires ", handles.axes1" or
  %   a new figure is opened!
  imagesc(formImage,'parent', handles.axes1)
  
  axes(handles.axes1)
  
  handles.ax1 = axis;
  % % % retain the aspect ratio of the jpeg...
  % % set(gca, 'DataAspectRatio',[1,1, 1])
  
  load(strcat(pathstrImage,'grayMap'))
  set(handles.figure1,'colormap', grayMap)
  
  %Turn off the axis. Again, MATLAB doesn't show this is the method that works!
  set(handles.axes1,'visible','off')
  
  h_field = fieldsOnForm(formField, handles) ;
else %if length(fPathNameExt) 
  [h_field, formField] = createSimpleForm(handles);
end % if length(fPathNameExt) if length(fPathNameExt) else
set(0,'ShowHiddenHandles', origHidden)
h_field(length(h_field)+1) = handles.figure1;

guidata(handles.figure1, handles);
varargout{1} = err;
varargout{2} = errMsg;
varargout{3} = h_field;
varargout{4} = formField;
varargout{5} = get(handles.figure1,'Position');
% --------------------------------------------------------------------
function [h_field] = fieldsOnForm(field, handles)
debugFlag = 0;
%#IFDEF debugOnly
% debugFlag = 1;
%#ENDIF

%pre-size the array.  Note: if a multiple page form
% & this page has fewer fields than another page, 
% h_field will have entries with value of zero.
h_field(1:length(field)) = 0;
for fldNdx =1:length(field)
  if ~length(char(field(fldNdx).digitizedName))
    %no more names in the list 
    %   can occur when a page from a multiple-page form
    break
  end
  %   if strcmp('B',char(field(fldNdx).digitizedName))
  %     fprintf('asdjlasd');
  %   end
  if ~findstrlen('_box',lower(char(field(fldNdx).digitizedName)))
    if findstrlen('Message_12_line', char(field(fldNdx).digitizedName))
      %only create the text box once
      if findstrlen('Message_12_line_1', char(field(fldNdx).digitizedName))
        lftBotWidHi = multiLineToOne(field, '12');
      else % if findstrlen('Message_12_line_1', char(field(fldNdx).digitizedName))
        % not the first line - one of the repeats
        lftBotWidHi(1) = -1; %disable
      end % if findstrlen('Message_12_line_1', char(field(fldNdx).digitizedName)) else
    elseif findstrlen('ActionTaken_13_line', char(field(fldNdx).digitizedName))
      %only create the text box once
      if findstrlen('ActionTaken_13_line_1', char(field(fldNdx).digitizedName))
        lftBotWidHi = multiLineToOne(field, '13');
      else % if findstrlen('ActionTaken_13_line_1', char(field(fldNdx).digitizedName))
        % not the first line - one of the repeats
        lftBotWidHi(1) = -1; %disable
      end % if findstrlen('ActionTaken_13_line_1', char(field(fldNdx).digitizedName)) else
    else %elseif findstrlen('ActionTaken_13_line', char(field(fldNdx).digitizedName))
      % Not a multiple line area.
      lftBotWidHi(1) = field(fldNdx).lftTopRhtBtm(1);
      lftBotWidHi(2) = (1-field(fldNdx).lftTopRhtBtm(4));
      lftBotWidHi(3) = (field(fldNdx).lftTopRhtBtm(3) - field(fldNdx).lftTopRhtBtm(1)) ;
      lftBotWidHi(4) = abs(field(fldNdx).lftTopRhtBtm(2) - field(fldNdx).lftTopRhtBtm(4)) ;
    end %if findstrlen('Message_12_line', char(field(fldNdx).digitizedName))
    if ~(lftBotWidHi(1) < 0) %if not disabled...
      ud.fieldDigName = field(fldNdx).digitizedName;
      %create a text box
      h_field(fldNdx) = uicontrol('Style', 'text', 'UserData', ud, 'parent', handles.figure1,'units','normalized');
      if ~length(field(fldNdx).PACFormTagSecondary)
        if debugFlag
          set(h_field(fldNdx),'String', field(fldNdx).digitizedName);
        end
      else % if ~length(field(fldNdx).PACFormTagSecondary)
        %the routine which loads the fields uses 'X'
        [outstring,newpos] = textwrap(h_field(fldNdx),{'X'});
        %center horizontally: digiized (left + 1/2 width) - 1/2 new width
        newpos(1) = lftBotWidHi(1) + (lftBotWidHi(3) - newpos(3))/2;
        %center vertically: digiized (left + 1/2 width) - 1/2 new width
        newpos(2) = lftBotWidHi(2) + (lftBotWidHi(4) - newpos(4))/2;
        lftBotWidHi = newpos;
        if ~debugFlag
          set(h_field(fldNdx),'FontWeight','Bold', 'String','','Visible','off');
        end
      end %if ~length(field(fldNdx).PACFormTagSecondary) else
      try
        set(h_field(fldNdx),'position', lftBotWidHi)
      catch
        fprintf('\nerror in %s/fieldsOnForm at "set(h_field(fldNdx),''position'', lftBotWidHi)"', mfilename);
      end
      if debugFlag
      else %if debugFlag
        %set color to white, the background of all forms
        set(h_field(fldNdx),'BackgroundColor', [1 1 1]);
      end % if debugFlag else
    end %if ~(lftBotWidHi(1) < 0)
    % set(handles.text1,'position', [txtLft txtBot txtWd txtHi])
  end % if ~findstrchr('_box',lower(char(field(fldNdx).digitizedName)))
end % for fldNdx =1:length(field)
% hh=find(h_field);for fldNdx =1:length(hh);try delete(h_field(hh(fldNdx)));catch;end;end

% --------------------------------------------------------------------
function [lftBotWidHi ] = multiLineToOne(field, PACFormTagPrimary)
%create one text box that goes from the top of _line_1 to the
%  bottom of the _line_n where "n" is the last line.
Ndx = find(ismember({field.PACFormTagPrimary}, PACFormTagPrimary));
[a, b] = sort({field(Ndx).digitizedName});
%partial bottom: bottom of last field
c = field(Ndx(b(length(b)))).lftTopRhtBtm;
lftBotWidHi(2) = c(4);
%average the left & right edges
d = 0;
e = 0;
for itemp = 1:length(b)
  c = field(Ndx(b(itemp))).lftTopRhtBtm;
  d = d + c(1);
  e = e + c(3);
end
% left
lftBotWidHi(1) = d/itemp;
% width
lftBotWidHi(3) = (e/itemp - lftBotWidHi(1));
%top of first field .... on the way to
c = field(Ndx(b(1))).lftTopRhtBtm;
%height
lftBotWidHi(4) = abs(lftBotWidHi(2) - c(2)) ;
%final bottom value
lftBotWidHi(2) = (1 - lftBotWidHi(2));
% ----- ^^^^^ function [lftBotWidHi ] = multiLineToOne(field, PACFormTagPrimary)
% --------------------------------------------------------------------
function [h_field, formField] = createSimpleForm(handles);
origUnits = get(handles.figure1, 'units');
set(handles.figure1, 'units', 'pixels');
positFig1 = get(handles.figure1, 'position');
brder = 2;
positFig1(1) = positFig1(1) + brder;
positFig1(2) = positFig1(2) + brder;
positFig1(3) = positFig1(3) - 2 * brder;
positFig1(4) = positFig1(4) - 2 * brder;
% formField: structure containing the location and names of every field
%     digitizedName
%     PACFormTagPrimary
%     PACFormTagSecondary
%     HorizonJust
%     VertJust
%     lftTopRhtBtm
formField.digitizedName = '';

opts = struct('Style', 'text', 'parent', handles.figure1,'units','pixels', ...
  'fontName', 'Courier', 'fontUnits', 'points', 'fontSize', 10, 'BackgroundColor', [1 1 1]);

formField(1).digitizedName = 'bbs';
[h_field, positAbove, formField] = createSimpleField(formField, '    BBS: K6MTV-1', 0, [brder (positFig1(4)-brder) positFig1(3:4)], positFig1, opts, []);

formField(length(h_field)+1).digitizedName = 'datetime';
[h_field, positAbove, formField] = createSimpleField(formField, 'Received: 15-Feb-2010 19:59', 1, [brder (positFig1(4)-brder) positFig1(3:4)], positFig1, opts, h_field);

formField(length(h_field)+1).digitizedName = 'from';
[h_field, p, formField] = createSimpleField(formField, '   From: K6MTV', 0, positAbove, positFig1, opts, h_field);

formField(length(h_field)+1).digitizedName = lower('Local MsgNum');
[h_field, positAbove, formField] = createSimpleField(formField, 'Local MsgNo: SEP-P12345', 1, positAbove, positFig1, opts, h_field);

formField(length(h_field)+1).digitizedName = 'to';
[h_field, positAbove, formField] = createSimpleField(formField, '     To: K6MTV', 0, positAbove, positFig1, opts, h_field);

formField(length(h_field)+1).digitizedName = 'subject';
[h_field, positAbove, formField] = createSimpleField(formField, 'Subject: Display format', 2, positAbove, positFig1, opts, h_field);

%footer large enough for three lines, placed at the bottom
% left edge
positFooter(1) = brder;
% full width
positFooter(3) = positFig1(3);
% figure bottom
positFooter(2) = brder;
% temporary: available height
positFooter(4) = positAbove(2) - 2 * brder;
fieldNdx = length(h_field) + 1;
h_field(fieldNdx) = uicontrol(opts, 'position', positFooter);
[outstring,newpos] = textwrap(h_field(fieldNdx), {'one','two','three'});
% final: reduce height
positFooter(4) = newpos(4);
set(h_field(fieldNdx), 'position', positFooter,'HorizontalAlignment','Center');
formField(fieldNdx).digitizedName = 'Footer';
formField(fieldNdx).lftTopRhtBtm = positFooter;
formField(fieldNdx).PACFormTagPrimary = formField(fieldNdx).digitizedName;
formField(fieldNdx).PACFormTagSecondary = '';
formField(fieldNdx).HorizonJust = 'Hcenter';
formField(fieldNdx).VertJust = 'Vtop';

%message box at the bottom
% "edit" cannot be more than one line so we'll
% create a 'look' by framing a text box
%Frame:
% left edge
posit(1) = brder;
% full width
posit(3) = positFig1(3);
% % % figure bottom
% % posit(2) = brder + positFooter(2) + positFooter(4);
posit(2) = positAbove(2) - 4 * brder;
% % % available height
% % posit(4) = positAbove(2) - 2 * brder - posit(2);
posit(4) = 2 * brder ;
fieldNdx = length(h_field) + 1;
h_field(fieldNdx) = uicontrol('Style', 'frame', 'parent', handles.figure1,'position', posit, 'BackgroundColor',[1 1 1]);
formField(fieldNdx).digitizedName = 'frameTop';
formField(fieldNdx).lftTopRhtBtm = posit;
formField(fieldNdx).PACFormTagPrimary = formField(fieldNdx).digitizedName;
formField(fieldNdx).PACFormTagSecondary = '';
formField(fieldNdx).HorizonJust = '';
formField(fieldNdx).VertJust = '';

%Text box- position one brdr within frame
% left edge
posit(1) = brder + posit(1);
% width
posit(3) = posit(3) - 2 * brder;
% figure bottom
% % posit(2) = posit(2) + brder ;
posit(2) = brder + positFooter(2) + positFooter(4);
% available height
% % posit(4) = posit(4) - 2 * brder;
posit(4) = positAbove(2) - 4 * brder - posit(2);
fieldNdx = length(h_field) + 1;
h_field(fieldNdx) = uicontrol(opts, 'position', posit);
formField(fieldNdx).digitizedName = 'message';
formField(fieldNdx).lftTopRhtBtm = posit;
formField(fieldNdx).PACFormTagPrimary = formField(fieldNdx).digitizedName;
formField(fieldNdx).PACFormTagSecondary = '';
formField(fieldNdx).HorizonJust = 'Hleft';
formField(fieldNdx).VertJust = 'Vtop';

posit(2) = positFooter(2) + positFooter(4);
posit(4) = brder;
fieldNdx = length(h_field) + 1;
h_field(fieldNdx) = uicontrol('Style', 'frame', 'parent', handles.figure1,'position', posit, 'BackgroundColor',[1 1 1]);
formField(fieldNdx).digitizedName = 'frameBtm';
formField(fieldNdx).lftTopRhtBtm = posit;
formField(fieldNdx).PACFormTagPrimary = formField(fieldNdx).digitizedName;
formField(fieldNdx).PACFormTagSecondary = '';
formField(fieldNdx).HorizonJust = '';
formField(fieldNdx).VertJust = '';

for itemp =1:fieldNdx
  set(h_field(itemp),'units','normalized', 'String', '');
end
ud.formType = 'simple'
set(handles.figure1, 'units', origUnits, 'Color', [1 1 1], 'UserData', ud);
% ------^^^^^^^^^    createSimpleForm(handles); ^^^^^^^^^^^^^^-------------------
function [h_field, posit, formField] = createSimpleField(formField, str, leftRIGHT, positAbove, positFig1, opts, h_field)
fieldNdx = length(h_field) + 1 ;
h_field(fieldNdx) = uicontrol(opts, 'position', positFig1, 'fontWeight', 'bold');
[outstring,newpos] = textwrap(h_field(fieldNdx), {str});
%height
posit(4) = newpos(4);
% bottom 
posit(2) = positAbove(2) - newpos(4);
switch leftRIGHT
case 0 %from left edge to center
  posit(1) = 1;
  posit(3) = positFig1(3)/2;
  hz = 'left';
case 1 %from center to right
  posit(1) = positFig1(3)/2 - 1;
  posit(3) = positFig1(3)/2;
  hz = 'right';
case 2 %from left to right
  posit(1) = 1;
  posit(3) = positFig1(3);
  hz = 'left';
end
formField(fieldNdx).PACFormTagPrimary = formField(fieldNdx).digitizedName;
formField(fieldNdx).PACFormTagSecondary = '';
formField(fieldNdx).HorizonJust = strcat('H', hz);
formField(fieldNdx).VertJust = 'Vtop';
formField(length(h_field)).lftTopRhtBtm = posit;

set(h_field(fieldNdx), 'position', posit, 'HorizontalAlignment', hz,'string',str)
% --------------------------------------------------------------------
