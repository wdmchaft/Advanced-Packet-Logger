function varargout = figImageAlign(varargin)
% figImageAlign Application M-file for figImageAlign.fig
%    FIG = figImageAlign launch figImageAlign GUI.
%    figImageAlign('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 08-May-2010 18:01:23

err = 0;
errMsg = '';
figure1 = 0 ;
callback = 0;
if nargin == 0  % LAUNCH GUI
  [err, errMsg, figure1] = figImageAlign_OpeningFcn;
elseif nargin < 2 % LAUNCH GUI and pass path or path\name
  [err, errMsg, figure1] = figImageAlign_OpeningFcn(varargin{1});
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
  callback = 1;
  err = 0;
  try
    if (nargout)
      [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    else
      feval(varargin{:}); % FEVAL switchyard
    end
  catch
    err = 1;
  end %try
  %This "if" provides a method of passing parameters to "figImageAlign_OpeningFcn".  It responds
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
        [err, errMsg, figure1] = figImageAlign_OpeningFcn(varargin{:}) ;
      catch
        % disp(lasterr);
        fprintf('\r\n%s while attempting figImageAlign_OpeningFcn with %s', lasterr, varargin{1});
      end
      if nargout > 0
        varargout{1} = err;
        if nargout > 1
          varargout{2} = errMsg;
          if nargout > 2
            varargout{3} = figure1 ;
          end
        end
      end
    else % if ~isempty(f1)
      %was not the 'Undefined function' error message - report the error
      errMsg = sprintf('%s while attempting %s', lasterr, varargin{1});
      fprintf('\r\n%s', errMsg);
    end %if ~isempty(f1)else
  end % if err
end % if nargin == 0 elseif ischar(varargin{1})
if err
  fprintf('\nErr %i, err msg %s', err, errMsg);
end
switch nargout
case 0
  if ~callback
    assignin('base', 'err', err);
    assignin('base', 'errMsg', errMsg);
    assignin('base', 'figure1', figure1);
    assignin('base', 'handles', guidata(figure1));
  end
case 1
  varargout{1} = figure1 ;
case 2
case 3
  varargout{1} = err;
  varargout{2} = errMsg;
  varargout{3} = figure1 ;
otherwise
end

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
function varargout = figImageAlign_OpeningFcn(varargin)

[err, errMsg, modName] = initErrModName(strcat(mfilename, '(figImageAlign_OpeningFcn)'));

fig = openfig(mfilename,'reuse');

% Use system color scheme for figure:
set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

% Generate a structure of handles to pass to callbacks, and store it. 
handles = guihandles(fig);
guidata(fig, handles);

[err, errMsg, outpostNmNValues] = OutpostINItoScript;
handles.pathAddOns = outpostValByName('DirAddOns', outpostNmNValues);
handles.pathPrgms = outpostValByName('DirAddOnsPrgms', outpostNmNValues);

%file stored in .mat is much faster loading
fPathName = strcat(handles.pathPrgms, 'ICS-213-SCC-Message-Form1 copy');

fPathName='F:\Downloads\Ham Radio\Packet_soundcard\Computer screen shoots';

fPathName = 'ICS-213-SCC-Message-Form 1';

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

origDir = pwd;
cd(handles.pathPrgms);
[fname,pname] = uigetfile(fileMask);
cd(origDir)
% if cancel:
if isequal(fname,0) | isequal(pname,0)
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
  delete (handles.figure1)
  return
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
end
[path, fname, ext, version] = fileparts(fname);
fPathName = strcat(pname, fname);
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

formImage = imread(fPathName, ext(2:length(ext)) );

%  get "axes1" to fit the full window
set(handles.axes1,'position', [0 0 1 1])

% MATLAB doesn't tell you statement requires ", handles.axes1" or
%a new figure is opened!
imagesc(formImage,'parent', handles.axes1)

origHidden = get(0,'ShowHiddenHandles');

set(0,'ShowHiddenHandles','on')
axes(handles.axes1)
colormap('gray')
handles.ax1 = axis;

set(0,'ShowHiddenHandles', origHidden)
%Turn off the axis. Again, MATLAB doesn't show this is the method that works!
set(handles.axes1,'visible','off')

%action when mouse moved: updates the X-Y location of the mouse
set(handles.figure1,'WindowButtonMotionFcn', '');
set(handles.figure1,'WindowButtonMotionFcn', 'figImageAlign(''figImageAlign_WindowButtonMotionFcn'',gcbo,[],guidata(gcbo))')
% % %action when mouse button pushed: will call this function with a flag; actual decoding is here
set(handles.figure1,'WindowButtonDownFcn','');
set(handles.figure1,'WindowButtonDownFcn','figImageAlign(''figImageAlign_WindowButtonDownFcn'',gcbo,[],guidata(gcbo))')
set(handles.figure1,'WindowButtonUpFcn','');
set(handles.figure1,'WindowButtonUpFcn','figImageAlign(''figImageAlign_WindowButtonUpFcn'',gcbo,[],guidata(gcbo))')
%action when key pressed: will call this function with a flag; actual decoding is here
set(handles.figure1,'KeyPressFcn','')
set(handles.figure1,'KeyPressFcn','figImageAlign(''figImageAlign_KeyPressFcn'',gcbo,[],guidata(gcbo))')

handles.mouseActive = 0;
handles.whichEdge = 0;
handles.ptch(1:4) = 0;
guidata(handles.figure1, handles);
varargout{1} = err;
varargout{2} = errMsg;
varargout{3} = handles.figure1;
% --------------------------------------------------------------------
function figImageAlign_KeyPressFcn(h, eventdata, handles, varargin)
%key pressed
currentCharacter = get(gcf,'CurrentCharacter') ;
switch lower(currentCharacter)
case 'l'
  selectColr(handles, 1);
case 'r'
  selectColr(handles, 2);
case 't'
  selectColr(handles, 3);
case 'b'
  selectColr(handles, 4);
case 's'
  [err, errMsg] = saveAlignment(handles);
otherwise
end
% --------------------------------------------------------------------
function handles = selectColr(handles, newEdge)
if (handles.whichEdge ~= newEdge) & handles.whichEdge
  if handles.ptch(handles.whichEdge)
    set(handles.ptch(handles.whichEdge), 'EdgeColor', [0 1 0]);
  end % if handles.ptch(handles.whichEdge)
end % if (handles.whichEdge ~= newEdge)
handles.whichEdge = newEdge ;
guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function figImageAlign_WindowButtonDownFcn(h, eventdata, handles, varargin)
handles.mouseActive = 1;
set(handles.figure1,'WindowButtonMotionFcn', 'figImageAlign(''figImageAlign_WindowButtonMotionFcn'',gcbo,[],guidata(gcbo))')
guidata(handles.figure1, handles);

% --------------------------------------------------------------------
function figImageAlign_WindowButtonUpFcn(h, eventdata, handles, varargin)
handles.mouseActive = 0;
set(handles.figure1,'WindowButtonMotionFcn', '');
b = calcNrmlEdges(handles);
fprintf('\nLeft: %.6f,  Right: %.6f, Top: %.6f, Bottom: %.6f', b);
guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function b = calcNrmlEdges(handles);
b(1:4) = 0;
if handles.ptch(1)
  a = get(handles.ptch(1), 'xdata');
  b(1) = (a(1) - handles.ax1(1))/(handles.ax1(2) - handles.ax1(1));
end
if handles.ptch(2)
  a = get(handles.ptch(2), 'xdata');
  b(2) = (a(1) - handles.ax1(1))/(handles.ax1(2) - handles.ax1(1));
end
if handles.ptch(3)
  a = get(handles.ptch(3), 'ydata');
  b(3) = (a(1) - handles.ax1(3))/(handles.ax1(4) - handles.ax1(3));
end
if handles.ptch(4)
  a = get(handles.ptch(4), 'ydata');
  b(4) = (a(1) - handles.ax1(3))/(handles.ax1(4) - handles.ax1(3));
end
% --------------------------------------------------------------------
function figImageAlign_WindowButtonMotionFcn(h, eventdata, handles, varargin)
if ~handles.mouseActive
  return
end
set(handles.figure1,'WindowButtonMotionFcn', '');
if (handles.whichEdge)
  if handles.ptch(handles.whichEdge)
    delete (handles.ptch(handles.whichEdge))
  end
end

% The returned matrix is of the form:
% [ Xback,  Yback,  Zback
%   Xfront, Yfront, Zfront]
%For a 2D plot, the X & Y values are the same & Z is +/-1
mouseXYZ = get(handles.axes1, 'CurrentPoint');

switch handles.whichEdge
case {1,2}  
  handles.ptch(handles.whichEdge) = patch([mouseXYZ(1,1) mouseXYZ(1,1)],  [handles.ax1(3) handles.ax1(4)],[1 0 0], 'EdgeColor', [1 0 0]);
case {3,4}
  handles.ptch(handles.whichEdge) = patch([handles.ax1(1) handles.ax1(2)],[mouseXYZ(1,2) mouseXYZ(1,2)], [1 0 0], 'EdgeColor', [1 0 0]);
otherwise
end
set(handles.figure1,'WindowButtonMotionFcn', 'figImageAlign(''figImageAlign_WindowButtonMotionFcn'',gcbo,[],guidata(gcbo))')

guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function [err, errMsg] = saveAlignment(handles)
b = calcNrmlEdges(handles);
%top_fromMsgHdrBtm = b(3);left_fromMsgHdr = b(1);right_fromMsgHdr = b(2);bottom_fromOpratrUseBtm = b(4)
[err, errMsg, fPathName] = write213Alignment(strcat(handles.pathAddOns,'_jpg'), b(3), b(1), b(2), b(4), 1);
if err
  fprintf('\n*** error = %i: %s', err, errMsg);
else
  fprintf('\n results saved in "%s"', fPathName);
end

% --------------------------------------------------------------------
% AFTER call to "[err, errMsg, field, printerPort] = loadICS213FormPositions(pathToFiles);"

% field = 
% 1x59 struct array with fields:
%     digitizedName
%     PACFormTagPrimary
%     PACFormTagSecondary
%     HorizonJust
%     VertJust
%     lftTopRhtBtm
function nothing

set(handles.text1,'position', ...
  [field(2).lftTopRhtBtm(1) ...
    (1-field(2).lftTopRhtBtm(4)) ...
    (field(2).lftTopRhtBtm(3) - field(2).lftTopRhtBtm(1)) ...
    abs(field(2).lftTopRhtBtm(2) - field(2).lftTopRhtBtm(4))...
  ])

%lets try creating controls and placing them
%  needs special handling for the multiple line regions before real use but let's give it a try
for fldNdx =1:length(field)
  if ~length(field(fldNdx).PACFormTagSecondary)
    h(fldNdx) = uicontrol('Style', 'text', 'String', field(fldNdx).digitizedName);
  else
    h(fldNdx) = uicontrol('Style', 'checkbox', 'String', '','ToolTip', field(fldNdx).digitizedName);
  end
  set(h(fldNdx),'position', ...
    [field(fldNdx).lftTopRhtBtm(1) ...
      (1-field(fldNdx).lftTopRhtBtm(4)) ...
      (field(fldNdx).lftTopRhtBtm(3) - field(fldNdx).lftTopRhtBtm(1)) ...
      abs(field(fldNdx).lftTopRhtBtm(2) - field(fldNdx).lftTopRhtBtm(4))...
    ])
end
