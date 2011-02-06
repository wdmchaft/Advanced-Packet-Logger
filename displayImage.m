function varargout = displayImage(varargin)
% displayImage Application M-file for displayImage.fig
%    FIG = displayImage launch displayImage GUI.
%    displayImage('callback_name', ...) invoke the named callback.

% build list of N most recent files & add each to the File menu... or should that open/unhide a ListBox?
% Zoom main fig in & out
% if "bomb site" figure is on top of main figure, what should be action:
%   1) automatically move main image when mouse would become hidden.  Note this requires 
%      moving the mouse in absolute terms so it stays in the same relative location on the main figure.
%   2) making the bomb site figure translucent (is this possible?)
%   3) snapping the bombsite figure to a new location.
%   4) doing nothing

% list of the digitized points so user can review &/or change the name.  
%  good if it displays some of the parameters such as area.

% scale either doesn't have to be first or ask user if it has a scale, etc to begin with.

% current file's name needs to be prominently displayed perhaps in the title bars

% need powerful "forcecloseallfigs" copyied to all computers

% Last Modified by GUIDE v2.0 26-Feb-2009 16:03:16

if nargin < 2  % LAUNCH GUI
  if nargin < 1  % LAUNCH GUI
    fig = displayImage_OpeningFunction;
  else
    fig = displayImage_OpeningFunction(varargin{:});
  end
  
  if nargout > 0
    varargout{1} = fig;
  end
  
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
  err = 0 ;
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
        fig = displayImage_OpeningFunction(varargin{:}) ;
      catch
        disp(lasterr);
      end
      if nargout > 0
        varargout{1} = fig;
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
%| 'fig_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.fig, handles.slider2. This
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

function varargout = displayImage_OpeningFunction(varargin)
nameForStore = strcat(mfilename,'.mat');
fig = openfig(mfilename,'reuse');

% Use system color scheme for figure:
set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

% Generate a structure of handles to pass to callbacks, and store it. 
handles = guihandles(fig);
%Most recently used list of the last N files the user has loaded into this program
handles.imageFileList = {}; %we'll try to load this from the last run settings
%create a list of all formats supported by "imread"
%  for speed we'll run the function once & store the results within handles. (don't know how much time this saves - may not be needed/user may not notice)
handles.fileMask = initializeFileMask; 
%name for storing the user choices & program conditions when we exit.  Results
% allow program to start next time with same values.
handles.nameForStore = nameForStore;
%if the user didn't give the fig a name in "guide", we'll default to the 
% name of this mfile.
a = get(fig, 'name');
ni = findstr(a,'Untitled');
if ~isempty(ni)
  set(fig,'name',mfilename);
end

% location and size of the figures
handles.FigMPposition = 0;
handles.Fig2Pposition = 0;
handles.figure2 = 0;
%check if conditions from previous run are exist (includes previous GUI position)
fidStore = fopen(nameForStore, 'r');
if (fidStore > 0)
  fclose(fidStore);
  load(nameForStore);
  handles.FigMPposition = FigMPposition ;
  handles.Fig2Pposition = Fig2Pposition;
  handles.imageFileList = imageFileList;
  set(fig, 'Position', FigMPposition);
else % if (fidStore > 0)
  movegui(fig, 'northeast');
end % if (fidStore > 0) else
%if the caller of this entire module is trying to set the properties....
initMainFig;
if nargin
  if (nargin > 1)
    set(fig, varargin{:})
  else
    handles.imagePathNName = char(varargin{:}) ;
    [pathstr,name,ext,versn] = fileparts(handles.imagePathNName);
    handles.imagePath = endWithBackSlash(pathstr);
    displayImage(handles);
    handles = guidata(handles.figure1);
  end
end

handles.nameForStore = nameForStore;
handles.imagePath = pwd ;
% now that we've updated the handles structure, we need to update the stored location
guidata(handles.figure1, handles);
set(fig,'visible','on');
% Wait for the callbacks to be run and the window to be dismissed
% % uiwait(fig)
varargout{1} = fig;
% --------------------------------------------------------------------

function fileMask = initializeFileMask;
%OUTPUT:
% Nx2 cell array for use by "uigetfile", an Explorer-like ui.
% the x1 elements are the actual masks only.
%     x2 elements contain the corresponding user prompts including 
%        the file mask within "( )" for user convenience/clarity.
%
%create a list of all formats supported by "imread"
% This will be used if the operator desires to open a file.
%The list will be presented to the user in two ways:
% 1) all supported files which is the complete list
% 2) a choice of each supported file.  For example, a separate choice for *.bmp, *.cur, etc.
%The first item in each line here is the actual file mask, not seen by the user.
%The second item in each line here is the user prompt which is only seen if the user
%  wants a subset of all the supported files.
a = {'*.bmp','Windows Bitmap',...
    '*.cur','Windows Cursor resources',...
    '*.hdf','Hierarchical Data Format',...
    '*.ico','Windows Icon resources',...
    '*.jpg;*.jpeg','Joint Photographic Experts Group',...
    '*.pcx','Windows Paintbrush',...
    '*.png','Portable Network Graphics',...
    '*.tif;*.tiff','Tagged Image File Format',...
    '*.xwd','X Windows Dump' ...
  };
%First step: build up a character string of the actual file masks
% which are the odd elements of the cell array "a"....
b = char(a(1));
for itemp = 3:2:length(a)
  %...separate the masks with a semi-colon ";"
  b = sprintf('%s;%s', b, char(a(itemp)) );
end
%create a cell array where the 1x1 element is the character string 
%   containing the file masks and the 1x2 element is the user prompt.
fileMask = {b,sprintf('All supported image files (%s)',b)};
%Extend the cell array adding elements in pairs where the first added element
% is a single mask from the original cell list "a" and the second element is the
% user prompt also from cell list "a"
%Loop index starting with the first element and stepping by 2 to access the odd elements
for itemp = 1:2:length(a)
  %calculate the index for the element we're adding
  b = size(fileMask,1)+1 ;
  %extract the file mask from cell array "a"
  c = char(a(itemp));
  %place the mask in the Nx1 position of the cell array....
  fileMask(b,1) = {sprintf('%s', c) };
  %place the user prompt in the Nx2 position of the cell array but for
  % user convenience/clarity also include the file mask within "( )"
  fileMask(b,2) = {sprintf('%s (%s)',char(a(itemp+1)), c) };
end
%FileMask list including the user prompts has been created.

% --------------------------------------------------------------------
function varargout = pushbutton1_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = File_menu_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = open_subFile_Callback(h, eventdata, handles, varargin)

curDir = pwd;
cd(handles.imagePath);
[fname,pname] = uigetfile(handles.fileMask) ;
cd(curDir)
if isnumeric(fname);
  if fname < 1
    return
  end
end
handles.imagePathNName = strcat(pname, fname);
handles.imagePath = pname;
guidata(handles.figure1, handles);
displayImage(handles);

% --------------------------------------------------------------------
function varargout = list_subFile_Callback(h, eventdata, handles, varargin)

%3 actions needed: open listBox, close listbox, accept user choice from listbox
% the first two actions are toggle operations controller from here
% the third action is in response to the listbox callback and is there

if findstr('on',lower(get(handles.recentFile_listbox,'visible')))
  set(handles.recentFile_listbox,'visible','off');
else
  %load the existing list
  set(handles.recentFile_listbox,'string', [handles.imageFileList {'<close list>'}]);
  %current file will be the top file
  set(handles.recentFile_listbox,'value', 1);
  set(handles.recentFile_listbox,'visible','on');
end

% --------------------------------------------------------------------
function varargout = displayImage(handles)
handles.imageFileList = updateFileList(handles.imageFileList, handles.imagePathNName);
hold off
A = imread(handles.imagePathNName);
imagesc(A)
hold on
initMainFig

if ~handles.figure2
  handles.figure2 = figure; %handles.figure1+1;
else
  figure(handles.figure2)
end
clf
imagesc(A)
hold on
a = get(get(handles.figure2,'CurrentAxes'),'CameraPosition');
set(get(handles.figure2,'CurrentAxes'),'CameraViewAngleMode','manual');
set(get(handles.figure2,'CurrentAxes'),'CameraPosition',[a(1:2) 1.2])
if length(handles.Fig2Pposition) > 1
  set(handles.figure2, 'Position', handles.Fig2Pposition);
end
set(handles.figure2,'visible','on');
% % set(handles.figure2,'CloseRequestFcn', 'displayImage(''figure1_CloseRequestFcn'',handles.figure1,[],guidata(handles.figure1))')
guidata(handles.figure1, handles);

% --------------------------------------------------------------------
function initMainFig
set(gca, 'DataAspectRatio',[1,1, 1])
set(gca, 'position',[0 0 1 1], 'visible','off')
set(gcf, 'color',[0 0 0]);


% --- Executes when user attempts to close figure1.
function varargout = figure1_CloseRequestFcn(hObject, eventdata, handles, varargin)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure

%this callback needs an appropriate function line as required by the new Matlab
%close all the sub panels

% close the figure
% use try/catch just in case the figure was closed in some manner or another
%  that we didn't detect.  In other words, do not assume that we know the figure status. 
%  This merely avoids a error message 
Fig2Pposition = 0;
try
  Fig2Pposition = get(handles.figure2, 'Position');
  delete(handles.figure2);
catch
end
%store the figure's position
FigMPposition = get(handles.figure1, 'Position');
imageFileList = handles.imageFileList;
save(handles.nameForStore, 'FigMPposition','Fig2Pposition','imageFileList');

% close the MasterPanel
%delete(handles.figure1)
delete(hObject);

% --------------------------------------------------------------------
function updatedFileList = updateFileList(fileList, currentFile);
%manages the passed in list:
% 1) if the currentFile is not in the list, it placed on the top & all others pushed down
% 2) if the currentFile is on the list, it is moved to the top

maxFileList = 20 ;

a = find(ismember(fileList, currentFile));
%is the currentFile already in the list?
if a
  %in the list!
  b = fileList(a);
  %if first member all ready, we're done
  if a < 2
    updatedFileList = fileList;
  else
    %not first member
    % is it last member?
    if a == length(fileList)
      %yes, last member
      c = [1:a-1];
    else
      %is not the last member
      c = [1:a-1 a+1:length(fileList)];
    end
    updatedFileList = fileList([a c]);
  end
else
  %New! not in list
  %is the list at the maximum allowed length?
  if length(fileList) < maxFileList
    %not at maximum length
    c = [1:length(fileList)];
  else
    %at maximum length: oldest is at the bottom & gets tossed
    c = [1:maxFileList-1];
  end
  updatedFileList = [{currentFile} fileList([c])];
end  


% --------------------------------------------------------------------
function varargout = recentFile_listbox_Callback(h, eventdata, handles, varargin)
%the listbox is made visible/not visible by the List submenu in the Files menu
a = get(handles.recentFile_listbox,'string');
val = get(handles.recentFile_listbox,'value');
handles.imagePathNName = char(a(val));
%last list entry is not a file but allows user to close the list
if val < length(a)
  displayImage(handles);
end
set(handles.recentFile_listbox,'visible','off');