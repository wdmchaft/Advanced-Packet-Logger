function varargout = ics213Alignment(varargin)
% ICS213ALIGNMENT Application M-file for ics213Alignment.fig
% User interface to provide alignment procedure to allow use
% of pre-printed ICS213 forms in printer.  Includes instructions.
% Procedure includes printing alignment grid on form.  Printing is
% performed via WinWord which requires two macros to be loaded:
%    "NoMarginPortrait" & "PrintNoSaveExit"
% Macros are included as comments here with the versions as of 2/25/2010.
%
% Uses the following external routines:
%   findWinWord
%   read213Alignment

% Note "NoMarginPortrait" was recording of keyboard steps & may
%  contain undesired or unnecessary steps.
% Sub NoMarginPortrait()
% '
% ' NoMarginPortrait Macro
% ' Macro recorded 2/23/2010 by Andy Rose
% '
%     With ActiveDocument.Styles(wdStyleNormal).Font
%         If .NameFarEast = .NameAscii Then
%             .NameAscii = ""
%         End If
%         .NameFarEast = ""
%     End With
%     'Selection.WholeStory
%     With ActiveDocument.PageSetup
%         .LineNumbering.Active = False
%         .Orientation = wdOrientPortrait
%         .TopMargin = InchesToPoints(0.17)
%         .BottomMargin = InchesToPoints(0.17)
%         .LeftMargin = InchesToPoints(0.17)
%         .RightMargin = InchesToPoints(0.33)
%         .Gutter = InchesToPoints(0)
%         .HeaderDistance = InchesToPoints(0.5)
%         .FooterDistance = InchesToPoints(0.5)
%         .PageWidth = InchesToPoints(8.5)
%         .PageHeight = InchesToPoints(11)
%         .FirstPageTray = wdPrinterDefaultBin
%         .OtherPagesTray = wdPrinterDefaultBin
%         .SectionStart = wdSectionNewPage
%         .OddAndEvenPagesHeaderFooter = False
%         .DifferentFirstPageHeaderFooter = False
%         .VerticalAlignment = wdAlignVerticalTop
%         .SuppressEndnotes = False
%         .MirrorMargins = False
%         .TwoPagesOnOne = False
%         .BookFoldPrinting = False
%         .BookFoldRevPrinting = False
%         .BookFoldPrintingSheets = 1
%         .GutterPos = wdGutterPosLeft
%     End With
%     With Selection.Font
%         .Name = "Courier"
%         .Size = 10
%         .Bold = False
%         .Italic = False
%         .Underline = wdUnderlineNone
%         .UnderlineColor = wdColorAutomatic
%         .StrikeThrough = False
%         .DoubleStrikeThrough = False
%         .Outline = False
%         .Emboss = False
%         .Shadow = False
%         .Hidden = False
%         .SmallCaps = False
%         .AllCaps = False
%         .Color = wdColorAutomatic
%         .Engrave = False
%         .Superscript = False
%         .Subscript = False
%         .Spacing = 0
%         .Scaling = 100
%         .Position = 0
%         .Kerning = 0
%         .Animation = wdAnimationNone
%     End With
% End Sub
% Sub PrintNoSaveExit()
%     ActiveDocument.ActiveWindow.PrintOut Background:=False
%     Application.Documents.Close (Word.WdSaveOptions.wdDoNotSaveChanges)
%     Application.Quit
% End Sub

%    FIG = ICS213ALIGNMENT launch ics213Alignment GUI.
%    ICS213ALIGNMENT('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 23-Feb-2010 14:36:43

err = 0;
errMsg = '';
figure1 = 0 ;
if nargin == 0  % LAUNCH GUI
  [err, errMsg, figure1] = ics213Alignment_OpeningFcn;
elseif nargin < 2 % LAUNCH GUI and pass path or path\name
  [err, errMsg, figure1] = ics213Alignment_OpeningFcn(varargin{1});
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
  %This "if" provides a method of passing parameters to "ics213Alignment_OpeningFcn".  It responds
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
        [err, errMsg, figure1] = ics213Alignment_OpeningFcn(varargin{:}) ;
      catch
        % disp(lasterr);
        fprintf('\r\n%s while attempting ics213Alignment_OpeningFcn with %s', lasterr, varargin{1});
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
function varargout = ics213Alignment_OpeningFcn(varargin)

[err, errMsg, modName] = initErrModName(strcat(mfilename, '(ics213Alignment_OpeningFcn)'));

fig = openfig(mfilename,'reuse');

% Use system color scheme for figure:
set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

% Generate a structure of handles to pass to callbacks, and store it. 
handles = guihandles(fig);
guidata(fig, handles);

[err, errMsg, outpostNmNValues] = OutpostINItoScript;
PathConfig = outpostValByName('DirAddOns', outpostNmNValues);
handles.pathPrgms = outpostValByName('DirAddOnsPrgms', outpostNmNValues);

%file stored in .mat is much faster loading
fPathName = strcat(handles.pathPrgms, 'ICS-213-SCC-Message-Form1copy1');
%make sure the jpg isn't newer. . . if it exists at all
jpgDir = dir(strcat(fPathName,'.jpg'));
needCopy = 0;
if length(jpgDir)
  matDir = dir(strcat(fPathName,'.mat'));
  if length(matDir)
    if (datenum(jpgDir.date) > datenum(matDir.date))
      % source is newer or size is different
      needCopy = 1;
    end
  else % if length(matDir)
    needCopy = 1;
  end % if length(matDir) else
  if needCopy
    % % formImage = importdata(strcat(fPathName,'.jpg'));
    %this is faster: 2.7 sec versus 3.1.  load comes in at 0.26
    formImage = imread(strcat(fPathName,'.jpg'),'jpg');
    sourceModule = mfilename;
    save(fPathName,'formImage','sourceModule');
  end % if needCopy
end % if length(jpgDir)
if ~needCopy
  load(strcat(fPathName,'.mat'));
end

% MATLAB doesn't tell you statement requires ", handles.axes1" or
% a new figure is opened!
image(formImage,'parent', handles.axes1)
%Turn off the axis. Again, MATLAB doesn't show this is the method that works!
set(handles.axes1,'visible','off')

%     % not used but figured out how to get "axes1" to fit the full window
%     set(handles.axes1,'position', [0 0 1 1)

handles.pathToWord = 'f:\program files\microsoft office\office10\winword.exe' ;
handles.minRow = 1;
handles.maxRow = 100;
handles.minCol = 1;
handles.maxCol = 100;
handles.fname = 'printerAlign_ICS213.txt';
handles.fPathName = strcat(PathConfig, handles.fname);
set(handles.textFileName,'string',handles.fname);

[handles.topRowAlign, handles.leftColAlign, handles.rightColAlign, handles.botRowAlign, fromFile] = read213Alignment(handles.fPathName);
if fromFile
  set(handles.textFileName,'string',handles.fname);
else
  set(handles.textFileName,'string','none');
end
set(handles.editTop, 'string', handles.topRowAlign, 'toolTip', 'Printed row (include decimal) of bottom line of upper frame');
set(handles.editBot, 'string', handles.botRowAlign, 'toolTip', 'Printed row (include decimal) of bottom line of lowest frame');
set(handles.editLeft, 'string', handles.leftColAlign, 'toolTip', 'Printed column (include decimal) of left line of upper frame');
set(handles.editRight, 'string', handles.rightColAlign, 'toolTip', 'Printed column (include decimal) of right line of upper frame');

a = 'Pre-printed ICS213 Forms (a.k.a. Message Forms) may be used in the printer.';
a = sprintf('%s\nThese are only usable with PacFORM ICS213 messages. Note that', a);
a = sprintf('%s\nthe contents of the form can be slightly different in size depending', a);
a = sprintf('%s\non where the form came from or how it was printed.  PDF "print to fit"', a);
a = sprintf('%s\nmay be different than PDF no rescaling or printing of a .doc.', a);
a = sprintf('%s\n\nThe alignment process involves the following steps:', a);
a = sprintf('%s\n  1) Place a pre-printed form in the default printer.', a);
a = sprintf('%s\n  2) Press "Print" to place the pattern on the form.', a);
a = sprintf('%s\n  3) Inspect the resultant output and enter the two rows & two columns as indicated.', a);
a = sprintf('%s\n     Use decimals for greater accuracy.  Keep in mind rows #s increase downward which', a);
a = sprintf('%s\n     means a line on the form which is just above a row needs the number of the line above', a);
a = sprintf('%s\n     plus a decimal.  Example: 13.99 means the form line is just above Row 14.', a);
a = sprintf('%s\n  4) Press "Save" button. As noted earlier, forms may be different in size', a);
a = sprintf('%s\n     so the program allows you to name the saved file in a manner that is', a);
a = sprintf('%s\n     meaningful to you. That name is the name you need to specify when configuring', a);
a = sprintf('%s\n     the logging program.', a);

set(handles.textHelp,'toolTip', a);
guidata(handles.figure1, handles);

varargout{1} = err;
varargout{2} = errMsg;
varargout{3} = handles.figure1;

% --------------------------------------------------------------------
function varargout = editTop_Callback(h, eventdata, handles, varargin)
[err] = getCheckNumValEditBox(h, 'topRowAlign', handles, handles.minRow, handles.maxRow);

% --------------------------------------------------------------------
function varargout = editBot_Callback(h, eventdata, handles, varargin)
[err] = getCheckNumValEditBox(h, 'botRowAlign', handles, handles.minRow, handles.maxRow);

% --------------------------------------------------------------------
function varargout = editLeft_Callback(h, eventdata, handles, varargin)
[err] = getCheckNumValEditBox(h, 'leftColAlign', handles, handles.minCol, handles.maxCol);

% --------------------------------------------------------------------
function varargout = editRight_Callback(h, eventdata, handles, varargin)
[err] = getCheckNumValEditBox(h, 'rightColAlign', handles, handles.minCol, handles.maxCol);

% --------------------------------------------------------------------
function varargout = pushbuttonCancel_Callback(h, eventdata, handles, varargin)
delete(handles.figure1);
%
% C:\Documents and Settings\arose>"f:\program files\microsoft office\office10\winw
% ord" "C:\Documents and Settings\arose\Application Data\Microsoft\Templates\norma
% l.dot" "f:\temp\housing map grids.doc" /m"Landscape"

% --------------------------------------------------------------------
function varargout = pushbuttonSave_Callback(h, eventdata, handles, varargin)
%file wil be saved to "printerAlign_ICS213_<user entry>.txt"
handles.pathToWord = findWinWord(handles.pathToWord);
guidata(handles.figure1, handles);

[err, errMsg, fPathName] = write213Alignment(handles.fname, handles.topRowAlign, handles.leftColAlign, handles.rightColAlign, handles.botRowAlign);
if err
  return
end
%no errors: load the variables into handles.
handles.fPathName = fPathName;
[pathstr,name,ext,versn] = fileparts(handles.fPathName);
handles.fname = strcat(name,ext);
guidata(handles.figure1, handles);
set(handles.textFileName,'string',handles.fname);

% --------------------------------------------------------------------
function varargout = pushbuttonPrint_Callback(h, eventdata, handles, varargin)
handles.pathToWord = findWinWord(handles.pathToWord);
guidata(handles.figure1, handles);
button = questdlg('Please place a pre-printed ICS213 form in the default printer.',...
'Load Form','Print','Cancel','Print');
if ~strcmp(button,'Print')
  return
end
fid = -1 ;
if (fid < 1)
  fid = fopen(fPathName, 'w');
  col = '--|';
  flg = 0;
  %+3 'cause the Row starts with 2 characters and we're now loading the next character space
  for colNdx = (length(col)+3):95
    %if a 10's column
    if ~mod(colNdx, 10)
      %just want to 10's MSD: 10 -> 1, 80-> 8, 150 -> 5
      col = sprintf('%s%i', col, mod(colNdx,100)/10);
      flg = 1;
    elseif ~mod(colNdx, 5)
      col = sprintf('%s|', col);
    elseif flg
      flg = 0;
      col = sprintf('%s_', col);
    else
      col = sprintf('%s-', col);
    end
  end %for colNdx = (length(col)+3):95
  handles.maxCol = 1.1 * colNdx;
  %each row starts with two characters containing the row #
  for rowNdx = 1:60;
    if rowNdx < 10
      %leading zero
      a = sprintf('0%i', rowNdx);
    else
      a = sprintf('%i', rowNdx);
    end
    fprintf(fid, '%s%s\r\n', a, col);
  end
  handles.maxRow = 1.1 * rowNdx;
  guidata(handles.figure1, handles);
end
fclose(fid);
dosCmd = sprintf('"%s" ', handles.pathToWord);
%dosCmd= sprintf('%s"C:\\Documents and Settings\\arose\\Application Data\\Microsoft\\Templates\\normal.dot"', dosCmd);
dosCmd= sprintf('%s "%s" /m"NoMarginPortrait" /mPrintNoSaveExit', dosCmd, fPathName);
dos(dosCmd);
set(h,'value',0);
% --------------------------------------------------------------------
function varargout = pushbuttonDone_Callback(h, eventdata, handles, varargin)
delete(handles.figure1);
% --------------------------------------------------------------------
function varargout = pushbuttonLoad_Callback(h, eventdata, handles, varargin)
[pathstr,name,ext,versn] = fileparts(handles.fPathName);
pathStr = endWithBackSlash(pathstr) ;
dirList = dir(strcat(pathStr, '*printerAlign_ICS213*.txt'));
if ~length(dirList)
  errordlg(sprintf('No valid alignment (*printerAlign_ICS213*.txt) files in "%s"', pathStr),'No Valid Files','modal')
  return
elseif (length(dirList) > 1)
  listIn = {dirList.name};
  choice = userChoice(listIn, 'Update/backup direction', 1);
  if choice < 1
    fprintf('\r\nUser canceled!');
    return
  end
else
  choice = 1;
end
handles.fPathName = strcat(pathStr, char(dirList(choice).name));

[handles.topRowAlign, handles.leftColAlign, handles.rightColAlign, handles.botRowAlign, fromFile, handles.pathToWord] = read213Alignment(handles.fPathName);
guidata(handles.figure1, handles);
if fromFile
  set(handles.textFileName,'string',handles.fname);
else
  set(handles.textFileName,'string','none');
end
set(handles.editTop, 'string', handles.topRowAlign); 
set(handles.editBot, 'string', handles.botRowAlign); 
set(handles.editLeft, 'string', handles.leftColAlign); 
set(handles.editRight, 'string', handles.rightColAlign); 
% --------------------------------------------------------------------

% To prevent the flickering, set the Application.ScreenUpdating property to 
% False before executing your PageSetup function. Then, when the PageSetup 
% function has completed, you can set the Application.ScreenUpdating property back to True to reenable screen redraws. 
% 
% Set myRange = ActiveDocument.Range( _
%     Start:=ActiveDocument.Paragraphs(1).Range.Start, _
%     End:=ActiveDocument.Paragraphs(3).Range.End)
% With myRange
%     .Font.Name = "Arial"
%     .ParagraphFormat.Alignment = wdAlignParagraphJustify
% End With


% ActiveDocument.ActiveWindow.PrintOut _
%     Range:=wdPrintFromTo, From:="1", To:="3"
