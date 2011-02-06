function [processOPM_run, last_cpy_Ndx, last_cpy_notNdx, last_logPathName, last_pathsTologCopies] = dCInitCopy(handles);
%function [processOPM_run, last_cpy_Ndx, last_cpy_notNdx] = dCInitCopy(handles)
%Support module for displayCounts's log status monitoring loop
%Performs initial status and updating of copies of the log if any are desired
%Called when monitor loop first starts or when new log is selected.

%the Monitor loop also updates copies of the Packet Log.  If certain overall conditions change
% the copying monitor process needs to be updated.  We'll store the current, initial values
% of those items here & the monitor loop will detect when the overall conditions change
%Name/location of the Packet Log being monitored.
last_logPathName = handles.logPathName ;
%Locations for the copies
last_pathsTologCopies = handles.pathsTologCopies;

% 0: updating not needed; 1: updating needed but Log not completed; 2: updating needed and log completed
processOPM_run = 0;

%hide all indicators - we'll make visible the proper number
%  of indicators with the current status for each once we know it.
for itemp = 1:length(handles.copyLED)
  set(handles.copyLED(itemp), 'visible','off');
end

%make sure all copies are up-to-date & determine which copy locations 
% are not accessible - we'll keep an eye on those so when they become 
% accessible we can update them if needed.  (example: flash drive removed previously & re-installed)
if length(last_pathsTologCopies)
  %make sure the log isn't being updated
  a = dir(strcat(handles.logPath, 'processOPM_run.txt'));
  %weird issue: found on a W7 laptop that some code detects this file & other code does not
  %   finds: this code compiled & Z Tree win
  %   doesn't find: this code in IDE, dir in Matlab command, Windows explorer, dir in command prompt
  %according to ZTreeWin, it is not a hidden or sys file merely archive
  %Attemped patch: if old file, let's try to delete it (tested & worked)
  if length(a)
    if (datenum(handles.header.logFDate) > datenum(a.date))
      delete(strcat(handles.logPath, 'processOPM_run.txt'))
    end
    a = dir(strcat(handles.logPath, 'processOPM_run.txt'));
  end
  if ~length(a) %log update may be underway
    %write the "copying underway" semaphore file so processOPM won't try to update the log
    fnameCopyFile = writeCopying(handles);
    fprintf('\nConfirming "%s*.csv" Packet Log copies in all %i locations are current. . .', handles.logCoreName, length(last_pathsTologCopies));
    %status indicators to blue to show underway
    updateCopyLEDStatus(handles, [], [], [], [1:length(handles.pathsTologCopies)]);
    [err, errMsg, last_cpy_Ndx, last_cpy_notNdx] = makeLogCopiesCurrent(handles);
    for itemp = 1:length(last_cpy_notNdx)
      fprintf('\r\nPacket Log location for copy %i: "%s" not currently available.', last_cpy_notNdx(itemp), char(handles.pathsTologCopies(last_cpy_notNdx(itemp))) );
    end
    fprintf(' done.');
    %if it exists, delete the "copying in process" semaphore flag
    if length(fnameCopyFile)
      delete(fnameCopyFile);
    end
    updateCopyLEDStatus(handles, last_cpy_Ndx, [], last_cpy_notNdx) ;
  else % if ~length(a) %Log update may be underway
    %Log is being updated so we need to postpone the testing for current copies.
    %We'll use the logic in the monitor loop that will wait for the completion of updating
    % & tell it that no copies were made/checked.
    last_cpy_Ndx = [] ;
    last_cpy_notNdx = [1:length(last_pathsTologCopies)] ;
    updateCopyLEDStatus(handles, last_cpy_Ndx, last_cpy_notNdx, []) ;
    %1: copy updating needed but Log still being updated; 2: updating needed and log completed
    processOPM_run = 1;
  end %if ~length(a) else
else %if length(last_pathsTologCopies)
  %no copies wanted
  set(handles.textCopyStatusLabel, 'visible','off');
  last_cpy_Ndx = [] ;
  last_cpy_notNdx = [] ;
end %if length(last_pathsTologCopies) else
