function varargout = progresss(namesOfSteps, releaseDEBUG, compiledName, origDir, debugRuleList, varargin)
%function varargout = progresss(namesOfSteps, releaseDEBUG, compiledName, origDir, debugRuleList, varargin)
% PROGRESS Application M-file for dispPopupInfo.fig
%    FIG = PROGRESS launch progress GUI.
%    PROGRESS('callback_name', ...) invoke the named callback.
%[fig, err, maxSteps] = progress
%Calls to the following also take action outside this function.  As a result
%  they have be written to operate even when the fig is closed -> they will
%  take only that action:
%listboxMsg_Callback: external function is to display in the command window.
%checkDiaryOn_Callback: external functions are to turn the diary on, off, and when a
%  name for the diary is passed in, any old copy with the same name is erased and a
%  new diary of that name is made current. Action is sent to "listboxMsg_Callback" &
%  therefore the command window.
%
% INPUT
%  namesOfSteps: cell list of the steps that are going to be performed
%  releaseDEBUG: flag 0 = release mode & 1 = DEBUG
%  compiledName: the name of the module being compiled (such as "matLLD.DLL" or "runReadParmLoadWave.exe"
%  origDirdirectory we started in
%  debugRuleList: (DEBUG only) cell list of additional information about the compiling rules such as "Focus Scan"
% OUTPUT
%  fig: identifier of the panel for subsequent calls
%  err: 0 if all OK, 1 if problem during initialization
%  maxSteps: the maximum number of entries on the panel available to list steps
%
% Last Modified by GUIDE v2.0 26-Jan-2007 14:54:58
%VSS revision   $Revision: 17 $
%Last checkin   $Date: 4/24/07 12:37p $
%Last modify    $Modtime: 4/24/07 9:44a $
%Last changed by$Author: Arose $
%  $NoKeywords: $


% First call pass in:
% 1) list of steps in procedure (would we want to update this as we go?)
% 2) releaseDEBUG flag
% 3) name being compiled
% 4) original directory to which current directory will be set as well
% 5) list of additional compile rules
% 
% Status of checked out file(s)?

persistent fig

if ( ((nargin < 1) | (nargin > 4))  & (~ischar(namesOfSteps)) )% LAUNCH GUI
  err = 0;
  %if first call, the release/debug status is not known and will be <0
  %  use this state to reset the panel/fig
  if (releaseDEBUG == -1) %if first call for this compile whether or not fig is open
    figPosition = 0;
    %Determine if we are refreshing an existing GUI & possibly additional figures (additional from readParmLoadWaveDetail)
    %  if so, we'll close and reopen to reinitialize to defaults
    wasHidden = get(0,'ShowHiddenHandles'); %temp stor current status
    set(0,'ShowHiddenHandles','on'); %turn on
    hlist = get(0,'children'); %get full list
    set(0,'ShowHiddenHandles', wasHidden) %restore status from tmp
    for itemp = 1:length(hlist) %close
      a = get(hlist(itemp),'FileName');
      if findstrchr(mfilename, a)
        % this is the figure: save its position on the display before we close: we'll use this when we re-open it
        figPosition = get(hlist(itemp),'Position');
        if ~isempty(fig)
          %save the breakpoints in memory (not file) (save and tag based on name of function being compiled)
          saveGetBreaks(guidata(fig), 0);
        end %if ~isempty(fig)
        delete(hlist(itemp))
      end % if findstrchr(mfilename, a)
    end %for itemp = 1:length(hlist) 
    
    fig = openfig(mfilename,'reuse');
    set(fig,'HandleVisibility','off');
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    %if fig wasn't open, load various information from file(s)
    if length(figPosition) < 2
      % see where figure was positioned last time this module was run.
      nameForReload = sprintf('%s.txt', mfilename);
      fid = fopen(nameForReload, 'r');
      if fid > 0
        [figPosition, fid] = readArrayKeyText('figPosition', fid, nameForReload);
        fcloseIfOpen(fid);
        %get the break points from the file (last time figure was closed down)
        saveGetBreaks(handles, 1, 1); 
      end
    end
    if length(figPosition) > 1
      set(fig, 'Position', figPosition);
    else
      movegui(fig, 'southwest');
    end
    %used by init to start or expand the list
    handles.currentStep = 0;
    guidata(fig, handles);
    % Use system color scheme for figure: 
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    %clear the list box
    set(handles.listboxMsg,'String', '');
    
    %General book keeping
    %learn the colors established when "guide" was used to create/update them
    handles.colorEventUpcoming = get(handles.toggleColor_1, 'BackgroundColor');
    handles.colorEventRunning = get(handles.toggleColor_2, 'BackgroundColor');
    handles.colorEventPass = get(handles.toggleColor_3, 'BackgroundColor');
    handles.colorEventFail = get(handles.toggleColor_4, 'BackgroundColor');
    %set all status colors to "upcoming" -> those not upcoming will not be visible
    handleFieldNames = fieldnames(handles);
    colorListNdx = 0;
    identListNdx = 0 ;
    %while we are at it, build up two arrays for convenience: index to color & to ident
    toolTip = sprintf('Color indicates progress.\r\nCan also be used to cause a breakpoint when\r\n  this step is first reached: X=active, ?=dormant');
    for itemp = 1:length(handleFieldNames)
      %key phrase to detect the check boxes:
      if findstrchr('toggleColor_', char(handleFieldNames(itemp)))
        b = char(handleFieldNames(itemp)) ;
        colorListNdx = str2num(b(1+findstrchr('_', b):length(b)));
        handles.colorList(colorListNdx) = getfield(handles, b);
        %set the background color, clear any markers that may have been played with in guide, disable responding to user
        set(handles.colorList(colorListNdx), 'BackgroundColor', handles.colorEventUpcoming, 'enable','inactive','string','', 'tooltip', toolTip); 
      else
        %key phrase to detect the check boxes:
        if findstrchr('textIdent_', char(handleFieldNames(itemp)))
          b = char(handleFieldNames(itemp)) ;
          identListNdx = str2num(b(1+findstrchr('_', b):length(b)));
          handles.identList(identListNdx) = getfield(handles, b);
          %set(handles.identList(identListNdx), 'tooltip', toolTip);
        end
      end
    end %for itemp = 1:length(handleFieldNames)
    a = sprintf('Break points can be set by clicking on the progress "lights".\r\n');
    a = sprintf('%sThe state of these breakpoints are controlled here.\r\n', a);
    a = sprintf('%sThe state and the break points can be changed any time this\r\n', a);
    a = sprintf('%s   figure is visible even if not compiling.', a);
    set(handles.popupmenuBreakpoints,'tooltip', a);
    maxColor = length(handles.colorList);
    maxIdent = length(handles.identList);
    if maxColor ~= maxIdent;
      fprintf('\nError in "guide" creation of this panel!  %i colors and %i identifiers of steps -> must be same', maxColor, maxIdent)
      err = 1;
    end
    %get the break points from memory
    saveGetBreaks(handles, 1); 
    
    handles.diaryPathName = '';
    handles.breakpoint = 0;
    %we're done adding all locals to the "handles." structure: save the structure so it can be accessed
    guidata(fig, handles);
  else %if (releaseDEBUG == -1) %if first call for this compile whether or not fig is open
    if (releaseDEBUG == -2)
      handles = guidata(fig);
    else %if (releaseDEBUG == -2)
      %a call to call/update such as setting Debug/Release
      handles = varargin{1};
      fig = handles.figure1;
    end %if (releaseDEBUG == -2) else
  end %if (releaseDEBUG == -1) else %if first call for this compile whether or not fig is open
  closeProgressSupportFigs; %close any figures which support this figure, such as helpdlg, that are still open
  %general bookeeping completed: process the initialization information if it was passed in
  if (nargin > 4)
    
    if releaseDEBUG > -1
      if releaseDEBUG
        %if debug, turn on the check & make the text visible....
        set(handles.checkboxDebug,'value',1,'visible','on');
        %if no additional rules (such as focusScan)...
        if ~length(debugRuleList)
          %... hide that listbox
          set(handles.listboxDebug,'visible','off');
        else
          %addition rules: loading rule listbox goes here
          set(handles.listboxDebug,'String', debugRuleList,'Value', 1) % Load listbox: with text & previous answer
          set(handles.listboxDebug,'visible','on');
        end
        set(handles.checkboxRelease,'value',0,'visible','off');
        set(handles.pushbuttonFindObfIssue, 'visible','off');
      else
        %release mode
        set(handles.checkboxDebug,'value',0,'visible','off');
        set(handles.listboxDebug,'visible','off');
        set(handles.checkboxRelease,'value',1,'visible','on');
        
        toolTip = sprintf('After compilation failure, can be used to scan diary\r\n');
        toolTip = sprintf('%sto find compiler issues with obfuscated names.\r\n', toolTip);
        toolTip = sprintf('%sFor each one that is found, the obfuscated name is\r\n', toolTip);
        toolTip = sprintf('%straced back through "ObfuscatedNames.txt".\r\n', toolTip);
        set(handles.pushbuttonFindObfIssue, 'visible','on','tooltip', toolTip);

      end
    end %if releaseDEBUG > -1
    if length(compiledName)
      set(handles.textFileName , 'string', sprintf('Compiling to create "%s"', compiledName), 'visible','on' );
    else
      set(handles.textFileName , 'visible','off' );
    end
    %get the break points from memory (yeah, a 2nd call.. not pretty)
    saveGetBreaks(handles, 1); 
    set(handles.editOrigDir , 'string', origDir);
    set(handles.editCurDir , 'string', origDir);
    set(handles.editTrgDir , 'string', '');
  end %if (nargin > 4)

  initAll_Ident(fig, [], handles, namesOfSteps, handles.currentStep);
  if nargout > 0
    varargout{1} = fig;
    varargout{2} = err;
    varargout{3} = length(handles.identList);
  end
  
elseif ischar(namesOfSteps) % INVOKE NAMED SUBFUNCTION OR CALLBACK
  if isempty(fig)
    guid = [];
  else %if isempty(fig)
    try
      guid = guidata(fig);
    catch
    end
  end %if isempty(fig) else
  switch nargin
  case 2
    %called with 2: fill in the additional which are the same for all calls
    varargin = {namesOfSteps, fig, [], guid, releaseDEBUG};
  case 3
    %called with 3: fill in the additional which are the same for all calls
    varargin = {namesOfSteps, fig, [], guid, releaseDEBUG, compiledName};
  case 4
    varargin = {namesOfSteps, releaseDEBUG, compiledName, origDir};
  case 5
    varargin = {namesOfSteps, releaseDEBUG, compiledName, origDir, debugRuleList}; % varargin
  otherwise
    if (nargin > 5)
      varargin = [{namesOfSteps, releaseDEBUG, compiledName, origDir, debugRuleList}, varargin];
    end 
  end
  
  try
    if (nargout)
      [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    else
      feval(varargin{:}); % FEVAL switchyard
    end
  catch
    disp(lasterr);
  end
  if ~isempty(fig)
    %if the figure was NOT just closed....
    if ~findstrchr('figure1_CloseRequestFcn', namesOfSteps);
      %refresh in case any changes
      guid = guidata(fig);
      if guid.breakpoint %set in updateStatus when the current step is set to "running" & user has activated a breakpoint at this step
        dbstop in progress at debugBreak
        %clear the flag and save before the breakpoint so when user steps it is less confusing
        guid.breakpoint = 0;
        guidata(fig, guid);
        %tell the user what is occuring
        a = guid.currentStep;
        b = sprintf('** User breakpoint @ step #%i, "%s".', a, char(get(guid.identList(a) ,'string')));
        listboxMsg_Callback(fig, [], guid, strcat(b, '  Look at editor for instructions in comments.') );
        b = sprintf('%s \n\nYou have paused the program in debug mode & are actually in a function called from the program.', b);
        b = sprintf('%s To get into the program, press F10 or the "Step Out" tool button several times.', b);
        b = sprintf('%s NOTE: you can now set break points anywhere in the code but do that before continuing.', b);
        b = sprintf('%s \n\n Closing this popup is benign & the code will remained paused.', b);
        h_help = helpdlg(b, 'Compile Paused');
        set(h_help, 'tag', mfilename); %for general closing...
        edit progress
        debugBreak;
        dbclear in progress at debugBreak
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
      end  % if guid.breakpoint
    end
  end % if ~isempty(fig)
end %elseif ischar(namesOfSteps) % INVOKE NAMED SUBFUNCTION OR CALLBACK


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
function varargout = initAll_Ident(h, eventdata, handles, varargin)
%How to call: (applies after the figure has been opened with "h_progress = progress;")
%  progress('initAll_Ident', h_progress, [], guidata(h_progress), {'one','two','three'},<lastStepWithValidStatus>)
%OR
%  progress('initAll_Ident', {'one','two','three'},<lastStepWithValidStatus>)
%set the color to upcoming
%load the text
%make 'em both visible
a = varargin{1};
for itemp = (1+varargin{2}):length(a)
  set(handles.identList(itemp), 'string', a(itemp), 'visible','on');
  set(handles.colorList(itemp), 'BackgroundColor', handles.colorEventUpcoming, 'visible','on'); 
end
handles.identifiedStepCount = length(a);
handles.currentStep = varargin{2};
%update the "handles." structure: save the structure so it can be accessed
guidata(handles.figure1, handles);

% --------------------------------------------------------------------
function varargout = updateStatus(h, eventdata, handles, varargin)
%varargin: 1 = step #, 2: text for status: running, pass, fail (capitalization not important)
%varargout: err (0 of OK), errMsg
%sample call
%  [err, errMsg, thisStep] = progress('updateStatus', h_progress, [], guidata(h_progress), <step#>, 'running');
%OR
%  [err, errMsg, thisStep] = progress('updateStatus', <step#>, 'running');

err = 0;
errMsg = '';
if isempty(h)
 return
end
statusChoices = {'running', 'pass', 'fail'};
stepNum = varargin{1};
%make sure within range
if stepNum > handles.identifiedStepCount
  err = 1;
  errMsg = sprintf('Unknown step: only %i initialized and request was for #%i.', handles.identifiedStepCount, stepNum);            
end
%make sure text is known
a = lower(char(varargin{2}));
b = ismember(statusChoices, a);
if ~any(b)
  err = err + 2;
  errMsg = sprintf('%s Unknown status of "%s"', a);
end
if ~err
  b = find(b) ;
  %numeric value is determined by order os "statusChoices", above
  switch b
  case 1 % running
    c = handles.colorEventRunning;
    %decide if user has a breakpoint set here
    if get(handles.colorList(stepNum), 'value')
      %if this type of breakpoint is enabled
      if (2==get(handles.popupmenuBreakpoints,'Value'))
        handles.breakpoint = 1;
      end
    end %if get(handles.colorList(stepNum), 'value')
  case 2 % pass
    c = handles.colorEventPass;
  case 3 % fail
    c = handles.colorEventFail;
  end %switch b
  set(handles.colorList(stepNum), 'BackgroundColor', c); 
  handles.currentStep = stepNum;
  %update the "handles." structure: save the structure so it can be accessed
  guidata(handles.figure1, handles);
end %if ~err
% % pause (0.1)
drawnow; %force an update
varargout{1} = err;
varargout{2} = errMsg ;
if ~err
  varargout{3} = handles.currentStep ;
else
  varargout{3} = 0 ;
end
% Update by either 
%  a) specific count (step "8"): done "updateStatus"
%  b) by passing the same text as passed to "initAll_Ident" and having this procedure determined which element is affected
%     this module could return the step #
%  c) 2 calls: update current and update next (which makes "current" point to next
%      each call returns the step number that is current.  The step # is also tracked here
%Update is just for color and only needs to indicate in process/running, completed/pass or fail

% --------------------------------------------------------------------
function varargout = updateStatusCurrent(h, eventdata, handles, varargin)
%sample call
%  [err, errMsg, thisStep] = progress('updateStatusCurrent', h_progress, [], guidata(h_progress), 'pass');
%OR
%  [err, errMsg, thisStep] = progress('updateStatusCurrent', 'pass');

if isempty(h)
  if nargout > 0
    varargout{1} = 1;
  end
  if nargout > 1
    varargout{2} = 'progress/updateStatusCurrent: Figure "progress" not available';
  end
  for itemp = 3:nargout
    varargout{itemp} = [];
  end
  return
end %if isempty(h)
[err, errMsg, thisStep] = updateStatus(h, [], handles, handles.currentStep, varargin);
switch nargout
case 1
  varargout{1} = err;
case 2
  varargout{1} = err;
  varargout{2} = errMsg;
case 3
  varargout{1} = err;
  varargout{2} = errMsg;
  varargout{3} = thisStep;
end

% --------------------------------------------------------------------
function varargout = updateStatusNext(h, eventdata, handles, varargin)
%Sets status of next.  Implies that the Current was a 'pass', so
%  this module performs a call to set the current to 'pass'
%sample call 
%  [err, errMsg, thisStep] = progress('updateStatusCurrent', h_progress, [], guidata(h_progress), 'running');
%OR
%  [err, errMsg, thisStep] = progress('updateStatusCurrent', 'running');
[err, errMsg, thisStep] = updateStatusCurrent(h, [], handles, 'pass');
if err
  varargout{1} = err;
  varargout{2} = sprintf('updateStatusNext>updateStatusCurrent:%s',errMsg) ;
  varargout{3} = 0 ;
else
  [err, errMsg, thisStep] = updateStatus(h, [], handles, (1+handles.currentStep), varargin);
  switch nargout
  case 1
    varargout{1} = err;
  case 2
    varargout{1} = err;
    varargout{2} = errMsg;
  case 3
    varargout{1} = err;
    varargout{2} = errMsg;
    varargout{3} = thisStep;
  end
end

% --------------------------------------------------------------------
function varargout = updateStatusByName(h, eventdata, handles, varargin)
%sample call
%  [err, errMsg, thisStep] = progress('updateStatusByName', h_progress, [], guidata(h_progress), 'Compiling', 'running');
%OR
%  [err, errMsg, thisStep] = progress('updateStatusByName', 'Compiling', 'running');
if isempty(h)
 return
end
a = char(varargin{1});
%scan the existing steps to find which is the match
found = 0;
for itemp = 1:handles.identifiedStepCount
  b = get(handles.identList(itemp), 'string');
  if strcmp(a, b)
    found = 1;
    break;
  end
end %for itemp = 1:handles.identifiedStepCount
if found
  %make this the current
  handles.currentStep = itemp;
  [err, errMsg, thisStep] = updateStatus(h, [], handles, handles.currentStep, varargin{2});
  switch nargout
  case 1
    varargout{1} = err;
  case 2
    varargout{1} = err;
    varargout{2} = errMsg;
  case 3
    varargout{1} = err;
    varargout{2} = errMsg;
    varargout{3} = thisStep;
  end
else % if found
  err = 1;
  errMsg = sprintf('Step name not found ("%s").', a);
  varargout{1} = err;
  varargout{2} = errMsg ;
  varargout{3} = 0 ;
end %if found else

% --------------------------------------------------------------------
function varargout = editOrigDir_Callback(h, eventdata, handles, varargin)
% sample call:
% progress('editOrigDir_Callback', h_progress, [], guidata(h_progress), 'running')
set(handles.editOrigDir, 'String', varargin{1} ); 

% --------------------------------------------------------------------
function varargout = editTrgDir_Callback(h, eventdata, handles, varargin)
% sample call:
% progress('editTrgDir_Callback', h_progress, [], guidata(h_progress), 'running')
set(handles.editTrgDir, 'String', varargin{1}, 'visible', 'on'); 
set(handles.textTrgDir, 'visible', 'on'); 

% --------------------------------------------------------------------
function varargout = editCurDir_Callback(h, eventdata, handles, varargin)
% sample call:
% progress('editCurDir_Callback', h_progress, [], guidata(h_progress), 'running')
if nargin > 3 & length(handles)
  set(handles.editCurDir, 'String', varargin{1} ); 
end

% --------------------------------------------------------------------
function varargout = checkboxRelease_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = checkboxDebug_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = checkDiaryOn_Callback(h, eventdata, handles, varargin)
% varargin{1}: 0 to turn off & 1 to turn it on
% varargin{2}: optional; when present, it is the name of the diary AND
%      if the flag is turning the diary on, the diary will be created with
%      any old copy deleted  Best to use this only once at the beginning
% sample calls:
% progress('checkDiaryOn_Callback', h_progress, [], guidata(h_progress), 0)
%OR
% progress('checkDiaryOn_Callback', h_progress, [], guidata(h_progress), 1, 'diaryrunReadparmLoadwave.txt')
%OR
% progress('checkDiaryOn_Callback', 0)
%OR
% progress('checkDiaryOn_Callback', 1, 'diaryrunReadparmLoadwave.txt')
figOK = ~isempty(h);
if varargin{1}
  %diary on
  if figOK
    set(handles.checkDiaryOn,'value',1,'visible','on');
  end
  if length(varargin) > 1
    diaryFileName = varargin{2} ;
    if figOK
      set(handles.checkDiaryOn,'string', diaryFileName);
    end
    if exist(diaryFileName)
      diary off; %just in case
      delete(diaryFileName);%delete old diary.
      %make sure delet worked
      if exist(diaryFileName)
        %delete didn't work: clear the contents
        fid = fopen(diaryFileName,'w');
        if (fid < 1)
          err = 1;
          errMsg = sprintf('Unable to delete or clear "%s"', diaryFileName);
          listboxMsg_Callback(h, eventdata, handles, errMsg);
          if nargout
            varargout{1} = err;
            varargout{2} = errMsg ;
          end
          return
        end
        fclose(fid);
      end
    end
    listboxMsg_Callback(h, eventdata, handles, sprintf('Starting diary "%s"', diaryFileName));
    diary (diaryFileName);%begin saving all Command Window information to the diary log file.
    if figOK
      set(handles.pushbuttonOpenDiary,'Enable','on','TooltipString','Opens the diary in the editor');
      handles.diaryPathName = sprintf('%s\\%s', pwd, diaryFileName);
      %update the "handles." structure: save the structure so it can be accessed
      guidata(handles.figure1, handles);
    end
  else %if length(varargin) > 1
    if figOK
      listboxMsg_Callback(h, eventdata, handles, 'diary on');
    end
    diary on;
  end %if length(varargin) > 1 else
else %if varargin{1}
  %diary off
  if figOK
    set(handles.checkDiaryOn,'value',0,'visible','on');
    listboxMsg_Callback(h, eventdata, handles, 'diary off');
  end
  diary off;
  if (length(varargin) > 1) & figOK
    set(handles.checkDiaryOn,'string', varargin{2});
  end
end %if varargin{1} else
if nargout
  varargout{1} = 0;
  varargout{2} = '' ;
end

% --------------------------------------------------------------------
function varargout = listboxDebug_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = listboxMsg_Callback(h, eventdata, handles, varargin)
newLines = varargin{1};
if ischar(newLines)
  newLines = {newLines};
end
if ~isempty(h)
  set(handles.listboxMsg,'visible','on');
  %get the existing list
  a = get(handles.listboxMsg,'String');
  if ischar(a) & length(a)
    a = {a};
  end
  %add the new line(s)
  a = [a' newLines];
  %update the list box
  set(handles.listboxMsg,'String', a, 'value', length(a) );
end %if ~isenpty(h)
%update the Matlab command window
for itemp = 1:length(newLines)
  fprintf('\n%s', char(newLines(itemp)));
end

% --------------------------------------------------------------------

%%% just for programming aid
%             figure1: 147.000244140625
%          listboxMsg: 180.000244140625
%        listboxDebug: 179.000244140625
%       checkboxDebug: 178.000244140625
%     checkboxRelease: 177.000244140625
%        textFileName: 176.000244140625
%        textIdent_17: 175.000244140625
%        toggleColor_17: 174.000244140625
%        textIdent_16: 173.000244140625
%        toggleColor_16: 172.000244140625
%        textIdent_15: 171.000244140625
%        toggleColor_15: 170.000244140625
%        textIdent_14: 169.000244140625
%        toggleColor_14: 168.000244140625
%        textIdent_13: 167.000244140625
%        toggleColor_13: 166.000244140625
%        textIdent_12: 165.000244140625
%        toggleColor_12: 164.000244140625
%        textIdent_11: 163.000244140625
%        toggleColor_11: 162.000244140625
%        textIdent_10: 161.000244140625
%        toggleColor_10: 160.000244140625
%         textIdent_9: 159.000244140625
%         toggleColor_9: 158.000244140625
%         textIdent_8: 157.000244140625
%         toggleColor_8: 156.000244140625
%         textIdent_7: 155.000244140625
%         toggleColor_7: 154.000244140625
%         textIdent_6: 153.000244140625
%         toggleColor_6: 152.000244140625
%         textIdent_5: 151.000244140625
%         toggleColor_5: 150.000244140625
%         textIdent_4: 149.000244140625
%         toggleColor_4: 61.001220703125
%         textIdent_3: 60.001220703125
%         toggleColor_3: 59.001220703125
%         textIdent_2: 58.001220703125
%         toggleColor_2: 57.001220703125
%          editCurDir: 56.001220703125
%          textCurDir: 55.001220703125
%          editTrgDir: 54.001220703125
%          textTrgDir: 53.001220703125
%         editOrigDir: 52.001220703125
%         textOrigDir: 51.001220703125
%         textIdent_1: 50.0013427734375
%         toggleColor_1: 148.000244140625

% --------------------------------------------------------------------
function varargout = pushbuttonOpenDiary_Callback(h, eventdata, handles, varargin)
%need diary name & directory where it is located
if isempty(h)
 return
end
if length(handles.diaryPathName)
  edit (handles.diaryPathName)
end

% --------------------------------------------------------------------
function varargout = pushbuttonMakeCurDirToOrig_Callback(h, eventdata, handles, varargin)
if isempty(h)
 return
end
a = get(handles.editOrigDir,'string');
cd(a);
set(handles.editCurDir ,'string',a);

% --------------------------------------------------------------------
%for guide: progress('figure1_CloseRequestFcn',gcbo,[],guidata(gcbo))
function varargout = figure1_CloseRequestFcn(h, eventdata, handles, varargin)
%save various conditions such as figure position so next run starts the same way

%Don't always want to ask user because that is annoying when we're closing
%Matlab or when the user has stopped compiling & doesn't care about the figure
ok = 1;
% see if we've been called from the command line.  If so, the compile operation has been stopped & no need to ask user.
[ST,I] = dbstack;
% if we've been called from the command line, the stack is only 2 elements: this sub and this module
if (size(ST, 1) > 2)
  %not from command line: check the action state
  %if we neither completed or failed, ask user before closing
  % go through the colors as long as "pass".  
  %  OK if we reach end or a "fail"
  %  ask user if "running" or "upcoming"
  for itemp = 1:handles.identifiedStepCount
    a = get(handles.colorList(itemp), 'BackgroundColor');
    if (a == handles.colorEventFail)
      break;
    end
    %if upcoming or running, user may not realize program could still be running
    if (a == handles.colorEventUpcoming) | (a == handles.colorEventRunning)
      ok = 0;
      break;
    end
  end %for itemp = 1:handles.identifiedStepCount
end %if (size(ST, 1) > 2)

if ~ok
  %make sure the user understands what they are doing.. and not doing!
  button = questdlg('Are you sure you want to close the "progress" figure?  If you were compiling, you will not be stopping that process.',...
    'Close "Progress"','Close','Cancel','Close');
  if strcmp(button,'Cancel')
    return
  end
end
%close any support figures
[hlist, wasHidden] = closeProgressSupportFigs;
figPosition = 0;
% wasHidden = get(0,'ShowHiddenHandles'); %temp stor current status
% set(0,'ShowHiddenHandles','on'); %turn on
% hlist = get(0,'children'); %get full list
for itemp = 1:length(hlist) %close
  a = get(hlist(itemp),'FileName');
  if findstrchr(mfilename, a)
    % this is the figure: save its position on the display before we close: we'll use this when we re-open it
    figPosition = get(hlist(itemp),'Position');
    % and save any breakpoints
    saveGetBreaks(handles, 0, 1);
    delete(hlist(itemp))
  end % if findstrchr('Waveform Parameters', a) 
end %for itemp = 1:length(hlist) 
set(0,'ShowHiddenHandles', wasHidden) %restore status from tmp has to be AFTER the delete(

%right now we're only saving the figure position so only access the file if we've determined it!
if length(figPosition)
  nameForReload = sprintf('%s.txt', mfilename);
  fid = fopen(nameForReload, 'w');
  if fid > 0
    writeArrayKeyText('figPosition', figPosition, fid);
    fcloseIfOpen(fid);
  end
end

% --------------------------------------------------------------------
function varargout = popupmenuBreakpoints_Callback(h, eventdata, handles, varargin)
persistent last_val
val = get(h,'Value');
switch val
case 1 %disable/make dormant the breakpoints: their stats is remembered but will have no effect
  % we'll show any breakpoints that have been idled by changing the symbol
  % and we'll de-activate responding to the user
  for itemp = 1:length(handles.colorList)
    if get(handles.colorList(itemp), 'value')
      set(handles.colorList(itemp), 'string','?','enable','inactive','style','text');
    else
      set(handles.colorList(itemp), 'enable','inactive','style','text');
    end
  end
case 2 %enable and activate breakpoints: allow user to set & re-activate those set previously
  for itemp = 1:length(handles.colorList)
    if get(handles.colorList(itemp), 'value')
      set(handles.colorList(itemp), 'string','X','enable','on','style','togglebutton');
    else
      set(handles.colorList(itemp), 'enable','on','style','togglebutton');
    end
  end
case 3 %clear breakpoints
  for itemp = 1:length(handles.colorList)
    set(handles.colorList(itemp), 'string','','value', 0);
  end
  if length(last_val)
    %and set the popup to where it was before the user chose "clear"
    set(h,'Value', last_val)
    val = last_val; %want "last_val" to be the same it was entering
  else
    %and set the popup to the first: idle/off
    set(h,'Value', 1)
  end
end %switch val
last_val = val;

% --------------------------------------------------------------------
function saveGetBreaks(handles, saveGET, file);
%function saveGetBreaks(handles, saveGET[, file]);
%  This function has nothing to do with the operation of the breakpoints, merely
%saving and recovering breakpoints when the process is re-started or exited.  The
%test & response to the breakpoints is done in the local function "updateStatus"
%This is named based so the settings for each compile file is tracked separately.
% *** currently no separation for Debug & Release ****
% file: if present and set, action is to/from disk as follows
%   If from disk, loads from disk and returns without affecting the handles structure
%     this means a 2nd call is needed to load the handles from the local persistent variables
%     (did this for code flow in main)
%   If to disk, reads latest from the figure and then saves.
persistent nameList stepBreaks popupBreakState

if nargin < 3
  file = 0;
end

if file
  nameForReload = sprintf('%s_break', mfilename);
  %if getting.....
  if saveGET
    %make sure there is previous data
    fid = fopen(strcat(nameForReload,'.mat'), 'r');
    if fid > 0
      fclose(fid);
      load(nameForReload);
      %%%%
      return
      %%%%
    end
  end % if saveGET
end %if file
%read the current name from the fig:
[thisName] = findThisName(handles);
%
new = 1;
for listNdx = 1:length(nameList)
  if strcmp(char(nameList(listNdx)), thisName)
    %found in list: update
    new = 0;
    break
  end
end %for listNdx = 1:length(nameList)
if saveGET
  %if getting...
  if ~new
    for itemp = 1:length(handles.colorList)
      set(handles.colorList(itemp), 'value', stepBreaks(itemp, listNdx));
    end
    set(handles.popupmenuBreakpoints, 'value', popupBreakState(listNdx));
  else %if ~new
    %if new, clear all
    for itemp = 1:length(handles.colorList)
      set(handles.colorList(itemp), 'value', 0);
    end
  end  % if ~new else
  %update the "handles." structure: save the structure so it can be accessed
  guidata(handles.figure1, handles);
  %call the popup so it will label and condition the buttons
  popupmenuBreakpoints_Callback(handles.popupmenuBreakpoints, [], handles);
  %%%%%%
else %if saveGET
  %save the name & then the break points at the same index
  if length(listNdx)
    Ndx = listNdx + new;
    nameList(Ndx) = {thisName} ;
  else
    Ndx = 1;
    nameList = {thisName};
  end
  popupBreakState(Ndx) = get(handles.popupmenuBreakpoints, 'value');
  for itemp = 1:length(handles.colorList)
    stepBreaks(itemp, Ndx) = get(handles.colorList(itemp), 'value');
  end
  if file
    save(nameForReload, 'nameList','stepBreaks', 'popupBreakState');
  end
end % if saveGET else

% --------------------------------------------------------------------
function [thisName] = findThisName(handles)
%reads the name from the figure and extracts it from the text it is embedded in
thisName = get(handles.textFileName, 'string');
quotesAt = findstrchr('"', thisName);
found = 0;
if (length(quotesAt) > 1)
  if (quotesAt(2) > (quotesAt(1)+1))
    found = 1;
  end
end
if found
  thisName = thisName(quotesAt(1)+1:quotesAt(2)-1);
else
  thisName = '1'; %safety valve if no name was passed in; can only support one!
end

% --------------------------------------------------------------------
function varargout = toggleColor_all(h, eventdata, handles, varargin)
%special case: all the toggleColor_* buttons do the same thing.... only need interact with the one the user activated
% set the text
if get(h, 'value')
  a = 'X'; %only called this function if breakpoints are active so use the active symbol
else
  a = '';
end
set(h,'string', a)
% --------------------------------------------------------------------
function [hlist, wasHidden] = closeProgressSupportFigs;
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
end


% --------------------------------------------------------------------
function debugBreak
% You have paused the program in debug mode & are actually in a function
%called from the program.
%To get into the program, press F10 several times or the "Step Out" tool button.
%NOTE: you can now set break points anywhere in the code but do that before continuing.
return

% --------------------------------------------------------------------
function varargout = pushbuttonFindObfIssue_Callback(h, eventdata, handles, varargin)

origTxt = get(h, 'string');
set(h, 'string','Working...');
%After compilation failure, scans diary & "ObfuscatedNames.txt"
findObfIssue;
%restore text and release button
set(h, 'string', origTxt, 'value', 0);
