function varargout = packetLogSettings(varargin)
%function varargout = packetLogSettings([<opening tab>[, OutpostPath])
%INPUT:
% either or none in any order:
%   <opening tab>[optinal]: desired tab initially active. 
%   <path to Outpost>[optinal]: if not present, search defined in findOutpostINI.m
%
% packetLogSettings Application M-file for packetLogSettings.fig
%    FIG = packetLogSettings launch packetLogSettings GUI.
%    packetLogSettings('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 22-Oct-2010 11:06:52
% Modified structure for similarity to Matlab 2008

%***************
% alert message numbering style and formatabout_packetLogSettings_private
% support not just number but timedate as well

%hide "reset' unless a) Andy or b) new start is before pointer!

% Reset "latest"... would "Restart Log" be better label?
% radiobNewMsgLatest needs text from the findNew file's reference
% should save screen location
% should test save before exiting if user closes window


%*********************
% RULES
%  * pane selection buttons must be tagged in guide (i.e. the .fig) by
%    tb<pane name>Pane. <pane name> does not have to be the label seen by the user
%  * All items that need to appear when that pane is selected need to be tagged 
%    <prefix><pane name><suffix>. <prefix> & <suffix> can be anything although 
%    <prefix> is typically the gui type and <suffix> is a functional reference: ex "editSummCity"
%  * the location of "radiobNewMsgToday" is the reference location for all items on any
%    pane that in turn has an item with "_0" in its tag.  That "_0" item will be moved
%    so its left & top edges are in the same location as the left & top of "radiobNewMsgToday".
%    All other items with the same pane name (other than the Pane selection button) will be
%    moved to maintain their alignment to the "_0" item.


%  Printing Pane
% names for copies
% numbers of copies
% address/name of printer(s)
% enable/disable
% possible choice of form versus printer
% print quality


%version number tracked in packetLogSettings_OpeningFcn via "handles.codeVersion"
err = 0;
errMsg = '';
figure1 = 0 ;
if nargin == 0  % LAUNCH GUI
  [err, errMsg, figure1] = packetLogSettings_OpeningFcn;
elseif nargin < 4 % LAUNCH GUI and pass path or path\name
  [err, errMsg, figure1] = packetLogSettings_OpeningFcn(varargin{:});
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
  err = 0;
  % %   try
  if (nargout)
    [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
  else
    feval(varargin{:}); % FEVAL switchyard
  end
  % %   catch
  % %     err = 1;
  % %   end %try
  % %   %This "if" provides a method of passing parameters to "packetLogSettings_OpeningFcn".  It responds
  % %   %  when the program has been called but not in response to a user activity on the GUI.
  % %   if err
  % %     lastErr = lasterr;
  % %     %if the caller was trying to pass parameters, we'll get this error
  % %     % alone.  However a coding error, example with "Ndx" causes "Undefined function or variable 'Ndx'."
  % %     %That is a real error and we do not want to try again!
  % %     f1 = findstr(lastErr,'Undefined function') & ~findstr(lastErr,'or variable');
  % %     %if something, make sure not 0/false
  % %     if ~isempty(f1)
  % %       %if zero, reset to null so tests following operate
  % %       if ~f1
  % %         f1 = [];
  % %       end
  % %     end
  % %     if isempty(f1)
  % %       f1 = findstr(lastErr,'Invalid function');
  % %     end
  % %     if isempty(f1)
  % %       f1 = findstr(lastErr,'Reference to unknown function') & findstr(lastErr,'in stand-alone mode');
  % %     end
  % %     if ~isempty(f1)
  % %       %let's try to set the properties
  % %       try
  % %         [err, errMsg, figure1] = packetLogSettings_OpeningFcn(varargin{:}) ;
  % %       catch
  % %         % disp(lasterr);
  % %         fprintf('\r\n%s while attempting packetLogSettings_OpeningFcn with %s', lasterr, varargin{1});
  % %       end
  % %       if nargout > 0
  % %         varargout{1} = err;
  % %         if nargout > 1
  % %           varargout{2} = errMsg;
  % %           if nargout > 2
  % %             varargout{3} = figure1 ;
  % %           end
  % %         end
  % %       end
  % %     else % if ~isempty(f1)
  % %       %was not the 'Undefined function' error message - report the error
  % %       errMsg = sprintf('%s while attempting %s', lasterr, varargin{1});
  % %       fprintf('\r\n%s', errMsg);
  % %     end %if ~isempty(f1)else
  % %   end % if err
end % if nargin == 0 elseif ischar(varargin{1})

if err
  fprintf('\nErr %i, err msg %s', err, errMsg);
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

function varargout = packetLogSettings_OpeningFcn(varargin)
global debugEnable
[err, errMsg, modName] = initErrModName(strcat(mfilename, '(packetLogSettings_OpeningFcn)'));

fid = fopen(strcat(mfilename,'_debug.txt'),'r');
if (fid > 0)
  debugEnable = 1;
  fclose(fid);
else
  debugEnable = 0;
end

figure1 = openfig(mfilename,'new');
% Use system color scheme for figure:
set(figure1,'Color',get(0,'defaultUicontrolBackgroundColor'));


% % %if the caller of this entire module is trying to set the properties....
% % if nargin
% %   set(figure1, varargin{:})
% % end
openTab = 'summary';
inOutpostPath = '';
if nargin
  for itemp = 1:size(varargin,2)
    a = char(varargin(itemp));
    b = findstrchr(':', a) + findstrchr('\\', a);
    if b
      inOutpostPath = a;
    else
      openTab = a;
    end
  end
end


% Generate a structure of handles to pass to callbacks, and store it. 
handles = guihandles(figure1);
fn = fieldnames(handles);

handles.codeVersion = 1.01;
[err, errMsg, handles.outpostNmNValues] = OutpostINItoScript(inOutpostPath); 
%if the user didn't give the fig a name in "guide", we'll default to the 
% name of this mfile.
a = get(figure1, 'name');
ni = findstr(a,'Untitled');
if ~isempty(ni)
  set(figure1,'name',sprintf('%s for Outpost in %s', mfilename, outpostValByName('DirOutpost', handles.outpostNmNValues)) );
end
guidata(figure1, handles);

[codeName, codeVersion, codeDetail] = getCodeVersion(handles);
fprintf('\r\nCode: %s, version %s %s', codeName, codeVersion, codeDetail);
fprintf('\r\nAccessing Outpost in %s', outpostValByName('DirOutpost', handles.outpostNmNValues));

fprintf('\r\n');
fprintf('\r\n*** you may minimize this window. Do NOT close ****');
fprintf('\r\n*** you may minimize this window. Do NOT close ****');
fprintf('\r\n*** To close: exit the window "%s" ****', get(figure1, 'name'));
fprintf('\r\n');

handles.lastMsg.select = 0;
handles.lastMsg.month = 0;
handles.lastMsg.day = 0;
handles.lastMsg.year = '';
handles.lastMsg.hr = '';
handles.lastMsg.min = '';

%flags set when the state of the related Master print/no print button is changed by the user
%  flag(s) indicate that a "Save" is required.  Cleared when save is performed or cancelled.
handles.printMasterPpr = 0;
handles.printMasterSent = 0;
handles.printMasterSentPpr = 0;
handles.printMasterRecvDelvrRecp = 0;
%flags set when the state of any checkbox in the category is changed by the user 
%  flag(s) indicate the related file with the list of copies needs to be written.  
%  Cleared when save is performed.
handles.printSentPpr = 0; %outTrayPaper_copies.txt: list of copies for outgoing messages that originated on paper
                          %  note this is not fully implemented because the Outpost side does not yet know the
                          %difference between a message which originated on paper versus one electronically.  The
                          %implement is complete here but the actual printing code will require update
handles.printSente = 0; %outTray_copies.txt: list of copies for outgoing messages that did not originate on paper.
handles.printRecv = 0; %inTray_copies.txt: list of copies for incoming messages other than delivery receipts
handles.printDelvrRecp = 0; %inTray_DelvrRecp.txt: list of copies  for incoming delivery receipts

handles = learnPaneNames(handles);

%if Outpost supports creating a local message number for incoming messages, the eLogger
% feature (pre-dates that by ~6 months) won't be used:
%Disable/hide & label UI elements as appropriate.
% (1) the Outpost message number may be used for only outgoing
%     or also incoming messages.  Both of the appropriate titles
%     are include in the GUI fig as editted by "guide".  We need
%     to only use the proper one.
tleMsgStr = get(handles.textSummTleMsgNo,'string');
if length(outpostValByName('LMIflag', handles.outpostNmNValues))
  %Outpost includes support for local message numbering
  b = char(tleMsgStr(2));
  a = 'Set via Outpost->Tools->Message Settings: Msg Numbering';
  set(handles.frameSumm2, 'ToolTip', a);
  set(handles.textSummTleRcvMsgNo, 'ToolTip', sprintf('%s, \nOutbound Message Indentification', a));
  set(handles.editSummRcvMsgNo, 'ToolTip',sprintf('%s, \nInbound Message Indentification (Local ID)\n\nOutpost preserves the sender''s message number when Incoming message numbering is enabled.', a));
  a = sprintf('The message number for outgoing messages and incoming messages');
  a = sprintf('%s\nare separately enabled but come from the same pool.', a);
  a = sprintf('%s\n\nOutpost preserves the sender''s message number when Incoming message numbering is enabled.', a);
else % if length(outpostValByName('LMIflag', handles.outpostNmNValues))
  b = char(tleMsgStr(1));
end % if length(outpostValByName('LMIflag', handles.outpostNmNValues)) else
c = findstrchr('!', b);
if c
  b = strtrim(b(1:c(1)-1));
end
set(handles.textSummTleMsgNo,'string', {b});
tt = get(handles.textSummTleMsgNo,'ToolTip');
set(handles.textSummTleMsgNo,'ToolTip', sprintf('%s\n%s',char(tt), a));
tt = get(handles.editSummMsgNo,'ToolTip');
set(handles.editSummMsgNo,'ToolTip', sprintf('%s\n%s',char(tt), a));


switch lower(openTab)
case 'summary'
  set(handles.tbSummPane,'value',1);
  tbSummPane_Callback(handles.tbSummPane, [], handles, []);
case 'logprint'
  set(handles.tbLogPrtPane,'value',1);
  tbLogPrintPane_Callback(handles.tbLogPrtPane, [], handles, []);
otherwise
  %want to open with the summary pane
  set(handles.tbSummPane,'value',1);
  tbSummPane_Callback(handles.tbSummPane, [], handles, []);
end
%place all the user controls nicely - need to be in accessible locations
%  on the edit window which isn't suitable for use.
initPlacement(handles);


[incidentName, incidentDate] = readIncidentName(outpostValByName('DirScripts', handles.outpostNmNValues)) ;
set(handles.editIncidentName, 'string', incidentName);
set(handles.radiobNewMsgIncidentNameDate, 'string', incidentDate);

handles.findNewOutpostMsgsINI = strcat(outpostValByName('DirAddOns', handles.outpostNmNValues), 'findNewOutpostMsgs.ini');
handles.newestTxtPathNameEx = strcat(outpostValByName('DirAddOnsPrgms', handles.outpostNmNValues), 'findNewOutpostMsgs_newest.txt');

fillDays(handles);
set(handles.figure1,'visible','on');

a = sprintf('A copy of the log will be maintained in each of the locations listed.\n');
a = sprintf('%s\nThe copy(ies) are updated whenever the log itself is updated.  If the location\n', a);
a = sprintf('%sis a removable drive, the copy is also updated when the drive is inserted.\n', a);
a = sprintf('%sSimilar behavior occurs for a location on a network.\n', a);
a = sprintf('%s\nCopies of all messages will be maintained in directories underneath each location below\n', a);
a = sprintf('%sMessages that have been sent will copied to "..\\<log name>_SentTray\\"\n', a);
a = sprintf('%sMessages that have received will copied "..\\<log name>_InTray\\" \n', a);
a = sprintf('%s\nThe location(s) you list for the log copies must exist - the program will not create them.\n', a);
a = sprintf('%sHowever, the program will create the sub-directories for the message copies.\n', a);
a = sprintf('%s\nIf a particular path isn''t found when a log is being updated, the program will skip\n', a);
a = sprintf('%sthat path and continue.  This could occur if the path is to a removable drive and that\n', a);
a = sprintf('%sdrive has been removed.  Note that once the drive (path) re-appears, the most up-to-date\n', a);
a = sprintf('%slogs will be copied to that drive, over writing any logs there. Similar behavior for\n', a);
a = sprintf('%snetworked locations\n', a);

%a = sprintf('%s\n', a);

set(handles.listboxBackupLocal,'ToolTip', a);
set(handles.listboxBackupLocal,'String', {});
set(handles.listboxBackupRemote,'ToolTip', a);
set(handles.listboxBackupRemote,'String', {});

set(handles.listboxTACAlias_0,'String', {});

%set units to pixels so UIs will not change their size
% adjust the background color of everything other than Edit and Listboxes to same as figure1
for itemp = 1:length(fn)
  if ~findstrchr('figure1', char(fn(itemp)) )
    set(getfield(handles, char(fn(itemp))), 'Units', 'pixels') ;
    ty = get(getfield(handles, char(fn(itemp))), 'Style') ;
    if (~findstrchr('edit', ty) & ~findstrchr('listbox', ty) )
      set(getfield(handles, char(fn(itemp))), 'BackgroundColor', get(0,'defaultUicontrolBackgroundColor') )
    end
  end 
end % for itemp = 1:length(fn);

set(handles.figure1,'Position', [111.80000000000001 26.23076923076924 158.0 47.53846153846154]);

movegui(figure1,'onscreen');

%set units to normalized to size will track anything user does to the size
for itemp = 1:length(fn)
  if ~findstrchr('figure1', char(fn(itemp)) )
    set(getfield(handles, char(fn(itemp))), 'Units', 'normalized') ;
  end 
end % for itemp = 1:length(fn);


guidata(figure1, handles);
varargout{3} = figure1;
varargout{1} = err;
varargout{2} = strcat(modName, errMsg);
%----------------- packetLogSettings_OpeningFcn -------------------
% --------------------------------------------------------------------
function [codeName, codeVersion, codeDetail] = getCodeVersion(handles);
codeName = get(handles.figure1,'Name');
try
[codeVersion, codeDetail] = about_packetLogSettings_private;
catch
  codeVersion = 0;
  codeDetail = '';
end

if ~codeVersion
  codeVersion = handles.codeVersion;
end
codeVersion = num2str(digRound(codeVersion, 12));
%pull the name 
b = ' created ';
a = findstrchr(b, lower(codeDetail));
if a
  codeDetail = strtrim(codeDetail(a(1):length(codeDetail)));
end
%#IFDEF debugOnly  
% actions in IDE only
a = dir(strcat(mfilename,'.m'));
codeDetail = sprintf('%s \n(running %s.m file: %s)', codeDetail, mfilename, a(1).date);
userCancel = 1;
%#ENDIF
codeDetail = sprintf('%s \n\nCopyright 2009-2010 Andy Rose  KI6SEP\nAll rights reserved.', codeDetail);

% --------------------------------------------------------------------
function varargout = listboxBackupLocal_Callback(h, eventdata, handles, varargin)
%set appropriate visibility for buttons
val = get(handles.listboxBackupLocal,'value');
cl = get(handles.listboxBackupLocal,'string');
if length(cl)
  set(handles.pbBULclDelete, 'visible','on');
  if (findstrchr('(disabled)', char(cl(val))) == 1)
    set(handles.pbBULclEnable, 'visible','on');
    set(handles.pbBULclDisable, 'visible','off');
  else
    set(handles.pbBULclEnable, 'visible','off');
    set(handles.pbBULclDisable, 'visible','on');
  end
else % if length(cl)
  set(handles.pbBULclEnable, 'visible','off');
  set(handles.pbBULclDisable, 'visible','off');
  set(handles.pbBULclDelete, 'visible','off');
end % if length(cl) else
% --------------------------------------------------------------------
function BUenable(h, thisPaneKey, handles)
%used by pbBULclEnable_Callback & pbBURmtEnable_Callback
val = get(h,'value');
cl = get(h,'string');
if length(cl)
  key = '(disabled)';
  textLine = strtrim(char(cl(val)));
  if (findstrchr(key, textLine) == 1)
    cl(val) = {strtrim(textLine(1+length(key):length(textLine)))};
    set(h,'string',cl)
    setUpdated(thisPaneKey, handles)
  end
end
% --------------------------------------------------------------------
function BUdisable(h, thisPaneKey, handles)
%used by pbBULclEnable_Callback & pbBURmtEnable_Callback
val = get(h,'value');
cl = get(h,'string');
if length(cl)
  key = '(disabled)';
  textLine = strtrim(char(cl(val)));
  if (findstrchr(key, textLine) ~= 1)
    cl(val) = {sprintf('%s %s', key, textLine)};
    set(h,'string',cl)
    setUpdated(thisPaneKey, handles)
  end
end
% --------------------------------------------------------------------
function varargout = pbBULclEnable_Callback(h, eventdata, handles, varargin)
BUenable(handles.listboxBackupLocal,'BULcl', handles)
listboxBackupLocal_Callback(handles.listboxBackupLocal, [], handles, [])
% --------------------------------------------------------------------
function varargout = pbBULclDisable_Callback(h, eventdata, handles, varargin)
BUdisable(handles.listboxBackupLocal,'BULcl', handles)
listboxBackupLocal_Callback(handles.listboxBackupLocal, [], handles, [])
% --------------------------------------------------------------------
function varargout = pbBURmtEnable_Callback(h, eventdata, handles, varargin)
BUenable(handles.listboxBackupRemote,'BURmt', handles)
listboxBackupRemote_Callback(handles.listboxBackupRemote, [], handles, [])
% --------------------------------------------------------------------
function varargout = pbBURmtDisable_Callback(h, eventdata, handles, varargin)
BUdisable(handles.listboxBackupRemote,'BURmt', handles)
listboxBackupRemote_Callback(handles.listboxBackupRemote, [], handles, [])
% --------------------------------------------------------------------
function varargout = listboxBackupRemote_Callback(h, eventdata, handles, varargin)
%set appropriate visibility for buttons
val = get(handles.listboxBackupRemote,'value');
cl = get(handles.listboxBackupRemote,'string');
if length(cl)
  set(handles.pbBURmtDelete, 'visible','on');
  if (findstrchr('(disabled)', char(cl(val))) == 1)
    set(handles.pbBURmtEnable, 'visible','on');
    set(handles.pbBURmtDisable, 'visible','off');
  else
    set(handles.pbBURmtEnable, 'visible','off');
    set(handles.pbBURmtDisable, 'visible','on');
  end
else % if length(cl)
  set(handles.pbBURmtEnable, 'visible','off');
  set(handles.pbBURmtDisable, 'visible','off');
  set(handles.pbBURmtDelete, 'visible','off');
end %if length(cl) else
% --------------------------------------------------------------------
function varargout = tbBackupPane_Callback(h, eventdata, handles, varargin)
val = get(h, 'val');
if ~val
  %user is not allowed to turn it off (redundant - control is made inactive below
  set(h, 'val',1);
else
  set(h, 'enable','inactive');
  % Make sure both types of lists of copy location exist even if empty:
  %   if they don't exist, these calls will cause them to be created & they will include usage instructions 
  %List for this computer
  [err, errMsg, pathsTologCopies, logPathsDisabled] = readProcessOPM_Logs(outpostValByName('DirAddOns', handles.outpostNmNValues));
  if ~err
    set(handles.listboxBackupLocal,'String',[pathsTologCopies, logPathsDisabled]);
  end
  %List when monitoring a remote computer:
  [err, errMsg, pathsTologCopies, logPathsDisabled] = readProcessOPM_Logs(outpostValByName('DirAddOns', handles.outpostNmNValues),...
    'network_PkLgMonitor_logs.ini','This file is used by "displayCounts" when monitoring a Packet Log on a network.');
  if ~err
    set(handles.listboxBackupRemote,'String', [pathsTologCopies, logPathsDisabled]);
  end
  handles = alterPaneState(handles, 'off');
  handles = alterPaneState(handles, {'BURmt','BULcl','Backup'}, 'on', h);
  listboxBackupLocal_Callback(handles.listboxBackupLocal, [], handles, []);
  listboxBackupRemote_Callback(handles.listboxBackupRemote, [], handles, []);
end
% --------------------------------------------------------------------
function varargout = tbNewMsgPane_Callback(h, eventdata, handles, varargin)
val = get(h, 'val');
if ~val
  %user is not allowed to turn it off
  set(h, 'val',1);
else %if ~val
  set(h, 'enable','inactive');
  handles = alterPaneState(handles, 'off');
  handles = alterPaneState(handles, {'NewMsg'}, 'on', h);
  [err, errMsg, startTimeOption, handles.dateTime] = readfindNewOutpostMsgs_INI(handles.findNewOutpostMsgsINI, handles.newestTxtPathNameEx);
  handles.nMstartTimeOption = [handles.radiobNewMsgToday, handles.radiobNewMsgIncidentChange, ...
      handles.radiobNewMsgCurrentSession, handles.radiobNewMsgSince, handles.radiobNewMsgAll];
  if (startTimeOption < 1 ) | (startTimeOption > length(handles.nMstartTimeOption))
    h_Obj = handles.radiobNewMsgToday;
    errordlg(sprintf('Unknown start time option of %i - setting to default.', startTimeOption))
  else
    h_Obj = handles.nMstartTimeOption(startTimeOption);
  end
  if h_Obj
    if (h_Obj == handles.radiobNewMsgSince)
      radiobNewMsgSince_Callback(h_Obj, [], handles, [])
    else
      cfgNewMsgRadioButtons(handles,h_Obj);
    end
    [Y,M,D,H,MI,S] = datevec(datenum(handles.dateTime));
    set(handles.popupNewMsgMnth,'Value',M);
    set(handles.popupNewMsgDa,'Value',D);
    set(handles.popupNewMsgYear,'String',sprintf('%i', Y));
    mnt = sprintf('%i', MI);
    if length(mnt) < 2
      mnt = sprintf('0%i', mnt);
    end
    hr = sprintf('%i', H);
    if length(hr) < 2
      hr = sprintf('0%i', hr);
    end
    set(handles.editNewMsgTime,'String', sprintf('%s%s', hr, mnt))
    %initialize/update the exisiting settings.  If the user changes any, flag will be set
    handles.lastMsg.select = h_Obj;
    handles.lastMsg.month = M;
    handles.lastMsg.day = D;
    handles.lastMsg.year = Y;
    handles.lastMsg.hr = hr;
    handles.lastMsg.min = mnt;
  end %if h_Obj
  handles.startTime = setLogStartTime(find(handles.nMstartTimeOption == handles.lastMsg.select), handles.dateTime, ...
    outpostValByName('DirScripts', handles.outpostNmNValues), outpostValByName('DirOutpost', handles.outpostNmNValues));
  handles = readNDispFindMsgLst(handles);
  guidata(handles.figure1, handles);
end % if ~val else
% --------------------------------------------------------------------
function varargout = tbPrintingPane_Callback(h, eventdata, handles, varargin)
val = get(h, 'val');
if ~val
  %user is not allowed to turn it off
  set(h, 'val',1);
else %if ~val
  set(h, 'enable','inactive');
  handles = alterPaneState(handles, 'off');
  [outCopies, err, errMsg] = readRecipients(strcat(outpostValByName('DirAddOns', handles.outpostNmNValues),'outTray_copies.txt'));
  configPrintCopyCB(outCopies, handles.cbPrintRadioSente, handles.cbPrintPlanningSente, handles.cbPrintOriginatorSente)
  
  [outCopiesPpr, err, errMsg] = readRecipients(strcat(outpostValByName('DirAddOns', handles.outpostNmNValues),'outTrayPaper_copies.txt'));
  configPrintCopyCB(outCopiesPpr, handles.cbPrintRadioSentPpr, handles.cbPrintPlanningSentPpr, handles.cbPrintOriginatorSentPpr)
  
  [inCopies, err, errMsg] = readRecipients(strcat(outpostValByName('DirAddOns', handles.outpostNmNValues),'inTray_copies.txt'));
  configPrintCopyCB(inCopies, handles.cbPrintRadioRecv, handles.cbPrintPlanningRecv, handles.cbPrintAddresseeRecv)
  
  [inCopiesDelvrRecp, err, errMsg] = readRecipients(strcat(outpostValByName('DirAddOns', handles.outpostNmNValues),'inTray_DelvrRecp.txt'));
  configPrintCopyCB(inCopiesDelvrRecp, handles.cbPrintRadioDelvrRecp, handles.cbPrintPlanningDelvrRecp, handles.cbPrintAddresseeDelvrRecp)
  
  % the globals
  [err, errMsg, printer] = readProcessOPM_INI(outpostValByName('DirAddOns', handles.outpostNmNValues));
  % the form specific - currently being applied to all forms . . 
  [err, errMsg, printEnableRec, printEnableSent, printEnableDelvrRecp, ...
      copies4recv, copies4sent, copies4sentFromPaper, copies4DelvrRecp, HPL3] = ...
    readPrintICS_213INI(outpostValByName('DirAddOns', handles.outpostNmNValues), 0);
  
  printEnableRec = printer.printEnable * (printEnableRec>0) ;
  printEnableSent = printer.printEnable * (printEnableSent>0) ;
  printEnableDelvrRecp = printer.printEnable * (printEnableDelvrRecp>0) ;
  set(handles.tbPrintMasterSentPpr, 'value', (printEnableSent>0));
  set(handles.tbPrintMasterSent, 'value', (printEnableSent>0));
  set(handles.tbPrintMasterRecv, 'value', (printEnableRec>0));
  set(handles.tbPrintMasterRecvDelvrRecp, 'value', (printEnableDelvrRecp>0));
  
  handles.printRecv = 0;
  handles.printSentPpr = 0;
  handles.printSente = 0; 
  handles.printDelvrRecp = 0 ;
  
  handles = alterPaneState(handles,{'Print'}, 'on', h);
  %pass 4th input to disabled the Save tags  
  tbPrintMasterRecv_Callback(handles.tbPrintMasterRecv, [], handles, 1)
  tbPrintMasterSent_Callback(handles.tbPrintMasterSent, [], handles, 1)
  tbPrintMasterSentPpr_Callback(handles.tbPrintMasterSentPpr, [], handles, 1)
  tbPrintMasterRecvDelvrRecp_Callback(handles.tbPrintMasterRecvDelvrRecp, [], handles, 1)
end %if ~val else
% --------------------------------------------------------------------
function varargout = tbLogPrintPane_Callback(h, eventdata, handles, varargin)
val = get(h, 'val');
set(h, 'enable','inactive');
handles = alterPaneState(handles, 'off');
[err, errMsg, logPrtEnable, handles.logPrt_minuteInterval, handles.logPrt_mnmToPrt, handles.logPrt_msgNums]...
  = readLogPrintINI(outpostValByName('DirAddOns', handles.outpostNmNValues));
set(handles.cbLogPrtEnable_0, 'value', logPrtEnable);
set(handles.editLogPrt_minuteInterval, 'value', handles.logPrt_minuteInterval);
set(handles.editLogPrt_mnmToPrt, 'value', handles.logPrt_mnmToPrt);
set(handles.editLogPrt_msgNums, 'value', handles.logPrt_msgNums);

cbLogPrintEnable_Callback(handles.cbLogPrtEnable_0, [], handles, [])

handles = alterPaneState(handles, {'LogPrt'}, 'on', h);
% --------------------------------------------------------------------
function varargout = tbSummPane_Callback(h, eventdata, handles, varargin)
val = get(h, 'val');
if ~val
  %user is not allowed to turn it off
  set(h, 'val',1);
else
  set(h, 'enable','inactive');
  handles = alterPaneState(handles, 'off');
  handles = alterPaneState(handles,{'Summ'},'on', h);
  summStatus(handles);
end
% --------------------------------------------------------------------
function varargout = editIncidentName_Callback(h, eventdata, handles, varargin)
[err, errMsg, incidentDate] = writeIncidentName(get(h, 'string'), outpostValByName('DirScripts', handles.outpostNmNValues)) ;
if err
  errordlg(errMsg);
end
set(handles.radiobNewMsgIncidentNameDate, 'string', incidentDate);

% --------------------------------------------------------------------
function varargout = popupNewMsgDa_Callback(h, eventdata, handles, varargin)
val = get(h,'value');
%change?
if (val ~= handles.lastMsg.day)
  handles.lastMsg.day = val;
  updateNewMsg(handles);
end
% --------------------------------------------------------------------
function varargout = popupNewMsgMnth_Callback(h, eventdata, handles, varargin)
%month has changed - update list of available days as needed
fillDays(handles);
val = get(h,'value');
%change in month?
if (val ~= handles.lastMsg.month)
  handles.lastMsg.month = val;
  %just in case user HAD last day of month & new month is shorter
  handles.lastMsg.day = get(handles.popupNewMsgDa,'value');
  updateNewMsg(handles);
end

% --------------------------------------------------------------------
function varargout = popupNewMsgYear_Callback(h, eventdata, handles, varargin)
%Supports various formats of years: 
%  * at least 2 digits & no more than 4
%  * if 3 or 3 digits, will be fluffed out to 4 presumming current year
%  * display will updated as needed

yr = get(h, 'string');
numsAt = find(ismember(yr,'0123456789'));
yr = yr(numsAt);
if (length(yr) > 4) | (length(yr) < 2)
  errordlg('Invalid year');
elseif (length(yr) < 4) % if (length(yr) > 4) | (length(yr) < 2)
  [Y, M] = datevec(now);
  y = sprintf('%i', Y);
  yr = strcat(y(1:(4-length(yr))), yr);
end %elseif (length(yr) < 4) % if (length(yr) > 4) | (length(yr) < 2)
set(h, 'string', yr);

fillDays(handles);
%change in year?
if (~strcmp(yr, handles.lastMsg.year))
  handles.lastMsg.year = yr;
  %just in case user HAD last day of month & new month is shorter
  handles.lastMsg.day = get(handles.popupNewMsgDa,'value');
  updateNewMsg(handles);
end
% --------------------------------------------------------------------
function fillDays(handles);
%fills the list of days-of-month with the appropriate #s
yr = str2num(get(handles.popupNewMsgYear, 'string'));

%last day of the month
endOfMonth = eomday(yr, get(handles.popupNewMsgMnth,'value'));

%check the list of days available to the user & if needed
% adjust for current month and year
days = length(get(handles.popupNewMsgDa,'string'));
if (days ~= endOfMonth)
  a = get(handles.popupNewMsgDa,'string');
  if (days > endOfMonth)
    set(handles.popupNewMsgDa,'string', a(1:endOfMonth));
  else %if days < endOfMonth
    for itemp = days+1:endOfMonth
      %two digits per day - add leading 0 as needed
      if itemp < 10
        b = '0';
      else
        b = '';
      end
      a(itemp) = {sprintf('%s%i', b, itemp)};
    end
    set(handles.popupNewMsgDa,'string', a);
  end % if days < endOfMonth else
end %if (days ~= endOfMonth)
%check the user's selection and make sure not beyond the end of the month of the year
%  if previous selection is now beyond end of this month, set to last available day
da = get(handles.popupNewMsgDa,'value');
if (da > endOfMonth)
  set(handles.popupNewMsgDa,'value', endOfMonth);
end

% --------------------------------------------------------------------
function varargout = pbBULclEnter_Callback(h, eventdata, handles, varargin)
enterPath('local', handles.listboxBackupLocal, 'BULcl', handles);
listboxBackupLocal_Callback(handles.listboxBackupLocal, [], handles, [])
% --------------------------------------------------------------------
function enterPath(whichSource, h_listBox, thisPaneKey, handles);
prompt  = {sprintf('Enter full path to the location for storing backup\n copies of the %s log & messages', whichSource)};
title   = sprintf('%s log backup location.', whichSource);
lines= 1;
def     = {''};
answer  = inputdlg(prompt,title,lines,def);
if length(char(answer))
  cl = get(h_listBox,'String');
  val = length(cl)+1;
  cl(val) = answer;
  set(h_listBox,'String', cl);
  set(h_listBox,'value', val);
  setUpdated(thisPaneKey, handles)
end
% --------------------------------------------------------------------
function varargout = pbBULclBrowseLocation_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = pbBULclDelete_Callback(h, eventdata, handles, varargin)
[cl] = confirmDelete(handles.listboxBackupLocal, 'BULcl', handles,'Backup Location');
listboxBackupLocal_Callback(handles.listboxBackupLocal, [], handles, [])
% --------------------------------------------------------------------
function varargout = pbBURmtEnter_Callback(h, eventdata, handles, varargin)
enterPath('remote', handles.listboxBackupRemote, 'BURmt', handles);
listboxBackupRemote_Callback(handles.listboxBackupRemote, [], handles, [])
% --------------------------------------------------------------------
function varargout = pbBURmtBrowseLocation_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = pbBURmtDelete_Callback(h, eventdata, handles, varargin)
[cl] = confirmDelete(handles.listboxBackupRemote, 'BURmt', handles,'Backup Location');
listboxBackupRemote_Callback(handles.listboxBackupRemote, [], handles, [])
% --------------------------------------------------------------------
function varargout = radiobNewMsgToday_Callback(h_Obj, eventdata, handles, varargin)
cfgNewMsgRadioButtons(handles,h_Obj)
% --------------------------------------------------------------------
function varargout = radiobNewMsgAll_Callback(h_Obj, eventdata, handles, varargin)
cfgNewMsgRadioButtons(handles,h_Obj)
% --------------------------------------------------------------------
function varargout = radiobNewMsgReset_Callback(h_Obj, eventdata, handles, varargin)
% check if the history file exists.
[handles] = readNDispFindMsgLst(handles);
if handles.latesTmRead
  a = sprintf('You have chosen to start the extended log at an earlier time.');
  a = sprintf('%s  The new start time covers a perion of time that has been previously logged.', a);
  a = sprintf('%s  This will likely result in messages being logged a second time.', a);
  a = sprintf('%s\n\nPrevious log ended at %s\nCurrent selection: %s', a, datestr(handles.latestTime), datestr(handles.startTime) );
  % % a = sprintf('Confirm that you want to reset the start of the log from %s.', datestr(handles.latestTime))
  button = questdlg(sprintf('%s', a),'Confirm Log Start','Yes','No','No');
  if strcmp(button,'Yes')
    deleteIfExist(handles.newestTxtPathNameEx);
    [pathstr,name,ext,versn] = fileparts(handles.newestTxtPathNameEx);
    pathstr = endWithBackSlash(pathstr);
    deleteIfExist(strcat(pathstr, 'findNewOutpostMsgs_newestLast.txt'));
    deleteIfExist(strcat(pathstr, 'findNewOutpostMsgs.mat'));
    deleteIfExist(strcat(pathstr, 'findNewOutpostMsgsLast.mat'));
  end
  %update
  [handles] = readNDispFindMsgLst(handles);
end % if handles.latesTmRead
% --------------------------------------------------------------------
function deleteIfExist(fPName)
fid = fopen(fPName);
if fid > 0
  fclose(fid);
  delete(fPName)
end

% --------------------------------------------------------------------
function varargout = radiobNewMsgIncidentChange_Callback(h_Obj, eventdata, handles, varargin)
cfgNewMsgRadioButtons(handles,h_Obj)
% --------------------------------------------------------------------
function varargout = radiobNewMsgCurrentSession_Callback(h_Obj, eventdata, handles, varargin)
cfgNewMsgRadioButtons(handles,h_Obj)
% --------------------------------------------------------------------
function varargout = radiobNewMsgSince_Callback(h_Obj, eventdata, handles, varargin)
cfgNewMsgRadioButtons(handles,h_Obj)
set(handles.popupNewMsgDa,'enable','on', 'BackgroundColor', [1 1 1]);
set(handles.popupNewMsgMnth,'enable','on', 'BackgroundColor', [1 1 1]);
set(handles.popupNewMsgYear,'enable','on', 'BackgroundColor', [1 1 1]);
set(handles.editNewMsgTime,'enable','on', 'BackgroundColor', [1 1 1]);
% --------------------------------------------------------------------
function cfgNewMsgRadioButtons(handles, h_Obj)
%clear all buttons, enable all buttons
%grey out the date/time/year fields - if they are used, they need to be enabled
%  in the routine that detects the enabling radio button is pushed
%set the button the user pushed & prevent user from unchecking it
val = get(h_Obj, 'val');
if ~val
  %user is not allowed to turn it off
  set(h_Obj, 'val',1);
else
  set(handles.radiobNewMsgToday,'value',0,'enable','on');
  set(handles.radiobNewMsgIncidentChange,'value',0,'enable','on');
  set(handles.radiobNewMsgCurrentSession,'value',0,'enable','on');
  set(handles.radiobNewMsgSince,'value',0,'enable','on');
  set(handles.radiobNewMsgAll,'value',0,'enable','on');
  
  colr = get(handles.figure1, 'Color');
  set(handles.popupNewMsgDa,'enable','off', 'BackgroundColor', colr);
  set(handles.popupNewMsgMnth,'enable','off', 'BackgroundColor', colr);
  set(handles.popupNewMsgYear,'enable','off', 'BackgroundColor', colr);
  set(handles.editNewMsgTime,'enable','off', 'BackgroundColor', colr);
  %config so user cannot turn it off
  set(h_Obj, 'enable','inactive');
  %restore the set state
  set(h_Obj, 'val',1);
  if (handles.lastMsg.select ~= h_Obj)
    handles.lastMsg.select = h_Obj;
    updateNewMsg(handles);
  end
end
% --------------------------------------------------------------------
function handles = alterPaneState(handles, paneList, vis, h_On);
if nargin < 3
  vis = paneList;
  paneList = handles.paneNames;
  if any(handles.paneUpdated)
    handles = userSaveAbandon(handles);
  end
else
  %code flow calls 0 for all pane selection buttons and then
  % we call which one is to be on: need to push it again
  set(h_On, 'Value', 1);
  a = find(handles.paneHandle == h_On);
  if a
    %clear Updated flag in case opening the pane
    %  called any callbacks which menas the user didn't make the change
    handles.paneUpdated(a) = 0;
    if ~any(handles.paneUpdated)
      set(handles.togglebuttonSave,'visible','off');
    end
    guidata(handles.figure1, handles);
  end
end

fn = fieldnames(handles);
for fieldNdx = 1:length(fn)
  %get the name of a variable in the structure "logged"
  thisField = char(fn(fieldNdx));
  %if this item is on the pane of interest...
  for paneNdx = 1:length(paneList)
    thisPane = char(paneList(paneNdx));
    if findstrchr(thisPane, thisField)
      %don't hide the pane selection button...
      a = findstrchr('Pane', thisField);
      % pane selection buttons end with "Pane" & begin with "tb"
      if ( ((a(1) + 3) == length(thisField)) & (1 == findstrchr('tb', thisField)) )
        %... but pane selection button needs to re-enabled to respond to user & released
        if findstrchr('off', vis)
          set(getfield(handles,thisField), 'enable','on','val',0);
        end % if findstrchr('off', vis)
      else % if ( ((a(1) + 3) == length(thisField)) & (1 == findstrchr('tb', thisField)) )
        %.. not pane selection button: make it visible!
        set(getfield(handles,thisField), 'visible', vis);
      end % if ( ((a(1) + 3) == length(thisField)) & (1 == findstrchr('tb', thisField)) ) else
    end % if findstrchr(thisPane, thisField)
  end %for paneNdx = 1:length(paneList)
end %for fieldNdx = 1:length(fn)

% --------------------------------------------------------------------
function initPlacement(handles)
%for each Pane, find the uicontrol we want in the top left position
% (has '_0' in its tag).  Determine that elements X & Y offset from
% our master reference item, radiobNewMsgToday.  Move all elements
% for that pane by that X & Y offset

paneList = handles.paneNames;
pane_0_FoundLeft(1:length(paneList)) = 0;
pane_0_FoundTop = pane_0_FoundLeft;
fn = fieldnames(handles);
for fieldNdx = 1:length(fn)
  %get the name 
  thisField = char(fn(fieldNdx));
  %if this item is on the pane of interest...
  for paneNdx = 1:length(paneList)
    thisPane = char(paneList(paneNdx));
    if findstrchr(thisPane, thisField)
      %don't consider the Pane selection button & look for the reference postion item (_0)
      if ~findstrchr('Pane', thisField) & findstrchr('_0', thisField)
        posit = get(getfield(handles,thisField), 'Position');
        pane_0_FoundLeft(paneNdx) = posit(1);
        pane_0_FoundTop(paneNdx) = posit(2) + posit(4);
        break
      end % if ~findstrchr('Pane', thisField) 
    end % if findstrchr(thisPane, thisField)
  end %for paneNdx = 1:length(paneList)
end %for fieldNdx = 1:length(fn)

%now position the panes
% a) which panes are using this'_0' alignment feature?
a = find(pane_0_FoundLeft);
% b) eliminate all unused array elements
paneList = paneList(a);
pane_0_FoundLeft = pane_0_FoundLeft(a);
pane_0_FoundTop = pane_0_FoundTop(a);
% c) get our reference's position
posit_0 = get(handles.radiobNewMsgToday, 'Position');
%calculate the motion needed
for paneNdx = 1:length(paneList)
  pane_0_FoundLeft(paneNdx) = pane_0_FoundLeft(paneNdx) - posit_0(1);
  pane_0_FoundTop(paneNdx) = pane_0_FoundTop(paneNdx) - (posit_0(2) + posit_0(4));
end %for paneNdx = 1:length(paneList)

%find & move 'em
for fieldNdx = 1:length(fn)
  %get the name of a variable in the structure "logged"
  thisField = char(fn(fieldNdx));
  %if this item is on the pane of interest...
  for paneNdx = 1:length(paneList)
    thisPane = char(paneList(paneNdx));
    if findstrLen(thisPane, thisField) 
      %       if findstrchr(thisField, 'LogPrt')
      %         fprintf('\n%s %s', thisPane, thisField);
      %       end
      %don't consider the Pane selection button & look for the reference postion item (_0)
      if ~findstrchr('Pane', thisField) 
        a = getfield(handles,thisField);
        posit = get(a, 'Position');
        set(a, 'Position', [posit(1)-pane_0_FoundLeft(paneNdx), posit(2)-pane_0_FoundTop(paneNdx), posit(3), posit(4)])
      end % if ~findstrchr('Pane', thisField) else
    end % if findstrchr(thisPane, thisField)
  end %for paneNdx = 1:length(paneList)
end %for fieldNdx = 1:length(fn)

%special cases:
positMain = get(handles.frame1, 'Position');
posit = get(handles.frameSumm1, 'Position');
%set l&r to be the same as the main frame
posit(1) = positMain(1);
posit(3) = positMain(3);
%do not move bottom but make top same
%top = bottom + height
posit(4) = positMain(4) + positMain(2) - posit(2);
set(handles.frameSumm1, 'Position', posit);

posit = get(handles.frameSumm2, 'Position');
%set left be the same as the main frame & r to not move
posit(3) = posit(3) + posit(1) - positMain(1);
posit(1) = positMain(1);
set(handles.frameSumm2, 'Position', posit);

posit = get(handles.frameSumm3, 'Position');
%set l&r to be the same as the main frame
posit(1) = positMain(1);
posit(3) = positMain(3);
%keep top's location but move bottom
posit(4) = posit(4) + posit(2) - positMain(2);
posit(2) = positMain(2);
set(handles.frameSumm3, 'Position', posit);

% --------------------------------------------------------------------
function summStatus(handles);
%refresh the status from Outpost
[err, errMsg, handles.outpostNmNValues] = OutpostINItoScript(outpostValByName('DirOutpost', handles.outpostNmNValues)); 
guidata(handles.figure1, handles);
%current settings
opCall = outpostValByName('StationID', handles.outpostNmNValues);
opName = outpostValByName('NameID', handles.outpostNmNValues);
set(handles.editSummOpName, 'string', opName);
set(handles.editSummOpCall, 'string', opCall);

tacCall = outpostValByName('TacticalCall', handles.outpostNmNValues);
% tactical enable (1) / disabled (0)
TCnPEnabled = outpostValByName('TCnPEnabled', handles.outpostNmNValues);
if strcmp(TCnPEnabled,'1')
  a = 'enabled';
else
  a = 'disabled';
end
set(handles.editSummTacCall, 'string',sprintf('%s (%s)', tacCall, a));

TacID = outpostValByName('TacID', handles.outpostNmNValues);
set(handles.editSummTacID, 'string', TacID);

NxtMsgNo = outpostValByName('ReportMsgNo', handles.outpostNmNValues);
set(handles.editSummMsgNo, 'string', NxtMsgNo);
set(handles.textSummMsgNoTac, 'string', TacID);
LMIflag = outpostValByName('LMIflag', handles.outpostNmNValues);
if length(LMIflag)
  %Outpost supports Local Message Numbers - hide eLogger's support
  set([handles.textSummRcvMsgNoTac], 'visible','off')
  if (1 == outpostValByName('AutoMsgNum', handles.outpostNmNValues))
    set(handles.textSummTleRcvMsgNo, 'string','Outgoing #: Enabled')
  else %if (1 == outpostValByName('AutoMsgNum', handles.outpostNmNValues))
    set(handles.textSummTleRcvMsgNo, 'string','Outgoing #: Disabled')
  end % if (1 == outpostValByName('AutoMsgNum', handles.outpostNmNValues)) else
  a = get(handles.textSummTleRcvMsgNo, 'Position');
  b = get(handles.editSummRcvMsgNo, 'Position');
  if (LMIflag)
    set(handles.editSummRcvMsgNo, 'string','Incoming #: Enabled','Style','text')
  else % if (LMIflag)
    set(handles.editSummRcvMsgNo, 'string','Incoming #: Disabled','Style','text')
  end % if (LMIflag)else
  set(handles.editSummRcvMsgNo, 'Position', [b(1) a(2) b(3) a(4)])
else % if length(LMIflag)
  cnt = readRecvMsgNum(handles.outpostNmNValues);
  if (1 == outpostValByName('AutoMsgNum', handles.outpostNmNValues))
    set(handles.editSummRcvMsgNo, 'string', sprintf('%i', cnt));
  else %if (1 == outpostValByName('AutoMsgNum', handles.outpostNmNValues))
    set(handles.editSummRcvMsgNo, 'string', sprintf('%i (disabled)', cnt));
  end %if (1 == outpostValByName('AutoMsgNum', handles.outpostNmNValues)) else
  set(handles.textSummRcvMsgNoTac, 'string', TacID);
end % if length(LMIflag) else

% TCwPEnabled = outpostValByName('TCwPEnabled', handles.outpostNmNValues);

Org = outpostValByName('Org', handles.outpostNmNValues);
set(handles.editSummOrgan, 'string', Org);

City = outpostValByName('City', handles.outpostNmNValues);
set(handles.editSummCity, 'string', City);

County = outpostValByName('County', handles.outpostNmNValues);
set(handles.editSummCounty, 'string', County);

State = outpostValByName('State', handles.outpostNmNValues);
set(handles.editSummState, 'string', State);

TacLoc = outpostValByName('TacLoc', handles.outpostNmNValues);
set(handles.editSummLoc, 'string', TacLoc);

% --------------------------------------------------------------------
function varargout = editSummLoc_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = editSummRcvMsgNo_Callback(h, eventdata, handles, varargin)
[err, errMsg] = writeRecvMsgNum(str2num(get(h,'string')), handles.outpostNmNValues);
if err
  errordlg(errMsg)
end
% --------------------------------------------------------------------
function varargout = editNewMsgTime_Callback(h_Obj, eventdata, handles, varargin)
str = get(h_Obj,'string');
%convert am/pm to 24 hour & pull ":"
colonAt = findstrchr(':',str);
numsAt = find(ismember(str,'0123456789'));
if length(numsAt) > 4
  errordlg('Invalid time: only hours & minutes allowed - too many digits.')
  set(h_Obj,'string','');
  return
end
if length(numsAt) > 2
  hr = str2num(str(numsAt(1:(length(numsAt)-2))));
else
  hr = 0;
end
if (hr > 23) | (hr < 0)
  errordlg('Invalid hour.')
  set(h_Obj,'string','');
  return
end
if length(numsAt) > 1
  mn = str2num(str(numsAt(length(numsAt)+[-1,0])));
else
  mn = str2num(str(numsAt(1)));
end
if (mn > 59) | (mn < 0)
  errordlg('Invalid minute.')
  set(h_Obj,'string','');
  return
end
a = findstrchr('AM',upper(str));
if ~a
  a = findstrchr('PM',upper(str));
  if (a & (hr < 13))
    hr = hr + 12;
  end
end
m = sprintf('%i', mn);
if length(m) < 2
  m = sprintf('0%s', m);
end
h = sprintf('%i', hr);
if length(h) < 2
  h = sprintf('0%s', h);
end
set(h_Obj,'string',sprintf('%s%s', h, m));
if ~strcmp(handles.lastMsg.hr, h) | ~strcmp(handles.lastMsg.min, m)
  handles.lastMsg.hr = h;
  handles.lastMsg.min = m;
  updateNewMsg(handles);
end

% --------------------------------------------------------------------
function varargout = editSummMsgNo_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = listboxTACAlias_0_Callback(h, eventdata, handles, varargin)
val = get(h, 'val');
%if operator doubled-clicked....
if strcmp(get(handles.figure1,'SelectionType'),'open')
  %... open the editor
  pushbuttonTACAliasEdit_Callback(handles.pushbuttonTACAliasEdit, [], handles, [])
end
% --------------------------------------------------------------------
function varargout = tbTACAliasPane_Callback(h, eventdata, handles, varargin)
val = get(h, 'val');
if ~val
  %user is not allowed to turn it off
  set(h, 'val',1);
else %if ~val
  set(h, 'enable','inactive');
  handles = alterPaneState(handles, 'off');
  handles = alterPaneState(handles, {'TACAlias'}, 'on', h);
  [tacAlias, tacCall, txtLineArray, errMsg] = readTacCallAlias(outpostValByName('DirAddOns', handles.outpostNmNValues));
  ud = get(handles.listboxTACAlias_0,'UserData');
  if length(tacAlias)
    ud.err = 0;
    set([handles.pushbuttonTACAliasEdit handles.pushbuttonTACAliasDelete],'enable','on');
    for itemp = 1:length(tacAlias)
      % format here, in "pushbuttonTACAliasAdd_Callback" & in "pushbuttonTACAliasEdit_Callback"
      cl(itemp) = {sprintf('%s  <->  %s', char(tacCall(itemp)), char(tacAlias(itemp)) )};
    end
  else
    ud.err = 1;
    cl = textwrap(handles.listboxTACAlias_0, {errMsg});
    set([handles.pushbuttonTACAliasEdit handles.pushbuttonTACAliasDelete],'enable','off');
  end
  set(handles.listboxTACAlias_0,'String', cl,'UserData', ud);
  if ~length(cl)
    a = 'off';
  else
    a = 'on';
  end
  %from before
  val = get(handles.listboxTACAlias_0,'Value');
  %0 is only valid if list is empty
  val = min(max(1, val), length(cl));
  set(handles.listboxTACAlias_0,'Value', val);
  set(handles.pushbuttonTACAliasDelete,'Visible', a);
  set(handles.pushbuttonTACAliasEdit,'Visible', a);
end % if ~val else
% --------------------------------------------------------------------
function argout = setUpdated(thisPane, handles);
handles.paneUpdated(find(ismember(handles.paneNames, thisPane))) = 1;
set(handles.togglebuttonSave,'visible','on');
guidata(handles.figure1, handles);
if nargout
  argout = handles;
end
% --------------------------------------------------------------------
function varargout = pushbuttonTACAliasAdd_Callback(h, eventdata, handles, varargin)
%add a new entry
prompt  = {'Enter 6 character Tactical Call sign', 'Enter Alias (location in plain English)' };
answer = enterCheckTACAlias(h, handles, 'Add: Tactical Call <-> Alias', prompt, {'',''}) ;
if length(char(answer))
  ud = get(handles.listboxTACAlias_0,'UserData');
  if ud.err
    ud.err = 0;
    set(handles.listboxTACAlias_0,'UserData', ud);
    cl = {};
    set([handles.pushbuttonTACAliasEdit handles.pushbuttonTACAliasDelete],'enable','on');
  else
    cl = get(handles.listboxTACAlias_0,'String');
  end
  % format here, in "tbTACAliasPane_Callback" (initial loading) & in "pushbuttonTACAliasEdit_Callback"
  cl(length(cl)+1) = {sprintf('%s  <->  %s', upper(char(answer(1))), char(answer(2)) )};
  set(handles.listboxTACAlias_0,'String', cl, 'value', length(cl));
  setUpdated('TACAlias', handles)
end
% --------------------------------------------------------------------
function varargout = pushbuttonTACAliasEdit_Callback(h, eventdata, handles, varargin)
%modify an existing entry
val = get(handles.listboxTACAlias_0,'Value');
cl = get(handles.listboxTACAlias_0,'String');
if val & length(cl)
  [tacCall, alias] = separateCallAlias(cl(val));
  prompt  = {'6 character Tactical Call sign', 'Alias (location in plain English)' };
  answer = enterCheckTACAlias(h, handles, 'Edit: Tactical Call <-> Alias', prompt, [tacCall,alias], 1);
  if length(char(answer))
    %format here and in "tbTACAliasPane_Callback" where initially loaded from file
    a = sprintf('%s  <->  %s', char(answer(1)), char(answer(2)) );
    %if the operator changed anything....
    if ~strcmp(a, char(cl(val)))
      %load the new values into the array
      cl(val) = {a};
      %update the display
      set(handles.listboxTACAlias_0,'String', cl, 'value', length(cl));
      %set the flag
      setUpdated('TACAlias', handles)
    end %if ~strcmp(a, char(cl(val)))
  end
end
% --------------------------------------------------------------------
function [answer] = enterCheckTACAlias(h, handles, title, prompt, def, disableDupChk)
if nargin < 6
  disableDupChk = 0;
end
lines= 1;
noGood = 1;
cl = get(handles.listboxTACAlias_0,'String');
%we'll keep looping until both answers are acceptable
while noGood
  answer  = inputdlg(prompt,title,lines,def);
  %similar test used by calling functions: don't change this without changing them!
  if ~length(char(answer))
    %exit the while & leave noGood set as the return variable
    break
  end
  msg = '';
  noGood = 0;
  %need two answers! - check for tac call
  if (length(char(answer(1))) < 1)
    msg = 'No Tactical Call sign entered';
    noGood = 1;
  else % if (length(char(answer(1))) < 1)
    %tactical call can only be 6 characters long
    if (length(char(answer(1))) > 6)
      msg = 'Tactical Call Sign is too long - it can be no more than 6 characters';
      noGood = 1;
      def(1) = {upper(char(answer(1)))};
    else %if (length(char(answer(1))) > 6)
      dup = 0;
      if ~disableDupChk
        %check if tactical call already in use!
        a = lower(char(answer(1)));
        for itemp = 1:length(cl)
          if (1 == findstrchr(a, lower(char(cl(itemp)))) )
            dup = 1;
            break
          end
        end % for itemp = 1:length(cl)
      end %if ~disableDupChk
      if dup
        msg = sprintf('Tactical Call Sign already assigned:\n%s\n', char(cl(itemp)) );
        noGood = 1;
        def(1) = {upper(char(answer(1)))};
      else
        def(1) = {upper(char(answer(1)))};
      end
    end %if (length(char(answer(1))) > 6) else
  end % if (length(char(answer(1))) < 1) else
  %need two answers! - check for alias
  if (length(char(answer(2))) < 1)
    if length(msg)
      msg = sprintf('%s & ', msg);
    end
    msg = sprintf('%sNo Alias entered', msg);
    noGood = 1;
  else %if length(char(answer(2))) < 1)
    def(2) = answer(2);
  end %if length(char(answer(2))) < 1) else
  if noGood
    %post an error dialog box
    h_err = errordlg(msg);
    %keep the error dialog on top of the data entry box which is about to re-appear
    waitfor(h_err);
  end % if noGood
end % while noGood
% --------------------------------------------------------------------
function varargout = pushbuttonTACAliasDelete_Callback(h, eventdata, handles, varargin)
[cl] = confirmDelete(handles.listboxTACAlias_0, 'TACAlias', handles,'Delete TAC Call <-> Alias');
if ~length(cl)
  set(handles.pushbuttonTACAliasDelete,'Visible','Off');
  set(handles.pushbuttonTACAliasEdit,'Visible','Off');
end
% --------------------------------------------------------------------
function [cl] = confirmDelete(h_listBox, paneCoreName, handles, dlgTitle)
val = get(h_listBox,'Value');
cl = get(h_listBox,'String');
%check that there is something to deleted
if val & length(cl)
  thisText = sprintf('"%s"', char(cl(val)));
  a = 'Are you sure you want to delete the following entry?';
  %"cute": make both lines the same length so they'll be centered"
  if length(a) ~= length(thisText)
    spc([1:abs((length(a) - length(thisText))/2)]) = ' ';
    if length(a) > length(thisText)
      thisText = sprintf('%s%s', spc, thisText);
    else
      a = sprintf('%s%s', spc, a);
    end
  end %if length(a) ~= length(thisText)
    
  button = questdlg(sprintf('%s\n%s', a, thisText),dlgTitle,'Yes','No','No');
  if strcmp(button,'Yes')
    switch val
    case 1
      cl = cl(2:length(cl));
    case length(cl)
      cl = cl(1:val-1);
    otherwise
      cl = cl([1:(val-1) (val+1):length(cl)]);
    end % switch val
    set(h_listBox,'String', cl);
    val = min(max(1,val), length(cl));
    set(h_listBox,'Value', val);
    setUpdated(paneCoreName, handles)
  end % if strcmp(button,'Yes')
end % if val & length(cl)
% --------------------------------------------------------------------
function [tacCall, alias] = separateCallAlias(cl);
%INPUT: cl is a cell array of strings each formatted 'tacCall  <->  alias'

%set aside memory
tacCall = cell(size(cl));
alias = tacCall;
for itemp = 1:length(cl)
  thisText = char(cl(itemp));
  a = findstrchr('<', thisText);
  tacCall(itemp) = {strtrim(thisText(1:a(1)-1))};
  a = findstrchr('>', thisText);
  alias(itemp) = {strtrim(thisText(a(1)+1:length(thisText)))};
end
% --------------------------------------------------------------------
function [handles] = learnPaneNames(handles);
%  Create a list of the available Panes by detecting the Pane selection buttons.
%A pane selection button starts with "tb" and ends with "Pane"
%  The pane name is the text after "tb" and before "Pane".  These names are
%handles.paneNames: cell array list of pane names
%handles.paneHandle: numeric array of the handles
%handles.paneUpdated: flag list to track when data on a pane has been changed 
%                     and the data saved or not.
%flag array - if user changed anything on the pane that
% isn't immediately stored, a flag will be set.  That flag will
% be cleared if operator hits Save.  Once set, operator cannot move
% away from pane without deciding to save or abandon the changes.

%Exampes:
%  handles.paneUpdated(find(ismember('TACAlias', handles.paneNames)))
%  char(get(handles.paneHandle(Ndx),'string'))

handles.paneNames = {};
fn = fieldnames(handles);
for fieldNdx = 1:length(fn)
  %get the name of a variable in the structure "logged"
  thisField = char(fn(fieldNdx));
  %if this a pane selection button, learns the name...
  if findstrchr('Pane', thisField) & findstrchr('tb', thisField)
    a = findstrchr('Pane', thisField);
    b = findstrchr('tb', thisField);
    handles.paneNames(length(handles.paneNames) + 1) = {thisField(b+2:a-1)};
    handles.paneHandle(length(handles.paneNames))= getfield(handles,thisField);
  end % if findstrchr('Pane', thisField) & findstrchr('tb', thisField)
end % for fieldNdx = 1:length(fn)
%some panes have sub-items that only appear when Outpost is on this computer
handles.paneNames = [handles.paneNames {'BURmt','BULcl'}];
handles.paneUpdated(1:length(handles.paneNames)) = 0;
% ----------------d----------------------------------------------------
function [handles] = userSaveAbandon(handles);
[err, errMsg, handles] = saveCore(handles, 1);

% --------------------------------------------------------------------
function [err, errMsg, handles] = saveCore(handles, askUser);
if nargin < 2
  askUser = 0;
end
err = 0;
errMsg = '';
NdxList = find(handles.paneUpdated > 0);
for itemp = 1:length(NdxList)
  Ndx = NdxList(itemp);
  %get the label on the gui for the pane in question
  if askUser
    %ask user if save or abandon
    a = min(Ndx, length(handles.paneHandle));
    button = questdlg(sprintf('You have made changes to %s.\n\nDo you want to save these changes?', char(get(handles.paneHandle(a),'string'))),...
      'Changes Not Saved','Yes','No','Yes');
  else
    button = 'Yes';
  end
  if strcmp(button,'Yes')
    %if save, call the appropriate save function
    [err, errMsg] = feval(strcat('save_', char(handles.paneNames(Ndx))), handles) ;
  end
  if ~err
    %clear the status
    handles.paneUpdated(Ndx) = 0;
  else
    errordlg(sprintf('Error %i: %s', err, errMsg),'Save Failed','modal');
  end
end
%hide the save button & release it
set(handles.togglebuttonSave,'visible','off','Value',0);
%preserve the status of all paneUpdated
guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function varargout = togglebuttonSave_Callback(h, eventdata, handles, varargin)
[err, errMsg, handles] = saveCore(handles);
%release button
set(h,'Value',0)
% --------------------------------------------------------------------
function [err, errMsg] = save_TACAlias(handles)
[tacCall, alias] = separateCallAlias(get(handles.listboxTACAlias_0,'String'));
[err, errMsg] = writeTacCallAlias(outpostValByName('DirAddOns', handles.outpostNmNValues), alias, tacCall);
% --------------------------------------------------------------------
function [err, errMsg] = save_Summ(handles)
% --------------------------------------------------------------------
function [err, errMsg] = save_Print(handles)
if handles.printRecv
  [err, errMsg] = writeRecvRecipients_213(handles) ;
end
if handles.printSentPpr
  [err, errMsg] = writeSentPprRecipients_213(handles) ;
end
if handles.printSente
  [err, errMsg] = writeSenteRecipients_213(handles) ;
end
if handles.printDelvrRecp
  [err, errMsg] = writeDelvrRecp_213(handles) ;
end
if (handles.printMasterPpr | handles.printMasterSent | handles.printMasterSentPpr | handles.printMasterRecvDelvrRecp)
  blankPaper = 2;
  printEnableRec = get(handles.tbPrintMasterRecv,'value');
  copies4recv = -1 * printEnableRec;
  printEnableSent = 0;
  if get(handles.tbPrintMasterSent,'value');
    copies4sent = -1;
    printEnableSent = 1;
  else
    copies4sent = 0;
  end
  if get(handles.tbPrintMasterSentPpr,'value');
    copies4sentFromPaper = -1;
    printEnableSent = 1;
  else
    copies4sentFromPaper = 0;
  end
  if get(handles.tbPrintMasterRecvDelvrRecp,'value');
    copies4DelvrRecp = -1;
    printEnableDelvrRecp = 1;
  else
    copies4DelvrRecp = 0;
    printEnableDelvrRecp = 0;
  end
  HPL3 = 0;
  [err, errMsg] = writePrintICS_213INI(outpostValByName('DirAddOns', handles.outpostNmNValues), ...
    printEnableRec*blankPaper, printEnableSent*blankPaper, copies4recv, copies4sent, copies4sentFromPaper, HPL3, ...
    copies4DelvrRecp, printEnableDelvrRecp*blankPaper);
  
  printerPort = 'LPT1:';
  qualLetter = 0;
  [err, errMsg] = writeProcessOPM_INI(outpostValByName('DirAddOns', handles.outpostNmNValues), ...
    (printEnableRec | printEnableSent)*blankPaper, HPL3, printerPort, qualLetter);
end %if (handles.printMasterPpr | handles.printMasterSent | handles.printMasterSentPpr | printMasterRecvDelvrRecp)
handles.printRecv = 0;
handles.printSentPpr = 0;
handles.printSente = 0; 
handles.printDelvrRecp = 0 ;

handles.printMasterPpr = 0;
handles.printMasterSent = 0;
handles.printMasterSentPpr = 0;
handles.printMasterRecvDelvrRecp = 0;
guidata(handles.figure1, handles)
% --------------------------------------------------------------------
function updateNewMsg(handles)
handles.dateTime = datestr(datenum(sprintf('%i/%i/%i %s:%s', handles.lastMsg.month, handles.lastMsg.day, ...
  handles.lastMsg.year, handles.lastMsg.hr, handles.lastMsg.min))) ;
handles = setUpdated('NewMsg', handles);
handles.startTime = setLogStartTime(find(handles.nMstartTimeOption == handles.lastMsg.select), handles.dateTime, ...
  outpostValByName('DirScripts', handles.outpostNmNValues), outpostValByName('DirOutpost', handles.outpostNmNValues));
handles = readNDispFindMsgLst(handles);
guidata(handles.figure1, handles)
% --------------------------------------------------------------------
function [err, errMsg] = save_NewMsg(handles)
%this should be current but just in case....
handles.dateTime = datestr(datenum(sprintf('%i/%i/%i %s:%s', handles.lastMsg.month, handles.lastMsg.day, ...
  handles.lastMsg.year, handles.lastMsg.hr, handles.lastMsg.min))) ;
startTimeOption = find(handles.nMstartTimeOption == handles.lastMsg.select);
[err, errMsg] = writefindNewOutpostMsgs_INI(handles.findNewOutpostMsgsINI, handles.newestTxtPathNameEx, ...
  startTimeOption, handles.dateTime);
% --------------------------------------------------------------------
function [err, errMsg] = save_Backup(handles)
% --------------------------------------------------------------------
function [err, errMsg] = save_BULcl(handles)
[err, errMsg] = writeProcessOPM_Logs(get(handles.listboxBackupLocal,'String'), outpostValByName('DirAddOns', handles.outpostNmNValues));
% --------------------------------------------------------------------
function [err, errMsg] = save_BURmt(handles)
[err, errMsg] = writeProcessOPM_Logs(get(handles.listboxBackupRemote,'String'), outpostValByName('DirAddOns', handles.outpostNmNValues),...
  'network_PkLgMonitor_logs.ini','This file is used by "displayCounts" when monitoring a Packet Log on a network.');
% --------------------------------------------------------------------
function [err, errMsg] = save_LogPrt(handles)
logPrtEnable = get(handles.cbLogPrtEnable_0, 'value');
[err, errMsg] = writeLogPrintINI(outpostValByName('DirAddOns', handles.outpostNmNValues), ...
  logPrtEnable, handles.logPrt_minuteInterval, handles.logPrt_mnmToPrt, handles.logPrt_msgNums);
% --------------------------------------------------------------------
function varargout = tbPrintMasterRecv_Callback(h, eventdata, handles, varargin)
%pass in 4th variable (i.e. varargin) to disable "save" tags
val = get(h, 'value');
if nargin < 4
  handles.printMasterPpr = 1 ;
  setUpdated('Print', handles)
end
configPrint('Recv', val, handles, h);
if val 
  %reload Outpost's settings just in case they've changed
  [err, errMsg, handles.outpostNmNValues] = OutpostINItoScript(outpostValByName('DirOutpost', handles.outpostNmNValues) ); 
  if str2num(outpostValByName('PrintOnReceipt', handles.outpostNmNValues))
    a = sprintf('Double printing:\n\n');
    a = sprintf('%sOutpost is also set to print received messages\n', a);
    a = sprintf('%swhich will done as text even for PacFORM messages.\n\n', a);
    a = sprintf('%sTo change in Outpost: Tools-> Send/Receive Settings: Other.', a);
    warndlg(a,'!! Warning Double printing!!')
  end
end %if val 
% --------------------------------------------------------------------
function varargout = tbPrintMasterSent_Callback(h, eventdata, handles, varargin)
%pass in 4th variable (i.e. varargin) to disable "save" tags
val = get(h, 'value');
if nargin < 4
  handles.printMasterSent = 1 ;
  setUpdated('Print', handles)
end
configPrint('Sente', val, handles, h);
if val 
  %reload Outpost's settings just in case they've changed
  [err, errMsg, handles.outpostNmNValues] = OutpostINItoScript(outpostValByName('DirOutpost', handles.outpostNmNValues) ); 
  if str2num(outpostValByName('PrintOnSend', handles.outpostNmNValues))
    a = sprintf('Double printing:\n\n');
    a = sprintf('%sOutpost is also set to print sent messages\n', a);
    a = sprintf('%swhich will done as text even for PacFORM messages.\n\n', a);
    a = sprintf('%sTo change in Outpost: Tools-> Send/Receive Settings: Other.', a);
    warndlg(a,'!! Warning Double printing!!')
  end
end %if val 
% --------------------------------------------------------------------
function varargout = tbPrintMasterSentPpr_Callback(h, eventdata, handles, varargin)
%pass in 4th variable (i.e. varargin) to disable "save" tags
val = get(h, 'value');
if nargin < 4
  handles.printMasterSentPpr = 1 ;
  setUpdated('Print', handles)
end
configPrint('SentPpr', val, handles, h);
% --------------------------------------------------------------------
function varargout = popupPrintRecv213_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = popupPrintSent213_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = popupPrintSentPpr213_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function configPrint(key, val, handles, h);
if val
  vis = 'on';
  set(h, 'string', 'Print');
else
  vis = 'off';
  set(h, 'string', 'Off');
end
%find popup, Print, & key
fn = fieldnames(handles);
for fieldNdx = 1:length(fn)
  %get the name 
  thisField = char(fn(fieldNdx));
  %if this item is on the pane of interest...
  if findstrchr('Print', thisField)
    if findstrchr('cb', thisField)
      if findstrchr(key, thisField)
        set(getfield(handles,thisField), 'visible',vis);
      end % if findstrchr(key, thisField)
    end % if findstrchr('popup', thisField)
  end % if findstrchr('Print', thisField)
end % for fieldNdx = 1:length(fn)
% --------------------------------------------------------------------
% function configPrintCopyPopups(list, key, handles);
% %find popup, Print, & key
% string = {'All','0'};
% for itemp = 1:(length(list)-1)
%   string(length(string)+1) = {sprintf('%i', itemp)};
% end
% fn = fieldnames(handles);
% for fieldNdx = 1:length(fn)
%   %get the name 
%   thisField = char(fn(fieldNdx));
%   %if this item is on the pane of interest...
%   if findstrchr('Print', thisField)
%     if findstrchr('popup', thisField)
%       if findstrchr(key, thisField)
%         set(getfield(handles,thisField), 'string', string);
%       end % if findstrchr(key, thisField)
%     end % if findstrchr('popup', thisField)
%   end % if findstrchr('Print', thisField)
% end % for fieldNdx = 1:length(fn)

% --------------------------------------------------------------------
function varargout = cbPrintRadioRecv_Callback(h, eventdata, handles, varargin)
handles.printRecv = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintPlanningRecv_Callback(h, eventdata, handles, varargin)
handles.printRecv = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintAddresseeRecv_Callback(h, eventdata, handles, varargin)
handles.printRecv = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintRadioSente_Callback(h, eventdata, handles, varargin)
handles.printSente = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintPlanningSente_Callback(h, eventdata, handles, varargin)
handles.printSente = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintOriginatorSente_Callback(h, eventdata, handles, varargin)
handles.printSente = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintRadioSentPpr_Callback(h, eventdata, handles, varargin)
handles.printSentPpr = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintPlanningSentPpr_Callback(h, eventdata, handles, varargin)
handles.printSentPpr = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintOriginatorSentPpr_Callback(h, eventdata, handles, varargin)
handles.printSentPpr = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function configPrintCopyCB(list, h_radio, h_planning, h_other)
set(h_radio, 'value', 0)
set(h_planning, 'value', 0)
set(h_other, 'value', 0)
if iscellstr(list)
  for itemp = 1:length(list)
    switch lower(char(list(itemp)))
    case 'radio'
      set(h_radio, 'value', 1)
    case 'planning'
      set(h_planning, 'value', 1)
    case {'originator', 'addressee'}
      set(h_other, 'value', 1)
    end
  end
end
% --------------------------------------------------------------------
function [err, errMsg] = writeRecvRecipients_213(handles)
a = {'RADIO','PLANNING','ADDRESSEE'} ;
list ={};
if get(handles.cbPrintRadioRecv, 'val')
  list = a(1);
end
if get(handles.cbPrintPlanningRecv, 'val')
  list(length(list) + 1) = a(2);
end
if get(handles.cbPrintAddresseeRecv, 'val')
  list(length(list) + 1) = a(3);
end
[err, errMsg] = writeRecipients(strcat(outpostValByName('DirAddOns', handles.outpostNmNValues),'inTray_copies.txt'), list);
% --------------------------------------------------------------------
function [err, errMsg] = writeDelvrRecp_213(handles)
a = {'RADIO','PLANNING','ADDRESSEE'} ;
list ={};
if get(handles.cbPrintRadioDelvrRecp, 'val')
  list = a(1);
end
if get(handles.cbPrintPlanningDelvrRecp, 'val')
  list(length(list) + 1) = a(2);
end
if get(handles.cbPrintAddresseeDelvrRecp, 'val')
  list(length(list) + 1) = a(3);
end
[err, errMsg] = writeRecipients(strcat(outpostValByName('DirAddOns', handles.outpostNmNValues),'inTray_DelvrRecp.txt'), list);
% --------------------------------------------------------------------
function [err, errMsg] = writeSenteRecipients_213(handles)
[err, errMsg] = writeSentRecipients(handles, handles.cbPrintRadioSente, ...
  handles.cbPrintPlanningSente, handles.cbPrintOriginatorSente, 'outTray_copies.txt');
% --------------------------------------------------------------------
function [err, errMsg] = writeSentPprRecipients_213(handles)
[err, errMsg] = writeSentRecipients(handles, handles.cbPrintRadioSentPpr, ...
  handles.cbPrintPlanningSentPpr, handles.cbPrintOriginatorSentPpr, 'outTrayPaper_copies.txt');
% --------------------------------------------------------------------
function [err, errMsg] = writeSentRecipients(handles, h_radio, h_planning, h_orig, fname)
a = {'RADIO','PLANNING','ORIGINATOR'} ;
list ={};
if get(h_radio, 'val')
  list = a(1);
end
if get(h_planning, 'val')
  list(length(list) + 1) = a(2);
end
if get(h_orig, 'val')
  list(length(list) + 1) = a(3);
end
[err, errMsg] = writeRecipients(strcat(outpostValByName('DirAddOns', handles.outpostNmNValues), fname), list);
% --------------------------------------------------------------------
function varargout = editLogPrint_minuteInterval_Callback(h_obj, eventdata, handles, varargin)
[err] = getCheckNumValEditBox(h_obj, handles.logPrt_minuteInterval, handles, 0);
if ~err
  setUpdated('LogPrt', handles)
end
% --------------------------------------------------------------------
function varargout = editLogPrint_mnmToPrt_Callback(h_obj, eventdata, handles, varargin)
[err] = getCheckNumValEditBox(h_obj, handles.logPrt_mnmToPrt, handles, 0);
if ~err
  setUpdated('LogPrt', handles)
end
% --------------------------------------------------------------------
function varargout = editLogPrint_msgNums_Callback(h_obj, eventdata, handles, varargin)
[err] = getCheckNumValEditBox(h_obj, handles.logPrt_minuteInterval, handles, 1);
if ~err
  setUpdated('LogPrt', handles)
end
% --------------------------------------------------------------------
function varargout = cbLogPrintEnable_Callback(h, eventdata, handles, varargin)
val = get(h,'value');
if val
  enb = 'on';
  colr = [1 1 1];
else
  enb = 'off';
  colr = get(handles.figure1, 'Color');
end
set(handles.editLogPrt_minuteInterval, 'enable', enb, 'BackgroundColor', colr);
set(handles.editLogPrt_mnmToPrt, 'enable', enb, 'BackgroundColor', colr);
set(handles.editLogPrt_msgNums, 'enable', enb, 'BackgroundColor', colr);
setUpdated('LogPrt', handles)
% --------------------------------------------------------------------
function varargout = figure1_CloseRequestFcn(h_obj, eventdata, handles, varargin)
%don't close figure if any information has been changed but not saved
while any(handles.paneUpdated)
  %if Save(s) is/are successful, handles.paneUpdated is cleared
  %if unsucccessful, handles.paneUpdated is not cleared UNLESS operator decides to not
  %  save.
  [err, errMsg, handles] = saveCore(handles, 1);
end
delete(handles.figure1);
% --------------------------------------------------------------------
function [latestTime, latesTmRead] = readFindMsgLast(newestTxtPathNameEx);
%partial duplication of the operation in "findNewOutpostMsgs" where the file contents affect program operation.
fid = fopen(newestTxtPathNameEx,'r');
if (fid>0)
  %want to convert date-time from Excel format (day 1 = 1900,01,01) to Matlab: add this to Excel value
  offAdd = datenum(1900,01,01) - 2;
  textLine = fgetl(fid);
  %make sure the file isn't corrupted:
  if length(textLine)
    %the line should only contain a floating point number
    if all(ismember(textLine, ['0123456789.']))
      latestTime = str2num(textLine);
      latesTmRead = 1;
      %if the time-date is in Excel format, convert to Matlab
      if latestTime < offAdd
        latestTime = latestTime + offAdd;
      end
    end % if all(ismember(textLine, ['0123456789.']))
  end % if length(textLine)
  fclose(fid) ;
else %if (fid>0)  fid = fopen(nmNewText,'r');
  latestTime = 0;
  latesTmRead = 0;
end % if fid>0  fid = fopen(nmNewText,'r'); else
% --------------------------------------------------------------------
function [handles] = readNDispFindMsgLst(handles);
[handles.latestTime, handles.latesTmRead] = readFindMsgLast(handles.newestTxtPathNameEx);
if handles.latesTmRead & (handles.startTime < handles.latestTime)
  set(handles.textNewMsgLatest,'visible','on','string', datestr(handles.latestTime));
  set(handles.textNewMsgTitleLatest,'visible','on');
else
  set(handles.textNewMsgLatest,'visible','off');
  set(handles.textNewMsgTitleLatest,'visible','off');
end
guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function varargout = togglebuttonDone_Callback(h, eventdata, handles, varargin)
figure1_CloseRequestFcn(gcbo,[],guidata(gcbo))
% --------------------------------------------------------------------



% --------------------------------------------------------------------



% --------------------------------------------------------------------
function varargout = tbPrintMasterRecvDelvrRecp_Callback(h, eventdata, handles, varargin)
%pass in 4th variable (i.e. varargin) to disable "save" tags
val = get(h, 'value');
if nargin < 4
  handles.printMasterRecvDelvrRecp = 1 ;
  setUpdated('Print', handles)
end
configPrint('DelvrRecp', val, handles, h);
% --------------------------------------------------------------------
function varargout = cbPrintRadioDelvrRecp_Callback(h, eventdata, handles, varargin)
handles.printDelvrRecp = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintPlanningDelvrRecp_Callback(h, eventdata, handles, varargin)
handles.printDelvrRecp = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
function varargout = cbPrintAddresseeDelvrRecp_Callback(h, eventdata, handles, varargin)
handles.printDelvrRecp = 1 ;
setUpdated('Print', handles)
% --------------------------------------------------------------------
