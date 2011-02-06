function varargout = packetLogAutoMonitor(varargin)
% PACKETLOGAUTOMONITOR Application M-file for packetLogAutoMonitor.fig
%    FIG = PACKETLOGAUTOMONITOR launch packetLogAutoMonitor GUI.
%    PACKETLOGAUTOMONITOR('callback_name', ...) invoke the named callback.
%ONLY purpose is to open the Packet Log monitor and then activate its
% constant monitoring loop.

% Last Modified by GUIDE v2.0 15-Dec-2009 20:59:40

if nargin == 0  % LAUNCH GUI

  figure1 = packetLogAutoMonitor_OpeningFcn;
  if nargout > 0
    varargout{1} = figure1;
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
  end
  if err
    lastErr = lasterr;
    %if the caller was trying to set properties of the figure, we'll get this error
    f1 = findstr(lastErr,'Undefined function');
    if ~isempty(f1)
      %let's try to set the properties
      try
        figure1 = packetLogAutoMonitor_OpeningFcn(varargin{:}) ;
      catch
        disp(lasterr);
      end
      if nargout > 0
        varargout{1} = figure1;
      end
    else % if ~isempty(f1)
      %was not the 'Undefined function' error message
      disp(lasterr);
    end %if ~isempty(f1)else
  end % if err
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

function varargout = packetLogAutoMonitor_OpeningFcn(varargin)
[err, errMsg, modName] = initErrModName(strcat(mfilename, '(packetLogAutoMonitor_OpeningFcn)'));

figure1 = openfig(mfilename,'new');
% Use system color scheme for figure:
set(figure1,'Color',get(0,'defaultUicontrolBackgroundColor'));

%if the user didn't give the fig a name in "guide", we'll default to the 
% name of this mfile.
a = get(figure1, 'name');
ni = findstr(a,'Untitled');
if ~isempty(ni)
  set(figure1,'name',mfilename);
end

%if the caller of this entire module is trying to set the properties....
if nargin
  set(figure1, varargin{:})
end

% Generate a structure of handles to pass to callbacks, and store it. 
handles = guihandles(figure1);

% set up default values

%open the actual log monitor
h_dC = displaycounts;
%get its handles
handles_dC = guidata(h_dC);

guidata(figure1, handles);
set(figure1,'visible','off');

%activate the monitor (push the button)
set(handles_dC.togglebuttonMonitorLog,'value', 1)
%tell the code the button has been pushed: this call will not end until/unless the user releases the button
% or closes the figure
displayCounts('togglebuttonMonitorLog_Callback',handles_dC.togglebuttonMonitorLog,[],handles_dC);

delete (figure1);
varargout{1} = figure1;
%---------- function varargout = displayText_OpeningFcn(varargin) ---------------
