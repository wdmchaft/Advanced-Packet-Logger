function [nextWaitUpdateTime, lastRatio] = checkUpdateWaitBar(progressRatio, handleWaitBar, lastWaitRatio, waitBarDelay, nextWaitUpdate);
%function [nextWaitUpdateTime, lastRatio] = checkUpdateWaitBar(progressRatio[, handleWaitBar[, lastWaitRatio, waitBarDelay, nextWaitUpdate]]);
%Updates the specified waitbar if either the current time is beyond the specified update time
% or the progressRatio shows a change greater than 1%.
%If only the progressRaio is passed in, uses & updates the globals shared with "initWaitBar.m"
%If all parameters are passed in, the globals are not affected.  This permits a "default" waitbar
% to be easily updated and children waitbars also to exist and be updated without confusion.
%Expected to be used with "initWaitBar".  If not, then the first call to this requires 
% all the input parameters to be valid and passed in.
%INPUT
%progressRatio: ratio (i.e.: 0 <= ratio <= 1) to set fill of waitbar
%   if this is less than zero OR less than the previous ratio, the actual waitbar figure will
%   be closed and reopened.  This is because the Matlab "waitbar" routine only can add/increase
%   the fill and not decrease.
%VSS revision   $Revision: 10 $
%Last checkin   $Date: 10/13/06 4:35p $
%Last modify    $Modtime: 10/13/06 4:24p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

%Could allow just progressRatio and handle -> globals would need to be arrays.  Control
% of arrays would be by determining if specified handle is in the array list.  Each call to
% initWaitBar would refresh the arrays by deleting those which were not still open.  That in turn
% could be detected by a=allchild(0); for itemp=1:length(h_waitBar); if ~find(h_waitBar(itemp)==a); (remove elements)....

%set/used by "initWaitBar.m" & "checkUpdateWaitBar.m"
global waitDelay h_waitBar nextWaitScanUpdateTime lastWaitScanRatio

%if parameters passed in, use them....
if nargin > 1
  h_wb = handleWaitBar;
else
  h_wb = h_waitBar;
end
if nargin > 2
  lastRatio = lastWaitRatio;
  delay = waitBarDelay;
  nextUpdateTime = nextWaitUpdate;
else
  %parameters not passed in: use the globals as set in "initWaitBar"
  lastRatio = lastWaitScanRatio;
  delay = waitDelay;
  nextUpdateTime = nextWaitScanUpdateTime;
end
%   time delay exceed         or "cputime" rolled over                  or  more than 1% change
if (cputime > nextUpdateTime) | ((cputime + delay) < nextUpdateTime) | (abs(progressRatio - lastRatio) > 0.01)
  %do we need to close & reopen? "waitbar" routine only can add/increase
  % the fill and not decrease
  if (progressRatio - lastRatio) < 0 | (progressRatio < 0)
    p = get(h_wb,'Position');
    n = get(h_wb,'Name');
    %get the text that is in the figure about the waitbar graphic.  This is the "title"
    t = get(get(get(h_wb,'Children'),'title'),'string');
    close(h_wb);
    h_wb = waitbar(0, t, 'Interpreter', 'none','visible','off');%re-create waitbar with same title
    set(h_wb, 'Position', p);
    set(h_wb,'Name', n);
    % % moved to always occur: places the bar on top  set(h_wb,'visible','on');
    if (progressRatio < 0)
      progressRatio = 0;
    end
  end
  set(h_wb,'visible','on');
  waitbar(progressRatio, h_wb);
  nextWaitUpdateTime = cputime + delay;
  lastRatio = progressRatio;
  %if parameters weren't passed in, update the global....
  if nargin < 2
    lastWaitScanRatio = lastRatio;
    nextWaitScanUpdateTime = nextWaitUpdateTime;
  end
  drawnow;
else
  nextWaitUpdateTime = nextUpdateTime;
end
if nargin < 1
  h_waitBar = h_wb;
end