function [nextWaitScanUpdate, h_waitBar] = initWaitBar(boxText, waitBarDelay, moveguiPosition, mfilename_caller);
%function [nextWaitScanUpdate, h_waitBar] = initWaitBar(boxText[, waitBarDelay[, moveguiPosition[, mfilename_caller]]]);
%INPUT:
% boxText: title/text to go above the graphical bar
% waitBarDelay[optional]:  the time between updates.  This procedure will add
%  this delay to the current time of 'toc' & return the sum in nextWaitScanUpdate.
%  usage would then be: if toc > nextWaitScanUpdate....  default = 0.2 seconds
%  If zero, uses default (same as if not passed in)
% moveguiPosition [optional]: either
%  1) text per the help on 'movegui' to position the figure.  If
%  empty or not passed in, position is the default which is the center.  If passed in, the
%  figure is hidden until the position is achieved.
%  or
%  2) handle to another waitbar (or figure, etc.): this new wait bar will be positioned
%  below and left aligned with it.  If negative, the new position will be above & left aligned.
% mfilename_caller [optional]: text appended to the waitbar's Tag which is used by
%  the selective waitBar closer "closeAllMyWaitbars.m" when it is called in the procedure
%  which called this one.  Typically that is before calling this -> close any old ones!
%OUTPUT:
% nextWaitScanUpdate: time of 'cputime' when next update should be performed:
%Can be used in conjunction with "checkUpdateWaitBar.m" in which case the necessary variables
% are shared via globals.  Call is then merely 
%   if only one waitbar
% "checkUpdateWaitBar(progressRatio)"
%   multiple waitbars: this updates a specific waitbar
% "[nextWaitScanUpdate, lastRatio] = checkUpdateWaitBar(progressRatio, h_waitBar, lastWaitRatio, waitBarDelay, nextWaitScanUpdate);"
%   if toc > nextWaitScanUpdate
%      <calc new value & update>
%      nextWaitScanUpdate = toc + waitBarDelay;
%   end
% h_waitBar: handle to the figure
%
%possible upgrades:
% enable/disable where positioning occurs
%Example
%function ... = example(...)
% .
% .
% closeAllMyWaitbars(mfilename);
% .
% .
%either:
% [nextWaitScanUpdate, h_waitbar] = initWaitBar(<title>);
% tagMyWaitBar(h_waitbar, mfilename);
% [nextWaitScanUpdateWrite, h_waitbar2] = initWaitBar(<title2>, 0, -h_waitbar, '', mfilename);
%or
% [nextWaitScanUpdate, h_waitbar] = initWaitBar(<title>, 0, '', mfilename);
% [nextWaitScanUpdateWrite, h_waitbar2] = initWaitBar(<title2>, 0, -h_waitbar, '', mfilename);
% .
% .
% closeAllMyWaitbars(mfilename);
%example end
%VSS revision   $Revision: 10 $
%Last checkin   $Date: 6/16/08 8:01p $
%Last modify    $Modtime: 10/21/07 3:40p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

%set/used by "initWaitBar.m" & "checkUpdateWaitBar.m"
global waitDelay h_waitBar nextWaitScanUpdateTime lastWaitScanRatio

waitDelay = 0.2;
if nargin > 2
  if waitBarDelay > 0
    waitDelay = waitBarDelay;
  end
end

if nargin < 3
  moveguiPosition = '';
  visibleMode = 'on';
else
  visibleMode = 'off';
end
if nargin < 4
  mfilename_caller = '';
end
%get the progress bar up & positioned
h_waitBar = waitbar(0, boxText, 'Interpreter', 'none','visible',visibleMode);
if length(moveguiPosition)
  if ishandle(abs(moveguiPosition))
    screenSize = get(0,'ScreenSize');
    screenUnits = get(0,'units');
    if moveguiPosition < 0
      moveguiPosition = -moveguiPosition;
      above = 1;
    else
      above = 0;
    end
    moveguiPosition_units = get(moveguiPosition,'units');
    %make sure the position units are the same as the screen size units
    if ~strcmp(moveguiPosition_units, screenUnits)
      set(moveguiPosition,'units',screenUnits);
      unitChg = 1;
    else
      unitChg = 0;
    end
    %make sure the units are the same as the preceeding waitbar or positioning won't be correct
    set(h_waitBar,'units', get(moveguiPosition,'units'));
    box_1Position = get(moveguiPosition,'position');
    waitBarPosition = get(h_waitBar,'position');
    %set the 2nd box left aligned to 1st:
    waitBarPosition(1) = box_1Position(1);
    if above
      waitBarPosition(2) = box_1Position(2) + waitBarPosition(4);
      if (waitBarPosition(2) + waitBarPosition(4)) > (screenSize(2) + screenSize(4))
        %reposition the new waitbar to the same screen bottom & slightly to the right
        waitBarPosition(2) = screenSize(2);
        % 0.05 = 5% of the screen width
        waitBarPosition(1) = waitBarPosition(1) + 0.05 * screenSize(3);
      end
    else
      %place the 2nd box beneath the 1st & left/right aligned
      waitBarPosition(2) = box_1Position(2) - waitBarPosition(4);
      if (waitBarPosition(2) < screenSize(2))
        %reposition the new waitbar to the top & slightly to the right
        waitBarPosition(2) = screenSize(4) - waitBarPosition(4); %top minus height of new wait bar
        % 0.05 = 5% of the screen width
        waitBarPosition(1) = waitBarPosition(1) + 0.05 * screenSize(3);
      end
    end
    set(h_waitBar,'position', waitBarPosition)
    %restore the wait bar units if needed
    if unitChg
      set(moveguiPosition,'units',moveguiPosition_units);
      set(h_waitBar,'units',moveguiPosition_units);
    end
  else%if ishandle(moveguiPosition)
    movegui(h_waitBar, moveguiPosition); %ex: 'northest': to top right
  end%if ishandle(moveguiPosition) else
  set(h_waitBar,'visible','on');
end %if length(moveguiPosition)
nextWaitScanUpdateTime = cputime + waitDelay;
nextWaitScanUpdate = nextWaitScanUpdateTime;
lastWaitScanRatio = 0;
if length(mfilename_caller)
  tagMyWaitBar(h_waitBar, mfilename_caller);
end
