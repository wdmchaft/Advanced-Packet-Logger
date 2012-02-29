function [err, errMsg] = addToMsgFile(pathToFile, fileName, outpost, receivedFlag, linesRead, fid, outpostNmNValues);
%function [err, errMsg] = addToMsgFile(pathToFile, fileName, outpost, receivedFlag, linesRead, fid, outpostNmNValues);
%  Support module for processOutpostPacketMessages
%Adds and potentially alters the contents of the text version
%  of a message.  Does NOT alter the original message which is
%  stored in Outpost.
%Message file will be renamed from <name><.ext> to <name>.mss   This is
%  being done to allow the calling program to prevent double processing a message
%Adds:
% If Outpost version doesn't support local message numbering:
%  * to all messages: the message number for this station: (from the field "outpost.logMsgNum")
%    - for received messages this is created by "processOutpostPacketMessages"
%    - for send messages this is created by the local instance of Outpost
%  The line "Local Msg.#: <outpost.logMsgNum>" is inserted after the line
%   which contains 'sent:' or 'received:' as appropriate
%Alters:
%  * for received PacFORMs messages swaps the contents of the Msg # fields
%    so they both the follow result
%    - sender's message number is placed in the field #2 "When Receiving
%      Msg.: Sender's msg #"
%    - the local message number for the received message is placed in the
%      Msg. # field.
%  * no action for sent PacFORMs
%Note: both Add & Alter operations require re-writing the message text file.
%Provision is made for condensed PacFORMs where blank fields are not transmitted.
%
%Pre-requiste:
%  file must be open to read and most recent line read must be the last
%  line of the heading.
%INPUTS:
%  pathToFile: path to the message file terminated with "\"
%  fileName: file name and extension of the message file
%  outpost: structure containing the Outpost header information for the
%       message as extracted from the message.  Must have outpost.logMsgNum loaded.
%  receivedFlag: 1 if a received message, 0 if a sent message
%  linesRead: number of lines read so far; (as stated above, must currently
%       be at last line of heading)
%  fid: pointer to the file <pathToFile><fileName> which must be open for reading
%OUTPUT:
%  err, errMsg: 0 if OK
%  the altered file "fileName" will be renamed from <name><.ext> to <name>.mss 
%  note that the file "fid" will be closed by this module
%PacFORM field IDs for the various forms per Phil Henderson 2010-Feb-17
%Updated 4/2010 per Phil's upgrades: added "FORM DOC-9 HOSPITAL-STATUS REPORT" & "RESOURCE REQUEST FORM #9A"

[err, errMsg, modName] = initErrModName(mfilename);

fPathName = strcat(pathToFile, fileName);

if (fid < 1)
  err = 1;
  errMsg = sprintf('%s: no longer open to read "%s".', modName, fPathName);
  return
end

%Message sample before we were able to obtain the Outpost date & time
% BBS: K6MTV-1
% From: k6fsh@scnorth.ampr.org
% To: 1PAPAV
% Subject: Test Message
% Cc: 1scksc, 1sjvmc, 1sjoch, 1sjgsh, 1sjsth, 1sjrsj, 1lglgh, 1grslh, 1pasuh, 
%     1papav, 1mtech
% Subject: Test Message

%Message samples after we were able to obtain the Outpost date & time
% BBS: K6MTV-1
% From: mtveoc@mtv.ampr.org
% To: KI6SEP
% Subject: READ: SER134: Monday Night Check In
% Received: 08-Feb-2010 19:37

% BBS: K6MTV-1
% From: KI6SEP
% To: KI6SEP
% Subject: SEP130: test
% Sent: 07-Feb-2010 21:13

% find end of "heading" information from Outpost - this ties in with 
%the Script.

headingEndLine = linesRead;
lastPACFheadingLine = 0;
myMsgNmCnt = 0;
sndrMsgNmCnt = 0;
PACF = 0;
if receivedFlag 
  [PACF, linesRead] = detectPacFORM(fid, linesRead);
  if PACF %% 10/23 & ~length(outpostValByName('LMIflag', outpostNmNValues))
    [err, errMsg, pacfListNdx, thisForm, textLine, linesRead] = getPACFType(fid, linesRead);
    if err
      errMsg = strcat(modName, errMsg);
      fcloseIfOpen(fid);
      if linesRead
        %don't pass 4th parameter
        [err, errMsg] = renameMsg(pathToFile, modName, fPathName);
      end
      return
    end
    %defaults.  If a given form uses different names for either, insert
    %  the correct one in the appropriate "case" statement
    origMsgFieldID = 'MsgNo';
    sndrsMsgNoFieldID = 'A.';
    %for completeness but not used currently  10-Feb-17
    recvrMsgNoFieldID = 'C.';
    %set to 0 for any form that you do NOT want to have a message # inserted
    good = 1;
    %needs to be same order as List
    switch pacfListNdx
    case 1 % 'CITY-SCAN UPDATE FLASH REPORT'
    case 2 % 'SC COUNTY LOGISTICS', ...
    case 3 % 'EOC MESSAGE FORM',  ...
      sndrsMsgNoFieldID = '2.';
      recvrMsgNoFieldID = '3.';
      %these fields will have their contents updated to replace the sender's information
      % with information about the receiver.
      recvrInfoList = {'Rec-Sent','OpCall','OpName','OpDate','OpTime'};
    case 4 % 'CITY MUTUAL AID REQUEST',  ...
    case 5 % 'SHORT FORM HOSPITAL STATUS',  ...
    case 6 % 'HOSPITAL STATUS',  ...
    case 7 % 'HOSPITAL-BEDS',  ...
    case 8 % 'OES MISSION REQUEST',  ... 
      sndrsMsgNoFieldID = 'A.0';
      recvrMsgNoFieldID = 'C.0';  %  Rec-Sent: [Sent]  Rec-Sent: [Received]
    case 9 % 'SEMS SITUATION'
    case 10 % FORM DOC-9 HOSPITAL-STATUS REPORT
    case 11 % RESOURCE REQUEST FORM #9A
    case 12 % FORM DOC-9 BEDS HOSPITAL-STATUS REPORT
    otherwise
      good = 0;
    end % switch pacfListNdx
    if good
      % skip through the remainder of the comment/heading
      while (1==findstrchr('#', textLine) & ~feof(fid))
        textLine = fgetl(fid);
        linesRead = linesRead + 1;
      end
      lastPACFheadingLine = linesRead -  1;
      [err, errMsg, myMsgNmCnt, myMsgNmText, myMsgNmEnd, sndrMsgNmCnt, sndrMsgNmText]...
        = recvdPACFSwapMsgNm(fid, textLine, linesRead, origMsgFieldID, sndrsMsgNoFieldID);
      if err
        errMsg = strcat(modName, errMsg);
        fcloseIfOpen(fid);
        return
      end
    end % if good
  end %if PACF %%& ~length(outpostValByName('LMIflag', outpostNmNValues))
end % if receivedFlag

%all the learning is done: we know the locations where lines need to
% be added and any that need to be altered.
%Reset to the beginning of the file & start the re-writting operation.
fseek(fid, 0, 'bof');
%%%%%
fPathNameOut = strcat(pathToFile, 'temp.txt');
[err, errMsg, fidOut] = fOpenToWrite(fPathNameOut, 'w', modName);
if (err)
  errMsg = sprintf('%s%s', modName, errMsg);
  fcloseIfOpen(fid);
  return
end
for linesRead = 1:headingEndLine
  textLine = fgetl(fid);
  %if Outpost isn't capable of creating a local message number, we did & insert the number we created
  % on a line before the Subject line
  if ~length(outpostValByName('LMIflag', outpostNmNValues))
    if ((findstrchr('subject:', lower(textLine)) == 1) & length(outpost.logMsgNum) )
      fprintf(fidOut,'Local Msg ID: %s\r\n', outpost.logMsgNum);
    end % if (findstrchr('subject:', lower(textLine)) == 1)
  else
    a = findstrchr('Local_Msg_ID:', textLine);
    %reformat the wording
    if a
      textLine = strrep(textLine,'_',' '); 
    end
  end % if ~length(outpostValByName('LMIflag', outpostNmNValues))
  fprintf(fidOut,'%s\r\n', textLine);
end % for linesRead = 1:headingEndLine
if lastPACFheadingLine
  for linesRead = linesRead+1:lastPACFheadingLine
    textLine = fgetl(fid);
    fprintf(fidOut,'%s\r\n', textLine);
  end % for linesRead = linesRead:lastPACFheadingLine
end
%if this is a received message of type PACF and we've moved the original
%   Msg# to the Sender's Msg# field as indicated by either myMsgNm or sndrMsgNm ~= 0
if receivedFlag & PACF & (myMsgNmCnt | sndrMsgNmCnt)%%& ~length(outpostValByName('LMIflag', outpostNmNValues))
  myMsgText = sprintf('%s: [%s%s',  myMsgNmText, outpost.logMsgNum, myMsgNmEnd);
  if myMsgNmCnt < sndrMsgNmCnt
    linesRead = insertPACF(fid, fidOut, linesRead, myMsgNmCnt, myMsgText);
    linesRead = insertPACF(fid, fidOut, linesRead, sndrMsgNmCnt, sndrMsgNmText);
  else % if myMsgNmCnt < sndrMsgNmCnt
    %if there was a line with the sender msg number or if we created one...
    %            if we created the line, "sndrMsgNmCnt" will be negative & "insertPACF" will treat it as an insert, not a replace.   
    linesRead = insertPACF(fid, fidOut, linesRead, sndrMsgNmCnt, sndrMsgNmText);
    linesRead = insertPACF(fid, fidOut, linesRead, myMsgNmCnt, myMsgText);
  end % if myMsgNmCnt < sndrMsgNmCnt else
end % if receivedFlag & PACF & (myMsgNmCnt | sndrMsgNmCnt) %%& ~length(outpostValByName('LMIflag', outpostNmNValues))

if receivedFlag & PACF
  % if ICS213 we'll replace the sending ham's info with the receiving info
  Ndx = [];
  if pacfListNdx == 3
    Ndx = [1:length(recvrInfoList)];
    %explicit tracking of all items we want to replace.
  end
  % loop until the end of the file
  while ~feof(fid) 
    % look at each line of the PACFORM.  There is not guarantee the operator
    %  hadn't added lines after the PACFORM.... not that they are likely to be seen by anybody!!
    %loop until EOF or break when #EOF found!
    while ~feof(fid)
      textLine = fgetl(fid) ;
      %if we've got more fields to replace/update
      if length(Ndx)
        a = findstrchr(':', textLine);
        % which member matches...
        b = find(ismember(recvrInfoList(Ndx), textLine(1:a-1)));
        % if a match...
        if b
          %... do the update
          [textLine, Ndx] = updateRecvrInfo(recvrInfoList(Ndx), b, outpostNmNValues, outpost, textLine, Ndx) ;  
          Ndx(b) = 0;
          % remove the just processed item -> faster execution w/ shorter list
          Ndx = Ndx(find(Ndx));
        end %if b
      end %if length(Ndx)
      if (findstrchr('#EOF', textLine) ~= 1)
        % pulled 6/6/11: redundant!!        fprintf(fidOut,'%s\r\n', textLine);
        break
      end
    end % while (findstrchr('#EOF', textLine) ~= 1) & ~feof(fid)
    if (findstrchr('#EOF', textLine) == 1) & length(Ndx)
      for itemp = 1:length(Ndx)
        b = Ndx(itemp);
        tl = sprintf('%s: []', recvrInfoList{b});
        [tl, Ndx] = updateRecvrInfo(recvrInfoList, b, outpostNmNValues, outpost, tl, Ndx) ;  
        fprintf(fidOut,'%s\r\n', tl);
      end % for itemp = 1:length(Ndx)
    end % if (findstrchr('#EOF', textLine) == 1) & length(Ndx)
    fprintf(fidOut,'%s\r\n', textLine);
  end % while ~feof(fid)
else % if receivedFlag & PACF
  %sent or not a PACF 
  while ~feof(fid)
    textLine = fgetl(fid) ;
    fprintf(fidOut,'%s\r\n', textLine);
  end % while ~feof(fid)
end % if receivedFlag & PACF else
fcloseIfOpen(fid);
fcloseIfOpen(fidOut);

%all done: rename from .txt to .mss
[err, errMsg] = renameMsg(pathToFile, modName, fPathName, fPathNameOut);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function linesRead = insertPACF(fid, fidOut, linesRead, lineCnt, newText);
% if we created the newText line, lineCnt will be negative
for x = (linesRead+1):(abs(lineCnt)-1)
  textLine = fgetl(fid);
  fprintf(fidOut,'%s\r\n', textLine);
end
if length(x)
  linesRead = x;
end
% if we created the newText line, lineCnt will be negative
%  so we are not replacing a line but inserting one!
if (lineCnt > 0)
  %old line - we're replacing this one but we need to read it so we can toss it.
  textLine = fgetl(fid);
  linesRead = linesRead + 1;
end
%insert the new line
fprintf(fidOut,'%s\r\n', newText);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [textLine, Ndx] = updateRecvrInfo(recvrInfoList, b, outpostNmNValues, outpost, textLine, Ndx) ;
% flag: when set, the modified field will include (sent: <sender info>)
keepSent = 1;
switch char(recvrInfoList(b))
case 'OpCall'
  d = outpostValByName('StationID', outpostNmNValues);
case 'OpName'
  d = outpostValByName('NameID', outpostNmNValues);
case 'OpDate'
  a = findstrchr(' ', outpost.dateTime);
  d = outpost.dateTime(1:a-1);
case 'OpTime'
  a = findstrchr(':', outpost.time);
  if a
    d = strcat(outpost.time(1:a-1),outpost.time(a+1:length(outpost.time)));
  else
    d = outpost.time;
  end
case 'Rec-Sent'
  d = 'Received' ;
  keepSent = 0;
otherwise
  d = '';
end %switch recvrInfoList(b)

if length(d)
  a = findstrchr('[', textLine);
  b = findstrchr(']', textLine);
  if keepSent
    textLine = sprintf('%s%s (sent: %s)%s', textLine(1:a), d, textLine(a+1:b-1), textLine(b:length(textLine)) );
  else % if keepSent
    textLine = sprintf('%s%s%s', textLine(1:a), d, textLine(b:length(textLine)) );
  end % if keepSent else
end % if length(d)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
