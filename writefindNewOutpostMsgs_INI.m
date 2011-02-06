function [err, errMsg] = writefindNewOutpostMsgs_INI(pathNameExt, newestTxtPathNameEx, startTimeOption, dateTime);
[err, errMsg, fidINI] = fOpenToWrite(pathNameExt, 'w');
if err
  errMsg = sprintf('>%s%s', mfilename, errMsg);
  return
end
fprintf(fidINI, '%% This file establishes certain conditions for "sfindNewOutpostMsgs".\r\n');
fprintf(fidINI, '%% Comment lines are any line that start with a space or % \r\n');
fprintf(fidINI, '%% If this file did not exist when the program was run, it was written with\r\n');
fprintf(fidINI, '%%  the program''s default values.  You may alter them as desired.\r\n');
fprintf(fidINI, '%% Alterations will take effect the next time a log is created - if you\r\n');
fprintf(fidINI, '%%  already have run the script and a log has been created today, the change\r\n');
fprintf(fidINI, '%%  will not take effect until tomorrow UNLESS you erase "%s"\r\n', newestTxtPathNameEx);
fprintf(fidINI, '%%  You should also edit all versions of today''s logs (packetCommLog_YrMoDa*.csv)\r\n');
fprintf(fidINI, '%%  to remove any logged entries after the startTimeOption of "findNewOutpostMsgs.ini".\r\n');
fprintf(fidINI, '%%  However if you know that ALL logged entries are after the startTimeOption you\r\n');
fprintf(fidINI, '%%  can merely delete all versions of today''s logs.\r\n');
fprintf(fidINI, '%%  Note that the files are read only\r\n');
fprintf(fidINI, '%%  * * Warning: if you need to edit, use notepad or a simple text edit - do NOT use Excel * *.\r\n');
fprintf(fidINI, '%% Any lines converted to a Comment or removed will result in the default being used.\r\n');
fprintf(fidINI, '%%\r\n');
fprintf(fidINI, '%% Options of establishing start time (script typically imposes the\r\n');
fprintf(fidINI, '%%  additional requirement the messages have to be in the InTray or SentTray):\r\n');
fprintf(fidINI, '%% 1) (default) All messages from "today"\r\n');
fprintf(fidINI, '%% 2) all messages since Outpost''s DirScripts IncidentName.txt has changed.\r\n');
fprintf(fidINI, '%% 3) only those message that were transferred during this session of the script\r\n'); 
fprintf(fidINI, '%% 4) time specified a few lines below with "dateTime = "\r\n');
fprintf(fidINI, '%% 5) no time filter - any & all messages\r\n');
fprintf(fidINI, 'startTimeOption = %i \r\n', startTimeOption);
fprintf(fidINI, '%%\r\n');
fprintf(fidINI, '%%Date/time only used if "startTimeOption" = 4 \r\n');
fprintf(fidINI, '%%  Format can include date & time "dd-mmm-yyyy HH:MM:SS" (ex: 01-Mar-2000 15:45:17)\r\n');
fprintf(fidINI, '%%  or merely the date which will set the time to 0, the start of the day\r\n');
fprintf(fidINI, '%%  "dd-mmm-yyyy"  (ex: 01-Mar-2000)\r\n');
fprintf(fidINI, 'dateTime = %s \r\n', dateTime);
fcloseIfOpen(fidINI);