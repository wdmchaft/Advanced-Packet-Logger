function varargout = displayText(varargin)
%Caller needs to make this panel visible!
%     h_displayText = displayText;
%     % get handles of the new window
%     handlesText = guidata(h_displayText);
%    <do stuff to displayText>
%     %make the new displayText window visible
%     set(handlesText.figure1,'Visible', 'on')

% DISPLAYTEXT Application M-file for displayText.fig
%    FIG = DISPLAYTEXT launch displayText GUI.
%    DISPLAYTEXT('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 28-Nov-2009 10:49:19

if nargin == 0  % LAUNCH GUI

  figure1 = displayText_OpeningFcn;
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
        figure1 = displayText_OpeningFcn(varargin{:}) ;
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

function varargout = displayText_OpeningFcn(varargin)
[err, errMsg, modName] = initErrModName(strcat(mfilename, '(displayText_OpeningFcn)'));

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
%  Clear the text boxes - they are pre-loaded with aids for programming not usage!
set(handles.textHdg1,'string','');
set(handles.textHdg2,'string','');
set(handles.lbHdg3,'string','');
set(handles.textHdg4,'string','');
set(handles.textHdg5,'string','');
set(handles.textHdg6,'string','');
set(handles.textMsgType,'string','');

% %create the user-accessible menus
% handles = createMenuBar(handles);

guidata(figure1, handles);
% caller will make this panel visible: set(figure1,'visible','on');
% % %Wait for the callbacks to be run and the window to be dismissed
% % uiwait(figure1)
varargout{1} = figure1;
if err
  varargout{2} = err;
  varargout{3} = strcat(modName, errMsg);
end
%---------- function varargout = displayText_OpeningFcn(varargin) ---------------

% --------------------------------------------------------------------
function varargout = listbox1_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = figure1_CloseRequestFcn(h, eventdata, handles, varargin)
%call the main panel function to force a release of its user toggle button
% and all associated actions, including closing this figure.
ud = get(h,'userdata') ;
if length(ud)
  %call the caller presummably so it can take note that this window has been closed
  feval(ud.callingProgram, ud.callBackName, h, eventdata, guidata(ud.callingFigure), ud.displayedFilePathName, handles.figure1) ;
else
  delete(handles.figure1)
end
% --------------------------------------------------------------------
function varargout = displayText_ResizeFcn(h, eventdata, handles, varargin)
%reflow the text in the box
ud = get(handles.figure1,'userdata') ;
list = textwrap(handles.textListWidth, ud.listAsRead);
set(handles.listbox1, 'string', list)
% --------------------------------------------------------------------
function handles = createMenuBar(handles)

%menuhandles = findall(handles.figure1,'type','uimenu')

%============= FILE menu ==============
%"root" menu item because "handles.figure1"
% % been getting "Attempt to reference field of non-structure array 'handles'."
% % when the first uimenu line is executed. Get same error msg on uimenu
% % line even if changed to two lines:
% %   a = handles.figure1
% %   h_fileMenu = uimenu(...
% % No clue why a=handles.figure1 doesn't create an error but uimenu does!

h_fileMenu = uimenu(handles.figure1,'Label', 'File', 'accelerator','f', ...
  'Callback', 'displayText(''file_Callback'',gcbo,[],guidata(gcbo))'...
  );
handles.h_fileMenu = h_fileMenu;
%Files menu sub-item
h_filePrint = uimenu(h_fileMenu,'Label', 'Print Preview', 'accelerator','v', ...
  'Callback', 'displayText(''filePrintPrvw_Callback'',gcbo,[],guidata(gcbo))'...
  );
%Files menu sub-item
h_filePrint = uimenu(h_fileMenu,'Label', 'Print Msg', 'accelerator','p', ...
  'Callback', 'displayText(''filePrintMsg_Callback'',gcbo,[],guidata(gcbo))'...
  );
% --------------------------------------------------------------------
function varargout = filePrintPrvw_Callback(h, eventdata, handles, varargin)
% setting this to zero & notepad will deal with
%  page numbering etc.
handles.printerLinesPerPage = 0; %60;
handles.printerCmdLine = 'notepad /a';
createFile2Print(handles);
% --------------------------------------------------------------------
function varargout = filePrintMsg_Callback(h, eventdata, handles, varargin)
% % % no sure this makes any difference!  Nice if it allows landscape mode!
% % %  can't test on this machine because nothing on LPT1
% % printdlg('-setup',handles.figure1)

% prompt  = {'Lines per page:'};
% title   = 'Printer characteristics';
% lines= 1;
% def     = {num2str(handles.printerLinesPerPage)};
% answer  = inputdlg(prompt,title,lines,def);
% if ~length(answer)
%   return
% end
% handles.printerLinesPerPage = str2num(answer{1});
% guidata(handles.figure1, handles);
% [err, errMsg] = printLog(handles)

% set up default values
% setting this to zero & notepad will deal with
%  page numbering etc.
handles.printerLinesPerPage = 0; %60;
%
handles.printerCmdLine = 'notepad /a /p';
createFile2Print(handles);
% --------------------------------------------------------------------
function createFile2Print(handles);
[err, errMsg, modName] = initErrModName(strcat(mfilename, '(printLog)'));

spaces(1:100) = ' ';
charPerLine = 80;
a = length( get(handles.textHdg1,'string') ) + length( get(handles.textHdg5,'string') ); 
handles.header.line = {sprintf('%s%s%s', get(handles.textHdg1,'string'), spaces(1:charPerLine-a), get(handles.textHdg5,'string') )};
a = length( get(handles.textHdg2,'string') ) + length( get(handles.textHdg6,'string') ); 
handles.header.line(2) = {sprintf('%s%s%s', get(handles.textHdg2,'string'), spaces(1:charPerLine-a), get(handles.textHdg6,'string') )};
handles.header.line(3) = {get(handles.lbHdg3,'string')} ;
handles.header.line(4) = {get(handles.textHdg4,'string')} ;
b(1:charPerLine) = '-';
handles.header.line(4) = {b};

ud = get(handles.figure1,'userdata') ;
% % ud.displayedFilePathName
[pathstr,name,ext,versn] = fileparts(ud.displayedFilePathName) ;
handles.workingDir = endWithBackSlash(pathstr);

totalPages = 0;
displayedText = ud.listAsRead;
[err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
%pull seconds.  ex: 15:01:59.7810 -> 15:01
a = findstrchr(':', prettyDateTime);
prettyDateTime = prettyDateTime(1:a(2)-1);
for loopNdx = 1:2
  displayedTextNdx = 2;
  thisPage = 0;
  % loop through the log until all entires are printed using as many pages as needed
  while displayedTextNdx <= length(displayedText)
    %here because starting a new page
    thisPage = thisPage + 1;
    lineCount = 0;
    % initialize the text output array
    if handles.printerLinesPerPage
      textToPrint([1:handles.printerLinesPerPage]) = {''};
    else
      textToPrint([1:(length(handles.header.line) + length(displayedText))]) = {''};
    end
    %place the header from the log at the top of the page & include a page count on the second line
    for itemp = 1:length(handles.header.line)
      lineCount = lineCount + 1;
      textToPrint(lineCount) = handles.header.line(itemp);
    end % for itemp = 1:length(handles.header.line)
    %the column heading
    lineCount = lineCount + 1;
    textToPrint(lineCount) = displayedText(1);
    %keep adding the actual logged information until we've filled the page or reached the end of the log
    while (lineCount < length(textToPrint)) & (displayedTextNdx <= length(displayedText))
      lineCount = lineCount + 1;
      textToPrint(lineCount) = displayedText(displayedTextNdx);
      displayedTextNdx = displayedTextNdx + 1;
    end
    lineCount = length(textToPrint) ;
    if handles.printerLinesPerPage
      a = sprintf('Page %i of %i printed %s', thisPage, totalPages, prettyDateTime);
    else
      a = sprintf('Printed %s', prettyDateTime);
    end
    textToPrint(lineCount) = {sprintf('%s%s', spaces(1:floor((charPerLine-length(a))/2)), a)};
    %if second time through we've got the page count so we can accurately print
    if loopNdx > 1
      fname = sprintf('%s%s.prt', handles.workingDir, name); 
      fid = fopen(fname, 'w');
      if fid > 0
        % %         %if first time printing
        % %         if (thisPage < 2)
        % %           %                                    (draftLETR, portraitLANDSCAPE)
        % %           [initString, EjectPageTxt] = initPrintStrings(0, 1);
        % %           fprintf(fid, '%s', initString);
        % %         end
        % dump this page to a file
        for itemp = 1:lineCount
          fprintf(fid, '%s\r\n', char(textToPrint(itemp)));
        end
        %form feed: eject the page:
        % %         fprintf(fid, EjectPageTxt);
        fclose(fid);
        %send the file to the printer.
        % /a: open as ASCII; /p: send to default printer
        err = dos (sprintf('%s "%s"', handles.printerCmdLine, fname));
        % % err = dos (sprintf('copy "%s" %s', fname, handles.printerPort));
        if err
          errMsg = sprintf('%s: error printing "%s" on "%s".', modName, fname, handles.printerPort);
          break
        end
        delete(fname);
      end %if fid > 0
    end %if loopNdx > 1
  end %while displayedTextNdx <= length(displayedText)
  totalPages = thisPage ;
end % for loopNdx = 1:2
% --------------------------------------------------------------------
function varargout = file_Callback(h, eventdata, handles, varargin)
% Pull down menu.  chosing File is a noop
