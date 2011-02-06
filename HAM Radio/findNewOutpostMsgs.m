function [err, errMsg, sentList, recvList] = findNewOutpostMsgs(inOutpostPath);
%function [err, errMsg, sentList, recvList] = findNewOutpostMsgs([inOutpostPath]);
%  Works with Outpost Script.  Determines which are the new messages, 
%what the date and time of each message is from "message.log" (not available within
%the scripting language), and developes the name for the text file version of
%each message that the script will write.  The lists identifying the new messages
%written in two files allowing the Script to find and the write to text files.  One 
%list is for received messages and the other is for sent messages. 
%   Detects if the logging program didn't complete successfully.  This could be
%due to the script not completing or a problem with the logging parameters. 
%Should that happen, the time pointers used to define what is a new message
%are not advanced.  Therefore the list of new messages will continue to
%include messages that are new since the last successful logging.
%  Various options are available to specify the time filter.
%Once messages have been found that are newer than the time filter,
%this program will use the newer of the time filter or the newest message
%it has found.  The time of the newest message found is recorded in
%the program directory in 'findNewOutpostMsgs_newest.txt'.  If this
%file is erased, the time filter again establishes the earliest message
%which could result in messages being doubled processed.
%  This program accesses Outpost's "message.log" in whatever directory
%Outpost is using for its logs (DirLogs) via "readOutpostMsgLog".  Because 
%message.log can be substantial in size and therefore take significant 
%time to read, this program works with readOutpostMsgLog to record exactly
%where the previous read of "message.log" ended.  This means it only needs
%to be read in its entirety once and there after the code will jump to the
%new information.  file "findNewOutpostMsgs.mat" stores the information.
%
% Options of establishing start time (script typically imposes the
%  requirement the messages have to be in the InTray or SentTray):
% 1) (default) All messages from "today"
% 2) all messages since Outpost's DirScripts IncidentName.txt has changed.
% 3) only those message that were transferred during this session of the 
%   script
% 4) time specified in the same file that specifies which of these options
%   is active
% 5) no time filter - any & all messages
%OUTPUTS
%  sentList: for each new file, a csv line consisting of 
%    1) Outpost's internal message # for the message (this is not the user configurable ID that is inserted on the subject line.
%    2) Human readable message date as it will appear in the Log:  da-MON-year; example "29-Jan-2010"
%    3) time in 24 hour format: hr:mn
%    4) name for text file.  It has the prefix "S_" (sent) or "R_" (received) followed by the date, time, and finally the subject 
%      line from Outpost: S_YrMoDa_HrMnSc_<subject>.txt (ex: S_100129_213813_SEP010:_My_bad.txt)
%   <msg #>,<da-MON-Year>,Hr:Mn,SentMsg
%  recvList: same as sentList except applies to received messages & the prefix for the name is RecvMsg
%Files used by scripts: both these files are placed in Outpost's DirLogs
%  newSent.txt: contains sentList with last line starting with zero 0 and then after the comma containing the time filter
%           the time filter is informational only and isn't used by the script.
%  newRecv.txt: same as newSent.txt but using the recvList information.
%Files for operator
%  findNewOutpostMsgs.ini: operator sets the time filter for today's log; file is ..\Outpost\AddOns\
%Files used internally
%  findNewOutpostMsgs_newest.txt: time of the last message this program has
%       identified as a new message.  Next run of this program will look for
%       messages that are newer than this time.
%  findNewOutpostMsgs_newestLast.txt: copy of most recent 'findNewOutpostMsgs_newest.txt' that resulted
%       in successful logging - used when Logging didn't occur/script quit unexpectedly; 
%       updated when logging successful.
%  findNewOutpostMsgs.mat: for fast reading of "message.log" this contains the pointer
%       to the last line of message.log previously read.
%  findNewOutpostMsgsLast.mat copy of most recent 'findNewOutpostMsgs.mat' that resulted
%       in successful logging - used when Logging didn't occur/script quit unexpectedly; 
%       updated when logging successful.
%PROGRAMS CALLED (Major)
%  OutpostINItoScript
%  readOutpostMsgLog: module that reads Outpost's "message.log"

% *List:
%   .msgID
%   .dateTime
%   .nameForFile

% Need to remove from List messages that are no longer in the
% InTray or SentTray
% 
% Need to remove any remaining duplicates
% Want method to allow user to set a start time other than
%   the current session

% Script steps:
% 1) write a file contents unimporant - we'll use it for a time stamp
% 2) do all preparations desired
% 3) perform a send/receive
% 4) call this program and wait
% 5) this program will locate all message sent and received since
%    the file in (1) was created and place the information in files
% 6) the script will read the list files and then write text files
%    per the specified msgIDs using the name as specified and
%    inserting the dateTime as specified.
% 7) the script will then call the program to process the messages
% 
% Details:
% 1) we'll need a name for the file in step 1
%    the contents of step one will be the prefix for the list files
% 2) need to read up on Outpost scripting to establish the format of
%   the list files.


[err, errMsg, modName] = initErrModName(mfilename);
if nargin < 1
  inOutpostPath = '';
end

[err, errMsg, outpostNmNValues] = OutpostINItoScript(inOutpostPath);
PathToOutpost = endWithBackSlash(outpostValByName('DirOutpost', outpostNmNValues));
pathToINI = outpostValByName('DirAddOns', outpostNmNValues);
pathToPrograms = outpostValByName('DirAddOnsPrgms', outpostNmNValues);
PathToScripts = endWithBackSlash(outpostValByName('DirScripts', outpostNmNValues));

newestTxtPathNameEx = strcat(pathToPrograms, 'findNewOutpostMsgs_newest.txt');
newestTxtPNmExLast = strcat(pathToPrograms, 'findNewOutpostMsgs_newestLast.txt');
INIpathNameExt = sprintf('%sfindNewOutpostMsgs.ini', pathToINI);
[err, errMsg, startTimeOption, dateTime] = readfindNewOutpostMsgs_INI(INIpathNameExt, newestTxtPathNameEx);
currentDirINI = dir(INIpathNameExt); 

msgLogPath = endWithBackSlash(outpostValByName('DirLogs', outpostNmNValues));

namePathforStore = sprintf('%sfindNewOutpostMsgs.mat', pathToPrograms);
namePathforLastStore = sprintf('%sfindNewOutpostMsgsLast.mat', pathToPrograms);

%the script requires a file called "quote.txt" that contains a single quote
%if it isn't there, let's create it:
a = strcat(PathToScripts, 'quote.txt');
fid = fopen(a,'r');
fcloseIfOpen(fid);
if (fid < 1)
  fid = fopen(a,'w');
  fprintf(fid,'"');
  fclose(fid);
end %if (fid < 1)

%want to convert date-time from Excel format (day 1 = 1900,01,01) to Matlab: add this to Excel value
offAdd = datenum(1900,01,01) - 2;

% startTimeOption
startTime = setLogStartTime(startTimeOption, dateTime, PathToScripts, PathToOutpost);
origStartTime = startTime ;

%determine if script ran successfully: we know processOPM runs at end of script after this program
% if any new messages had been processed.  If a file we know it generates
% has a date older than the date of a file this program creates, processOPM didn't
% run.  We want to continue to use the start pointers used previously, not those from this programs
% last run.  Even if processOPM had no new messages, it is OK to use the previous pointers - no new messages!

scriptGood = 0;
%we could use the log but that won't guarantee its update was fully completed - data going to
% pOPM may have caused a crash mid-way.  We'll risk double entries over missed entries
pOPMdir = dir(strcat(pathToPrograms, 'processOutpostPacketMessages_errMsg.txt') );
if length(pOPMdir)
  fid = fopen(strcat(pathToPrograms, 'processOutpostPacketMessages_errMsg.txt'),'r');
  if (fid>0)
    textLine = fgetl(fid);
    fclose(fid);
  else
    textLine = 'file not found!';
  end
  %if nothing in the file, no error: check dates
  if ~ischar(textLine)
    ourDir = dir(namePathforStore);
    if length(ourDir)
      %if pOPM is newer than a file we wrote, script ran & new messages
      scriptGood = (datenum(pOPMdir.date) > datenum(ourDir.date) );
    else
      scriptGood = 0;
    end
  end % if ischar(textline)
end %if length(pOPMdir)

if scriptGood
  nmStore = namePathforStore;
  nmNewText = newestTxtPathNameEx;
  fprintf('\nConfigured for next Log update.');
else
  nmStore = namePathforLastStore;
  nmNewText = newestTxtPNmExLast;
  fprintf('\nContinuing configuration for Log update.');
end

fid_nmStore = fopen(nmStore, 'r');
if (fid_nmStore > 0)
  fclose(fid_nmStore);
  load(nmStore);
  try
    %revision level for the "store/load" MAT file format - not program revision
    matRev = rev;
  catch
    matRev = 0;
    rev = 0;
  end
  if matRev
    if ~length(currentDirINI)
      currentDirINI(1).date = '';
    end
    if ~length(lastINI)
      lastINI(1).date = '';
    end
    % if the current INI date is the same as the INI the previous instance of this program, INI_same > 0
    %if different, INI_same = 0
    INI_same = strcmp(currentDirINI.date, lastINI.date);
  else % if matRev
    INI_same = 1;
  end % if matRev else
  if scriptGood
    %create copy
    save(namePathforLastStore, 'rev','fileInfo', 'lastINI');
  end % if scriptGood
end %if (fid_nmStore > 0)

%if this program has been run before, read what the latest/newest message was processed
% because we only want to process newer messages - we do not want to double process messages!
fid = fopen(nmNewText,'r');
if (fid>0)
  textLine = fgetl(fid);
  %make sure the file isn't corrupted:
  if length(textLine)
    %the line should only contain a floating point number
    if all(ismember(textLine, ['0123456789.']))
      latestTime = str2num(textLine);
      latesTmRead = 1;
      %if the time-date is in Excel format, convert to Matlab
      if latestTime < offAdd
        latestTime = latestTime + offAdd;
      end
    end % if all(ismember(textLine, ['0123456789.']))
  end % if length(textLine)
  if scriptGood
    %create copy
    fidOut = fopen(newestTxtPNmExLast,'w');
    if (fidOut > 0)
      while length(textLine) & ~feof(fid)
        fprintf(fidOut,'%s\r\n', textLine);
        %don't want the user explanations
        if findstrchr('Used by "findNewOutpostMsgs"', textLine)
          break
        end
        textLine = fgetl(fid);
      end %while length(textLine) & ~feof(fid)
      fclose(fidOut);
    end % if (fidOut > 0)
  end %if scriptGood
  fclose(fid) ;
else %if (fid>0)  fid = fopen(nmNewText,'r');
  latestTime = 0;
  latesTmRead = 0;
end % if fid>0  fid = fopen(nmNewText,'r'); else

%if we loaded the MAT file (contains the 'fileInfo" from earlier) and we read the time of the latest message we'd found
if (fid_nmStore >0) & latesTmRead
  %read the message.log file giving it the information from the last read for faster updating
  [err, errMsg, msgList, fileInfo] = readOutpostMsgLog(msgLogPath, fileInfo);
else %if (fid_nmStore >0) & latesTmRead
  %read the message.log file from the beginning
  [err, errMsg, msgList, fileInfo] = readOutpostMsgLog(msgLogPath);
end %if (fid_nmStore >0) & latesTmRead

if err
  errMsg = strcat(modName, errMsg);
  sentList = [];
  recvList = [];
  return
end

finalMsg =  sprintf(' "%s"', datestr(origStartTime));
%use the LATER of the selected time or the latest previously processed message
if (latestTime > startTime)
  startTime = latestTime;
  finalMsg = sprintf('started as "%s" & became "%s" based on previous run per "%sfindNewOutpostMsgs.INI"',...
    datestr(origStartTime), datestr(startTime), pathToINI);
end %if (latestTime > startTime)
%create an informational message to be placed in inactive region of file
finalMsg = sprintf('Message time filter option startTime=%i, %s', ...
  startTimeOption, finalMsg) ;

if length(msgList)
  %find entries that are newer than the startTime
  NewNdx = find([msgList.dateTime] > startTime);
else %if length(msgList)
  NewNdx = [] ;
end % if length(msgList) else
 
%if any messages were found
if length(NewNdx)
  %Messages need to be in numerical order because
  %the script has to process them in that order
  [a, Ndx] = sort([msgList(NewNdx).msgId]);
  NewNdx = NewNdx(Ndx);
  
  validNdx([1:length(NewNdx)]) = 1;
  %remove any that have been deleted
  for itemp = length(NewNdx):-1:2
    if (msgList(NewNdx(itemp)).msgId == msgList(NewNdx(itemp-1)).msgId)
      if (msgList(NewNdx(itemp)).action == 8)
        % deleted 
        validNdx(itemp-1) = 0;
      end
    end
  end
  NewNdx = NewNdx(find(validNdx));
  
  % find received messages:
  %we want: UNREAD = 4; Received message, not opened
  %we do not want: READ = 5; Received message, and opened
  %   a = find([msgList(NewNdx).action] > 3 &  [msgList(NewNdx).action] < 6);
  a = find([msgList(NewNdx).action] == 4);
  recdNdx = NewNdx(a);
  
  % SENT = 3; created message, after Send/Receive
  %find sent messages:
  a = find([msgList(NewNdx).action] == 3);
  sentNdx = NewNdx(a);
  % we need to store the time of newest entry so we don't include any of the
  %current entries
  % If any messages were found. . .
  if length([recdNdx sentNdx])
    %only create/replace the file if we have processed more messages
    latestProcessed = max([msgList([recdNdx sentNdx]).dateTime]) ;
    fid = fopen(newestTxtPathNameEx,'w');
    if fid>0
      %write the time in Excel format to be consistent with Outpost "message.log"
      fprintf(fid,'%.15f\r\n', latestProcessed-offAdd);
      fprintf(fid,'%%Time of last message processed. Above in Excel time/date format\r\n%%a.k.a. %s\r\n', datestr(latestProcessed));
      fprintf(fid,'%%%s\r\n', finalMsg);
      %don't remove or move this line unless information vital to recover from a script not running is added!
      %  THAT information MUST be placed ahead of this line because copying stops with this line!
      fprintf(fid,'%%Used by "findNewOutpostMsgs".\r\n') ; 
      fprintf(fid,'%%  Erase this file to reset to .INI rules. \r\n') ;
      fprintf(fid,'%%  You should also edit all versions of today''s logs (packetCommLog_YrMoDa*.csv)\r\n');
      fprintf(fid,'%%  to remove any logged entries after the startTimeOption of "findNewOutpostMsgs.ini".\r\n');
      fprintf(fid,'%%  However if you know that ALL logged entries are after the startTimeOption you\r\n');
      fprintf(fid,'%%  can merely delete all versions of today''s logs.\r\n');
      fprintf(fid,'%%  Note that the files are read only\r\n');
      fprintf(fid,'%%  * * Warning: if you need to edit, use notepad or a simple text edit - do NOT use Excel * *.\r\n');
      fclose(fid);
    end
  end %if length([recdNdx sentNdx])
else %if length(NewNdx)
  % no messages found: initialize to empty arrays
  recdNdx = [];
  sentNdx = [];
end %if length(NewNdx) else

%create an informational message to be placed in inactive region of file
finalMsg = sprintf('Message time filter option startTime=%i, started as "%s" & became "%s" based on previous run per "%sfindNewOutpostMsgs.INI"', ...
  startTimeOption, datestr(origStartTime), datestr(startTime), pathToINI) ;
%create files for script
sentList = buildListMakeFile(sentNdx, msgList,'Sent', msgLogPath, finalMsg);
recvList = buildListMakeFile(recdNdx, msgList,'Recv', msgLogPath, finalMsg);

lastINI = currentDirINI;
%revision level for the "store" format - not program revision
rev = 1;
save(namePathforStore, 'rev','fileInfo', 'lastINI');

%-----------------------------------
function infoList = buildListMakeFile(Ndx, msgList, coreName, msgLogPath, finalMsg);
%builds the list that is used by the script
%Each message has four entries in the CSV list: messageID,msgDate,msgTime,name for file of text version of msg
%End of list has msgID = 0 and then information ignored by the script but available when the file is inspected

%1=Private, 2=NTS, 3=Bulletin
bbsMsgType = {'Private','NTS','Bulletin'};

fname = sprintf('%snew%s.txt', msgLogPath, coreName); 
if ~length(Ndx)
  infoList = [];
  %create an empty file
  fid = fopen(fname,'w');
  if fid > 0
    %tell the script the msgID is 0 -> when NextMessage reaches end, this is the value returned
    fprintf(fid,'0, %s\r\n', finalMsg);
    fclose(fid);
  end
  return
end
%     msgList(Ndx).lmi = '';
%     msgList(Ndx).msgType = '';

for itemp = 1:length(Ndx)
  infoList(itemp).msgID = msgList(Ndx(itemp)).msgId ;
  %date as da-mon-year.  Avoids possibly confusion when day & month are numeric  ex: 01-Mar-2000
  %  this format is compatable with datenum & datevec
  infoList(itemp).date = {datestr(msgList(Ndx(itemp)).dateTime,1)} ;
  %only want message time to minute; this format is compatable with datenum & datevec
  infoList(itemp).time = {datestr(msgList(Ndx(itemp)).dateTime,15)} ;
  %Outpost Script sees a space as a delimiter - replace spaces with underscore
  [err, errMsg, date_time] = datevec2timeStamp(msgList(Ndx(itemp)).dateTime) ;
  b = sprintf('%s_%s_%s.txt', coreName(1:1), date_time, msgList(Ndx(itemp)).subject);
  b = strrep(b,' ','_');
  % and of course we've got to replace any comma with something -> use ' (sort of an superscript comma.....)
  b = strrep(b,',','''');
  infoList(itemp).nameForFile = {b} ;
  if length(strtrim(char(msgList(Ndx(itemp)).lmi)))
    %warning: this format is detected in the modules "getOpstMsgNum" & "processOutpostPacketMessages"
    b = sprintf('Local Msg ID:%s', char(msgList(Ndx(itemp)).lmi) );
    %Outpost Script sees a space as a delimiter - replace spaces with _
    b = strrep(b,' ','_');
    infoList(itemp).lmi = {b};
  else
    infoList(itemp).lmi = {'_'};
  end
  a = str2num(char(msgList(Ndx(itemp)).msgType));
  if (a & a <= length(bbsMsgType))
    %warning: this format is detected in the module "processOutpostPacketMessages"
    b = sprintf('%s Message', char(bbsMsgType(a)));
    %Outpost Script sees a space as a delimiter - replace spaces with _
    b = strrep(b,' ','_');
    infoList(itemp).msgType = {b};
  else
    infoList(itemp).msgType = char('_');
  end
end

fid = fopen(fname,'w');
if fid > 0
  for itemp = 1:length(Ndx)
    fprintf(fid,'%i,%s,%s,%s,%s,%s,\r\n', infoList(itemp).msgID, char(infoList(itemp).date), ...
      char(infoList(itemp).time), char(infoList(itemp).nameForFile), ...
      char(infoList(itemp).lmi), char(infoList(itemp).msgType) );
  end  
  %tell the script the msgID is 0 -> when NextMessage reaches end, this is the value returned
  fprintf(fid,'0, %s\r\n', finalMsg);
  fclose(fid);
end
% ----^^^^-- function infoList = buildListMakeFile(Ndx, msgList, fileName, msgLogPath, finalMsg);
%-------------------------------------------------------
