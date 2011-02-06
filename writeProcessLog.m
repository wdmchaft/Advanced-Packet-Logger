function [fid] = writeProcessLog(fid, trayList, trayType, processLog);
% function [fid] = writeProcessLog(fid, trayList, trayType, processLog);
%Used by "processOutpostPacketMessages" to create the log of messages that have been printed
% See also "readProcessLog"
%if the file isn't open - this will be the case for the call to the first folder
if ~fid
  %check if the file exists.  If not, we'll create it and include a header on the the first line
  fid = fopen(processLog, 'r');
  if fid < 1
    %doesn't exist: create it with a heading line
    fid = fopen(processLog, 'w');
    fprintf(fid','Outpost Tray,Msg Name/Subject,When Detected,When Printed,Path and Name of Msg as Printed\r\n');
  else % if fid < 1
    %already exists: close & reopen for append
    fclose(fid);
    fid = fopen(processLog, 'a');
  end % if fid < 1 else
end %if ~fid
for itemp = 1:length(trayList)
  fprintf(fid, '%s,"%s","%s","%s","%s"\r\n', ...
    trayType, ...
    char(trayList(itemp).name), ...
    char(trayList(itemp).date), ...
    char(trayList(itemp).prtDate), ...
    char(trayList(itemp).pathName) );
end
