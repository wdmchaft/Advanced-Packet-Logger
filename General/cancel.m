function varargout = cancel(varargin)
% CANCEL Application M-file for cancel.fig
%    FIG = CANCEL launch cancel GUI.
%    CANCEL('callback_name', ...) invoke the named callback.
%To close the window programmaticallY
%  h=cancel;
%  ...
%either
%  CANCEL('pbCancel_Callback', h, [], guidata(h))
%or
%  close(h)
%VSS revision   $Revision: 10 $
%Last checkin   $Date: 7/19/07 5:15p $
%Last modify    $Modtime: 7/19/07 3:35p $
%Last changed by$Author: Arose $
%  $NoKeywords: $
global userCancel hCancel
global checkCancelSec nextCheckCancel %for checkCancel.m defaults


if nargin == 0  % LAUNCH GUI
  
  fig = openfig(mfilename,'reuse');
  
  closeCancelSupportFigs;
  % Use system color scheme for figure:
  set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
  movegui(fig, 'northwest');
  % Generate a structure of handles to pass to callbacks, and store it. 
  handles = guihandles(fig);
  guidata(fig, handles);
  userCancel = 0;
  %initialize delays and variables for 'checkCancel'
  try
    a = toc; %dummy op just to see if timer is running
  catch
    tic;
  end
  checkCancelSec = 1;
  nextCheckCancel = toc + checkCancelSec;
  %#IFDEF debugOnly  
  % the debug action can only operate in the Matlab environment and not when compiled
  % these lines removed during precompile.  Work with lines beyond the #ENDIF 
  set(handles.pushbuttonDebug, 'visible','on','enable','on');
  userCancel = 1;
  %#ENDIF
  if ~userCancel %only if compiled!
    %here when compiled version
    set(handles.pushbuttonDebug, 'visible','off','enable','off');
  else
    %here in Matlab IDE
    userCancel = 0;
  end
  
  hCancel = fig;
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
function varargout = pbCancel_Callback(h, eventdata, handles, varargin)
global userCancel
%h=cancel;
%CANCEL('pbCancel_Callback', h, [], guidata(h))

%Was the button pushed or was the function called programmatically to close the window
try
  a = get(h, 'Value') ;
  userCancel = 1;
catch
  userCancel = 0;
end
%unpush the button
set(h, 'value',0);
[figPos(1:4)] = get(handles.Cancel, 'Position');
closeCancelSupportFigs;
delete (handles.Cancel)
% --------------------------------------------------------------------
function [hlist, wasHidden] = closeCancelSupportFigs;
%1) closes any open figures that have the name of this module in their
% tag.
%2) leaves the "ShowHiddenHandles" state in "show" if the
%  caller is asking for returned variables
%THE CALLER MUST EXECUTE "set(0,'ShowHiddenHandles', wasHidden)"
%
% Tag is set as part of how figs are opened.  Example:
%  h_help = helpdlg(b, 'Compile Paused');
%  set(h_help, 'tag', mfilename); %for general closing...

wasHidden = get(0,'ShowHiddenHandles'); %temp stor current status
set(0,'ShowHiddenHandles','on'); %turn on
hlist = get(0,'children'); %get full list
for itemp = 1:length(hlist) %close
  a = get(hlist(itemp),'Tag');
  if findstrchr(mfilename, a)
    delete(hlist(itemp));
  end
end
if nargout < 1
  set(0,'ShowHiddenHandles', wasHidden) %restore status from tmp
  clear hlist wasHidden
end
% --------------------------------------------------------------------
function varargout = pushbuttonDebug_Callback(h, eventdata, handles, varargin)
%#IFDEF debugOnly  
% the debug action can only operate in the Matlab environment and not when compiled
% these lines removed during precompile
%unpush the button
set(h, 'value',0);
dbstop in cancel at debugBreak
edit (mfilename)
b = sprintf('You have paused the program in debug mode & are actually in a function called from the program.');
b = sprintf('%s To get into the program, press F10 or the "Step Out" tool button several times.', b);
b = sprintf('%s NOTE: you can now set break points anywhere in the code but do that before continuing.', b);
b = sprintf('%s \n\n Closing this popup is benign & the code will remained paused.', b);
h_help = helpdlg(b, 'Progam Paused');
set(h_help, 'tag', mfilename); %for general closing...
debugBreak;
dbclear in cancel at debugBreak
%close the helpdlg if the user didn't all ready....
%  need to check if the user closed it
wasHidden = get(0,'ShowHiddenHandles'); %temp stor current status
set(0,'ShowHiddenHandles','on'); %turn on
hlist = get(0,'children'); %get full list
set(0,'ShowHiddenHandles', wasHidden) %restore status from tmp
itemp = ismember(hlist,h_help);
%not closed!
if any(itemp)
  itemp = find(itemp);
  delete(hlist(itemp));
end
% done with helpdlg
%#ENDIF
% --------------------------------------------------------------------
function debugBreak
% You have paused your program in debug mode & are actually in a function
%called from your program.
%To get into your program, press F10 several times or the "Step Out" tool button.
return
