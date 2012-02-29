function [fid] = writeProcessLog(fid, trayList, trayType, processLog, callerName);
% function [fid] = writeProcessLog(fid, trayList, trayType, processLog);
%Used by "processOutpostPacketMessages" to create the log of messages that have been printed
% See also "readProcessLog"
%if the file isn't open - this will be the case for the call to the first folder
if ~fid
  %check if the file exists.  If not, we'll create it and include a header on the the first line
  fid = fopen(processLog, 'r');
  if fid < 1
    %doesn't exist: create it with a heading line
    [err, errMsg, fid] = fOpenToWrite(processLog, 'w', callerName);
    if (fid>0)
      fprintf(fid,'Outpost Tray,Msg Name/Subject,When Detected,When Printed,Preprinted form Msg as Printed,Print Name\r\n');
    end
  else % if fid < 1
    %already exists: close & reopen for append
    fclose(fid);
    [err, errMsg, fid] = fOpenToWrite(processLog, 'a', callerName);
  end % if fid < 1 else
end %if ~fid
if (fid>0)
  tt = trayType;
  for itemp = 1:length(trayList)
    if ~length(trayType)
      if findstrchr('R', char(trayList(itemp).name(1:1)) );
        tt = 'InTray';
      else
        tt = 'SentTray';
      end
    end
    fprintf(fid, '%s,"%s","%s","%s","%s","%s"\r\n', ...
      tt, ...
      char(trayList(itemp).name), ...
      char(trayList(itemp).date), ...
      char(trayList(itemp).prtDate), ...
      char(trayList(itemp).pathName), ...
      char(trayList(itemp).prtName) );
  end % for itemp = 1:length(trayList)
  fclose(fid);
end % if (fid>0)