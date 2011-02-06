function [debugPauseType] = debugBreakpoint(debugPauseType, additionalPrompt)
%function [debugPauseType] = debugBreakpoint(debugPauseType[, additionalPrompt])
%Allows a program itself to invoke a breakpoint . . . helps
% in development as well as ML's tendency to arbitrarilt clear active breakpoints
%INPUT:
% debugPauseType = 0: pause & ask user, not debug
%                  1: pause, ask user, & breakpoint in this file
%                  2: no pause, no breakpoint (immediate return from here)
%OUTPUT: debugPauseType - last user response per above definitions
%VSS revision   $Revision: 6 $
%Last checkin   $Date: 6/16/08 9:14p $
%Last modify    $Modtime: 10/12/07 5:43p $
%Last changed by$Author: Arose $
%  $NoKeywords: $
global userCancel

if debugPauseType < 2
  if nargin < 2
    additionalPrompt = '';
  end
  a = debugPauseType;
  if 0
    debugPauseType = inputNumber('<enter> for next, 1: to break/debug, 2: run without this pause', debugPauseType, '');
  else
    prompt  = {sprintf('1: to break/debug, 2: run without this pause %s', additionalPrompt)};
    title   = 'Debug mode';
    lines   = 1;
    def     = {num2str(debugPauseType)};
    answer  = inputdlg(prompt,title,lines,def);
    %if CANCEL button pressed....
    if length(answer) < 1
      userCancel = 1;
      debugPauseType = 0;
      % %invoke a debugBreak
      % debugPauseType = 1;
      %       button = questdlg('You pressed "Cancel".  This will abort the running program.  Are you sure you want to do this?','Confirm','Yes: abort','No: continue','Yes: abort');
      %       if strcmp(button, 'Yes: abort');
      %         stop
      %       end
    else %if length(answer) < 1
      debugPauseType = str2num(char(answer(1)));
    end % if length(answer) < 1 else
  end
  
  if (debugPauseType == 1)
    dbstop in debugBreakpoint at debugBreak
    edit (mfilename) %open the editor to this module.  The break will do that but this call additionally brings the editor window to the front
    b = sprintf('You have paused the program in debug mode & are actually in a function called from the program.');
    b = sprintf('%s To get into the program, press F10 or the "Step Out" tool button several times.', b);
    b = sprintf('%s NOTE: you can now set break points anywhere in the code but do that before continuing.', b);
    b = sprintf('%s \n\n Closing this popup is benign & the code will remained paused. (This will auto-close when you continue)', b);
    h_help = helpdlg(b, 'Progam Paused');
    set(h_help, 'tag', mfilename); %for general closing...
    debugBreak; %now call the sub that has the activated breakpoint
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
  else
    if a == 1 %clear the break point if it had been set the last time
      dbclear in debugBreakpoint at debugBreak
    end
  end
  %fprintf('...continuing.');
end
return
%%%%%%%%%%%%%%%%%%%
function debugBreak
% You have paused your program in debug mode & are actually in a function
%called from your program.
%To get into your program, press F10 several times or the "Step Out" tool button.
return
