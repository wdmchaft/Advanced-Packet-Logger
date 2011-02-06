function updateCopyLEDStatus(handles, NdxGood, NdxPending, NdxUnavail, NdxUnderway);
%function updateCopyLEDStatus(handles, NdxGood, NdxPending, NdxUnavail, NdxUnderway);
%Support module for displayCounts's log status monitoring loop
%Updates the status for the specified indicators and makes them visible.
%Leaves all the other indicators alone which means they will retain their
% previous status
%Status is the indicator's color and the ToolTip which gives the path
% for the copy and a verbal description of the staus
%Indices into the list of copy locations that are being updated.  
% Can be > the number of LEDs in which case
%  if any in this excessive group are red, last LED will be red;
%  if none in this excessive group are red but any are orange, last LED will be orange;
%statusNdx:  (colors passed in via handles.copyLED<color> (ex: handles.copyLEDgreen)
%   the colors are read from the indicators on the figure that have been adjusted in the gui
%   editor, "guide", and assigned to be that color.  Reading is performed in the OpeningFnc of displayCounts
%NdxGood = good (green)
%NdxPending = update pending (orange)
%NdxUnavail = not available (red)
%NdxUnderway = update in process (blue)

if nargin < 5
  NdxUnderway = [];
end

if length(handles.pathsTologCopies) <= length(handles.copyLED)
  NdxGoodOver = NdxGood(find(NdxGood > length(handles.copyLED))) ;
  NdxGood = NdxGood(find(NdxGood <= length(handles.copyLED))) ;
  
  NdxPendingOver = NdxPending(find(NdxPending > length(handles.copyLED))) ;
  NdxPending = NdxPending(find(NdxPending <= length(handles.copyLED))) ;
  
  NdxUnavailOver = NdxUnavail(find(NdxUnavail > length(handles.copyLED))) ;
  NdxUnavail = NdxUnavail(find(NdxUnavail <= length(handles.copyLED))) ;
  
  NdxUnderwayOver = NdxUnderway(find(NdxUnderway > length(handles.copyLED))) ;
  NdxUnderway = NdxUnderway(find(NdxUnderway <= length(handles.copyLED))) ;
else
  NdxGoodOver = [] ;
  NdxPendingOver = [] ;
  NdxUnavailOver = [] ;
  NdxUnderway = [] ;
end

%mark the successful copies
for itemp = 1:length(NdxGood)
  Ndx = NdxGood(itemp);
  set(handles.copyLED(Ndx), 'BackgroundColor', handles.copyLEDgreen, 'visible','on', 'ToolTip',...
    sprintf('Copy location "%s" current', char(handles.pathsTologCopies(Ndx))));
end
%mark the pending
for itemp = 1:length(NdxPending)
  Ndx = NdxPending(itemp);
  set(handles.copyLED(Ndx), 'BackgroundColor', handles.copyLEDorange, 'visible','on', 'ToolTip',...
    sprintf('Copy location "%s" pending Log update', char(handles.pathsTologCopies(Ndx))));
end
%mark the being copied
for itemp = 1:length(NdxUnderway)
  Ndx = NdxUnderway(itemp);
  set(handles.copyLED(Ndx), 'BackgroundColor', handles.copyLEDblue, 'visible','on', 'ToolTip',...
    sprintf('Copy location "%s" being updated', char(handles.pathsTologCopies(Ndx))));
end
%mark the unavailable copy locations
for itemp = 1:length(NdxUnavail)
  Ndx = NdxUnavail(itemp);
  set(handles.copyLED(Ndx), 'BackgroundColor', handles.copyLEDred, 'visible','on', 'ToolTip',...
    sprintf('Copy location "%s" unavailable', char(handles.pathsTologCopies(Ndx))));
end
% % 
% %   for itemp = 1:length(handles.copyLED)-1
% %     set(handles.copyLED(itemp), 'ToolTip',...
% %       sprintf('Copy location "%s"\nred: not available\norgange: update pending Log completion\ngreen: current', char(handles.pathsTologCopies(itemp))));
% %   end
% %   a = sprintf('Copy location "%s"', char(handles.pathsTologCopies(length(handles.copyLED))));
% %   for itemp = (length(handles.copyLED)+1):length(handles.pathsTologCopies)
% %     a = sprintf('%s\nCopy location "%s"', a, char(handles.pathsTologCopies(itemp)));
% %   end
% %   a = sprintf('%s\nred: not available\norgange: update pending Log completion\ngreen: current', a);
% %   set(handles.copyLED(ength(handles.copyLED)), 'ToolTip', a);
% % end

a = sprintf('Red: path not available');
a = sprintf('%s\nOrgange: update needed-waiting for Log completion', a);
a = sprintf('%s\nBlue: copying underway', a);
a = sprintf('%s\nGreen: Log copy current', a);
if (1 == findstrchr('\\', handles.logPath))
  b = 'network_PkLgMonitor_logs.ini';
else
  %log is from a local drive
  b = 'ProcessOPM_logs.ini';
end
a = sprintf('%s\n\nCopy locations specified in\n%s%s', a, handles.configDir, b);


set(handles.textCopyStatusLabel, 'visible','on', 'ToolTip', a);
% % 

