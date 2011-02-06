function digitizePoints(figToTrack, figMagd, keyMOUSEpress, pathNName, groupNameIn);
%keyMOUSEpress:
% -2 = cell array "groupName" has been loaded but nothing else
% -1 = reinitialize
%  0 = key was pressed while 'figToTrack' was selected
%  1 = mouse button pushed while 'figToTrack' was selected
global digitizerOn currentGroup totalGroups pointsInGroup xOfGroup yOfGroup figsUsed
global initialized pH plotPtH scaleDistance groupName scaleDistance scaleFeetPerPixel h_dispPopupInfo scaleOrientation scaleOrientationText
global mouseXYZ lineColor lineColorNdx colorOrder pathNName
global projectName

global promptFromGroupNames

if nargin < 1
  figToTrack = 1;
end
if nargin < 2
  figMagd = 2;
end
if nargin < 3
  keyMOUSEpress = -1;
  promptFromGroupNames = 0;
end
% [ Xback,  Yback,  Zback
%   Xfront, Yfront, Zfront]

%  CODE being used
% % digitizePoints
% % 'cameraTrack'
% % ,'mouseButton'
% % 'whichkeyMOUSEpress'
% % zoomTrack
% % 
% % test code:
% % digitizeMouseButton
% % testkeyMOUSEpress
% figure(1);set(gcf,'WindowButtonMotionFcn', 'cameraTrack');figure(2);figure(1)

if (keyMOUSEpress == -2)
  promptFromGroupNames = 1;
  groupName = groupNameIn;
  if length(pathNName)
    [pathstr, projectName, ext, versn] = fileparts(pathNName);
  end  
end

%initialize

if length(initialized) < 1
  initialized = 0;
end
if ~initialized | keyMOUSEpress < 0
  set(figToTrack,'WindowButtonMotionFcn', '');
  set(figToTrack,'WindowButtonDownFcn','');
  set(figToTrack,'KeyPressFcn','')
  
  if length(projectName)
    a = projectName;
  else
    a = 'Test_digitize';
  end
  resumeIt = -1;
  while resumeIt == -1;
    prompt = {'Name of this project/image for later retrieval.  Each group or series of points is independently named by you within the project.'};
    answer  = inputdlg(prompt,'Digitize Points',1,{a});
    if length(answer) < 1
      return
    end
    projectName = char(answer(1));
    %check if the name all ready has a file associated with it
    % if it does, give the user the option of erasing the old file, adding to it, or trying a new name.
    fid = fopen(strcat(projectName, '.mat'), 'r');
    if fid > 0
      fclose(fid);
      a = sprintf('The project named "%s" all ready exists.  What do you want to do?', projectName);
      button = questdlg(a,...
        'Project Name','Load & resume/continue','Erase & replace','Enter a new name','Load & resume/continue');
      if strcmp(button,'Load & resume/continue')
        % these were added as user options in later versions: preset to the pre-choice settings
        %  which will be overwritten in the newer version but unaltered in the old ones.
        scaleOrientation = 2; 
        scaleOrientationText = 'Horizontal'; %just for the user - not critical
        loadDigitizedPoints(projectName);
        resumeIt = 1;
      elseif strcmp(button,'Erase & replace')
        resumeIt = 0;
      elseif strcmp(button,'Enter a new name')
        resumeIt = -1;
      end    
    else
      resumeIt = 0;
    end  
  end %while resumeIt == -1;
  if resumeIt == 0
    if promptFromGroupNames
      a = groupName(1);
    else
      a = {'Scale'};
    end
    prompt = {'Name of the first group or series of points'};
    answer  = inputdlg(prompt,'Digitize Points',1, a);
    if length(answer) < 1
      return
    end
    if promptFromGroupNames
      groupName(1) = answer(1);
    else
      groupName = answer(1);
    end    
    if strcmp('scale', lower(char(groupName)))
      prompt = {'Distance in feet of the scale'};
      answer  = inputdlg(prompt,'Digitize Points',1,{'400'});
      if length(answer) < 1
        return
      end
    else
      scaleDistance = 0;
    end
    scaleFeetPerPixel = 0;
    
    figsUsed(1) = figToTrack;
    figsUsed(2) = figMagd;
    digitizerOn = 1;
    currentGroup = 1;
    lineColorNdx = currentGroup;
    totalGroups = 1;
    pointsInGroup = 0;
    xOfGroup = 0;
    yOfGroup = 0;
    plotPtH = 0
    pH = 0;
  end %if resumeIt == 0
  %action when mouse moved: updates the X-Y location of the mouse & pans 2nd figure, the zoomed figure
  set(figToTrack,'WindowButtonMotionFcn', '');
  set(figToTrack,'WindowButtonMotionFcn', 'mouseTrack');
  fprintf('\n set figure(%i) for WindowButtonMotionFcn to mouseTrack.m', figToTrack);
  %action when mouse button pushed: will call this function with a flag; actual decoding is here
  set(figToTrack,'WindowButtonDownFcn','');
  set(figToTrack,'WindowButtonDownFcn','mouseButton');
  fprintf('\n set figure(%i) for WindowButtonDownFcn to mouseButton.m', figToTrack);
  %action when key pressed: will call this function with a flag; actual decoding is here
  set(figToTrack,'KeyPressFcn','')
  set(figToTrack,'KeyPressFcn','keyPress')
  fprintf('\n set figure(%i) for KeyPressFcn to keyPress.m', figToTrack);
  initialized = 1;
  [lineColor, lineStyle, colorOrder] = setColorLine(lineColorNdx(currentGroup));
  fprintf('\n Digitizing initialized on figure %i, magnified figure %i.  Old points erased.', figToTrack, figMagd);
  digitizeHelp
  return
end %if ~initialized | keyMOUSEpress < 0

%    make sure mouse is within the figure
if ~digitizeMouseInImage
  return
end

if ~keyMOUSEpress
  %key pressed
  currentCharacter = get(gcf,'CurrentCharacter') ;
  switch lower(currentCharacter)
  case 'c' %roll through the available colors & change the displayed colors of the current group
    lineColorNdx(currentGroup) = lineColorNdx(currentGroup) + 1;
    [lineColor, lineStyle, colorOrder] = setColorLine(lineColorNdx(currentGroup));
    for thisFig = 2:-1:1
      %find the valid handles
      a = find(pH(:, thisFig, currentGroup));
      %change the color of all existing "lines"
      for itemp = 1:length(a)
        set(pH(a(itemp), thisFig, currentGroup), 'EdgeColor', lineColor);
      end
      %change the color of all existing markers
      a = find(plotPtH(:, thisFig, currentGroup));
      for itemp = 1:length(a)
        set(plotPtH(a(itemp), thisFig, currentGroup), 'Color', lineColor);
      end
    end %for thisFig = 2:-1:1
  case 'g' % grab the nearest point from a previous group
    digitizeGrabNearestPt
  case 'p' %pause digitizing
    digitizerOn = 0;
    set(figsUsed(1),'WindowButtonMotionFcn', '');
  case 'r' %resume digitizing
    digitizerOn = 1;
    set(figsUsed(1),'WindowButtonMotionFcn', 'mouseTrack');
  case 'm' % modify a group
    listIn = {};
    for itemp = 1:totalGroups
      listIn(itemp) = groupName(itemp);
    end
    choice = userChoice(listIn, 'Group to modify', 1);
    if choice < 1
      fprintf('\r\nUser canceled!');
      return
    end
    %if previous group was a multiple point group but not a closed polygon, close it
    digitizeCloseGroup
    save(projectName,'currentGroup','totalGroups','pointsInGroup','xOfGroup','yOfGroup','figsUsed','pH',...
      'plotPtH','lineColorNdx','groupName','scaleDistance','scaleFeetPerPixel','scaleOrientation','scaleOrientationText',...
      'pathNName');
    fprintf('  Updated file "%s".', projectName);
    digitzeModifyGroup(choice)
  case 'n' %new group
    if pointsInGroup(currentGroup) < 2
      d = {'Continue existing','Start new group'};
      button = questdlg(sprintf('There are fewer than 2 points in the current group (%s): are you sure you want to start a new group?', char(groupName(currentGroup))),...
        'Few points', char(d(1)), char(d(2)), char(d(1)));
      if strcmp(button, char(d(1)))
        fprintf('\nContinuing existing group...');
        return
      end % if strcmp(button, char(d(1)))
    end % if pointsInGroup(currentGroup) < 2
    %setup for the new group
    tempA = totalGroups + 1;
    a = sprintf('Name of the new group (#%i) \nFormat "fieldID:=field text" if check box where checking is based on field text.', tempA);
    a = sprintf('%s\n  ex:\n   Enter 8:=FullAct for checkbox active when 8.: [FullAct]', a);
    prompt = {sprintf('%s\n   Enter 8:=Limited for checkbox active when 8.: [Limited]', a)};
    if promptFromGroupNames & (length(groupName) > currentGroup)
      a = char(groupName(currentGroup + 1));
    else %if promptFromGroupNames
      %develop a default name for the new name: add "_1" to the previous name.
      a = char(groupName(currentGroup));
      a = sprintf('%s_1', a);
    end % if promptFromGroupNames else
    answer  = inputdlg(prompt,'Digitize Points',1,{a});
    if length(answer) < 1
      return
    end
    %If the scaling group is just completed, determine the conversion factor
    if (currentGroup == 1)
      if strcmp('scale', lower(char(groupName(currentGroup))))
        d = {'Vertical','Horizontal','Mixed'};
        %suggest a default based on whether dX or dY is significantly greater
        a = xOfGroup(2, currentGroup) - xOfGroup(1, currentGroup);
        b = yOfGroup(2, currentGroup) - yOfGroup(1, currentGroup);
        c = char(d(3)) ;
        if abs(a/b) > 3
          c = char(d(2)) ;
        end
        if abs(b/a) > 3
          c = char(d(1)) ;
        end
        button = questdlg('Scale orientation on figure',...
          'Scale orientation', char(d(1)), char(d(2)), char(d(3)), c);
        if strcmp(button, char(d(1))) % vertical
          scaleFeetPerPixel = scaleDistance/(yOfGroup(2, currentGroup) - yOfGroup(1, currentGroup));
          scaleOrientation = 1;
        elseif strcmp(button, char(d(2)))  % horizontal
          scaleFeetPerPixel = scaleDistance/(xOfGroup(2, currentGroup) - xOfGroup(1, currentGroup));
          scaleOrientation = 2;
        elseif strcmp(button, char(d(3))) % mixed
          scaleFeetPerPixel = scaleDistance/sqrt(a^2 + b^2);
          scaleOrientation = 3;
        end
        scaleOrientationText = char(d(scaleOrientation));
        h_dispPopupInfo = dispPopupInfo;
      else%if strcmp('scale', lower(char(groupName)))
        if totalGroups < 2
          scaleFeetPerPixel = 0;
        end
      end %if strcmp('scale', lower(char(groupName))) else
    end % if (currentGroup == 1)
    digitizeCloseGroup
    save(projectName,'currentGroup','totalGroups','pointsInGroup','xOfGroup','yOfGroup','figsUsed','pH',...
      'plotPtH','lineColorNdx','groupName','scaleDistance','scaleFeetPerPixel','scaleOrientation','scaleOrientationText',...
      'pathNName');
    fprintf('  Updated file "%s".', projectName);
    currentGroup = tempA;
    groupName(currentGroup) = answer(1);
    
  
    totalGroups = max(totalGroups, currentGroup);
    pointsInGroup(currentGroup) = 0;
    lineColorNdx(currentGroup) = lineColorNdx(totalGroups-1) + 1;
    [lineColor, lineStyle, colorOrder] = setColorLine(lineColorNdx(currentGroup));
  case 'q' %quit
    digitizeCloseGroup
    set(figsUsed(1),'WindowButtonMotionFcn', '');
    set(figsUsed(1),'WindowButtonDownFcn','');
    set(figsUsed(1),'KeyPressFcn','')
    fprintf('\n Quit key pressed: window response disabled.  Data being saved.');
    if pointsInGroup(currentGroup) < 1
      totalGroups = currentGroup - 1;
    else
      totalGroups = max(totalGroups, currentGroup);
    end
    save(projectName,'currentGroup','totalGroups','pointsInGroup','xOfGroup','yOfGroup','figsUsed','pH',...
      'plotPtH','lineColorNdx','groupName','scaleDistance','scaleFeetPerPixel','scaleOrientation','scaleOrientationText',...
      'pathNName');
    fprintf('\n Digitized information saved in file "%s"', projectName);
  case {'?','h'}
    digitizeHelp
  otherwise
    fprintf('\nKey "%s" pressed.', currentCharacter);
  end %switch lower(currentCharacter)
else %if KeyPress
  %here because mouse button was pressed
  if digitizerOn
    SelectionType = lower(get(1,'SelectionType'));
    switch SelectionType
    case 'normal' %left: digitize point
      pointsInGroup(currentGroup) = pointsInGroup(currentGroup) + 1;
      thisPoint = pointsInGroup(currentGroup);
      xOfGroup(thisPoint, currentGroup) = mouseXYZ(1,1);
      yOfGroup(thisPoint, currentGroup) = mouseXYZ(1,2);
      figure(figsUsed(2))
      plotPtH(thisPoint, 2, currentGroup) = plot(mouseXYZ(1,1), mouseXYZ(1,2), '*', 'Color', lineColor);
      figure(figsUsed(1))
      fprintf('\nAdded 1 point:  %i points in group %i (%s)', thisPoint, currentGroup, char(groupName(currentGroup)));
      % fprintf('\nMouse: %s', SelectionType);
    case 'extend' %shift left
      fprintf('\nMouse: %s', SelectionType);
    case 'alt'  %right, ctrl+left, alt+left: remove point from list
      digitizeEraseLinesToMouse
      thisPoint = pointsInGroup(currentGroup);
      if thisPoint
        %remove point from arrays
        xOfGroup(thisPoint, currentGroup) = 0;
        yOfGroup(thisPoint, currentGroup) = 0;
        pointsInGroup(currentGroup) = pointsInGroup(currentGroup) - 1;
        fprintf('\nRemoved 1 point: %i points in group %i', pointsInGroup(currentGroup), currentGroup);
      end %if pointsInGroup(currentGroup)
      %call procedure that will draw line(s) from last point to mouse
      mouseTrack;
      % fprintf('\nMouse: %s', SelectionType);
    case 'open' %double click, preceeded by one of the above
      fprintf('\nMouse: %s', SelectionType);
    otherwise
      fprintf('\nMouse: unknown: %s', SelectionType);
    end  
  end %if digitizerOn
end %if keyMOUSEpress else
