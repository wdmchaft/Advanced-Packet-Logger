function [err, errMsg, msgList, fileInfo] = readOutpostMsgLog(msgLogPath, lastFileInfo);
%function [err, errMsg, msgList] = readOutpostMsgLog(msgLogPath);
%Reads the entire "message.log" file and extracts the information
%  into the msgList structure.  The dateTime element is in
%  Matlab format while the message.log is in Excel format
%INPUT
% fileInfo: structure containing information about "message.log" intended
%  to allow fast determination of message updates 
%   .date    date of message.log file it had when last accessed
%   .bytes   size of message.log file it had when last accessed
%   .fPos    pointer to start of last line when last accessed
%   .lastLine last line of text of message.log file when last accessed
%   .msgLogVer version number (format) of the message.log file when last accessed
%OUTPUT
% fileInfo: structure containing information about "message.log" intended
%  to allow fast determination of message updates 
%   .date    current date of message.log file
%   .bytes   current size of message.log file
%   .fPos    current pointer to start of last line
%   .lastLine current last line of text of message.log file
%   .msgLogVer version number (format) of the message.log file
%msgList = 
%     msgId
%     dateTime
%     createRecv
%     action
%     bbs
%     from
%     to
%     msgSize
%     subject
%     lmi
%     msgType


%July 2010 "message.log" has undergone revision.  This detects the revision
%  by the number of column delimiters in the first line of the message.log file.
% msgLogVer = 0: original
% msgLogVer = 1: two new columns inserted before the Subject column per
%   Outpost documentation:
% Date: 26 July 2010
% File: 870-Local-Msg-ID-v11.doc
% Rev: 1.1
% Status: REVIEW
% 1.7.3. Outpost, Message Log
% Two additional parameters will be posted to the message.log file. 
%    (i) Local Message ID 
%    (ii) Message Type. This indicates whether the message is 
%         Private (1), NTS (2), or a bulletin (3). The format of  
%         each record entry in the message.log file is as follows:
% Position parameter Description _
% 1 Record ID Internal Outpost record identifier
% 2 Date Time MS internal date/time representation
% 3 Origin 1=Created, 2=Received
% 4. State 1=New, 2=Ready, 3=Sent, 4=Unread, 5=Read,
%    6=Draft, 7=Abandoned, 8=Deleted
% 5. Bbs
% 6. From
% 7. To
% 8. Message Length
% 9. Local Message ID << NEW
% 10. Message Type << NEW, 1=Private, 2=NTS, 3=Bulletin
% 11. Subject


[err, errMsg, modName] = initErrModName(mfilename);

if nargin < 1
  msgLogPath = '';
end
if nargin < 2
  readFullLog = 1;
else
  readFullLog = 0;
end

msgList = {};

if ~length(msgLogPath)
  [err, errMsg, outpostNmNValues] = OutpostINItoScript;
  msgLogPath = endWithBackSlash(outpostValByName('DirLogs', outpostNmNValues));
end
msgLogPathName = strcat(msgLogPath, 'message.log');
fid = fopen(msgLogPathName,'r');
if (fid < 1)
  % err = 1;
  errMsg = sprintf('%s: unable to read "%s".', modName, msgLogPathName)
  fileInfo.fPos = 0;
  return
end
%determine message.log revision: count number of columns
textLine = fgetl(fid);
delimAt = findstrchr('|', textLine);
msgLogVer = 0;
if length(delimAt) > 8
  msgLogVer = 1;
end

a = dir(msgLogPathName);
fileInfo.date = a.date;
fileInfo.bytes =a.bytes;
fileInfo.fPos = 0 ;
fileInfo.lastLine = '';
fileInfo.msgLogVer = msgLogVer;

%if we've got info from last run
if ~(readFullLog)
  %smaller file forces readFullLog
  readFullLog = (fileInfo.bytes < lastFileInfo.bytes);
  if ~(readFullLog)
    %hop to last location
    fseek(fid, lastFileInfo.fPos,'bof');
    %read the line at that location 
    textLine = fgetl(fid);
    %confirm same line - if not same, go to beginning of file
    if ~strcmp(textLine, lastFileInfo.lastLine)
      %move to beginning of file
      fseek(fid, -ftell(fid),'cof');
    else % if ~strcmp(textLine, lastFileInfo.lastLine)
      fileInfo.fPos = lastFileInfo.fPos;
      fileInfo.lastLine = lastFileInfo.lastLine;
    end %if ~strcmp(textLine, lastFileInfo..lastLine) else
  else
    %move to beginning of file
    fseek(fid, -ftell(fid),'cof');
  end %if ~(readFullLog)
else
  %move to beginning of file
  fseek(fid, -ftell(fid),'cof');
end %if ~(readFullLog)

% file ..\logs\message.log

% 11|40192.4461458333|1|2|W6XSC-1|CUPEOC|XSCEOC|14|Test Subject
%  

% column location for each piece of information
% Field 1: 11 - Message ID, this is an internal number uniquely assigned to each message.
msgIdAt = 0;
% Field 2: 40192.4461458333 - Date/Time.  If you drop this into excel for format the cell as a date or time format, you get just that
dateTimeAt = 1;
% Field 3: 1 - Flag for created (1) vs received (2)... need to confirm when I get back home.
createRecvAt = 2;
% Field 4: 2 - Status/Action on the messages.  See below.
actionAt = 3;
% Field 5: W6XSC-1 - BBS name
bbsAt = 4;
% Field 6: CUPEOC - From name
fromAt = 5;
% Field 7: XSCEOC - TO name
toAt = 6;
% Field 8: 14 - Message size
msgSizeAt = 7;
if msgLogVer < 1
  % Field 9: "test subject" - subject
  subjectAt = 8;
  lmiAt = -1 ;
  msgTypeAt = -1 ;
else %if msgLogVer < 1
  % 9. Local Message ID << NEW
  % 10. Message Type << NEW, 1=Private, 2=NTS, 3=Bulletin
  % 11. Subject
  lmiAt = 8 ;
  msgTypeAt = 9;
  subjectAt = 10;
end %if msgLogVer < 1 else

%want to convert date-time from Excel format (day 1 = 1900,01,01) to Matlab: add this to Excel value
offAdd = datenum(1900,01,01) - 2;
textLine = '';

Ndx = 0;
tic;
lt = 0;
noFp = 1;
while ~feof(fid)
  fPos = ftell(fid);
  textLine = fgetl(fid);
  if ~length(textLine)
    break
  end
  fileInfo.fPos = fPos;
  fileInfo.lastLine = textLine;
  Ndx = Ndx + 1;
  delimAt = findstrchr('|', textLine);
  [err, errMsg, msgList(Ndx).msgId] = extractFromCSVText(textLine, delimAt, msgIdAt);
  [err, errMsg, a] = extractFromCSVText(textLine, delimAt, dateTimeAt);
  msgList(Ndx).dateTime = a + offAdd;
  [err, errMsg, msgList(Ndx).createRecv] = extractFromCSVText(textLine, delimAt, createRecvAt);
  [err, errMsg, msgList(Ndx).action] = extractFromCSVText(textLine, delimAt, actionAt);
  [err, errMsg, msgList(Ndx).bbs] = extractTextFromCSVNoQuote(textLine, delimAt, bbsAt);
  [err, errMsg, msgList(Ndx).from] = extractTextFromCSVNoQuote(textLine, delimAt, fromAt);
  [err, errMsg, msgList(Ndx).to] = extractTextFromCSVNoQuote(textLine, delimAt, toAt);
  [err, errMsg, msgList(Ndx).msgSize] = extractFromCSVText(textLine, delimAt, msgSizeAt);
  [err, errMsg, msgList(Ndx).subject] = extractTextFromCSVNoQuote(textLine, delimAt, subjectAt);
  if 0
    if findstrchr('RE: Solved! SNYEOC', msgList(Ndx).subject)
      fprintf('ajskldaslj');
    end
  end
  if msgLogVer < 1
    msgList(Ndx).lmi = '';
    msgList(Ndx).msgType = '';
  else % if msgLogVer < 1
    [err, errMsg, msgList(Ndx).lmi] = extractTextFromCSVNoQuote(textLine, delimAt, lmiAt);
    % 1=Private, 2=NTS, 3=Bulletin
    [err, errMsg, msgList(Ndx).msgType] = extractTextFromCSVNoQuote(textLine, delimAt, msgTypeAt);
  end % if msgLogVer < 1 else
  if (toc - lt) > 1 %  present status for long reads every 1 second
    if noFp
      %only display if still a long way to go
      if (fileInfo.fPos/fileInfo.bytes < 0.5)
        %first time: explain
        colOut = fprintf('\nReading %s', msgLogPathName);
        noFp = 0;
      end %if (fileInfo.fPos/fileInfo.bytes > 0.5)
    else % if noFp
      % show % of file read
      %  line long: roll it over
      if colOut > 75
        colOut = fprintf('...\n   ');
      end
      %
      colOut = colOut + fprintf(' %i%%', floor(100*fileInfo.fPos/fileInfo.bytes) );
    end %if noFp else
    lt = toc;
  end %if (toc - lt) > 1 
end
fcloseIfOpen(fid);
%  final status for long reads
if ~noFp
  fprintf(' 100%% - done!');
end

%  
% As an example, I opened up the above message and added some more message text.  The things that changed in the log are: DateTime, and Message size (2nd entry)....
%  
% 11|40192.4461458333|1|2|W6XSC-1|CUPEOC|XSCEOC|14|Test Subject
% 11|40192.4496527778|1|2|W6XSC-1|CUPEOC|XSCEOC|22|Test Subject
%  
% Next, I deleted the message.  The things that changed in the log are: DateTime, and Status/Action....
%  
% 11|40192.4461458333|1|2|W6XSC-1|CUPEOC|XSCEOC|14|Test Subject
% 11|40192.4496527778|1|2|W6XSC-1|CUPEOC|XSCEOC|22|Test Subject
% 11|40192.4503356482|1|8|W6XSC-1|CUPEOC|XSCEOC|22|Test Subject
%  
% The "|" delimiter is what I will use to parse the fields that can be either loaded into Excel now, 
%or for the reporting program that is to be written.  If you know Excel Pivot tables, this is a 
%great way to prototpye reports.
%  
% The Field 4 Actions are:
%  
% NEW = 1; created message; result of New or Forward or Reply
% READY = 2; created message, after Send (before Send/Receive)
% SENT = 3; created message, after Send/Receive
% UNREAD = 4; Received message, not opened
% READ = 5; Received message, and opened
% DRAFT = 6; created message, Saved to draft folder
% ABANDONED = 7; created message, but canceled before saved or sent
% DELETED = 8; any message, deleted
