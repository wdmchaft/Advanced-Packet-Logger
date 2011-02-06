function varargout = logPrint(varargin)
% LOGPRINT Application M-file for logPrint.fig
%    FIG = LOGPRINT launch logPrint GUI.
%    LOGPRINT('callback_name', ...) invoke the named callback.
%INPUT
%  handles structure including
%     .logPrintStartLogLine: line of data of the log to start printing
%         (always prints to end of log).  Note: countof data lines
%         headings, headers, and anything preceeding the data isn't counted.
%     .logPrintFirstPageNum: merely for the print-out, this is the number
%         to be placed on the first page printed during run 
%     .logged: array of the lines of data from the log



% Creating using GUIDE v2.0 27-May-2010 11:00:09

% wip: 
%   return variables not implemented suitably yet
%  be nice to have summary on the last page.. or perhaps
%   on its own page but with the same title & footer
%  how is displayCounts eliminating quotes in title?

% Should call this passing in the log line(s) of interest, and the page number
%   of the first page.
% This program will print the log using as many pages as needed. :
%   * each page will start with the same title
%   * each page will have a footer containing page number information to assist keeping the
%     pages together (something like "page X of N through M"), the time and date of the printing

% Need to handle a condition change line differently than a logged info line: one textbox,
%   perhaps no border.  May need to consider how to re-format the title when this occurs!

err = 0;
errMsg = '';
figure1 = 0 ;
if nargin == 0  % LAUNCH GUI
  [err, errMsg, lastPagePrt, lastLogLinePrt] = logPrint_OpeningFcn;
elseif nargin < 4 % LAUNCH GUI and pass path or path\name
  [err, errMsg, lastPagePrt, lastLogLinePrt] = logPrint_OpeningFcn(varargin{:});
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
  %This "if" provides a method of passing parameters to "logPrint_OpeningFcn".  It responds
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
        [err, errMsg, lastPagePrt, lastLogLinePrt] = logPrint_OpeningFcn(varargin{:}) ;
      catch
        % disp(lasterr);
        fprintf('\r\n%s while attempting logPrint_OpeningFcn with %s', lasterr, varargin{1});
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
  %#IFDEF debugOnly
  % these only work in IDE... which is also the only time we want them!
  assignin('base', 'err', err);
  assignin('base', 'errMsg', errMsg);
  assignin('base', 'lastPagePrt', lastPage);
  assignin('base', 'lastLogLinePrt', lastLogLinePrt);
  %#ENDIF
case 1
  varargout{1} = figure1 ;
case 2
case 3
  varargout{1} = err;
  varargout{2} = errMsg;
  varargout{3} = lastPagePrt ;
case 4
  varargout{1} = err;
  varargout{2} = errMsg;
  varargout{3} = lastPagePrt ;
  varargout{4} = lastLogLinePrt ;
otherwise
end
% --------------------------------------------------------------------

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
function varargout = logPrint_OpeningFcn(varargin)

[err, errMsg, modName] = initErrModName(strcat(mfilename, '(logPrint_OpeningFcn)'));

fig = openfig(mfilename,'reuse');

%color to white - we're going to be printing!
bcolr = [1 1 1];
set(fig,'Color', bcolr);
% % % Use system color scheme for figure:
% % set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

handles = guihandles(fig);
handles.bcolr = bcolr;
guidata(fig, handles);

if nargin
  h_in = varargin{1};
end

%place these in the order we want them displayed
columnNames = {
    'textHdgLclMsgNo', ...
    'textHdgSndrMsgNo', ...
    'textHdgBBS', ...
    'textHdgOpstTm', ...
    'textHdgFormTime', ...
    'textHdgFrom', ...
    'textHdgTo', ...
    'textHdgType', ...
    'textHdgSubject', ...
    'textHdgComment', ...
    'textHdgReplyReq', ...dd
    'border', ...
  };

%set the column headings & make their background color the same as the figure's
handles.fontSize = 10;
opts = struct('BackgroundColor', handles.bcolr, 'fontName', 'Courier', 'fontUnits', 'points', 'fontSize', handles.fontSize);

initHeading(handles.textHdgLclMsgNo, {'LOCAL','Msg No'}, opts)
initHeading(handles.textHdgSndrMsgNo, {'SENDER','Msg No'}, opts);
initHeading(handles.textHdgBBS, {'','BBS'}, opts);
initHeading(handles.textHdgOpstTm, {'OUTPOST','TIME'}, opts);
initHeading(handles.textHdgFormTime, {'FORM','TIME'}, opts);
initHeading(handles.textHdgFrom, {'','FROM'}, opts);
initHeading(handles.textHdgTo, {'','TO'}, opts);
initHeading(handles.textHdgType, {'MESSAGE','TYPE'}, opts);
initHeading(handles.textHdgSubject, {'','SUBJECT'}, opts);
initHeading(handles.textHdgComment, {'','COMMENT'}, opts);
initHeading(handles.textHdgReplyReq, {'REPLY','RQD.'}, opts);

set(handles.textFooter, opts);
%border color for the log entries (not the columns titles): darken compare to the figure background:
handles.brdcolr = 0.5 * handles.bcolr;

handles.h_column(1:length(columnNames), 1) = 0;
handles.borderNdx = length(columnNames);
%if textwrap can't fit the text in the width, split before these
handles.lineBreak = '-@:[](){}/,;'; %/ splits within date
%find all the column heading fields "textHdg<name>" & the border behind them
fn = fieldnames(handles);
for itemp = 1:length(fn)
  Ndx = find(ismember(columnNames, fn(itemp))) ;
  if Ndx 
    handles.h_column(Ndx, 1) = getfield(handles, char(fn(itemp))) ;
  end % if Ndx
end % for itemp = 1:length(fn);

%title height, width, & position are performed in firstTime
% % %adjust the height of the title box - position is adjusted in "positBorder"
% % % % st = get(handles.textPageTitle, 'string');
% % st = h_in.header.line;
% % st(length(st)+1) = {h_in.logCoreName};
% % posit = get(handles.textPageTitle, 'Position');
% % [outstring,newpos] = textwrap(handles.textPageTitle, st);
% % %if text wrapping occurs, at least one line is too long
% % posit(4) = newpos(4);
% % set(handles.textPageTitle, 'position' , posit, 'string', outstring, opts);
set(handles.textPageTitle, opts);
set(handles.figure1,'Name', h_in.logPathName);

%first call: position the column headings, make all column headings the same size, 
%  position title, border (border), and
%  figure size (eliminate white space top, left, & right borders beyond the margins;
%  maintain paper aspect ratio.
handles = positBorder(handles.textPageTitle, handles, 1, h_in);

conChgNdx = find(ismember(h_in.dispFieldNms,'conditionChange')) ;

% h_in.columnHeader:
%  []    'LOCAL,XFR   ,   ,OUTPOST,FORM,    ,  ,         ,       ,       ,REPLY'
% 'MSG #,MSG NO,BBS, TIME  ,TIME,FROM,TO,FORM TYPE,SUBJECT,COMMENT, RQD.,FileName,When Logged'
% h_in.dispColHdg [1:11]
% 'LOG-MSG-NO' 'TRANSFER-MSG-NO' 'BBS' 'OUTPOST-TIME' 'FORM-TIME' 'FROM' 'TO' 'MSG-TYPE' 'SUBJECT' 'COMMENT' 'REPLY-RQD.'

%set date & time for footer
[err, errMsg, date_time, prettyDateTime] = datevec2timeStamp(now);
%pull seconds.  ex: 15:01:59.7810 -> 15:01
a = findstrchr(':', prettyDateTime);
prettyDateTime = prettyDateTime(1:a(2)-1);
%learn current location of footer: we'll add lines from the log
%  until the page is full enough to impinge on the footer
posit_footer = get(handles.textFooter, 'Position');
%first time is page counting, second is actual printing
lastPage = 0;
for printIt = 0:1
  thisPage = h_in.logPrintFirstPageNum;
  footText = sprintf('Page %i of %i through %i.  Printed %s', thisPage, h_in.logPrintFirstPageNum, lastPage, prettyDateTime);
  set(handles.textFooter, 'String', footText);
  %lines printed/displayed so far on this page - only the column headings
  linePageNdx = 1;
  for lineLogNdx = h_in.logPrintStartLogLine:size(h_in.logged, 1)
    linePageNdx = linePageNdx + 1;
    [endOfPage, currentVposition] = addRow(h_in.logged(lineLogNdx, :), handles, linePageNdx, conChgNdx);
    handles = guidata(handles.figure1);
    handles = positBorder(handles.h_column(size(handles.h_column, 1), (linePageNdx-1)), handles, linePageNdx);
    %check if the latest line is interfering with the footer
    % %     if lineLogNdx == 96
    % %       fprintf('\ndebug.');
    % %     end
    posit = get(handles.h_column(size(handles.h_column, 1), linePageNdx), 'Position') ;
    if (posit(2) < (posit_footer(2) + posit_footer(4)) )
      %hide the line just created
      %  create index based on non-zero handles!
      validHndl = find(handles.h_column(:, linePageNdx));
      for Ndx = 1:length(validHndl)
        set(handles.h_column(validHndl(Ndx), linePageNdx), 'Visible', 'off');
      end % for Ndx = 1:length(validHndl)
      if printIt
        %print the page
        %%%%%%%%%%%%%%%%
        printPage(handles);
        %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%
      end
      %delete all lines from the log except for the column heading & the non-yet-displayed line
      for colNdx = 1:size(handles.h_column, 1)
        for LiNdx = 2:(linePageNdx-1)
          a = handles.h_column(colNdx, LiNdx) ;
          if a
            delete (a)
          end
        end % for LiNdx = 2:LiNdx
      end % for colNdx = 1:size(handles.h_column, 1)
      %re-size the array
      handles.h_column = [handles.h_column(:,1) handles.h_column(:,linePageNdx)] ;
      guidata(handles.figure1, handles)
      linePageNdx = 2;
      %unhide the line just created
      for Ndx = 1:length(validHndl)
        set(handles.h_column(validHndl(Ndx), linePageNdx), 'Visible', 'on');
      end % for Ndx = 1:length(validHndl)
      %position the line relative to the column heading
      handles = positBorder(handles.h_column(size(handles.h_column, 1), (linePageNdx-1) ), handles, linePageNdx);
      % update the footer text
      thisPage = thisPage + 1;
      footText = sprintf('Page %i of %i through %i.  Printed %s', thisPage, h_in.logPrintFirstPageNum, lastPage, prettyDateTime);
      set(handles.textFooter, 'String', footText);
      % loop
    end %if (posit(2) < (posit_footer(2) + posit_footer(4)) )
  end % for lineLogNdx = 1:size(h_in.logged, 1)
  lastPage = thisPage;
end %for printIt = 0:1
%print the page
printPage(handles);
%close the form
delete(handles.figure1)

varargout{1} = err;
varargout{2} = errMsg;
varargout{3} = lastPage;
varargout{4} = lineLogNdx;
% --------------------------------------------------------------------
function [handles] = positBorder(h_refAbove, handles, linePageNdx, h_in);
%  make the "textHdg" items all the same height
%  adjust the border size to be outside of all these fields

%  create index based on non-zero handles!
validHndl = find(handles.h_column(:, linePageNdx));
%exclude the border from this list
validHndl = validHndl(find(validHndl<handles.borderNdx));
if (linePageNdx == 1)
  [leftMove, posit_title, handles] = firstTime(handles, linePageNdx, validHndl, h_in);
  handles = guidata(handles.figure1);
else
  leftMove = 0;
  posit_title = get(h_refAbove, 'Position');
end
%measure the height of all elements other than the last which is the border
maxHi = 0 ;
for Ndx = 1:length(validHndl)
  % guide was used to set the units to pixels
  posit = get(handles.h_column(validHndl(Ndx), linePageNdx), 'Position');
  maxHi = max(maxHi, posit(4));
end % for Ndx = 1:length(validHndl)
%adjust the height of all text boxes to be the same, and position aligning
%  the top of the boxes
for Ndx = 1:length(validHndl)
  % guide was used to set the units to pixels
  % x, y, wide, hi
  posit = get(handles.h_column(validHndl(Ndx), linePageNdx), 'Position');
  posit(4) = maxHi;
  % don't double the border line at the top except for the column heading line
  posit(2) = posit_title(2) - maxHi - (linePageNdx == 1)*handles.outWid;
  %if not first line (column headings), leftMove will be zero
  posit(1) = posit(1) - leftMove;
  set(handles.h_column(validHndl(Ndx), linePageNdx), 'Position', posit);
end % for itemp = 1:length(fn);

%adjust the border to just surround the text boxes:
posit = get(handles.h_column(1, linePageNdx), 'Position');
posit_border = posit(1) - handles.outWid;
posit_border(2) = posit(2) - handles.outWid;
% don't double the border line at the top
posit_border(4) = posit(4) + (1+(linePageNdx == 1))*handles.outWid ;
% % posit = get(handles.h_column(size(handles.h_column, 1)-1, linePageNdx), 'Position');
posit = get(handles.h_column(length(validHndl), linePageNdx), 'Position');
posit_border(3) = posit(1) + posit(3) - posit_border(1) + handles.outWid;
set(handles.h_column(size(handles.h_column, 1), linePageNdx), 'Position', posit_border);
% --------------------------------------------------------------------
function [endOfPage, currentVposition] = addRow(logLineData, handles, linePageNdx, conChgNdx)
%logLineData(ColNdx): array containing data for this line
%linePageNdx: line number which starts with 1 == column title line, 
%  therefore 2== first line of log data on this page
% Another sub to create a row of boxes + border (set background color)
% * loads each box with data from a line in the log
% * textwrap each box.
% * adjust height of all boxes to equal maximum height of any box
% * call sub 1 to adjust Y of all boxes to align with element above 
% Set figure units to inches
% handles.dispFieldNms = {'logMsgNo','xfrMsgNo','bbs','shortOutpostDTime','shortFormDTime',...
%     'from','to','formType','subject','comment','replyReqd',...
%     'outpostDTime','formDTime','fpathName','conditionChange'};
%the log data will be loaded in handles.logged(logLineNdx, ColNdx) where
%  ColNdx corresponds 1:1 to these headings.  The tie-in between these headings
%  and the data is via the actual field names coded in "handles.dispFieldNms"
endOfPage = 0 ;
currentVposition = 0;
%create the background border - sizing will come later.
handles.h_column(size(handles.h_column, 1), linePageNdx) = uicontrol('Style', 'text', 'parent', handles.figure1,'units','normalized','backgroundColor', handles.brdcolr);
opts = struct('Style', 'text', 'parent', handles.figure1,'units','normalized', ...
  'fontName', 'Courier', 'fontUnits', 'points', 'fontSize', handles.fontSize, 'BackgroundColor', handles.bcolr);

%is this line showing what conditions changed?
str = logLineData{conChgNdx};
if length(str)
  % this line is a conditions changed informational line
  numCols = 1;
else
  numCols = min(length(logLineData), size(handles.h_column, 1)-1);
end

%create a box for each entry & adjust the height so the the info will fit without changing the width
for colNdx = 1:numCols
  %going to use the column headings as the reference
  lineAboveNdx = 1;
  h_colAbove = handles.h_column(colNdx, lineAboveNdx);
  posit = get(h_colAbove, 'Position');
  %as a starting point move down one position guessing height will be the same - adjust later
  %  main thing we want is the width for textwrap
  posit(2) = posit(2) - posit(4) - handles.outWid;
  if numCols < 2
    %only one entry on this line.  Extend width to last column's right edge
    p2 = get(handles.h_column(size(handles.h_column, 1)-1, lineAboveNdx), 'Position');
    posit(3) = p2(3) + p2(1) - posit(1);
  else
    str = logLineData(colNdx);
  end
  handles.h_column(colNdx, linePageNdx) = uicontrol(opts, 'position' , posit);
  % %   if  strcmp(str,'KI6SEP@mtv;K6FSH@mtv,; KI6SEP@mtv')
  % %     fprintf('ajds;askldjk');
  % %   end
  [outstring,newpos] = textwrap(handles.h_column(colNdx, linePageNdx), str);
  %if too wide for the box, find breaks other than spaces, which is all that text wrap uses
  if newpos(3) > posit(3)
    newLine = 0;
    a = length(char(outstring(1)));
    for itemp = 2:length(outstring)
      a = max(a, length(char(outstring(1))) );
    end
    maxLen = floor(posit(3)/newpos(3) * a);
    %check created line & shorten those that are too long
    wrapNdx = 1;
    b = '';
    newOut = {};
    while wrapNdx <= length(outstring)
      [os,newpos] = textwrap(handles.h_column(colNdx, linePageNdx), outstring(wrapNdx));
      if newpos(3) > posit(3)
        b = '';
        for itemp = 1:length(os)
          b = strcat(b, char(os(itemp)) );
        end
        a = find(ismember(b, handles.lineBreak));
        if a
          %find the break character closest to but before the width limit
          a = a(find(a <= maxLen & (a>1)));
          if a
            a = a(length(a));
          else
            a = maxLen+1;
          end
          %           %if multiple, this may not be the best place to do the split
          %           %  Also not considering there may be a need for more than two lines
          newLine = newLine + 1;
          %extract up to the break
          newOut(newLine) = {b(1:a(1)-1)};
          %get the remainder
          b = b(a(1):length(b));
          %prepend the remainder on to the next wrapped line
          if (wrapNdx) < length(outstring)
            b = sprintf('%s %s', b, char(outstring(wrapNdx+1)));
          end
          wrapNdx = wrapNdx + 1;
          outstring(wrapNdx) = {b};
        else
          newOut = {b};
        end
      else %if newpos(3) > posit(3)
        newLine = newLine + 1;
        newOut(newLine) = outstring(wrapNdx);
        wrapNdx = wrapNdx + 1;
      end %if newpos(3) > posit(3) else
    end
    [outstring,newpos] = textwrap(handles.h_column(colNdx, linePageNdx), newOut);
  end %if newpos(3) > posit(3)
    
  % x, y, wide, hi: adjust height but not width!
  posit(4) = newpos(4);
  set(handles.h_column(colNdx, linePageNdx), 'position' , posit);
  
  set(handles.h_column(colNdx, linePageNdx), 'string', outstring);
end % for colNdx = 1:min(length(logLineData), size(handles.h_column, 1)-1)
guidata(handles.figure1, handles);
% --------------------------------------------------------------------
function [leftMove, posit_title, handles] = firstTime(handles, linePageNdx, validHndl, h_in);
% Establish motion needed to left justify column locations
% Center Title & Footer to the columns
% Adjust paper width to just fit columns
% Adjust paper height to maintain aspect ratio (11x8.5)
% Adjust form size to fit on the screen
%  adjust FontSize if needed to account for any change in form width
% Place Title at top of page & Footer at bottom


%set the outline border width based on the layout from guide
posit = get(handles.h_column(2, linePageNdx), 'Position');
handles.outWid = posit(1); %width ends at the left edge of the second column....
%want to fill the figure so there is no white space to the left, right or top
% first determine how far things have to move to the left
posit = get(handles.h_column(1, linePageNdx), 'Position');
%. . . width begins with the right edge of the first column
handles.outWid = handles.outWid - (posit(1) + posit(3));
%want left to be at left edge (0) but need the border to be there first
leftMove = posit(1) - handles.outWid;
%columns start at the X of the first column....
colWidth = posit(1);
%... and end at the X+width of the last column
posit = get(handles.h_column(validHndl(length(validHndl)), linePageNdx), 'Position');
%  colWidth needs to include the border width
colWidth = posit(1) + posit(3) + 2 * handles.outWid - colWidth;

%However we need to adjust the figure size. . .
posit_fig = get(handles.figure1, 'Position');
posit_fig(3) = posit_fig(3) * colWidth;
%  adjust the height to maintain the aspect ratio of the paper
paperPosit = get(handles.figure1, 'paperPosition'); %paperPosition includes the margin settings
%PaperPosition Location on printed page. A rectangle that determines the location of 
%  the figure on the printed page. [left, bottom, width, height]
posit_fig(4) = posit_fig(3)*(paperPosit(4)) / (paperPosit(3));

%disable re-sizing so UI elements don't change as form size established
set(handles.h_column(1:size(handles.h_column, 1), 1), 'Units','pixels');
set(handles.textPageTitle, 'Units','pixels');
%form adjusted to paper size
set(handles.figure1, 'Position', posit_fig);
%enable re-sizing to track form size adjust to screen size
set(handles.h_column(1:size(handles.h_column, 1), 1), 'Units','Normalized');
set(handles.textPageTitle, 'Units','Normalized');

%find the max width & height that will fit and NOT be hidden by Windows' taskbar
[figFillPos, figMenuNoBrd, figMenu] = screenSize(handles.figure1);
%adjust if width or height is too big for the screen maintaining aspect ratio
posit3 = posit_fig(3);
if figMenu(3) < posit_fig(3)
  %too wide - adjust 
  posit_fig(4) = posit_fig(4) * figMenu(3) / posit_fig(3);
  posit_fig(3) = figMenu(3) ;
elseif figMenu(4) < posit_fig(4)
  %too high - adjust 
  posit_fig(3) = posit_fig(3) * figMenu(4) / posit_fig(4);
  posit_fig(4) = figMenu(4) ;
end
posit_fig(2) = figMenu(2);
%calculate the ratio to adjust the font based on the change in width
handles.fontSize = handles.fontSize * posit_fig(3) / posit3;
%adjust the font size so the titles still fit.
set(handles.h_column(1:size(handles.h_column, 1), 1), 'FontSize', handles.fontSize);

%finally set the figure to the new height & width
%  for some reason, perhaps related to the use of "maximize", the "set"
%  results in the figure being made visible.  This resolves the issue.
%Detect the current state (in case we're debugging & have over ridden the
%  normal non visible state)...
visNow = get(handles.figure1,'visible');
%... position the figure and re-establish the visibility
set(handles.figure1, 'Position', posit_fig, 'visible', visNow);
%move it on screen in case the adjustments have moved it off.
movegui(handles.figure1,'onscreen')

%center of colums are here:
c_cols = (colWidth)/2 - leftMove;

%position title at top of page centered to columns
posit_title = get(handles.textPageTitle,'position');
%set title width to figure width
posit_title(3) = 1; %1==100%   % % posit_fig(3);
% % c_tle = posit_title(1) + posit_title(3)/2;
%want the title at the top of the figure
posit_title(2) = 1 - posit_title(4); % % %  - topMargin;
%adjust the title position to the left edge
posit_title(1) = 0; % % posit_title(1) + c_cols - c_tle ;
%place the title & adjust the font size (if it changed)
set(handles.textPageTitle,'position', posit_title, 'FontSize', handles.fontSize) ;
st = h_in.header.line;
st(length(st)+1) = {h_in.logCoreName};
posit = get(handles.textPageTitle, 'Position');
[outstring,newpos] = textwrap(handles.textPageTitle, st);
%if text wrapping occurs, at least one line is too long
if length(outstring) > length(st)
  %determine which line(s) too long
  for itemp = 1:length(st)
    while 1
      [outstring,newpos] = textwrap(handles.textPageTitle, st(itemp));
      %not this line - go to next
      if (length(outstring) < 2)
        break
      end
      b = char(st(itemp)) ;
      % pull a double space out: one at the beginning & one at the end
      a = findstrchr('  ', b );
      if length(a)
        if length(a) > 2
          b = sprintf('%s%s%s', b(1:a(1)-1), b(a(1)+2:a(length(a))-1), b(a(length(a))+2:length(b)) );
        else % if length(a) >2
          if a
            b = sprintf('%s%s', b(1:a(1)-1), b(a(1)+2:length(b)) );
          else %if a
            break
          end % if a break
        end %if length(a) >2 else
      else % if length(a)
        break
      end %if length(a) else
      st(itemp) = {b};
    end %while 1
  end % for itemp = 1:length(st)
  [outstring,newpos] = textwrap(handles.textPageTitle, st);
end % if length(outstring) > length(st)
set(handles.textPageTitle, 'string', outstring);

%in case fontSize adjusted...
set(handles.textFooter, 'FontSize', handles.fontSize) ;
%position the footer:
[outstring,newpos] = textwrap(handles.textFooter, {get(handles.textFooter, 'String')}) ;
newpos(1) = c_cols - newpos(3)/2;
newpos(2) = 0; %at bottom
set(handles.textFooter, 'Position', newpos, 'String', outstring)

guidata(handles.figure1, handles)
% --------------------------------------------------------------------
function initHeading(h_col, instring, opts)
posit = get(h_col, 'Position');
[outstring,newpos] = textwrap(h_col, instring) ;
posit(4) = newpos(4);
set(h_col, 'String', outstring, opts, 'Position', posit);
% --------------------------------------------------------------------
function printPage(handles)
set(handles.figure1, 'visible', 'on')
drawnow
figure(handles.figure1)
%#IFDEF debugOnly
% IDE... ask user
if 1
  %IDE - user specifies printer... which also means there is a wait cycle
  print ('-v','-r600', '-painters', handles.figure1 )
else
  % compiled - print to default
  %#ENDIF
  print ('-r600', '-painters', handles.figure1 )
  %#IFDEF debugOnly
end
%#ENDIF
set(handles.figure1, 'visible', 'off')
% --------------------------------------------------------------------
