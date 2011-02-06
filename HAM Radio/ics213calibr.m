function varargout = ics213Calibr(varargin)
% ICS213CALIBR Application M-file for ics213Calibr.fig
%    FIG = ICS213CALIBR launch ics213Calibr GUI.
%    ICS213CALIBR('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 21-Feb-2010 18:12:29

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
%B=importdata('f:\temp\AndyMaster.jpg');
B= importdata('C:\PacFORMS\exec\ICS-213-SCC-Message-Form1copy1.jpg');
% % set(handles.pushbutton1,'cdata',B)
% % axes(handles.axes1)
pos = get(handles.figure1,'position');
%set(handles.axes1,'position', pos)
image(B,'parent',handles.axes1)
set(handles.axes1,'visible','off')
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

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
function varargout = pushbutton1_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = editTop_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = editBot_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = editLeft_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = editRight_Callback(h, eventdata, handles, varargin)

