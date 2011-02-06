function [nextCheckCancelSecOut] = checkCancel(hCancelIn, nextCheckCancelSec, checkCancelSecInterval);
%function [nextCheckCancelSecOut] = checkCancel(hCancelIn[, nextCheckCancelSec[, checkCancelSecInterval]);
%Checks the status of the Cancel figure at the specified interval.
% This is needed if the code is in a tight loop that doesn't access the CRT or keyboard
% and doesn't hurt even if it does.
%INPUT
% hCancel: handle to the Cancel figure.  ex:  hCancel = cancel; %activate the GUI
% nextCheckCancelSec [optional] the time in seconds when the next check is to occur
% checkCancelSecInterval [optional] the time delay between checks.  Default is set in 'cancel.m'
%OUTPUT:
% nextCheckCancelSecOut[optional] the time in seconds when the next check is to occur
%VSS revision   $Revision: 6 $
%Last checkin   $Date: 1/12/06 3:25p $
%Last modify    $Modtime: 1/10/06 4:05p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

global checkCancelSec nextCheckCancel hCancel %initialized in cancel.m but can be over-ridden here

%call "cancel.m" as needed to get a valid GUI up
if nargin < 1
  %if no figure is passed in
  hFigCancel = hCancel;
else
  hFigCancel = hCancelIn;
end
%if no figure has been opened by "cancel.m"
if length(hCancel) < 1
  hFigCancel = cancel;
else
  %if figure has been opened by "cancel.m" 
  %  if passed in handle isn't real, 
  if hCancel < 1
    hFigCancel  = cancel;
  end
end

if nargin > 1
  nextCheckCancel = nextCheckCancelSec;
end
if nargin > 2
  checkCancelSec = checkCancelSecInterval;
end

if (nextCheckCancel > toc)
  if nargout > 0
    nextCheckCancelSecOut = nextCheckCancel;
  end
  return
end

nextCheckCancel = toc + checkCancelSec;
a = toc + 0.1; %check/wait for 100mS
while toc < a
  %% doesn't apply to GUI control: if ( figflag(hFigCancel) ) %1 means the figure exists and 'figflag' moves the figure to the foreground
  try
    figure (hFigCancel)
    pause(0.01);
    %%else
  catch
    if nargout > 0
      nextCheckCancelSecOut = nextCheckCancel;
    end
    return
  end
end
if nargout > 0
  nextCheckCancelSecOut = nextCheckCancel;
end
