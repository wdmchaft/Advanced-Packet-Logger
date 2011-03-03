function varargout = displayCounts(varargin)
% DISPLAYCOUNTS Application M-file for displayCounts.fig
%Provides real time display of the Packet Log written by processOutpostPacketMessages
% All returned variables are optional
%Simple launch: starts the program accessing the same path as previously
%        looking for today's log
%    [err, errMsg, figure1] = DISPLAYCOUNTS launch displayCounts GUI.
%Partially directed launch: starts the program accessing the specified path
%        looking for today's log
%    [err, errMsg, figure1] = DISPLAYCOUNTS(path)
%Fully directed launch: will open specified log at specified location - any extension 
%        will be ignored & will always be .csv
%    [err, errMsg, figure1] = DISPLAYCOUNTS(path\logName)
%
%    DISPLAYCOUNTS('callback_name', ...) invoke the named callback.
%        
% Modified structure for similarity to Matlab 2008

%version number tracked in displayCounts_OpeningFcn via "handles.codeVersion"
err = 0;
errMsg = '';
figure1 = 0 ;
if nargin == 0  % LAUNCH GUI
  [err, errMsg, figure1] = displayCounts_OpeningFcn;
elseif nargin < 2 % LAUNCH GUI and pass path or path\name
  [err, errMsg, figure1] = displayCounts_OpeningFcn(varargin{1});
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
        [err, errMsg, figure1] = displayCounts_OpeningFcn(varargin{:}) ;
      catch
        % disp(lasterr);
        fprintf('\r\n%s while attempting displayCounts_OpeningFcn with %s', lasterr, varargin{1});
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

% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = displayCounts_OpeningFcn(varargin)
global debugEnable
[err, errMsg, modName] = initErrModName(strcat(mfilename, '(displayCounts_OpeningFcn)'));

fid = fopen(strcat(mfilename,'_debug.txt'),'r');
if (fid > 0)
  debugEnable = 1;
  fclose(fid);
else
  debugEnable = 0;
end

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

% % %if the caller of this entire module is trying to set the properties....
% % if nargin
% %   set(figure1, varargin{:})
% % end

% Generate a structure of handles to pass to callbacks, and store it. 
handles = guihandles(figure1);
handles.codeVersion = 1.01;
[codeName, codeVersion, codeDetail] = getCodeVersion(handles);
fprintf('\r\nCode: %s, version %s %s', codeName, codeVersion, codeDetail);

fprintf('\r\n');
fprintf('\r\n*** you may minimize this window. Do NOT close ****');
fprintf('\r\n*** you may minimize this window. Do NOT close ****');
fprintf('\r\n*** To close: exit the window "Packet Log Monitor ****');
fprintf('\r\n');

handles.logPath = '';  
handles.logPathName  = '';
handles.logCoreName = '' ;
logPathPassedIn = 0;
logPathNNamePassedIn = 0;
if (nargin > 0)
  logPathPassedIn = 1;
  a = varargin{1};
  %Need to clean up some weird business with the passed in parameter.
  %  do not know if the weirdness is an artifact of being called from Outpost
  %  or something about Matlab when compiled or what.
  %call from script:
  %    Run(PathToPrgms & "displayCounts.exe " & quote & PathToLogs & quote )
  %the first character as #13, CR.
  while double(a(1) < 33)
    a = a(2:length(a));
  end
  %finding a trailing quote!
  a = strrep(a, '"','');
  [pathstr,name,ext,versn] = fileparts(a);
  %a path that is not \ terminated will result in name being the last dir in the path, but ext will be blank
  if length(ext)
    %input includes a file name
    handles.logPath = endWithBackSlash(pathstr);
    handles.logPathName = a;
    handles.logCoreName = name;
    logPathNNamePassedIn = 1;
  else % if length(ext)
    handles.logPath = endWithBackSlash(strcat(endWithBackSlash(pathstr), name));
  end % if length(ext) else
end % if (nargin > 0)

if debugEnable
  fid = fopen('\displayCount.log','a');
  fprintf(fid,'handles set\r\n');
  fclose(fid);
end

outpostOK = 0;
%We need a few things from Outpost's .ini file so let's find that file.
%  If we don't find it, we'll (evenutally) have defaults.
[err, errMsg, outpostNmNValues] = OutpostINItoScript; 
if err
  errMsg = strcat(modName, errMsg);
  return
else
  outpostOK = 1;
end
if debugEnable
  fid = fopen('\displayCount.log','a');
  fprintf(fid,'Outpost OK: %i\r\n', outpostOK);
  fclose(fid);
end
% handles.workingDir: where this program is located.  Batch file(s) written 
%  by this program will also be there.
if outpostOK
  % location of  this program, the logging program (processOPM) and the semaphore files that are not in the
  %  log's directory
  handles.workingDir = outpostValByName('DirAddOnsPrgms', outpostNmNValues);
  
  %location of pac-forms
  handles.DirPF = endWithBackSlash(outpostValByName('DirPF', outpostNmNValues));
  handles.opCall = outpostValByName('StationID', outpostNmNValues);
else
  handles.workingDir = sprintf('%sAddOns\\Programs\\', endWithBackSlash(pwd)) ;
  handles.DirPF = 'c:\pacforms\';
  handles.opCall = '' ;
end
nameForStore = sprintf('%s%s.mat', handles.workingDir, mfilename);

% configuration files usually .ini
%the configuration files are in the directory above the program's directory
a = findstrchr('\', handles.workingDir);
handles.configDir = handles.workingDir(1:a(length(a)-1));

% Printers:
% Ideally we'd like to have the program be able to switch from Portrait to Landscape,
%   know or specify the character-per-inch, margins, etc.  The purposes include 
%   automatically:
%   1) being able to print to exact locations on a pre-printed form which will be
%      in Portrait mode. (This is from another program which likely will be running
%      concurrently which means Windows' Default cannot be set properly for both this
%      case and the Landscape case.)  A variant on this is to print on a blank sheet 
%      of paper in portrait mode.
%   2) print the packet log in Landscape, wrapping lines as necessary.
%   3) being able to perform a manually activated print of a message - this is a
%      trival problem because the settings can be changed by the user as needed.
%
% local printers can be accessed directly for LPT1: and perhaps for USB as well.
%   This permits direct configuration commands for font, pitch, orientation, etc but
%   may require printer brand-specific commands.  The killer limitation is the inability
%   to easily access a networked printer.  The implementation I've gotten working for 
%   LPT1: is to print text to a file and then copy to the printer.
% accessing a printer through Windows is most likely limited to the "default printer"
%   set up to what ever the user has defined as the default conditions.

% User choices:
% 1) semi-automatic printing: program brings up notepad & user takes it from there
% 2) automatic printing through notepad
% 3) automatic printing through a 3rd party program, command line as loaded from a file
% ====
% For now, let's presume local printer, LPT1:, HP compatible command set (check out Canons)
% and use portrait/landscape etc with command sequences.

%Some todos: 
%  * ics213 on blank paper (need to know where to put field headings);
%  * processOutpost... : control file to know what type of paper is loaded into the printer: plain, preprinted, etc
%  *  (same)   saving log to additional locations such as network, usb drives, etc.  Would be good to have
%     action log to record the activities.  Of interest in situation where a usb drive is removed for a
%     period of time and then re-installed.
%  * method to enter incident name
%  * option to name log on incident name instead of date
%  * option to specify starting date (&time?) for logged events such as from now on, N hours before now & on,
%    today, etc.
%  * program that will open packet log display and then activate the monitor
%  * might be good to use different colors on the Packet Log Monitor button so user knows when it is not active.
%  * indicate when log lines are > printer line width & then invoke line wrap?
%  * timed auto printed of log

% set up default values

%flag.  set when monitor loop is running and cleared when it is closed
%    Used by displayCounts_CloseRequestFnc to determine figure closing process
handles.monitoring = 0 ; 
%flag.  set when displayCounts_CloseRequestFnc has determined monitor loop is
%    running to indicate monitor loop should call the figure closing code
handles.closeRequest = 0 ;
handles.listSortedNdx = [] ;

%we'll have a list of the displayText windows we open so when we shut down this
% application/window all those windows will also close.  This is the
% index into that list.
handles.h_displayTextNdx = 0;
handles.h_displayText = [];
handles.h_displayTextPathName = {};
handles.subLeftOffset = 13.8;  % cascade the displayText figures: offset to the left this amount 
handles.subDownOffset = 1.62;% cascade the displayText figures: offset down this amount
%
set(handles.textMonitoring,'ToolTip',sprintf('Blinks every time the current Log is checked for an update.\n\nIf a Log copy to an unavailable network location,\noccasional long delay during retry.'));

handles.recentLogs = {} ;
handles.pathsTologCopies = {};

if outpostOK
  handles.DirLogs = endWithBackSlash(outpostValByName('DirLogs', outpostNmNValues));
else
  handles.DirLogs = '';
end

if ~length(handles.logPath)
  handles.logPath = handles.DirLogs;
end
handles.header.logFDate = '';
handles.header.bytes = '';
handles.green = get(handles.pushbuttonUpdatedOK,'BackgroundColor');
handles.tbMonitorLogOffColor = get(handles.togglebuttonMonitorLog,'BackgroundColor');
set(handles.pushbuttonUpdatedOK,'Visible','off');

%1) load the handle of all indicators for copy status into an array for
%easier program flow.
%2) learn the default names for each sort button
fn = fieldnames(handles);
for itemp = 1:length(fn);
  if findstrchr('textCopy_',char(fn(itemp))) %1) load the handle of all indicators for copy status
    b = char(fn(itemp)) ;
    a = findstrchr('_', b);
    c = str2num(b(a+1:length(b))) ;
    handles.copyLED(c) = getfield(handles,b);
  elseif findstrchr('togglebutton',char(fn(itemp))) %2) learn the default names for each sort button
    b = char(fn(itemp)) ;
    a = find(ismember(b,'123456789'));
    if length(a)
      c = str2num(b(a(1):length(b))) ;
      h = getfield(handles,b) ;
      %the labels may have trailing spaces to simulated the width needed for the sort order symbols
      a = strtrim(char(get(h,'string')) );
      handles.sortLabel(c) = {a} ;
      %place oldest/first at top
      set(h, 'String',strcat(char(handles.sortLabel(c)), '^'));
    end %if length(a)
  elseif findstrchr('pushbuttonOpenPACF',char(fn(itemp)))
    %program fiddles with the key: to clearly show when it isn't an option, it is changed to text
    %This makes sure that code will restore the key to whatever the latest "guide" design has styled
    handles.typePushbuttonOpenPACF =  get(getfield(handles,char(fn(itemp))),'Style');
  elseif findstrchr('pushbuttonOpenOutpost',char(fn(itemp)))
    %program fiddles with the key: to clearly show when it isn't an option, it is changed to text
    %This makes sure that code will restore the key to whatever the latest "guide" design has styled
    handles.typePushbuttonOpenOutpost =  get(getfield(handles,char(fn(itemp))),'Style');
  elseif findstrchr('togglebuttonPrint',char(fn(itemp)))
    handles.typeTogglebuttonPrint =  get(getfield(handles,char(fn(itemp))),'Style');
  end
end % for itemp = 1:length(fn);
handles.copyLEDred = get(handles.copyLED(1), 'BackgroundColor') ;
handles.copyLEDgreen = get(handles.copyLED(2), 'BackgroundColor') ;
handles.copyLEDorange = get(handles.copyLED(3), 'BackgroundColor') ;
handles.copyLEDblue = get(handles.copyLED(4), 'BackgroundColor') ;

%Headings for the columns in the display pane
%the log data will be loaded in handles.logged(logLineNdx, ColNdx) where
%  ColNdx corresponds 1:1 to these headings.  The tie-in between these headings
%  and the data is via the actual field names coded in "handles.dispFieldNms"
%don't change this order - change the order in "handles.dispColOrdr"
%  These names must match the names in displayLog's switch/case statement
handles.dispColHdg = {'LOCAL-MSG-NO','TRANSFER-MSG-NO','BBS','OUTPOST-TIME','FORM-TIME',...
    'FROM','TO','MSG-TYPE','SUBJECT','COMMENT','REPLY-RQD.'};
%these are the actual field names that contain the data to be displayed as defined in readPacketLog
% 1:1 correspondence with the "dispColHdg" above for those items that are in
% that list.  This list has additional entries so support items such as handles.len work
%  If the log has additional fields, those will be added to then end of this list is displayLogs
handles.dispFieldNms = {'logMsgNo','xfrMsgNo','bbs','shortOutpostDTime','shortFormDTime',...
    'from','to','formType','subject','comment','replyReqd',...
    'outpostDTime','formDTime','fpathName','conditionChange'};
%default order of display.  
a = [1:length(handles.dispColHdg)];
%two dimensioned array: first is order, second is flag for visible
handles.dispColOrdrDflt(a,1) = a; %sequential order
handles.dispColOrdrDflt(a,2) = 1; %set to visible
handles.dispJust(a) = 0; %set to left justify
handles.dispJust([4 5]) = 1; %set the short times to right justify
%current display column order. This may be changed by the user via "displayOrder"
handles.dispColOrdr = handles.dispColOrdrDflt;
handles.dispColFName = 'Default';
% reset memory of last highlighted list entry
ud.listSortedNdx = 0;
set(handles.listboxAllStation, 'UserData', ud);

%check if conditions from previous run are exist (includes previous GUI position)
% some of these may override the deaults of above
fidStore = fopen(nameForStore, 'r');
if debugEnable
  fid = fopen('\displayCount.log','a');
  fprintf(fid,'fidStore %i\r\n', fidStore);
  fclose(fid);
end
handles.viewSummary = 1;
handles.viewDetail = 1;
if (fidStore > 0)
  fclose(fidStore);
  load(nameForStore);
  set(figure1, 'position', FigMPposition) ;
  % there is a chance the position is not from this computer so
  %let's make sure it is visible.  (How not visible?  If the entire
  %directory was copied from another computer with higher resolution
  %and the position was outside of this computer's screen - happened to me!)
  movegui(figure1,'onscreen')
  % %   screenPos = get(0,'ScreenSize'); %[left bottom width height]
  % %   % first we'll adjust the position based on the top & right
  % %   %   if right edge is off the screen to the right, move to be AT the right
  % %   if (FigMPposition(1) + FigMPposition(3)) > (screenPos(1) + screenPos(3))
  % %     FigMPposition(1) = (screenPos(1) + screenPos(3)) - FigMPposition(3);
  % %   end
  % %   %   if top edge is off the top of screen, pull it down to be AT the top
  % %   if (FigMPposition(2) + FigMPposition(4)) > (screenPos(2) + screenPos(4))
  % %     FigMPposition(2) = (screenPos(2) + screenPos(4)) - FigMPposition(4);
  % %   end
  % %   % second adjust the left & bottom: if the window is too big for the screen,
  % %   %the right &/or top will be off screen & the operator will have to adjust the size
  % %   %  left
  % %   if FigMPposition(1) < screenPos(1)
  % %     FigMPposition(1) = screenPos(1);
  % %   end
  % %   % bottom
  % %   if FigMPposition(2) < screenPos(2)
  % %     FigMPposition(2) = screenPos(2);
  % %   end
  % %   set(figure1, 'Position', FigMPposition);
  %the following will be set after the question dialog
  %because if the path is a net path it may not exist or the
  %operator may not want to be going there
  %  handles.logPath = h_logPath;
  %  handles.logPathName = h_logPathName;
  
  %may not be using the Log information from the previous run . . . see below
  if ~length(handles.logCoreName)
    handles.logCoreName = h_logCoreName;
  end
  
  handles.recentLogs = h_recentLogs;
  % aid for the load process: as we change the variables & what is stored, this will facilitate
  %  program flow
  if  storeVersion > 1;
    handles.viewSummary = h_viewSummary;
    handles.viewDetail = h_viewDetail;
  end % if  storeVersion > 1;
else % if (fidStore > 0)
  movegui(figure1, 'northeast');
end % if (fidStore > 0) else

handles.initPosLBAllStations = get(handles.listboxAllStation,'position');
handles.posScoreBrd = get(handles.listboxScoreboard,'position');
handles.posScoreSumm = get(handles.listboxScoreboardSumm,'position');
adjustView(handles)
handles.nameForStore = nameForStore;
set(figure1,'visible','on');

%Need two files to be semaphore flags.  Both are looked at by the program that writes the Packet Log, 
% processOutpostPacketMessages, a.k.a. processOPM. A version of the first is also looked at by the Outpost script
% that is run on the comuunications computer and which invokes processOPM
% 1) The first is written locally & looked at by any local instance of processOPM to decide if it or this
%   program will perform the copy operations for the Packet Log. Placed in the directory which contains this
%   program and processOPM: <local path>PkLgMonitor<time>_on.txt
% 2) The second is written to the system that has the log being monitored. <Log's path>PcktLogMonitor<time>_copy.txt
%Because multiple instances of this program can be running (example - local monitor & remote monitor)
% we want to make the files opened by this instance (most likely) unique: use the time which is good to mSec
[err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
a = findstrchr('_', date_time);
tm = date_time(a+1:length(date_time));
%started here & refined line 3 lines down by adding the time as a suffix:
handles.semaphoreCoreName = 'PkLgMonitor' ;
handles.programRunningSimpleExt = sprintf('%s%s_on.txt', handles.workingDir, handles.semaphoreCoreName) ;
%modify semaphoreCoreName: add the time as a suffix to make it unique
handles.semaphoreCoreName = sprintf('%s%s_', handles.semaphoreCoreName, tm) ;
handles.programRunning = sprintf('%s%s', handles.workingDir, handles.semaphoreCoreName) ;
%write the unique time stamped semaphore flag used by processOPM (do we really need a unique one? AR Jan 2010)
% "0": indicates monitor loop is not running so auto-updating of copies isn't active
writePrgmRunning(handles, 0) ;
%write the semaphore flag used by the script
fid = fopen(handles.programRunningSimpleExt,'w');
if (fid > 0)
  fprintf(fid,'This file indicates that "%s" is running - it is created when it starts & deleted when it closes.', mfilename);
  fclose(fid);
end

% Make sure both types of lists of copy location exist even if empty:
%   if they don't exist, these calls will cause them to be created & they will include usage instructions 
%List when monitoring a remote computer:
[err, errMsg, handles.pathsTologCopies] = readProcessOPM_Logs(handles.configDir,...
  'network_PkLgMonitor_logs.ini',sprintf('This file is used by "%s" when monitoring a Packet Log on a network.', mfilename));
%List for this computer
[err, errMsg, handles.pathsTologCopies] = readProcessOPM_Logs(handles.configDir);
%The active list is opened in "readNDspPckt"
handles.pathsTologCopies = {};

%load the alias list
[handles.tacAlias, handles.tacCall] = readTacCallAlias(outpostValByName('DirAddOns', outpostNmNValues));

%load the settings regarding printing the log
[err, errMsg, handles.logPrtEnable, handles.logPrt_minuteInterval, handles.logPrt_mnmToPrt, handles.logPrt_msgNums]...
  = readLogPrintINI(outpostValByName('DirAddOns', outpostNmNValues));
%   page numbering to be displayed on hardcopy of log
handles.logPrintFirstPageNum = 1;
%  line of data from log that the printing is to
%    start at.  For full log, set to 1; for incremental print, set to one more
%    that the last line of the previous printing (returned by logPrint)
handles.logPrintStartLogLine = 1;
%time when the log was printed - zero shows not initialized
handles.logPrintTimePrinted = 0;

if handles.logPrtEnable
  a = sprintf('Current settings: Print log update every time %i messages have been logged\nor at least %i messages have been logged in %i minutes.', ...
    handles.logPrt_msgNums, handles.logPrt_mnmToPrt, handles.logPrt_minuteInterval);
  button = questdlg(sprintf('Please confirm you want automatic printing of today''s log?\n\nYou can change this later in the Settings menu.\n\n%s', a),...
    'Automatic Log Printing','Yes','No','Yes');
  handles.logPrtEnable = strcmp(button,'Yes');
end
today = 1 ;
if ~(logPathNNamePassedIn)
  %ALWAYS start with today - operator can change the Log choice if desired via File->Open Log
  today = 1 ;
  userNEWEST = 1;
  if ~logPathPassedIn
    %if previous run had been to a networked computer, we'll confirm 
    %  because the initial access delay over a network can be significant which
    %  is annoying if the operator no longer wants to access that location. The
    %  annoyance is even greater if the operator knows the networked system
    %  is no longer availabe which could happen if the operator had been a supervisor
    %  the last time out.
    if (1 == findstrchr('\\', handles.logPath))
      qstring = sprintf('The previous time this program was operated it accessed\n     %s\na networked computer.  Do you want to monitor this again?', handles.logPath) ;
      qstring = sprintf('%s\n\nNote that the first access to a network can take some time & make it appear this program is hung.',qstring);
      str1 = 'Yes: same computer';
      str2 = 'No: use this computer';
      str3 = 'No: select different';
      if outpostOK
        button = questdlg(qstring,'Confirm Network Access', str1, str2, str3, str1);
      else
        button = questdlg(qstring,'Confirm Network Access', str1, str3, str1);
      end
      if strcmp(button, str1) %'Yes: same computer'
        handles.logPath = h_logPath;
        handles.logPathName = h_logPathName;
      elseif strcmp(button, str2) % 'No: use this computer';
        handles.logPath = handles.DirLogs;
      elseif strcmp(button, str3) % 'No: select different';
        userNEWEST = 0;
      end
    else %if (1 == findstrchr('\\', handles.logPath))
      %if the .mat file exists, previous conditions have been loaded & should be used to override the defaults
      if (fidStore > 0)
        %local log:
        handles.logPath = h_logPath;
        handles.logPathName = h_logPathName;
      end
    end % if (1 == findstrchr('\\', handles.logPath)) else
  end % if ~logPathPassedIn
  
  if today
    list(5) = {sprintf('Accessing today''s Packet Log in %s. . .', handles.logPath)};
  else
    list(5) = {sprintf('Determining the most recent Packet Log in %s. . .', handles.logPath)};
  end
  set(handles.listboxAllStation,'string', list) ;
  setSortButtons(handles, 0);
  %get the most up-to-date log & the appropriate list of the paths for the log copies
  %  (the list is different for a log on this machine & for a log on a remote machine.
  handles = choseLog(handles, userNEWEST, today);
end %if ~(logPathNNamePassedIn)
%set default ordering the same as the log:
clearToggles1_6(handles);
set(handles.togglebutton1,'value',1);
%create the user-accessible menus
handles = createMenuBar(handles);


%for consistency with Matlab 2008
handles.output = figure1;
guidata(figure1, handles);
% if "handles.logPathName" is empty, this call will immediately return
[err, errMsg] = readNDspPckt(handles, handles.logPathName);
if err
  if today
    list = {};
    list(5) = {sprintf('Waiting for today''s Packet Log %s.csv', handles.logCoreName)};
    list(6) = {sprintf('in %s. . .', handles.logPath)};
    set(handles.listboxAllStation,'string', list) ;
  end
end
%activate the monitor (push the button)
set(handles.togglebuttonMonitorLog,'value', 1)
%tell the code the button has been pushed: this call will not end until/unless the user releases the button
% or closes the figure
handles = guidata(handles.figure1);
drawnow
%we'll stay in the montior loop until the operator turns off monitoring or attemps to close the figure
displayCounts('togglebuttonMonitorLog_Callback', handles.togglebuttonMonitorLog,[],handles);

%if not an attempt to close the figure....
handles = guidata(handles.figure1);
if ~(handles.closeRequest)
  %Wait for the callbacks to be run and the window to be dismissed
  uiwait(figure1)
end
CloseRequest(handles)

varargout{3} = figure1;
varargout{1} = err;
varargout{2} = strcat(modName, errMsg);
%---------- function varargout = displayCounts_OpeningFcn(varargin) ---------------

% --------------------------------------------------------------------
function varargout = listboxAllStation_Callback(h, eventdata, handles, varargin)
%When the operator selects a line other than the title/heading line,
% we'll enable the buttons which will open the message for viewing.  The
% exact buttons depend on whether the message is a PACF.
%When the operator selects the title/heading line, we'll disable the viewing buttons.
set(handles.listboxAllStation,'max',1)
val = get(h, 'Val');
a = 0 ;
% if operator chose a message line from the log (i.e: not the heading nor an informational line)....
if ~(ismember(val, handles.nonLogLines))
  %need to adjust the index based on the number of dead lines (non-log lines, ie informational)
  val = val - length(find(handles.nonLogLines < val));
  % increase the index by the number of logged lines that aren't being displayed
  val = val + length(find(handles.noDispLogLines < val));
  %support for re-ordering the display: take note of current selection
  ud = get(handles.listboxAllStation, 'UserData');
  ud.listSortedNdx = handles.listSortedNdx(val);
  set(handles.listboxAllStation, 'UserData', ud);
  %... and if we have a file path and name for the selection. . .
  if length(handles.logged{ud.listSortedNdx, find(ismember(handles.dispFieldNms,'fpathName'))} )
    %. . . allow the buttons to be appropriately enabled.
    a = 1;
  end
  [err, errMsg] = dispMsg2Scoreboard(handles, ud.listSortedNdx) ;
end 
if a
  %viewing of messages is enabled - text will be enabled & decide if PACF also.
  enable = 'on';
  a = {'Enable', enable, 'style', handles.typePushbuttonOpenOutpost};
  if findstrchr('simple',lower(char(handles.logged(ud.listSortedNdx, find(ismember(handles.dispFieldNms,'formType'))))) )
    %simple message - not a PACF so disabled PACF viewing
    set(handles.pushbuttonOpenPACF,'Enable', 'off','style','text');
  else
    %not simple - must be PACF so allow user to select PACF
    set(handles.pushbuttonOpenPACF,'Enable', enable,'style',handles.typePushbuttonOpenPACF);
  end
  %if operator doubled-clicked....
  if strcmp(get(handles.figure1,'SelectionType'),'open')
    %... open message in text mode
    pushbuttonOpenOutpost_Callback(h, eventdata, handles);
  end %if strcmp(get(handles.figure1,'SelectionType'),'open')
  %enable the print button
  % % set(handles.togglebuttonPrint,'Enable', enable,'style', handles.typeTogglebuttonPrint);
else %if a
  % viewing of messages is not enabled.
  enable = 'off';
  a = {'Enable', enable,'style', 'text'};
  set(handles.pushbuttonOpenPACF, a{:});
  %disable (grey out) the print button
  % % set(handles.togglebuttonPrint,'Enable', enable,'style','text');
end % if a else
%enable/disable text (aka Outpost) viewing
set(handles.pushbuttonOpenOutpost, a{:});
%enable/disable (grey out) the frame and the label for the frame & buttons
set(handles.frameOpen,'Enable', enable);
set(handles.textOpen,'Enable', enable);
% --------------------------------------------------------------------
function toggleLblOrder(h, handles, num)
val = get(h, 'Value');
strg = get(h, 'String');
clearToggles1_6(handles);
%button isn't clear by operator, only by the operator selecting a different sort
set(h, 'Value', 1);
if ~val
  %toggle the sort order
  if findstrchr('^', char(strg))
    %place newest/last at top
    set(h, 'String',strcat(handles.sortLabel(num), ' v'));
  else % if findstrchr('^', char(strg))
    %place oldest/first at top
    set(h, 'String',strcat(handles.sortLabel(num), ' ^'));
  end % if findstrchr('^', char(strg)) else
end % if ~val
displayLog(handles);
% --------------------------------------------------------------------
function varargout = togglebutton1_Callback(h, eventdata, handles, varargin)
%Log order - order as stored in log
toggleLblOrder(h, handles, 1)
% --------------------------------------------------------------------
function varargout = togglebutton2_Callback(h, eventdata, handles, varargin)
% From order
toggleLblOrder(h, handles, 2)
% --------------------------------------------------------------------
function varargout = togglebutton3_Callback(h, eventdata, handles, varargin)
% To order
toggleLblOrder(h, handles, 3)
% --------------------------------------------------------------------
function varargout = togglebutton4_Callback(h, eventdata, handles, varargin)
% Type order
toggleLblOrder(h, handles, 4)
% --------------------------------------------------------------------
function varargout = togglebutton5_Callback(h, eventdata, handles, varargin)
% ReplyReqd order
toggleLblOrder(h, handles, 5)
% --------------------------------------------------------------------
function varargout = togglebutton6_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = popupmenu1_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function displayLog(handles);
%space the heading based on the maximum number of characters of each entry/column
spaces(1:100)= ' ';
% handles.columnHeader
% We could actually use the header from the log.  Would need to change the tests
%that look at the listBox's selection that presently expect the header to be only on line 1
%to instead be based on the length of handles.columnHeader.  We could use the column "FileName"
%to be the first non-appearing column heading
%  One disadvantage is the the listBox doesn't support mixed fonts nor does it support highlighting
%more than one line.  Therefore the heading might not be as obvious.

ud = get(handles.listboxAllStation, 'UserData');
%columns in order specified in handles.dispColOrdr array
heading = '';
for jtemp = 1:size(handles.dispColOrdr,1)
  %if visible
  if handles.dispColOrdr(jtemp, 2)
    thisCol = handles.dispColOrdr(jtemp, 1) ;
    thisHdg = char(handles.dispColHdg(thisCol) );
    thisLen = handles.len(thisCol) ;
    %we may want to shorten or eliminate some headings based on the width
    %  of the data being displayed
    %The names in the "case" statements must match the names in "handles.dispColHdg"
    switch thisHdg
    case 'LOCAL-MSG-NO'
      if thisLen
        a = {thisHdg,'LCL-MSG-NO','LCL-MSG#','LCL-#','L#'};
        for itemp=1:length(a)
          if (length(char(a(itemp))) <= thisLen)
            break
          end
        end
        thisHdg = char(a(itemp));
      else
        thisHdg = '';
      end %if thisLen
    case 'TRANSFER-MSG-NO'
      if thisLen
        a = {thisHdg,'XFR-MSG#','XFR-#','X#'};
        for itemp=1:length(a)
          if (length(char(a(itemp))) <= thisLen)
            break
          end
        end
        thisHdg = char(a(itemp));
      else
        thisHdg = '';
      end %if thisLen
    case 'OUTPOST-TIME'
      if (thisLen < length(thisHdg))
        %time is at least 4 digits
        thisHdg = 'OTME';
      end %if (handles.len.shortOutpostDTime < length(a))
    case 'FORM-TIME'
      if (thisLen < length(thisHdg))
        if thisLen
          %time is at least 4 digits
          thisHdg = 'FTME';
        else
          thisHdg = '';
        end
      end %if (handles.len.shortOutpostDTime < length(a))
    case 'MSG-TYPE'
      if (thisLen < length(thisHdg))
        thisHdg = 'TYPE';
      end %if (handles.len.shortOutpostDTime < length(a))
    case 'COMMENT'
      if ~thisLen
        thisHdg = '';
      end %if (handles.len.shortOutpostDTime < length(a))
    otherwise
    end % switch thisHdg
    
    if jtemp < 2
      heading = sprintf('%s', sameLength(thisHdg, thisLen, spaces, 1)) ;
    else
      heading = sprintf('%s|%s', heading, sameLength(thisHdg, thisLen, spaces));
    end
  end %  if handles.dispColOrdr(jtemp, 2)
end % for jtemp = 1:size(handles.dispColOrdr,1)
%"heading" is the first line
heading = {heading};
% if we every have additional heading lines, they'd be built here.
% heading(2) = 

list = heading ;

%if we change the number of lines that make up the heading, this will track:
handles.nonLogLines = [1:length(list)];
%Determine which sort button was pressed
% the order is controlled by the button pushed by the operator
val = get(handles.togglebutton1,'value') + 2 * get(handles.togglebutton2,'value') + ...
  3 * get(handles.togglebutton3,'value') + 4 * get(handles.togglebutton4,'value') + ...
  5 * get(handles.togglebutton5,'value') + 6 * get(handles.togglebutton6,'value');
%disable display of a "conditions changed" line - skip display any
enableCndtChange = 0;
fldNm = [];
switch val
case 1
  handles.listSortedNdx = [1:size(handles.logged, 1)];
  %enable display of a "conditions changed" line
  enableCndtChange = 1 ;
  strg = get(handles.togglebutton1, 'String');
case 2 %From
  fldNm = 'from' ;
  strg = get(handles.togglebutton2, 'String');
case 3 %To
  fldNm = 'to';
  strg = get(handles.togglebutton3, 'String');
case 4 %Type
  fldNm = 'formType';
  strg = get(handles.togglebutton4, 'String');
case 5 %Reply
  fldNm = 'replyReqd';
  strg = get(handles.togglebutton5, 'String');
otherwise %Logged + unknown buttons
  % ****************************************************
  % ****************************************************
  % ****************** if time is every added for sorting
  % ******** be sure to sort on long/complete time, nto displayed/shortened time
  % ****************************************************
  % ****************************************************
  handles.listSortedNdx = [1:size(handles.logged, 1)];
  strg = '';
end % switch val
%if needed, sort by specified field
if length(fldNm)
  [a, handles.listSortedNdx] = sort(handles.logged(:,find(ismember(handles.dispFieldNms,fldNm))) );
end % if length(fldNm)
%determine operator's selection of display order
reverse = 0 ;
if ~(findstrchr('^', char(strg)))
  reverse = 1 ;
  handles.listSortedNdx = handles.listSortedNdx([length(handles.listSortedNdx):-1:1]);
end % if ~(findstrchr('^', char(strg)))

%initialize index to the number of lines we're already going to display 
%  i.e. the heading
listNdx = length(list);

%one improvement suggestion is to add the column heading labels every so
%many displayed lines.  If we do, the following lines need to be included in the 
% "for jtemp = 1:length(handles.listSortedNdx)" loop below
% for Ndx = 1:length(heading)
%   listNdx = listNdx + 1;
%   list(listNdx) = heading(Ndx);
%   %add this line index to the list of displayed lines that are not from the log
%   handles.nonLogLines(1+length(handles.nonLogLines)) = listNdx;
% end
handles.noDispLogLines = [];
conChgNdx = find(ismember(handles.dispFieldNms,'conditionChange')) ;
%if not highlighting the heading now or in the last display. . .
hiLitLine = get(handles.listboxAllStation,'value');
if (hiLitLine > length(heading)) & (ud.listSortedNdx > 0)
  hiLitLine = 0; %. . .enable locating the line last highlighted in the current list
end

for jtemp = 1:length(handles.listSortedNdx)
  thisLogLine = handles.listSortedNdx(jtemp);
  a = char(handles.logged{thisLogLine, conChgNdx} );
  if length(a)
    % this line is a conditions changed informational line
    %if displaying of informational line is enabled (i.e: sort order is per log)
    if (enableCndtChange)
      listNdx = listNdx + 1;
      if reverse
        a = strrep(a,'following','preceding');
      end
      %add to display
      list(listNdx) = {a};
    else % if (enableCndtChange)
      %displaying is not enabled - note this line in the log isn't displayed & then get next line
      %store the index to the sorted list
      handles.noDispLogLines(1+length(handles.noDispLogLines)) = jtemp;
    end % if (enableCndtChange) else
  else % if length(a)
    %extract the data for this line in the column order specified
    for Ndx = 1:size(handles.dispColOrdr,1)
      %if visible
      if handles.dispColOrdr(Ndx, 2)
        thisCol = handles.dispColOrdr(Ndx, 1) ;
        thisData = char(handles.logged(thisLogLine, thisCol));
        thisLen = handles.len(thisCol) ;
        %space each log entry based on the maximum number of m characters of each entry
        if Ndx < 2
          a = sprintf('%s', sameLength(thisData, thisLen, spaces, 1, handles.dispJust(thisCol)) );
        else
          a = sprintf('%s|%s', a, sameLength(thisData, thisLen, spaces, 0, handles.dispJust(thisCol)) );
        end
      end % if handles.dispColOrdr(Ndx, 2)
    end %for Ndx = 1:size(handles.dispColOrdr,1)
    listNdx = listNdx + 1;
    list(listNdx) = {a};
    if ~hiLitLine 
      if thisLogLine == ud.listSortedNdx
        hiLitLine = listNdx;
      end
    end
  end % if length(a) else
end %for jtemp = 1:length(handles.listSortedNdx)
setSortButtons(handles, 1);
set(handles.listboxAllStation,'string', list) ;
%safety valve in case bug & we didn't find the previously highlighted line
if ~hiLitLine
  hiLitLine = 1;
end
set(handles.listboxAllStation,'value',hiLitLine);

listboxAllStation_Callback(handles.listboxAllStation, [], handles)

beginPathName = shortPathName(handles.logPathName); 
[pathstr,name,ext,versn] = fileparts(handles.logPathName);
%want the drive/network identification
a = findstrchr('\', pathstr);
hm = '';
if a
  b = find(a > 2);
  if length(b)
    a = a(b(1));
    hm = strcat(pathstr(1:a),'...');
  end
end
%update the disply of the log's name. . . 
set(handles.textLogName, 'string', sprintf('%s    %s', beginPathName, handles.header.logFDate)) ; 
%... and the associated ToolTip
a = '';
for itemp = 1:length(handles.header.line)
  a = sprintf('%s  %s\r\n', a, char(handles.header.line(itemp)));
end
set(handles.textLogName, 'ToolTip',...
  sprintf('Currently displayed Packet Log\r\n  Log name: %s%s\r\n  Log path: %s\r\n  Log date && time: %s\r\n  Total entries: %i\r\nHeader:\r\n%s',...
  name,ext, handles.logPath, handles.header.logFDate, size(handles.logged, 1), a));
guidata(handles.figure1, handles); %store handles.listSortedNdx
% -------------^^ function displayLog(handles) ^^-------------------------------------------------------
function [err, errMsg] = readNDspPckt(handles, logPathNName)
if ~length(logPathNName)
  err = 0;
  errMsg = '';
  return
end
[err, errMsg, logged, header, columnHeader] = readPacketLog(logPathNName) ;
if err
  set(handles.listboxAllStation,'string', errMsg) ;
  setSortButtons(handles, 0);
  return
end
%move highlight to first line: new load of log
set(handles.listboxAllStation,'value',1)
if (1 == findstrchr('\\', handles.logPath))
  [err, errMsg, handles.pathsTologCopies] = readProcessOPM_Logs(handles.configDir,...
    'network_PkLgMonitor_logs.ini','This file is used by "%s" when monitoring a Packet Log on a network.');
else
  %log is from a local drive: read the locations for the copies of the logs:
  [err, errMsg, handles.pathsTologCopies] = readProcessOPM_Logs(handles.configDir);
end

%update the log type popup appropriately
val = 1 ;
if findstrchr('_Recvd', logPathNName)
  val = 2;
elseif findstrchr('_Sent', logPathNName)
  val = 3;
end
set(handles.popupmenuWhichLog, 'Value', val);

%reformat the address information to remove excess information
% that can be present after an "@"
for itemp = 1:length(logged)
  % to improve readability, we'll lower case anything after the "@" 
  logged(itemp).from = cleanStationAddress(logged(itemp).from);
  logged(itemp).to = cleanStationAddress(logged(itemp).to);
end %for itemp = 1:length(logged)

%if the logged date is the same as the date of the log,
% only include the time
%1) get the log's date
% find the location of digits
c = (ismember(handles.logCoreName, '0123456789'));
% find the prefix "_"
aa = findstrchr('_', handles.logCoreName) ;
% find the first prefix that is followed contiguously by 6 digits
found = 0;
for itemp = 1:length(aa)
  if sum(c(aa(itemp)+[1:6])) == 6
    found = 1;
    break
  end
end
if found
  a = handles.logCoreName(aa(itemp)+[1:6]);
  logDate = datenum(sprintf('%s/%s/%s', a((length(a)-3):(length(a)-2)), a((length(a)-1):(length(a))),a(1:(length(a)-4))));
  for itemp = 1:length(logged)
    logged(itemp).shortOutpostDTime = cleanDateTime(logged(itemp).outpostDTime, logDate);
    logged(itemp).shortFormDTime = cleanDateTime(logged(itemp).formDTime, logDate);
    logged(itemp).shortOutpostPostTime = cleanDateTime(logged(itemp).outpostPostTime, logDate);
  end %for itemp = 1:length(logged)
end % if found


%determine the longest string for each field:
% RATHER than doing a fixed, hard coded determination like this....
%           len.xfrMsgNo = size(char(logged.xfrMsgNo),2);
%..... lets do one for each field of "logged" regardless of the names
%  because this keeps code maintenance simpler - when new fields are added, we'll
%  only need to fiddle with the code where those fields are used & not in this support operation:
fn = fieldnames(logged);
len = {}; %create the variable
for fieldNdx = 1:length(fn)
  %get the name of a variable in the structure "logged"
  thisField = char(fn(fieldNdx));
  %make sure we know of this name
  if ~find(ismember(handles.dispFieldNms,thisField))
    handles.dispFieldNms(length(handles.dispFieldNms)+1) = {thisField};
  end
  %add a field to the len structure of the same name & give it the value associated with the first logged entry
  len = setfield(len, thisField, length(getfield(logged, {1,1}, thisField)));
  %cylce through the remaining logged entries & store the largest
  for itemp = 2:length(logged)
    thisLen = length(getfield(logged, {1,itemp}, thisField));
    if getfield(len, thisField) < thisLen
      len = setfield(len, thisField, thisLen);
    end %if getfield(len, thisField) < thisLen
  end % for itemp = 2:length(logged)
end % for fieldNdx = 1:length(fn)

% It can be confusing to the operator if the column widths change when the log type
%is switched among Sent&Rec'd, Received, and Sent.  We'll use the larger of the
%current log's widths or the width's developed from Sent&Rec'd.  This allows us
%to monitor a log other than Sent&Rec'd and respond to new data that is wider.  Of course
%since all logs are update by the same program, when we next check Sent&Rec'd its widths
%will reflect the new values.  In other words, we don't want to lock to the Sent&Rec'd widths
%from the last time we were monitoring that log since those widths may become too narrow.
%  if NOT Sent&Rec'd
if (1 ~= get(handles.popupmenuWhichLog,'Value') ) 
  % if values exist in handles (i.e." if we've loaded a log)
  fn = fieldnames(handles);
  if length(find(ismember(fn,'len')))
    %compare the values for the current log type to the existing values....
    for itemp = 1:length(handles.dispFieldNms)
      thisLen = char(handles.dispFieldNms(itemp)) ;
      %... if the current log's item's width is shorter than the existing value...
      if getfield(len, thisLen) < handles.len(itemp)
        %... set the current's width to the existing value
        len = setfield(len, thisLen, handles.len(itemp));
      end % if getfield(len, thisLen) < handles.len(itemp)
    end % for itemp = 1:length(hlen)
  end % if length(find(ismember(fn,'len')))
end % if (1 ~= get(handles.popupmenuWhichLog,'Value') ) 

handles.len = [] ;
handles.logged = {} ;
for itemp = 1:length(handles.dispFieldNms)
  handles.len(itemp) = getfield(len,char(handles.dispFieldNms(itemp))) ;
  for jtemp = 1:length(logged)
    handles.logged(jtemp, itemp) = {getfield(logged(jtemp),char(handles.dispFieldNms(itemp)))} ;
  end %for jtemp = 1:length(logged)
end % for itemp = 1:length(fl)
handles.header = header;
handles.columnHeader = columnHeader;
guidata(handles.figure1, handles)

%fill in the scoreboard: for each station, number sent, received, etc.
displayScoreboard(handles, logged, len);

%display the log
displayLog(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [textBack] = sameLength(newText, lengthNeeded, spaces, resetCol, justify);
%pads "newText" to be the required length.  If newText is longer than
%  the required length it will be full returned AND the length of the overage
%  will be remembered.  The overage will result in the padding for subsequent
%  calls being reduced until there is no more overage
%INPUTS:
% newText: the text of interest
% lengthNeeded: total number of characters required: new text + pad
% spaces: a long string of spaces for padding
% resetCol[optional]: 1: cancel any overage.  Used for a new line. If
%   no present or 0, excessCol internally managed
% justify[optional]: 0 or not present: left justify (pad at end)
%   1: right justify (pad in beginning)
persistent excessCol

if nargin < 4
  resetCol = 0;
end
if nargin < 5
  justify = 0;
end
if resetCol
  excessCol = 0;
end
% if any previous "newText" was too long, we're stuck with this
% entry being offset but we might be able to absorb the issue if we have a short
% entry now - we just need to shorten the padding of spaces.
if length(newText) > lengthNeeded
  excessCol = length(newText) - lengthNeeded + excessCol;
else % if length(newText) > lengthNeeded
  if excessCol
    %shorten the padding as needed....
    lengthNeeded = lengthNeeded - excessCol;
    if lengthNeeded < 0
      %but we can't reduce it by more than what's defined as available:
      %  store how many we can't absorb...
      excessCol = 1 - lengthNeeded;
      % ... and set the minimum to 1
      lengthNeeded = 0 ;
    else % if lengthNeeded < 0
      excessCol = 0;
    end % if lengthNeeded < 0 else
  end % if excessCol
end % if length(newText) > lengthNeeded
if lengthNeeded > length(spaces)
  spaces(1:lengthNeeded) = ' ';
end
if (justify == 1)
  %right justify: additional spaces before newText
  textBack = sprintf('%s%s', spaces(1:(lengthNeeded-length(newText))), newText);
else
  textBack = sprintf('%s%s', newText, spaces(1:(lengthNeeded-length(newText))));
end  
%%%%%%%%%%%%%%%%%% function [textBack] = sameLength(ne %%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function varargout = pushbuttonOpenOutpost_Callback(h, eventdata, handles, varargin)
val = get(handles.listboxAllStation, 'Val');
% This module checks to see if the current file is already in a view
%and if so merely switch to that view; if not in a view, open a view
if ~(ismember(val, handles.nonLogLines))
  %need to adjust the index based on the number of dead lines (non-log lines, ie informational)
  val = val - length(find(handles.nonLogLines < val));
  % increase the index by the number of logged lines that aren't being displayed
  val = val + length(find(handles.noDispLogLines < val));
  msgPathName = repathIfNet(handles.logged(handles.listSortedNdx(val),find(ismember(handles.dispFieldNms,'fpathName'))), handles);
  %scan to see if the window is already open
  if length(find(ismember(handles.h_displayTextPathName, msgPathName)))
    a = find(ismember(handles.h_displayTextPathName, msgPathName)) ;
    figure(handles.h_displayText(a(1)));
  else %if length(find(ismember(handles.h_displayTextPathName, msgPathName)))
    %window is not open: create one
    %read the file into a cell array & then pass to the listBox of displayText
    fid = fopen(msgPathName, 'r');
    if fid < 1
      errordlg(sprintf('Unable to open "%s"', msgPathName),'File Error');
      return
    end
    %update book keeping
    handles.h_displayTextNdx = handles.h_displayTextNdx + 1;
    %open a new window for the file's contents
    handles.h_displayText(handles.h_displayTextNdx) = displayText;
    handles.h_displayTextPathName(handles.h_displayTextNdx) = {msgPathName} ;
    
    %store all the information we've just updated
    guidata(handles.figure1, handles)
    % get handles of the new window
    handlesText = guidata(handles.h_displayText(handles.h_displayTextNdx));
    ud = get(handlesText.figure1, 'userdata');
    %name the figure: last folder of the path + file name
    % ex: "...\SentTray\Message_091102190538; EOC MESSAGE FORM_9.txt"
    [beginPathName, beginEndPathName] = shortPathName(msgPathName);
    set(handlesText.figure1, 'name', beginEndPathName); 
    list = {};
    count = 0;
    asReadCnt = 0;
    %populate the "heading" area: we're getting the data from 6 heading lines
    % so we'll quit loading the head when we reach that number or when 
    % a line starts with something other than a recognized heading
    hdgLine = 0; % heading display number
    % names/titles of the lines as they appear in the message
    hdgNames = {'bbs:','from:','to:','subject:',...
        'sent:','received:'};
    hdgNamesNdx = [1:length(hdgNames)] ;
    specialHdg = {'local msg.#','local msg id','_message'} ;
    specialHdgFound = 0;
    %by inspection: longest heading is "subject:" which has ":" in 8th position
    spaces(1:7) = ' ' ;
    while hdgLine < 7 ;
      textLine = fgetl(fid) ;
      a = lower(textLine);
      for itemp = 1:length(specialHdg)
        b = findstrchr(specialHdg{itemp}, a);
        if b
          b = b(1);
          % if "_message"
          if itemp == 3
            %no local ID
            % set the local ID field to be a blank
            set(handlesText.textHdg6, 'string', '');
            c = textLine;
          else
            %local id is present
            set(handlesText.textHdg6, 'string', textLine(b:length(textLine)) );
            c = textLine(1:b-1);
          end
          % from the Message Type, pull the "_" which are there only for the script
          c = strtrim(strrep(c, '_', ' '));
          set(handlesText.textMsgType, 'string', c)
          specialHdg = {};
          hdgLine = hdgLine + 1;
          a = ''; %clear: use as flag to indicate we've found it
          break
        end % if findstrchr(specialHdg{itemp}, textLine)
      end % for itemp = 1:length(specialHdg)
      if specialHdgFound | length(specialHdg)
        for hdgNamesNdx = 1:length(hdgNames)
          if (1 == findstrchr(a, char(hdgNames(hdgNamesNdx))))
            b = findstrchr(':', textLine);
            %only want one space after the first ":"
            c = strtrim(textLine(b(1)+1:length(textLine)));
            textLine = sprintf('%s %s', textLine(1:b(1)), c);
            %by inspection: longest heading is "subject:" which has ":" in 8th position
            textLine = sprintf('%s%s', spaces(1:(8-b(1))), textLine);
            hdgLine = hdgLine + 1;
            switch hdgNamesNdx
            case 1 % BBS
              set(handlesText.textHdg1, 'string', textLine);
            case 2 % From
              set(handlesText.textHdg2, 'string', textLine);
            case 3 % To
              [textLine, newpos] = textwrap(handlesText.lbHdg3, {textLine});
              if length(textLine) > 1
                sty = 'listbox';
              else
                sty = 'text';
                posit = get(handlesText.lbHdg3, 'Position');
                % ui is taller than needed: adjust bottom...
                posit(2) = posit(2) + (posit(4) - newpos(4));
                %.. reduce heigh
                posit(4) = newpos(4);
                % move "Subject:" box up/down page to touch bottom of "To:" which is
                %  different height when listbox vs text
                b = get(handlesText.textHdg4, 'Position');
                mv = posit(2) - (b(2) + b(4));
                b(2) = b(2) + mv;
                set(handlesText.textHdg4, 'Position', b);
                posit(1) = b(1);
                set(handlesText.lbHdg3, 'Position', posit);
                % raise height of list box
                posit = get(handlesText.listbox1, 'Position');
                % gap?
                mv = b(2) - (posit(2) + posit(4));
                posit(4) = posit(4) + mv ;
                set(handlesText.listbox1, 'Position', posit);
              end
              set(handlesText.lbHdg3, 'style', sty, 'string', textLine);
            case 4 % Subject
              set(handlesText.textHdg4, 'string', textLine);
            case {5 6} % time (sent/received)
              set(handlesText.textHdg5, 'string', textLine);
            end % switch hdgLine
            a = ''; %clear: use as flag to indicate we've found it
            break;
          end % switch hdgLine
        end % for hdgNamesNdx = 1:length(hdgNames)
      else % if specialHdgFound
        specialHdgFound = ~length(specialHdg);
      end % if specialHdgFoundelse
      if length(a)
        %not a recognized heading line: must have gone beyond heading!
        break; %the while
      end
    end %while hdgLine < 5
    while ~feof(fid)
      if length(a)
        a ='';
      else
        textLine = fgetl(fid);
      end
      %replace each TAB with up to 8 spaces
      textLine = tabToSpaces(textLine);
      asReadCnt = asReadCnt + 1;
      listAsRead(asReadCnt) = {textLine};
      outstring = textwrap(handlesText.listbox1, {textLine});
      list(count+[1:length(outstring)]) = outstring;
      count = length(list);
    end % while ~feof(fid)
    fclose(fid);
    %pass the extracted file contents to the listbox of the window
    set(handlesText.listbox1, 'string', list);
    
    %If the user closes the subpanel directly (i.e. not using this figure's toggle button), we want
    %the operation to be as if that toggle button had been released by the user.  We achieve that by having the
    %subpanel's CloseRequestFnc call the same function that toggle button activates.  This is accomplished by
    %having a line in that CloseRequestFnc with the following syntax:
    %  <this mfilename>(<toggle button callback name>, <>, <>, guidata(<this fig's handle>), 0)
    %The most general case is to allow the subpanel to be used by more than one master panel.  This
    % means we need to provide three things: <this mfilename>, <toggle button callback name>, & <this fig's handle>.
    %We'll store them in the subpanel fig's "user data" field
    ud.callingProgram = mfilename;  %this file's name. 
    
    %name of module in this program to be called when the just opened windows is being closed.
    ud.callBackName = 'closeTextView_Callback';
    % this module's figure
    ud.callingFigure = handles.figure1;
    % name of the file being displayed
    ud.displayedFilePathName = msgPathName;
    ud.listAsRead = listAsRead;
    % update the user data field. . .
    set(handlesText.figure1,'userdata',ud)
    %. . . and store the subpanel's updated ud information back into the subpanels figure's handle structure
    guidata(handles.h_displayText(handles.h_displayTextNdx), handlesText);
    
    % cascade the displayText figure window
    %values in assigned to handles.subLeftOffset & .subDownOffset are based on the position units being "characters"
    %  We'll temporarily force them to this
    origUnits = get(handlesText.figure1,'units');
    origUnitsMain = get(handles.figure1,'units');
    set(handlesText.figure1,'units', 'characters');
    set(handles.figure1,'units', 'characters');
    %The offset is referenced to the preceding displayText window if any
    % or to the Packet Log window if we are opening the first display window
    if handles.h_displayTextNdx < 2
      refLeftBotWidHeight = get(handles.figure1,'position');
    else
      refLeftBotWidHeight = get(handles.h_displayText(handles.h_displayTextNdx-1),'position');
    end
    %   learn the figure's current position: we're going to ignore its position but need its width & height
    subLeftBotWidHeight = get(handlesText.figure1,'position');
    %   set to position to the left of the main panel by the amount handles.subLeftOffset * handles.h_displayTextNdx
    subLeftBotWidHeight(1) = refLeftBotWidHeight(1) - handles.subLeftOffset; 
    % We want the title bar to be visible for the subpanel figure without covering the main's top bar
    %   set so the top of the sub will be below the top of the main
    %      by the amount handles.subDownOffset * handles.h_displayTextNdx
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
    subLeftBotWidHeight(2) = topRef - subLeftBotWidHeight(4) - handles.subDownOffset;
    %We don't want the figure to be positioned off the bottom or the left of the screen!
    %  Various options: allow none of the window to go off the bottom; allow part off; allow
    %all but the title bar.  Other options are to limit the window position or to restart the window position 
    %vertically but keep its horizontal index. We'll go with the common implementation of restarting
    %the vertical position
    %if     below the screen bottom OR  to the left of the left edge           
    if (subLeftBotWidHeight(2) < 1 ) | (subLeftBotWidHeight(1) < 1 )
      %get the new reference
      if handles.h_displayTextNdx < 2
        refLeftBotWidHeight = get(handles.figure1,'position');
      else
        refLeftBotWidHeight = get(handles.h_displayText(1),'position');
      end
      %if below the screen bottom 
      if (subLeftBotWidHeight(2) < 1 )
        % move to be one offset below the new reference
        topRef = refLeftBotWidHeight(2) + refLeftBotWidHeight(4);
        subLeftBotWidHeight(2) = topRef - subLeftBotWidHeight(4) - handles.subDownOffset;
      end
      %if  to the left of the left edge
      if (subLeftBotWidHeight(1) < 1 )
        % move to be one offset to the left of the new reference
        subLeftBotWidHeight(1) = refLeftBotWidHeight(1) - handles.subLeftOffset;
      end
    end
    
    %reposition the figure
    set(handlesText.figure1,'position', subLeftBotWidHeight);
    %restore the original units
    set(handlesText.figure1,'units', origUnits);
    set(handles.figure1,'units', origUnitsMain);
    set(handlesText.listbox1,'ToolTip',sprintf('Message is from Packet Log:\n%s\nMessage location:\n%s', handles.logPathName, msgPathName));
    set(handlesText.listbox1,'Visible', 'on')
    %make the new displayText window visible
    set(handlesText.figure1,'Visible', 'on')
  end % else if length(find(ismember(handles.h_displayTextPathName, msgPathName)))
end % if val > 1
% --------------------------------------------------------------------
function varargout = pushbuttonOpenPACF_Callback(h, eventdata, handles, varargin)
%Calls "pac-read.exe" to convert the message from ASCII to PACForms and then
%  open a browser.  Because that routine renames the original file which is the file
%  we also are accessing, we will create a copy for it to rename and then delete the
%  copy to keep the clutter down.  This is all best (fastest) performed with a batch
%  file so we only need to access the system once. 
%pac-read operating on a quote path doesn't properly pass the path to the browser
% so we'll tell pac-read to not open the browser & do it in our batch file.

%pac-read.exe $1 INI C:\PacFORMS\data\sent\sample.tx

val = get(handles.listboxAllStation, 'Val');
%confirm we're not pointing to the heading or a conditioned changed informational line
if ~(ismember(val, handles.nonLogLines))
  %need to adjust the index based on the number of dead lines (non-log lines, ie informational)
  val = val - length(find(handles.nonLogLines < val));
  % increase the index by the number of logged lines that aren't being displayed
  val = val + length(find(handles.noDispLogLines < val));
  %get the name of the button as established elsewhere
  outText = get(handles.pushbuttonOpenPACF,'string');
  %rename the button because this process takes a bit & therefore operator needs to know WIP
  set(handles.pushbuttonOpenPACF,'string','working');

  msgPathName = repathIfNet(handles.logged(handles.listSortedNdx(val),find(ismember(handles.dispFieldNms,'fpathName'))), handles);
  [err, errMsg] = viewPACF(handles.DirPF, handles.workingDir, msgPathName);
  %all done: restore the button name
  set(handles.pushbuttonOpenPACF,'string',outText);
end
%release the button
set(handles.pushbuttonOpenPACF,'val', 0);

% --------------------------------------------------------------------
function varargout = displayCounts_CloseRequestFcn(hObject, eventdata, handles, varargin)
%Called when user attempts to close this program's window.
% 1) Closes any text display windows of messages (don't know how to track nor close 
% lose the browser windows opened for a PACF) 
% 2) Saves certain conditions and variables for initialization of the next run.
% 3) closes this window (and exits)

%find the text windows we think are open - PACF windows are open indirectly via pac-read.exe
%  so we don't know where they are
a = find(handles.h_displayText);
%  go through the entire list of open figures
for itemp = 1:length(a)
  % close the figure
  % use try/catch just in case the sub panel figure was closed in some manner or another
  %  that we didn't detect.  In other words, do not assume that we know the figure status. 
  %  This merely avoids a error message 
  try
    delete(handles.h_displayText(a(itemp)));
  catch
  end
  % clear the associated status flag
  handles.h_displayText(a(itemp)) = 0 ;
end
%store the figure's position (& size)
FigMPposition = get(handles.figure1, 'Position');
% lets add "h_" to each as an indicator the variable is part of the handles structure
h_logPath = handles.logPath;
h_logCoreName = handles.logCoreName;
h_logPathName = handles.logPathName;
h_recentLogs = handles.recentLogs;
h_viewSummary = handles.viewSummary;
h_viewDetail = handles.viewDetail;

% aid for the load process: as we change the variables & what is stored, this will facilitate
%  program flow
storeVersion = 2; %2: added viewDetail & viewSummary
nameForStore = handles.nameForStore;
save(nameForStore, 'FigMPposition', 'h_logCoreName', 'h_logPath',...
  'h_logPathName', 'storeVersion', 'h_recentLogs', 'h_viewSummary', 'h_viewDetail');

%if the monitor loop is running, we'll tell it to perform the shutdown
%   that's a little scary in the event there is a hang
if handles.monitoring
  %set flag
  handles.closeRequest = 1;
  % % sometimes even though the monitor was running, it doesn't always exit.  Might
  % be hung trying to update the status of a copy location
  % % we'll reset it here to allow second click from user to affect a closure
  handles.monitoring = 0;
  guidata(handles.figure1, handles)
  %release the button
  set(handles.togglebuttonMonitorLog,'value',0);
  togglebuttonMonitorLog_Callback(handles.togglebuttonMonitorLog, [], handles);
else
  %monitor not running: do the shutdown
  uiresume(handles.figure1)
end
% --------------------------------------------------------------------
function CloseRequest(handles)
% close the figure
delete(handles.figure1)
% delete the files used to indicate when this program is running.
delete(strcat(handles.programRunning, '*.txt'));
delete(handles.programRunningSimpleExt);
%same line in writeCopy
fName = sprintf('%s%scopy.txt', handles.logPath, handles.semaphoreCoreName);
if length(dir(fName))
  delete(fName)
end
% --------------------------------------------------------------------
function clearToggles1_6(handles);
%release all the sort criteria buttons
set(handles.togglebutton1,'value',0);
set(handles.togglebutton2,'value',0);
set(handles.togglebutton3,'value',0);
set(handles.togglebutton4,'value',0);
set(handles.togglebutton5,'value',0);
set(handles.togglebutton6,'value',0);
% --------------------------------------------------------------------
function varargout = popupmenuWhichLog_Callback(h, eventdata, handles, varargin)
%User selection of which of the fundamental log types: combined (sent & received),
%  received only, and sent only.  These are actually separate logs although all
%  are written at the same time.
val = get(h, 'Val');
switch val
case 1
  handles.logPathName = sprintf('%s%s.csv', handles.logPath, handles.logCoreName);
case 2
  handles.logPathName = sprintf('%s%s_Recvd.csv', handles.logPath, handles.logCoreName);
case 3
  handles.logPathName = sprintf('%s%s_Sent.csv', handles.logPath, handles.logCoreName);
otherwise
end
%position to the heading - data has changed as well as prevented it from being beyond end of list
set(handles.listboxAllStation,'val',1);
[err, errMsg] = readNDspPckt(handles, handles.logPathName);
% --------------------------------------------------------------------
function handles = choseLog(handles, userNEWEST, today);
% logName = choseLog(handles[, userNEWEST[, today]])
%ACTION
% Operates in the directory specified in handles.logPath
% userNEWEST[optional]: 
%      0 or not present: will open an explorer-like window
%        that will allow user to chose the desired log.  This permits
%        selecting a computer on the network.
%      1: opens the most up-to-date sent&received log based
%        on the system's file date-time & named "packetCommLog_*.csv"
%        or today's if "today" is set.
% today[optional]: 
%      0: or not present: action is controlled by
%        'userNEWEST' -> most recent or user selection.
%      1: will open today's log with the log source controlled by userNEWEST.
%Updates handles via guidata as needed for handles.logPath, handles.logCoreName,
% & handles.logPathName -> guidata(handles.figure1, handles);
%If no log found when userNEWEST is set, handles.logCoreName,
% & handles.logPathName will be null.

if nargin < 2
  userNEWEST = 0;
end
if nargin < 3
  today = 0;
end
if ~userNEWEST % if userNEWEST
  %userNEWEST == 0: allow user to chose
  currentDir = pwd;
  a = dir(strcat(handles.logPath,'*.'));
  if length(a)
    cd (handles.logPath);
  else
    handles.logPath = handles.DirLogs;
    a = dir(strcat(handles.logPath,'*.'));
    if length(a)
      cd (handles.logPath);
    end
  end
  %if accessing network, bring up message
  if (1 == findstrchr('\\', handles.logPath))
    b = sprintf('Accessing network which may take a moment or two.');
    b = sprintf('%s (this message will automatically close or you may close it)', b);
    h_help = helpdlg(b, 'Accessing network');
    set(h_help, 'tag', mfilename); %for general closing...
  end
  [fname, pname] = uigetfile('packetCommLog_*.csv');
  cd (currentDir);
  if (1 == findstrchr('\\', handles.logPath))
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
  end
  % if cancel:
  if isequal(fname,0) | isequal(pname,0)
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
    return
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
  end
  handles.logPath = pname;
end % if userNEWEST 
if today
  %build today date string
  %same code as in "processOutpost Packet Messages" - change one, change both
  [err, errMsg, date_time, prettyDateTime, Yr, Mo, Da, Hr, Mn, Sc] = datevec2timeStamp(now);
  a = findstrchr('_', date_time);
  fname = sprintf('packetCommLog_%s.csv', date_time(1:a-1) ) ; %just want the date
else % if today
  if userNEWEST
    %want the newest log located in the same place the previous log was
    a = dir(sprintf('%spacketCommLog_*.csv', handles.logPath));
    if length(a)
      %sort by name: this will place list in date order because of the naming convention
      [b, Ndx]=sort({a.name}) ;
      a = a(Ndx);
    else %if length(a)
      %no file found
      list(5) = {sprintf('No Packet Log found in %s. . .', handles.logPath)};
      set(handles.listboxAllStation,'string', list) ;
      handles.logCoreName = '' ;
      handles.logPathName = '' ; 
      guidata(handles.figure1, handles);
      %%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%
      return
      %%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%
    end % if length(a) else
    %Exclude _Sent & _Recvd logs:
    count = 0;
    Ndx = [];
    for itemp =  1:length(a)
      b = findstrchr('_Recvd', a(itemp).name) + findstrchr('_Sent', a(itemp).name) + findstrchr('_sprt', a(itemp).name);
      if ~b
        count = count + 1;
        Ndx(count) = itemp;
      end
    end
    a = a(Ndx);
    fname = a(length(a)).name;
  end
end % if today else
handles.logCoreName = extractCoreName(fname); %local function
handles.logPathName = sprintf('%s%s', handles.logPath, fname); 
%if log is from a network drive
guidata(handles.figure1, handles);
set(handles.listboxAllStation,'val',1);
% ------------- ^^^^^^^^ function choseLog ^^^^^^^
% --------------------------------------------------------------------
function setSortButtons(handles, offON);
if offON
  enable = 'on';
else
  enable = 'off';
end
set(handles.togglebutton1,'Enable',enable);
set(handles.togglebutton2,'Enable',enable);
set(handles.togglebutton3,'Enable',enable);
set(handles.togglebutton4,'Enable',enable);
set(handles.togglebutton5,'Enable',enable);
set(handles.togglebutton6,'Enable',enable);
set(handles.popupmenu1,'Enable',enable);
% --------------------------------------------------------------------
function varargout = edit_Callback(h, eventdata, handles, varargin)
% Pull down menu.  chosing Edit is a noop
% --------------------------------------------------------------------
function varargout = view_Callback(h, eventdata, handles, varargin)
% Pull down menu.  chosing View is a noop
% --------------------------------------------------------------------
function varargout = file_Callback(h, eventdata, handles, varargin)
% Pull down menu.  chosing File is a noop
% --------------------------------------------------------------------
function varargout = fileTodayLog_Callback(h, eventdata, handles, varargin)
%menu: File > Today's
% get today's log in the existing location, whether or not the local machine
handles = choseLog(handles, 1, 1);
[err, errMsg] = readNDspPckt(handles, handles.logPathName);
guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function handles = updateRecentFileList(handles);
%returns "hanldes" because it modifies some values & saves them
%  This return means the calling function doesn't "handles = guidata(handles.figure1);"
%check if this log is already in the recent log list...
if find(ismember(handles.recentLogs, handles.logPathName))
  %.. in list: move to top
  itemp = find(ismember(handles.recentLogs, handles.logPathName));
  Ndx = [1:(itemp-1) (itemp+1):length(handles.recentLogs)];
  handles.recentLogs = handles.recentLogs([itemp Ndx]);
else
  %.. not in list: add to top
  % Arbitrarily "most recent" list limited to 10 - all 
  %use the same single callback so this number can be changed with any hassle
  Ndx = [1:min(9,length(handles.recentLogs))];
  handles.recentLogs(Ndx+1) = handles.recentLogs(Ndx);
  handles.recentLogs(1) = {handles.logPathName};
end
guidata(handles.figure1, handles);
createRecentFileMenu(handles);
% --------------------------------------------------------------------
function varargout = fileOpen_Callback(h, eventdata, handles, varargin)
%menu: File > Open
handles = choseLog(handles, 0);
[err, errMsg] = readNDspPckt(handles, handles.logPathName);
updateRecentFileList(handles);
% --------------------------------------------------------------------
function varargout = fileLocalLog_Callback(h, eventdata, handles, varargin)
%menu: File > Local logs
handles.logPath = handles.DirLogs;
handles = choseLog(handles, 0);
[err, errMsg] = readNDspPckt(handles, handles.logPathName);
updateRecentFileList(handles);
% --------------------------------------------------------------------
function varargout = filePrintLog_Callback(h, eventdata, handles, varargin)
% % % no sure this makes any difference!  Nice if it allows landscape mode!
% % %  can't test on this machine because nothing on LPT1
% % printdlg('-setup',handles.figure1)

% % prompt  = {'Lines per page:'};
% % title   = 'Printer characteristics';
% % lines= 1;
% % def     = {num2str(handles.printerLinesPerPage)};
% % answer  = inputdlg(prompt,title,lines,def);
% % if ~length(answer)
% %   return
% % end
% % handles.printerLinesPerPage = str2num(answer{1});
% % guidata(handles.figure1, handles);
[err, errMsg] = printLog(handles);
% --------------------------------------------------------------------
function [err, errMsg] = printLog(handles)
%Count pages and then print
[err, errMsg, modName] = initErrModName(strcat(mfilename, '(printLog)'));

handles.logPrintFirstPageNum = 1;
handles.logPrintStartLogLine = 1;
[err, errMsg, lastPagePrt, lastLogLinePrt] = logPrint(handles);

% the following was setup to print the log as sorted & displayed. 
%  not going to use it not but loath to remove it quite yet..

% % totalPages = 0;
% % displayedLog = get(handles.listboxAllStation,'string');
% % [err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
% % %pull seconds.  ex: 15:01:59.7810 -> 15:01
% % a = findstrchr(':', prettyDateTime);
% % prettyDateTime = prettyDateTime(1:a(2)-1);
% % for loopNdx = 1:2
% %   displayedLogNdx = 2;
% %   lineCount = 0;
% %   thisPage = 0;
% %   % initialize the text output array
% %   textToPrint([1:handles.printerLinesPerPage]) = {''};
% %   % loop through the log until all entires are printed using as many pages as needed
% %   while displayedLogNdx <= length(displayedLog)
% %     %here because starting a new page
% %     thisPage = thisPage + 1;
% %     %place the header from the log at the top of the page & include a page count on the second line
% %     for itemp = 1:length(handles.header.line)
% %       lineCount = lineCount + 1;
% %       if itemp == 2
% %         textToPrint(lineCount) = {sprintf('%s Page %i of %i printed %s', char(handles.header.line(itemp)), thisPage, totalPages, prettyDateTime)};
% %       else % if itemp == 2
% %         textToPrint(lineCount) = handles.header.line(itemp);
% %       end % if itemp == 2 else
% %     end % for itemp = 1:length(handles.header.line)
% %     %the column heading
% %     lineCount = lineCount + 1;
% %     textToPrint(lineCount) = displayedLog(1);
% %     %keep adding the actual logged information until we've filled the page or reached the end of the log
% %     while (lineCount < handles.printerLinesPerPage) & (displayedLogNdx <= length(displayedLog))
% %       lineCount = lineCount + 1;
% %       textToPrint(lineCount) = displayedLog(displayedLogNdx);
% %       displayedLogNdx = displayedLogNdx + 1;
% %     end
% %     %if second time through we've got the page count so we can accurately print
% %     if loopNdx > 1
% %       fname = sprintf('%stempPrint.txt', handles.workingDir); 
% %       fid = fopen(fname, 'w');
% %       if fid > 0
% %         %if first time printing
% %         if (thisPage < 2)
% %           %                                    (draftLETR, portraitLANDSCAPE)
% %           [initString, EjectPageTxt] = initPrintStrings(0, 1);
% %           fprintf(fid, '%s', initString);
% %         end
% %         % dump this page to a file
% %         for itemp = 1:lineCount
% %           fprintf(fid, '%s\r\n', char(textToPrint(itemp)));
% %         end
% %         %form feed: eject the page:
% %         fprintf(fid, EjectPageTxt);
% %         fclose(fid);
% %         %send the file to the printer.
% %         % /a: open as ASCII; /p: send to default printer
% %         err = dos (sprintf('%s "%s"', handles.printerCmdLine, fname));
% %         % % err = dos (sprintf('copy "%s" %s', fname, handles.printerPort));
% %         if err
% %           errMsg = sprintf('%s: error printing "%s" on "%s".', modName, fname, handles.printerPort);
% %           break
% %         end
% %         delete(fname);
% %       end %if fid > 0
% %     end %if loopNdx > 1
% %   end %while displayedLogNdx <= length(displayedLog)
% %   totalPages = thisPage ;
% % end % for loopNdx = 1:2
% --------------------------------------------------------------------
function varargout = togglebuttonMonitorLog_Callback(h, eventdata, handles, varargin)
global debugEnable
%Loops to monitor the date-time of the Log file.  When the Log is updated, this
% routing will re-load and display the updated file as well as providing a visual
% indicator to the operator.  A momentarily lit indicator regularily comes on to
% show monitoring is active.
% * updates copies of the Packet Log:
%    * if Packet Log is from local drive, uses list from readProcessOPM_Log
%    * if Packet Log is from a network file, uses different list
%works with pushbuttonUpdatedOK_Callback which provides the means for the operator
% to turn off the visual indicator.
val = get(h,'Value');
lbl = get(h,'string');
%re-write the "programming running" semaphore file to update the information
% regarding which log if any is being monitored.  This is used by processOutpostMessages
% so it can decide whether it needs to keep the copies up-to-date or if this program
% will be keeping the copies up to date.
writePrgmRunning(handles, val);
if val
  %
  handles.monitoring = 1;
  guidata(handles.figure1, handles);
  % monitor is being turned on: alter the button's label from "off" to "on" . . .
  lbl = strrep(lbl,' Off',' On');
  %. . .make the "light" visible so the ToolTip can work....
  set(handles.textMonitoring, 'Visible','on');
  set(h,'BackgroundColor', get(handles.figure1,'Color'));
  %. . . and initialize the update timer for the momentary indicator
  gt = 0;
  dlyAvg = 0;
  %processOPM_run: flag used to control when we update the Log's copies
  % 0: updating not needed; 1: updating needed but Log not completed; 2: updating needed and log completed
  [processOPM_run, last_cpy_Ndx, last_cpy_notNdx, last_logPathName, last_pathsTologCopies] = dCInitCopy(handles);
else % if val
  % monitor is being turned off: alter the button's label from "on" to "off" . . .
  lbl = strrep(lbl,' On',' Off');
  % . . . turn off the momentary indicator just it case it had been on & hide it so the
  % ToolTip won't be active & potentially confuse the operator.
  set(handles.textMonitoring,'BackgroundColor', get(handles.figure1,'Color'),'Visible','off');
  set(h,'BackgroundColor', handles.tbMonitorLogOffColor);
end
set(h,'string',lbl);

% if monitor has been turned off we'll not enter this 'while'.
if ~val
  return
end
% % fidTemp = fopen('temp.txt','w');
% % fclose(fidTemp);
while 1
% %   fidTemp = fopen('temp.txt','a');
  %-----------------------------
  %           MONITOR LOOP
  %-----------------------------
  %Get latest information:
  handles = guidata(handles.figure1);
  %blink green every 0.5 second
  if (cputime - gt) > 0.5
    set(handles.textMonitoring,'BackgroundColor', handles.green)
    gt = cputime;
  end
  %if we haven't been able to find a log to load...
  a = '';
  if ~length(handles.logPathName)
    %check for the newest file in the specified location
    handles = choseLog(handles, 1);
    %if a log is found, handles.logPathName will be loaded
    %  and the following "if" will be true, leading to triggering
    %  the detection of a date change which will display the new log
  end
  %if we have an active log . . .
  %we'll time how long it takes to perform a "dir" and use that 
  % to make establish the update rate
  %-- vvvvvv start of time measurement vvvvvvvvv
  tic
  if length(handles.logPathName)
    logFileInfo = dir(handles.logPathName);
  else
    logFileInfo = [] ;
  end
  dly = toc;
  % ^^^^^^^^^^^ end of time measurement ^^^^^^^^^
  %if the log is not accessible
  if ~length(logFileInfo)
    %make the variables which will be tested in a little bit
    %the same which indicates the log has not been been updated
    %  We want something so the delay-loop is active
    logFileInfo(1).date = handles.header.logFDate;
    logFileInfo(1).bytes = handles.header.bytes ;
    if length(handles.header.logFDate)
      %clear the list box & display a message
      if length(handles.logPathName)
        set(handles.listboxAllStation,'string', {sprintf('Unable to access "%s".', handles.logPathName),'Retrying'} ) ;
      else
        set(handles.listboxAllStation,'string', {sprintf('No Log in "%s"', handles.logPath),'Monitoring'} ) ;
      end
      %let's leave the any message in the window because this code could
      % have been called under various different intial conditions
      % %     else % if length(handles.header.logFDate)
      % %       list(5) = {sprintf('Waiting for Packet Log %s.csv in %s. . .', handles.logCoreName, handles.logPath)};
      % %       set(handles.listboxAllStation,'string', list) ;
    end % if length(handles.header.logFDate) else
  end % if ~length(logFileInfo)
  %if the log file has been found.....
  if length(logFileInfo)
    %if log's date-time or size has changed or if this is a different log
    logUpdated = ~strcmp(logFileInfo(1).date, handles.header.logFDate) |...
      (logFileInfo(1).bytes ~= handles.header.bytes);
    logNew = ~strcmp(last_logPathName, handles.logPathName);
    if (logUpdated | logNew)
      %log has been updated!
      if debugEnable
        if strcmp(logFileInfo(1).date, handles.header.logFDate) & ~strcmp(logFileInfo(1).bytes, handles.header.bytes)
          fprintf('\nLog date has not changed but size has changed!');
        end
      end
      set(handles.textMonitoring,'BackgroundColor', get(handles.figure1,'Color'));
      [err, errMsg] = readNDspPckt(handles, handles.logPathName);
      if err
        % may not have loaded the new file but still need to pause between "dir" polling
        handles.header.logFDate = logFileInfo(1).date ;
        handles.header.bytes = logFileInfo(1).bytes  ;
        guidata(handles.figure1, handles)
      else % if err
        % if (operator wants copies) and (the flag is not set to copies-needed-but-wait)...
        %    (if set to copies-needed-but-wait, there is no further information needed
        %     until a) the log is not being updated and b) processOPM is done so
        %     no need to spend system resources here.  When "a" occurs we'll be in
        %     a differnt portion of the code & not here - see a bit below "if processOPM_run")
        if length(handles.pathsTologCopies) & (processOPM_run ~= 1)
          % log has been updated so let's start the process to update the copies.  The log is 
          % updated as each message of a send/receive is processed rather than waiting for
          % all the messages to be processed. When there are multiple messages we want to update the
          % display of the log after each message but do not want to update the copies for two reasons:
          %  1) to avoid blocking updating of the Log.  The "copy" operation momentarily 
          %     blocks the Log from being updated.
          %  2) to allow the fastest processing by not using system resources for copying that 
          %     will need to be repeated in a few seconds.  The time lost can be significant when
          %     a copy is being placed on a network.
          %
          % Test if processOPM is runnning if running, set a flag that will tell us to keep
          % checking & when it is not running, perform the copy
          a = dir(strcat(handles.logPath, 'processOPM_run.txt'));
          if length(a)
            %file exists meaning processOPM is running: set state to "update needed but need to wait"
            fprintf('\r\nPacket Log updating: waiting for processOPM to complete...');
            processOPM_run = 1;
            %if different log 
            if ~strcmp(last_logPathName, handles.logPathName)
              [a, last_cpy_Ndx, last_cpy_notNdx, last_logPathName, last_pathsTologCopies] = dCInitCopy(handles);
            else % if ~strcmp(last_logPathName, handles.logPathName)
              %same log
              %indicate "pending" for the available locations as we last knew
              updateCopyLEDStatus(handles, [], last_cpy_Ndx, last_cpy_notNdx);
            end % if ~strcmp(last_logPathName, handles.logPathName) else
          else %if length(a) 
            if logUpdated %only copy if log updated, not if new choice/different log
              % file does not exist meaning processOPM is not running: 
              %set state to "update needed - do it now"
              fprintf('\r\nPacket Log updated & processOPM completed...');
              processOPM_run = 2;
              %write semaphore flag file so processOPM won't try to update the log
              fName = writeCopying(handles);
            end %if logUpdated
          end % if length(a) else
        end % if length(handles.pathsTologCopies) & (processOPM_run ~= 1)
      end  % if err else
      %turn on the visible indicators to show the log and display have been updated
      set(handles.pushbuttonUpdatedOK,'Visible','on');
    else %if ~strcmp(logFileInfo(1).date, handles.header.logFDate)
      %Log's date-time has not changed: wait and and then loop
      %check if there is a pending update for copying the logs
      if processOPM_run
        % an update is pending - check if we can perform the update now
        a = dir(strcat(handles.logPath, 'processOPM_run.txt'));
        if ~length(a)
          % file does not exist meaning processOPM is not running: 
          %set state to "update needed - do it now"
          fprintf('\r\nPacket Log updated & processOPM completed...');
          processOPM_run = 2;
          %write semaphore flag file so processOPM won't try to update the log
          fName = writeCopying(handles);
        end % if ~length(a)
      end %if processOPM_run
      %total pause is 10 * dly (see loop below) or (10 sec >= total >= 0.2 sec)
      dly = min(1, max(0.02, dly));
      if ~dlyAvg
        dlyAvg = dly;
      else
        %exponential (rolling) average to smooth out impact of system activities
        if dly < dlyAvg/2
          %if latest is a lot shorter, we may have been suffering from initialization of network communication
          dlyAvg = dly;
        else
          dlyAvg = 0.75 * dlyAvg + 0.25 * dly;
        end
      end
      %don't want to bog down the system so we'll bypass checking the Log's time
      % for 10x the length of time it took to determine the log's time (in other words,
      % time delay is variable depending on the system speeds.
      for itemp = 1:10 % delay loop
        pause(dlyAvg)
        if (itemp == 2)
          % after 2 pauses, 
          %turn off the green background - it came on when we last checked the Log's time
          set(handles.textMonitoring,'BackgroundColor', get(handles.figure1,'Color'));
          set(handles.figure1,'windowstyle','normal')
        end
        val = get(h,'Value');
        if ~val
          break
        end
      end % for itemp = 1:10
    end % if ~strcmp(logFileInfo(1).date, handles.header.logFDate) else
    
    %if we haven't detected that Log is being updated or a different log selected....
    if (processOPM_run == 0) 
      %... if Log copies are desired: check the availablity of the copy locations
      %   note any that are no longer available & update as needed the copies in any that have just become available
      if length(last_pathsTologCopies)
        %make sure the log isn't being updated
        pOPM = dir(strcat(handles.logPath, 'processOPM_run.txt'));
        if ~length(pOPM)
          %log isn't being updated right now
          %write semaphore flag file so processOPM won't try to update the log
          fName = writeCopying(handles);
          % update availability of all desired locations:
          %  1) tells us which locations are not available.
          %  2) tells us which locations are currently available -> we'll check this against
          %    the list from the last time we checked of what locations were not available.
          [cpy_Ndx, cpy_notNdx] = validateLogCopyLocations(handles.pathsTologCopies);
          % status display only
          if length(cpy_notNdx)
            %check if any of the locations that had been available just became unavailable
            a = find(ismember(last_cpy_Ndx, cpy_notNdx));
            for itemp = 1:length(a)
              fprintf('\r\nPacket Log location for copy %i: "%s" not currently available.', last_cpy_Ndx(a(itemp)), char(handles.pathsTologCopies(last_cpy_Ndx(a(itemp)))) );
            end % for itemp = 1:length(a)
          end %if length(cpy_notNdx)
          %if all copy locations had not been available . . .
          if length(last_cpy_notNdx)
            % . . . find any locations that had not been available that are now available
            newAvailNdx = last_cpy_notNdx(find(ismember(last_cpy_notNdx, cpy_Ndx))) ;
            for itemp = 1:length(newAvailNdx)
              a = newAvailNdx(itemp);
              fprintf('\r\nPacket Log location for copy %i: "%s" now available.', a, char(handles.pathsTologCopies(a)) );
            end %for itemp = 1:length(last_cpy_notNdx)
            %if any that hadn't been available but now are, update those but only those
            if length(newAvailNdx)
              % update them as needed by building a structure that only contains the
              % elements the sub needs:
              %    This is the list of locations that have just become available - it is not all all available locations!
              h_.pathsTologCopies = handles.pathsTologCopies(newAvailNdx);
              h_.logCoreName = handles.logCoreName;
              h_.header.logFDate = handles.header.logFDate;
              h_.logPath = handles.logPath;
              h_.workingDir = handles.workingDir;
              %       indicate current, nothing pending, not avail, updating
              updateCopyLEDStatus(handles, cpy_Ndx, [], cpy_notNdx, newAvailNdx);
              [err, errMsg] = makeLogCopiesCurrent(h_);  
              % we JUST checked the availability a few lines above - we're going to ignore any changes
              %that might have happened in the brief interval: we're not going to ask for the other 2 returns: Ndx, notNdx
            end % if length(newAvailNdx)
          end % if length(last_cpy_notNdx)
          %if it exists, delete the "copying in process" semaphore flag
          if length(fName)
            delete(fName);
          end
          last_cpy_Ndx = cpy_Ndx;
          last_cpy_notNdx = cpy_notNdx;
          %update the indiviual status: we're here because the availability of a location for a copy
          %  has changed, the Log is not now being updated nor were we waiting for a Log update to be completed.
          updateCopyLEDStatus(handles, last_cpy_Ndx, [], last_cpy_notNdx);
        end %if ~length(pOPM) %if Log is not being updated
      end % if length(last_pathsTologCopies)
    end % if (processOPM_run == 0)
    %if master log has been updated and processOPM is done updating (for now) 
    if (processOPM_run == 2)
      % state is "update needed - do it now". . . so we'll do it!
      fprintf('\r\n...updating log copies');
      %updating underway....
      %show none good, none waiting,       same not avail,  last avail being updated
      updateCopyLEDStatus(handles, [], [], last_cpy_notNdx, last_cpy_Ndx);
      [err, errMsg, cpy_Ndx, cpy_notNdx] = updateLogCopies(handles.pathsTologCopies, handles.logPath, handles.logCoreName, handles.workingDir);
      %update the status
      last_cpy_notNdx = cpy_notNdx;
      last_cpy_Ndx = cpy_Ndx;
      processOPM_run = 0;
      %Name/location of the Packet Log being monitored.
      last_logPathName = handles.logPathName ;
      %Locations for the copies
      last_pathsTologCopies = handles.pathsTologCopies;
      %if it exists, delete the "copying in process" semaphore flag
      if length(fName)
        delete(fName);
      end
      %updating completed
      updateCopyLEDStatus(handles, cpy_Ndx, [], last_cpy_notNdx);
      %print the log?
      if handles.logPrtEnable
        %automatic printing is enabled
        % how many messages have been logged since the last printing?
        newLogLines = size(handles.logged, 1) - handles.logPrintStartLogLine;
        printIt = 0;
        if (newLogLines >= handles.logPrt_msgNums)
          %enough new messages - print regardless of the time interval
          % print
          printIt = 1;
        elseif (handles.logPrintTimePrinted & ...
            ((now - handles.logPrintTimePrinted) > handles.logPrt_minuteInterval / (1440)) & ...
            (newLogLines >= handles.logPrt_mnmToPrt) )
          %time interval has transpired and sufficient messages have arrive
          %print
          printIt = 1;
        end  
        if printIt
          %, handles.logPrt_minuteInterval, handles.logPrt_mnmToPrt, handles.logPrt_msgNums
          [err, errMsg, lastPagePrt, lastLogLinePrt] = logPrint(handles);
          handles.logPrintFirstPageNum = handles.logPrintStartLogLine + 1;
          handles.logPrintStartLogLine = lastLogLinePrt + 1;
          handles.logPrintTimePrinted = now;
        end % if printIt
      end % if handles.logPrtEnable
    end %if (processOPM_run == 2)
  end %if length(logFileInfo)
  % this is a safety valve: updating should have occurred already if needed
  if ~strcmp(last_logPathName, handles.logPathName)
    fprintf('\nupdate sync')
    [a, last_cpy_Ndx, last_cpy_notNdx, last_logPathName, last_pathsTologCopies] = dCInitCopy(handles);
  end
  val = get(h,'Value');
  if ~val
    break
  end % if ~val
% % fclose(fidTemp);
end %while 1 (the forever loop)
% if CloseRequestFnc detected this loop was running, the
%flag will be set for the Close to occur at this point
handles = guidata(handles.figure1);
fprintf('\nExit monitor loop.')
if (handles.closeRequest)
  uiresume(handles.figure1);
  fprintf('\n exiting program');
else
  %used by closeReq for smooth shut down
  handles.monitoring = 0;
  guidata(handles.figure1, handles);
end
% --------------------------------------------------------------------
function varargout = pushbuttonUpdatedOK_Callback(h, eventdata, handles, varargin)
%works with togglebuttonMonitorLog_Callback and provides visual feedback to 
% operator when the Monitor is on and the log file's date/time has changed.
%That routine turns on the indicator & this turns them off.
set(handles.pushbuttonUpdatedOK,'Visible','off');
% --------------------------------------------------------------------
function varargout = recentLog_Callback(h, eventdata, handles, varargin)
%Called from user's Menu on the figure: File -> #  (Recent Files) 
% Calls "readNDspPckt" to actually load the chosen Log
% The user's choice (1-N) is passed back as the first element in varargin
itemp = varargin{1};
Ndx = [1:(itemp-1) (itemp+1):length(handles.recentLogs)];
handles.recentLogs = handles.recentLogs([itemp Ndx]);
%set the current log to the first, perform book keeping . . .
handles.logPathName = char(handles.recentLogs(1)) ;
createRecentFileMenu(handles);
[pathstr,name,ext,versn] = fileparts(handles.logPathName);
handles.logPath = endWithBackSlash(pathstr);
handles.logCoreName = extractCoreName(name); %local function
% . . . save the latest list and open the log
guidata(handles.figure1, handles);
[err, errMsg] = readNDspPckt(handles, handles.logPathName);
% --------------------------------------------------------------------
function varargout = closeTextView_Callback(h, eventdata, handles, varargin)
%Called from "displayText" gui when user attempts to close a "displayText" view
%window. 
% This procedure actually closes that window and removes it from
%the list of open windows.  This list is maintained in part so if the 
%operator selects a log entry that is already being view, another window 
%will not open but rather the existing window will be brought to the front

displayedFilePathName = varargin{1} ;
% search based on the file name just in case we've opened this file
%more than once - this could happen if we have different display formats 
%in an future upgrade *** actually, this may be a poor idea: we may want the other
%formats to stay open - after all the operator didn't close but the one window!
if length(find(ismember(handles.h_displayTextPathName, displayedFilePathName)))
  %find
  a = find(ismember(handles.h_displayTextPathName, displayedFilePathName)) ;
  for itemp = length(a):-1:1
    delete(handles.h_displayText(a(itemp)));
    Ndx = [1:(a(itemp)-1) (a(itemp)+1):length(handles.h_displayText)] ;
    %pull from the "catalog"
    handles.h_displayTextNdx = handles.h_displayTextNdx - 1;
    handles.h_displayText = handles.h_displayText(Ndx) ;
    handles.h_displayTextPathName = handles.h_displayTextPathName(Ndx) ;
  end %for itemp = 1:length(a)
  guidata(handles.figure1, handles);
else
  %if this program was restarted for some reason without the windows being closed....
  delete(varargin{2})
end
% --------------------------------------------------------------------
function new_filePathName = repathIfNet(filePathName, handles);
if iscell(filePathName)
  filePathName = char(filePathName);
end
isNetLog = (1 == findstrchr('\\', handles.logPath));
%Renames the path of the passed in message file iff the log is over a network
%if this log is coming over a network, the message file names in the log will
% be refering to the local drives on the networked computer & cannot be directly 
% used here. Various sharing is supporting and this code will keep trying until
% one of them reaches the message or all attempts have failed.  (Error reporting occurs elsewhere)
%
%In the exampels included here, the log path is capatilized just for emphasis and clarity
%1) We'll attempted the simplest network access where the share for the messages is at the drive level,
% both the log and the messages are on the same machine, and the share name
% is the drive letter of the messages: example "c:" is shared as "c"
%  (note this can be one or two shares)
%  drop the ":" from the drive letter & add the net path as the prefix
% message:   c:\dirName\.... 
% log:  \\<NETNAME>\DIFFERENT DIR NAME\LOGS\<log name>
%   newPathName = \\<NETNAME>\c\dirName\....
%
%2) If this doesn't work, we'll try to find a directory in the filePath that
%  is also in the path to the log & make the new path up to that point
%  the same as the log's path
%This works with a single Share or dual share as long as the log & files have a common directory level
% message  c:\<dir 1>\<dir 2>\dirname\archive\InTray\<file name> 
% log  \\<NETNAME>\dirName\logs\<log name>
%   newPathName = \\<NETNAME>\dirName\archive\InTray\<file name>
%
%3) If that also doesn't work, we'll try  \\<NETNAME>\archive\InTray\<file name>
%This works with two shares, one for the log and one for the files but only when
%  the file share for the messages is at "Archive" and uses that as the share name
% message  c:\<dir 1>\<dir 2>\...\dirname\archive\InTray\<file name> 
% log  \\<NETNAME>\dirName\logs\<log name>
%   newPathName = \\<NETNAME>\archive\InTray\<file name>
%
%4) If that also doesn't work, we'll try  \\<NETNAME>\<DirArchive>\InTray\<file name>
%This works with two shares, one for the log and one for the files but only when
%  the share for the messages is at <DirArchive> and uses that as the share name
%  where <DirArchive> is the archive directory used by Outpost & defined in outpost.ini
%  (script and code is hard-wired for the messages to be one directory under <DirArchive>
%  regardless of where <DirArchive> is located.
% message  c:\<dir 1>\<dir 2>\....\dirname\<DirArchive>\InTray\<file name> 
% log  \\<NETNAME>\dirName\logs\<log name>
%   newPathName = \\<NETNAME>\<DirArchive>\InTray\<file name>

if isNetLog
  bSlashAt = findstrchr('\',handles.logPath);
  % get  "\\<netname>\"
  nameOnNet = handles.logPath(bSlashAt(1):bSlashAt(3));
  a = findstrchr(':',filePathName); 
  %1) single share at the drive level
  new_filePathName = sprintf('%s%s%s', nameOnNet, filePathName(1:a(1)-1), filePathName((a(1)+1):length(filePathName)));
  if ~exist(new_filePathName)
    % 2) single Share for log & files at a common directory level
    %determine the first/highest directory named in the logPath & then find that name in the file path
    % log path: \\<netname>\<first dir>\
    highDirLog = handles.logPath(bSlashAt(3)+1:bSlashAt(4)-1);
    a = findstrchr(lower(highDirLog), lower(filePathName));
    if a
      new_filePathName = sprintf('%s%s', nameOnNet, filePathName((a(1)):length(filePathName)));
    end
    if ~exist(new_filePathName) %2nd
      %two shares, one for the log and one for the files but only when
      %  the file share is at "Archive" and uses that as the share name 
      a = findstrchr('archive', lower(filePathName));
      if a
        new_filePathName = sprintf('%s%s', nameOnNet, filePathName((a(1)):length(filePathName)));
      end
      if ~exist(new_filePathName) %3rd
        %two shares, one for the log and one for the messages but only when
        %  the messages share is at Outpost's DirArchive and uses that as the share name 
        % path name to the message is hard-coded to end with the directory 
        %       ...\<DirArchive>\InTray\<message name> or ...\<DirArchive>\SentTray\<message name>
        a = findstrchr('\', lower(filePathName));
        if a
          new_filePathName = sprintf('%s%s', nameOnNet, filePathName(((a(length(a)-2))+1):length(filePathName)));
        end
      end %if ~exist(new_filePathName) %3rd
    end %if ~exist(new_filePathName) %2nd
  end %if ~exist(new_filePathName)
else
  new_filePathName = filePathName;
end %if isNetLog
% --------------------------------------------------------------------
function [beginPathName, beginEndPathName] = shortPathName(fullPathName); 
%Just the drive or network designator for the file
% c:\...\<name.ext>
% \\arose_h\
[pathstr,name,ext,versn] = fileparts(fullPathName);
%want the drive/network identification
a = findstrchr('\', pathstr);
beginPathName = fullPathName;
beginEndPathName = fullPathName; 
hm = '';
lf = '';
if a
  b = find(a > 2);
  if length(b) & (length(a) > 1)
    %get just the drive/network designator
    if (a(2) == 2)
      %if network, want netname + first folder name
      hm = strcat(pathstr(1:a(b(2))),'...');
    else
      hm = strcat(pathstr(1:a(b(1))),'...');
    end
    %alternate output contains the last folder in the path
    lf = pathstr(a(b(length(b))):length(pathstr));
    beginPathName = sprintf('%s\\%s%s', hm, name,ext);
    beginEndPathName = sprintf('%s%s\\%s%s', hm, lf, name,ext); 
  end % if if length(b)
end % if a
% --------------------------------------------------------------------
function handles = createMenuBar(handles)

%menuhandles = findall(handles.figure1,'type','uimenu')

%============= FILE menu ==============
%"root" menu item because "handles.figure1"
h_fileMenu = uimenu(handles.figure1,'Label', 'File', 'accelerator','f', ...
  'Callback', 'displayCounts(''file_Callback'',gcbo,[],guidata(gcbo))'...
  );
handles.h_fileMenu = h_fileMenu;
%Files menu sub-item
h_fileOpen = uimenu(h_fileMenu,'Label', 'Today''s Log present path', 'accelerator','t', ...
  'Callback', 'displayCounts(''fileTodayLog_Callback'',gcbo,[],guidata(gcbo))'...
  );
%Files menu sub-item
if length(handles.DirLogs)
  % if we're running on a machine with Outpost...
  %Files menu sub-item
  h_fileOpen = uimenu(h_fileMenu,'Label', 'Open a Local Log', 'accelerator','l', ...
    'Callback', 'displayCounts(''fileLocalLog_Callback'',gcbo,[],guidata(gcbo))'...
    );
end %if length(fileLocalLog_Callback)
%Files menu sub-item
h_fileOpen = uimenu(h_fileMenu,'Label', 'Open Log', 'accelerator','o', ...
  'Callback', 'displayCounts(''fileOpen_Callback'',gcbo,[],guidata(gcbo))'...
  );
%Files menu sub-item
h_filePrint = uimenu(h_fileMenu,'Label', 'Print Log', 'accelerator','p', ...
  'Callback', 'displayCounts(''filePrintLog_Callback'',gcbo,[],guidata(gcbo))'...
  );
%Files menu sub-item: the recently opened list
createRecentFileMenu(handles);
%Files menu sub-item: exit
h_fileOpen = uimenu(h_fileMenu,'Label', 'Exit', ...
  'Callback', 'dispNghbrhdSmry(''figure1_CloseRequestFcn'',gcbo,[],guidata(gcbo))'...
  );
%============= EDIT menu ==============
%"root" menu item because "handles.figure1"
h_editMenu = uimenu(handles.figure1,'Label', 'Edit', 'accelerator','e', ...
  'Callback', 'displayCounts(''edit_Callback'',gcbo,[],guidata(gcbo))'...
  );
handles.h_editMenu = h_editMenu;
%Edit menu sub-item
h_editLoad = uimenu(h_editMenu,'Label', 'Load column order layout', ...
  'Callback', 'displayCounts(''editLoadOrdr_Callback'',gcbo,[],guidata(gcbo))'...
  );
%Edit menu sub-item
h_editSave = uimenu(h_editMenu,'Label', 'Save column order layout', ...
  'Callback', 'displayCounts(''editSaveOrdr_Callback'',gcbo,[],guidata(gcbo))'...
  );
%Edit menu sub-item
h_editMod = uimenu(h_editMenu,'Label', 'Modify column order layout', ...
  'Callback', 'displayCounts(''editModifyOrdr_Callback'',gcbo,[],guidata(gcbo))'...
  );
%Edit menu sub-item
h_editDefault = uimenu(h_editMenu,'Label', 'Default column order layout', ...
  'Callback', 'displayCounts(''editDefaultOrdr_Callback'',gcbo,[],guidata(gcbo))'...
  );

%============= VIEW menu ==============
%"root" menu item because "handles.figure1"
h_viewMenu = uimenu(handles.figure1,'Label', 'View', ...
  'Callback', 'displayCounts(''view_Callback'',gcbo,[],guidata(gcbo))'...
  );
%view menu sub-item
handles.h_viewScoreboard = uimenu(h_viewMenu,'Label', 'Summary', ...
  'Callback', 'displayCounts(''viewScoreboard_Callback'',gcbo,[],guidata(gcbo))'...
  );
%view menu sub-item
handles.h_viewDetail = uimenu(h_viewMenu,'Label', 'Detail', ...
  'Callback', 'displayCounts(''viewDetail_Callback'',gcbo,[],guidata(gcbo))'...
  );
viewSetChecks(handles)
guidata(handles.figure1, handles);

%============= SETTINGS menu ==============
%"root" menu item because "handles.figure1"
h_settingsMenu = uimenu(handles.figure1,'Label', 'Settings', ...
  'Callback', 'displayCounts(''settings_Callback'',gcbo,[],guidata(gcbo))'...
  );

%============= HELP menu ==============
%"root" menu item because "handles.figure1"
h_helpMenu = uimenu(handles.figure1,'Label', 'Help', 'accelerator','h', ...
  'Callback', 'displayCounts(''file_Callback'',gcbo,[],guidata(gcbo))'...
  );
%Help menu sub-item
h_helpAbout = uimenu(h_helpMenu,'Label', 'About', 'accelerator','a', ...
  'Callback', 'displayCounts(''helpAbout_Callback'',gcbo,[],guidata(gcbo))'...
  );
% --------------------------------------------------------------------
function settings_Callback(h, eventdata, handles, varargin)
packetLogSettings('logPrint');

% --------------------------------------------------------------------
function createRecentFileMenu(handles)
%first delete any recent files on the menu
menuhandles = findall(handles.figure1,'type','uimenu');
menuhandles = sort(menuhandles);
for itemp=1:length(menuhandles);
  if findstrchr(get(menuhandles(itemp),'Callback'), 'displayCounts(''recentLog')
    delete(menuhandles(itemp));
  end
end
for itemp = 1:min(9,length(handles.recentLogs))
  [beginPathName, beginEndPathName] = shortPathName(char(handles.recentLogs(itemp))); 
  a = uimenu(handles.h_fileMenu,'Label', sprintf('%i: %s', itemp, beginEndPathName), 'accelerator',num2str(itemp), ...
    'Callback', sprintf('displayCounts(''recentLog_Callback'',gcbo,[],guidata(gcbo),%i)', itemp)...
    );
  if itemp < 2
    set(a,'Separator','on');
  end
end
% --------------------------------------------------------------------
function [codeName, codeVersion, codeDetail] = getCodeVersion(handles);
codeName = get(handles.figure1,'Name');
[codeVersion, codeDetail] = about_displayCounts_private;

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
function viewScoreboard_Callback(h, eventdata, handles, varargin)
%toggle the indicator's state
handles.viewSummary = strcmp(lower(get(handles.h_viewScoreboard, 'checked')),'off') ;
adjustView(handles)
viewSetChecks(handles)
guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function viewDetail_Callback(h, eventdata, handles, varargin)
%toggle the indicator's state
handles.viewDetail = strcmp(lower(get(handles.h_viewDetail, 'checked')),'off') ;
adjustView(handles)
viewSetChecks(handles)
guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function viewSetChecks(handles)
% set/clear "check" status on the view menu choices
if handles.viewSummary
  set(handles.h_viewScoreboard, 'checked', 'on');
else % if handles.viewSummary
  set(handles.h_viewScoreboard, 'checked', 'off');
end % if handles.viewSummary else
if handles.viewDetail
  set(handles.h_viewDetail, 'checked', 'on');
else % if handles.viewDetail
  set(handles.h_viewDetail, 'checked', 'off');
end % if handles.viewDetail else
% --------------------------------------------------------------------
function adjustView(handles)
% adjust the pane(s) as indicated by the flags
if ~handles.viewDetail & ~handles.viewSummary
  % only view log: log pane to occupy area for all panes
  centerSubpane(handles.listboxScoreboard, 0, [], handles.textSummary)
  centerSubpane(handles.listboxScoreboardSumm, 0, [], handles.textDetail)
  p = handles.initPosLBAllStations;
  %don't want top of listboxAllStations to move when we move bottom down
  %  height = original height + distance between original listbox's bottom & scoreboard's bottom.
  %set the height:
  p(4) = p(4) + p(2) - handles.posScoreBrd(2);
  %move the bottom
  p(2) = handles.posScoreBrd(2);
  set(handles.listboxAllStation,'position', p);
elseif handles.viewDetail & handles.viewSummary
  % view all 3 panes
  set(handles.listboxAllStation,'position', handles.initPosLBAllStations);
  centerSubpane(handles.listboxScoreboard, 1, handles.posScoreBrd, handles.textSummary)
  %set(handles.listboxScoreboard, 'visible','on', 'position', handles.posScoreBrd)
  centerSubpane(handles.listboxScoreboardSumm, 1, handles.posScoreSumm, handles.textDetail)
  %set(handles.listboxScoreboardSumm, 'visible','on', 'position', handles.posScoreSumm)
elseif handles.viewDetail 
  % view log & right box - detail, expand right box's left edge to the left edge of the summ box
  set(handles.listboxAllStation,'position', handles.initPosLBAllStations);
  centerSubpane(handles.listboxScoreboard, 0, [], handles.textSummary)
  p = handles.posScoreSumm;
  p(3) = p(3) + p(1) - handles.posScoreBrd(1);
  p(1) = handles.posScoreBrd(1);
  centerSubpane(handles.listboxScoreboardSumm, 1, p, handles.textDetail)
else
  % view log & left box - summary, expand left box's right edge to the right edge of the detail box
  set(handles.listboxAllStation,'position', handles.initPosLBAllStations);
  centerSubpane(handles.listboxScoreboardSumm, 0, [], handles.textDetail)
  p = handles.posScoreBrd;
  %  width = 
  p(3) = handles.posScoreSumm(3) + handles.posScoreSumm(1) - p(1);
  centerSubpane(handles.listboxScoreboard, 1, p, handles.textSummary)
end
% --------------------------------------------------------------------
function centerSubpane(hObjListBox, offON, listBoxPos, hText)
%Either hides or shows passed-in subpane & associated passed-in text label
% center heading above selected "centerSubpane"
if offON
  set(hObjListBox, 'visible','on', 'position', listBoxPos)
  p = get(hText,'position') ;
  p(2) = listBoxPos(2) + listBoxPos(4) ;
  p(1) = listBoxPos(1) + listBoxPos(3) / 2 - p(3) / 2 ;
  set(hText,'position', p, 'visible','on');
else %if offON
  set(hObjListBox, 'visible','off')
  set(hText, 'visible','off')
end %if offON else
% --------------------------------------------------------------------
function varargout = helpAbout_Callback(h, eventdata, handles, varargin)
[codeName, codeVersion, codeDetail] = getCodeVersion(handles);
helpdlg(sprintf('%s\nVersion %s %s\n\nMonitoring program for Outpost Packet Message Manager\nCopyright by Jim Oberhofer KN6PE', codeName, codeVersion, codeDetail), sprintf('About %s', codeName));
% --------------------------------------------------------------------
function varargout = writePrgmRunning(handles, monitorRunning) ;
fid = fopen(strcat(handles.programRunning, 'on.txt'),'w');
if (fid > 0)
  fprintf(fid,'This file indicates that "%s" is running - it is created when it starts & deleted when it closes.', mfilename);
  if monitorRunning
    %don't change this wording without updating processOutpostMessages's reading operation
    fprintf(fid,'\r\nmonitoredLog = %s', handles.logPathName);
  end
  fclose(fid);
end
% --------------------------------------------------------------------
function thisStation = cleanStationAddress(thisStation);
% to improve readability, we'll lower case anything the "@" 
if findstrchr('@', thisStation)
  b = findstrchr('@', thisStation);
  periodAt = findstrchr('.', thisStation);
  %multiple "to" can exist!  real example: KI6SEP@MTV;k6fsh@mtv,; ki6sep@mtv
  %   using "findstr" instead of "findstrchr" because we do not want "0"
  % for any delimiter that isn't present.
  delimAt = [findstr(';', thisStation) findstr(',', thisStation) length(thisStation)];
  delimAt = sort(delimAt);
  for itemp = length(b):-1:1
    a = find(delimAt > b(itemp));
    a = delimAt(a(1));
    %if periodAt after this "@" and before this delimAt, pull all between periodAt & this delim
    %only include the first part of the address - per Fish we don't need the rest
    c = find(periodAt > b(itemp) & periodAt < a);
    if length(c)
      c = periodAt(c(1));
      thisStation = sprintf('%s%s%s', thisStation(1:b(itemp)), lower(thisStation(b(itemp)+1:c-1)), thisStation(a:length(thisStation)));
    else
      thisStation = sprintf('%s%s%s', thisStation(1:b(itemp)), lower(thisStation(b(itemp)+1:a)), thisStation(a+1:length(thisStation)));
    end
  end
end %if findstrchr('@', thisStation)
% --------------------------------------------------------------------
function varargout = editSaveOrdr_Callback(h, eventdata, handles, varargin)

%  handles.workingDir = strcat(handles.workingDir,'AddOns\Programs\');
a = findstrchr(handles.workingDir, 'AddOns\Programs');
% handles.workingDir has two different possible ending contents
if a
  b = findstrchr(handles.workingDir, '\');
  c = find(b > a);
  path = handles.workingDir(1:b(c(1)));
else
  path = handles.workingDir;
end
%attempt to get current operator
[err, errMsg, outpostNmNValues] = OutpostINItoScript; 
if err
  h_.opCall = handles.opCall;
else
  h_.opCall = outpostValByName('StationID', outpostNmNValues);;
end
h_.dispColFName = handles.dispColFName;
h_.dispColHdg = handles.dispColHdg;
h_.dispColOrdr = handles.dispColOrdr;

[err, errMsg] = displaySaveOrder(path, h_);
% --------------------------------------------------------------------
function varargout = editLoadOrdr_Callback(h, eventdata, handles, varargin)

%  handles.workingDir = strcat(handles.workingDir,'AddOns\Programs\');
a = findstrchr(handles.workingDir, 'AddOns\Programs');
% handles.workingDir has two different possible ending contents
if a
  b = findstrchr(handles.workingDir, '\');
  c = find(b > a);
  path = handles.workingDir(1:b(c(1)));
else
  path = handles.workingDir;
end
h_.dispColHdg = handles.dispColHdg;
h_.dispColFName = ''; %want user to pick

[err, errMsg, h_] = displayLoadOrder(path, h_);
if err
  fprintf('\nError: %s', errMsg);
  return
end
handles.dispColOrdr = h_.dispColOrdr;
handles.dispColFName = h_.dispColFName;
guidata(handles.figure1,handles)
displayLog(handles);
% --------------------------------------------------------------------
function varargout = editModifyOrdr_Callback(h, eventdata, handles, varargin)
%calls separate program & GUI that allows the order to be modified
h_.figure1 = handles.figure1;
h_.dispColHdg = handles.dispColHdg;
h_.dispColOrdr = handles.dispColOrdr;
h_.dispColFName = handles.dispColFName;
 
[err, errMsg, h_] = displayOrder(h_);

if ~err %error includes user not selecting "OK" to exit
  handles.dispColHdg = h_.dispColHdg;
  handles.dispColOrdr = h_.dispColOrdr;
  handles.dispColFName = h_.dispColFName;
  
  guidata(handles.figure1,handles)
  displayLog(handles);
end
% --------------------------------------------------------------------
function varargout = editDefaultOrdr_Callback(h, eventdata, handles, varargin)
%Restore the column order to the default.
handles.dispColOrdr = handles.dispColOrdrDflt;
handles.dispColFName = 'default' ;
guidata(handles.figure1,handles)
displayLog(handles);
% --------------------------------------------------------------------
function coreName = extractCoreName(fullName)
%pull any extension
a = findstrchr('.',fullName);
if a
  fullName = fullName(1:(a(1)-1));
end
coreName = fullName ;
a = findstrchr('_',fullName);
if a
  %take the last "_"
  b = fullName(a(length(a)):length(fullName)) ;
  %if the name ends with one of the reserved type declaration,
  if find(ismember({'_recvd', '_sent', '_sprt'}, lower(b)))
    %... those need to removed to get to the core name
    coreName = fullName(1:(a(length(a))-1));
  end
end
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function varargout = listboxScoreboard_Callback(h, eventdata, handles, varargin)
val = get(h, 'value');
cl = get(h,'string');
if ((val > 1) & length(cl))
  listboxScoreboardSumm_Callback(0, [], handles, char(cl(val)));
end %if ((val > 1) & length(cl))

% --------------------------------------------------------------------
function varargout = listboxScoreboardSumm_Callback(h, eventdata, handles, varargin)
if (nargin > 3)
  summScoreboard(handles, varargin);
end



% --------------------------------------------------------------------
function varargout = togglebuttonPrint_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = togglebuttonPrintPACF_Callback(h, eventdata, handles, varargin)
%not used & may never be used - place holder
