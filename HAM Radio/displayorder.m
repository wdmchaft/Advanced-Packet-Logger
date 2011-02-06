function varargout = displayOrder(varargin)
% DISPLAYORDER Application M-file for displayOrder.fig
%    FIG = DISPLAYORDER launch displayOrder GUI.
%    DISPLAYORDER('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 20-Feb-2010 13:21:15


% each line will start with the current column number assignment then the column
%   title.  If if is hidden, the word "hidden" & some prefix such as *** will follow.
%   When hidden, the program will not change the column's physical position on the list
%   but the number will be changed to .... --
%   
% Will want a File menu to Open, Save, Save As, Exit
% 
% Need to decide on a name and extension
% 
% What exactly will be stored?  Should it be in text format?
%   name of column & # of its location?
%   revision number of the file format
% Should we allow rename the column heading?
% "cute" would be to link operator call sign to layout if callsign is in name

if nargin == 0  % LAUNCH GUI
  [figure1, err, errMsg] = displayOrder_OpeningFcn;
  if nargout > 0
    varargout{1} = figure1;
    if nargout > 1
      varargout{2} = err;
      if nargout > 2
        varargout{3} = errMsg ;
      end
    end
  end
elseif nargin < 2
  [err, errMsg, h_] = displayOrder_OpeningFcn(varargin{1});
  if nargout > 0
    varargout{1} = err;
    if nargout > 1
      varargout{2} = errMsg ;
      if nargout > 2
        varargout{3} = h_ ;
      end
    end
  end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
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
  %This "if" provides a method of passing parameters to "displayCounts_OpeningFcn".  It responds
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
        figure1 = displayOrder_OpeningFcn(varargin{:}) ;
      catch
        % disp(lasterr);
        fprintf('\r\n%s while attempting displayOrder_OpeningFcn with %s', lasterr, varargin{1});
      end
      if nargout > 0
        varargout{1} = figure1;
      end
    else % if ~isempty(f1)
      %was not the 'Undefined function' error message - report the error
      fprintf('\r\n%s while attempting %s', lasterr, varargin{1});
    end %if ~isempty(f1)else
  end % if err
end % if nargin == 0 elseif ischar(varargin{1})


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

function varargout = displayOrder_OpeningFcn(varargin)

[err, errMsg, modName] = initErrModName(strcat(mfilename, '(displayCounts_OpeningFcn)'));
figure1 = openfig(mfilename,'reuse');
% Use system color scheme for figure:
set(figure1,'Color',get(0,'defaultUicontrolBackgroundColor'));

%if the user didn't give the fig a name in "guide", we'll default to the 
% name of this mfile.
a = get(figure1, 'name');
ni = findstr(a,'Untitled');
if ~isempty(ni)
  set(figure1,'name',mfilename);
end

% Generate a structure of handles to pass to callbacks, and store it. 
handles = guihandles(figure1);

% set up default values
if nargin
  handles.info = varargin{1} ;
  updateListboxHeadingOrder(handles); 
else 
  return
end

set(handles.editName, 'string', handles.info.dispColFName);
%We want to position this figure with respect to the displayCounts figure
%  get the information of that figure:
h_displayCounts = guidata(handles.info.figure1);

% cascade the figure window
%values in assigned to h_displayCounts.subLeftOffset & .subDownOffset are based on the position units being "characters"
%  We'll temporarily force them to this
origUnits = get(handles.figure1,'units');
origUnitsMain = get(h_displayCounts.figure1,'units');
set(handles.figure1,'units', 'characters');
set(h_displayCounts.figure1,'units', 'characters');
refLeftBotWidHeight = get(h_displayCounts.figure1,'position');
%   learn the figure's current position: we're going to ignore its position but need its width & height
subLeftBotWidHeight = get(handles.figure1,'position');
%   set to position to the left of the main panel
subLeftBotWidHeight(1) = refLeftBotWidHeight(1) - h_displayCounts.subLeftOffset; 
% We want the title bar to be visible for the subpanel figure without covering the main's top bar
%   set so the top of the sub will be below the top of the main
%      by the amount h_displayCounts.subDownOffset * h_displayCounts.h_displayTextNdx
%Da math: Top = Bottom + Height; we'll abbreviate T = B + H
%Main: Tm = Bm + Hm
%Sub:  Ts = Bs + Hs
%want  Ts = Tm - Offset
%subst:  (Bs + Hs) = (Bm + Hm) - Offset
%We control the figure position by the bottom so we need to 
%adjust the location of the bottom of the sub to
%  position the figure properly;
%    Bs = (Bm + Hm) - Hs - Offset 
%which can be written as
%    Bs = Tm - Hs - Offset 
topRef = refLeftBotWidHeight(2) + refLeftBotWidHeight(4);
subLeftBotWidHeight(2) = topRef - subLeftBotWidHeight(4) - h_displayCounts.subDownOffset;

%reposition the figure
set(handles.figure1,'position', subLeftBotWidHeight);
%restore the original units
set(handles.figure1,'units', origUnits);
set(h_displayCounts.figure1,'units', origUnitsMain);


%make the new displayText window visible
set(handles.figure1,'Visible', 'on')

handles.codeVersion = 1.0;
handles.err = err;
handles.errMsg = errMsg;

guidata(figure1, handles);
% caller will make this panel visible: set(figure1,'visible','on');
%Wait for the callbacks to be run and the user attemps to close the window -
%  which calls "displayOrder_CloseRequestFcn" to call uiresume & release the uiwait.
uiwait(figure1)

handles = guidata(handles.figure1);
%need to close the figure AFTER we've recovered the handles!
delete(handles.figure1);
varargout{1} = handles.err;
if handles.err
  varargout{2} = strcat(modName, handles.errMsg);
else
  varargout{2} = handles.errMsg;
end
varargout{3} = handles.info;
% --------------------------------------------------------------------
function updateListboxHeadingOrder(handles)
% handles.info.dispColHdg 
% handles.info.dispColOrdr
space([1:6]) = ' ';
count = 0;
for itemp = 1:length(handles.info.dispColHdg)
  Ndx = handles.info.dispColOrdr(itemp,1);
  %if hidden column
  a = '' ;
  if handles.info.dispColOrdr(itemp,2)
    a = num2str(itemp);
    a = sprintf('%s%s', space(1:6-length(a)),a);
  else
    a = 'hidden';
  end
  list(itemp) = {sprintf('%s   %s', a, char(handles.info.dispColHdg(Ndx)) )};
end
set(handles.listboxHeadingOrder,'string', list) ;
listboxHeadingOrder_Callback(handles.listboxHeadingOrder, [], handles);
% --------------------------------------------------------------------
function varargout = listboxHeadingOrder_Callback(h, eventdata, handles, varargin)
val = get(h, 'value');
%if visible
if handles.info.dispColOrdr(val,2)
  set(handles.togglebuttonHide,'value',0,'string','Hide')
else
  set(handles.togglebuttonHide,'value',1,'string','Unhide')
end
% --------------------------------------------------------------------
function varargout = pushbuttonLeft_Callback(h, eventdata, handles, varargin)
%move this column to the left which is up in the display
val = get(handles.listboxHeadingOrder,'value');
if (val > 1)
  handles.info.dispColOrdr = handles.info.dispColOrdr([1:(val-2) val (val-1) (val+1):length(handles.info.dispColOrdr)],:);
  updateListboxHeadingOrder(handles);
  set(handles.listboxHeadingOrder,'value',val-1)
  if strcmp('default',lower(handles.info.dispColFName))
    handles.info.dispColFName = 'modified' ;
    set(handles.editName, 'string', handles.info.dispColFName);
  end
  guidata(handles.figure1, handles);
end
% --------------------------------------------------------------------
function varargout = pushbuttonRight_Callback(h, eventdata, handles, varargin)
%move this column to the right which is down on the display
val = get(handles.listboxHeadingOrder,'value');
if (val < size(handles.info.dispColOrdr,1) )
  handles.info.dispColOrdr = handles.info.dispColOrdr([1:(val-1) (val+1) val (val+2):length(handles.info.dispColOrdr)],:);
  updateListboxHeadingOrder(handles);
  if strcmp('default',lower(handles.info.dispColFName))
    handles.info.dispColFName = 'modified' ;
    set(handles.editName, 'string', handles.info.dispColFName);
  end
  set(handles.listboxHeadingOrder,'value',val+1)
  guidata(handles.figure1, handles);
end
% --------------------------------------------------------------------
function varargout = togglebuttonHide_Callback(h, eventdata, handles, varargin)
%hide this column: neither the heading nor the data for the column will show
btnVal = get(h,'value');
val = get(handles.listboxHeadingOrder,'value');
if btnVal
  set(h,'string','Unhide')
  handles.info.dispColOrdr(val,2) = 0;
else
  set(h,'string','Hide')
  handles.info.dispColOrdr(val,2) = 1;
end
if strcmp('default',lower(handles.info.dispColFName))
  handles.info.dispColFName = 'modified' ;
  set(handles.editName, 'string', handles.info.dispColFName);
end
updateListboxHeadingOrder(handles);
guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function varargout = editName_Callback(h, eventdata, handles, varargin)
%name of the layout file being displayed/edited
% --------------------------------------------------------------------
function varargout = displayOrder_CloseRequestFcn(h, eventdata, handles, varargin)
handles.err = 1;
handles.errMsg = 'User cancel';
guidata(handles.figure1, handles);
uiresume %need to release the "uiwait" but don't want to delete the figure yet!
% --------------------------------------------------------------------
function varargout = pushbuttonOK_Callback(h, eventdata, handles, varargin)
handles.err = 0;
handles.errMsg = '';
guidata(handles.figure1, handles);
uiresume %need to release the "uiwait" but don't want to delete the figure yet!
% --------------------------------------------------------------------
function varargout = pushbuttonCancel_Callback(h, eventdata, handles, varargin)
handles.err = 1;
handles.errMsg = 'User cancel';
guidata(handles.figure1, handles);
uiresume %need to release the "uiwait" but don't want to delete the figure yet!
% --------------------------------------------------------------------

