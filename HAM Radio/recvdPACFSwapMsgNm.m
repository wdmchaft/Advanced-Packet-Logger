function [err, errMsg, myMsgNmCnt, myMsgNmText, myMsgNmEnd, sndrMsgNmCnt, sndrMsgNmText]...
  = recvdPACFSwapMsgNm(fid, textLine, linesRead, origMsgFieldID, whenRcvdFieldID);
% function [err, errMsg, myMsgNmCnt, myMsgNmText, myMsgNmEnd, sndrMsgNmCnt, sndrMsgNmText]...
%   = recvdPACFSwapMsgNm(fid, textLine, linesRead, origMsgFieldID, whenRcvdFieldID);
%Scan the file until both the line with the field name in "origMsgFieldID" & "whenRcvdFieldID" are found.
%  return the line number of each of these fields in the file.
%Moves the contents of origMsgField to whenRcvdField and empties 
%  origMsgField iff whenRcvdField was empty.
%  ex: 2.:[]          Msg.#:[SEP0123] 
%      2.:[SEP0123]   Msg.#:[]
%If origMsgFieldID field is not found, creates 
%    myMsgNmText = <origMsgFieldID>:[
%    myMsgNmCnt = line# before "#EOF"
%If whenRcvdFieldID is not found, sets sndrMsgNmCnt = 0 
%    to indicate there is no line to export
%If whenRcvdFieldID is found & origMsgFieldID is not found
%    sets sndrMsgNmText to blank: <whenRcvdFieldID>:[]
%    (see above for how not finding origMsgFieldID is handled)
%INPUT
% fid: pointer to open message file being read
% textLine: most recently read line
% linesRead: line number of "textLine" within the file
% origMsgFieldID: ID (text descriptor) for the field which will be followed by ":"
%    This is the field which contains the Msg# used by the sender.
% whenRcvdFieldID: similar to origMsgFieldID but is either blank or contains the
%    message number assigned by the receiving station.
%OUTPUT
% myMsgNmCnt: lines read count for the message number field that I use
% myMsgNmText: the field identifier for the field.  The same as origMsgFieldID
% myMsgNmEnd: starts with the first ] and goes to the end of the line
%      usage: newLine = sprintf('%s:[%s%s', myMsgNmText, newNumber, myMsgNmEnd);
% sndrMsgNmCnt: lines read count for the message number field of "whenRcvdFieldID"
% sndrMsgNmText: new text line for this field: <field ID>:[original number] 

[err, errMsg, modName] = initErrModName(mfilename);

%defaults: returned if nothing is found
myMsgNmCnt = 0 ;
%caller will use these two to add in the receive IDnumber:
%  (location controlled in "switch/case" after loop
myMsgNmText = sprintf('%s:[', origMsgFieldID);
myMsgNmEnd = ']' ;
%
sndrMsgNmCnt = 0 ; %0 means not to insert a line
sndrMsgNmText = '';

found = 0;
while 1 % read & detect the field for each line of the entire message
  textLine = readPACFLine(textLine, fid);
  if (1 == findstrchr(textLine, '#EOF'))
    break
  end
  if feof(fid)
    err = 1 ;
    errMsg = sprintf('%s: incomplete message: End-of-message but no "#EOF"', modName);
    %%%%%%%%%%%%%
    return
    %%%%%%%%%%%%%
  end % if feof(fid)
  [fieldText, fieldID] = extractPACFormField(textLine) ;
  % Decode the information for the Packet Log:
  %ID/names as contained within the Outpost form of the message
  switch fieldID
  case origMsgFieldID
    myMsgNmCnt = linesRead;
    myMsgNmText = fieldID;
    origMsgNum = fieldText;
    a = findstrchr(']', textLine);
    myMsgNmEnd = textLine(a(1):length(textLine));
    found = found + 1;
  case whenRcvdFieldID
    %if there is already information in this field
    % we will not swap.  A process before this one, such as Outpost or manual
    % has placed information in the field so we don't want to do anything.
    if length(fieldText)
      %receiving msg # field is not empty so a number must have been already assigned
      %  don't override it - flag to exit loop
      found = 10;
    end
    found = found + 2;
    sndrMsgNmCnt = linesRead;
    sndrMsgNmText = fieldID;
    a = findstrchr(']', textLine);
    sndrMsgLineEnd = textLine(a(1):length(textLine));
  otherwise
  end
  if found > 2
    break
  end
  textLine = fgetl(fid);
  linesRead = linesRead + 1;
end % while 1 % read & detect the field for each line of the entire message

if (found > 9)
  %sender msg# field was not empty - 
  %  turn off the replacing/editing the lines (performed in caller, which is typically "addToMsgFile.m".
  myMsgNmCnt = 0;
  sndrMsgNmCnt = 0;
else %if (found > 9)
  switch found
  case 0 % neither found
    if (1 == findstrchr(textLine, '#EOF'))
      myMsgNmCnt = linesRead - 1;
    end
  case 1 % only origMsgFieldID found
    %need to create "sndrMsgNm"
    %  give it the passed in field ID the found number/ID. . .
    sndrMsgNmText = sprintf('%s: [%s]', whenRcvdFieldID, origMsgNum);
    %...and arbitrarily insert it just before the myMsgNm line: make it negative to show we created it!
    sndrMsgNmCnt = -(myMsgNmCnt - 1);
  case 2 % only whenRcvdFieldID found
    %there is no message number to insert so we'll create a blank line.
    sndrMsgNmText = sprintf('%s: [%s', sndrMsgNmText, sndrMsgLineEnd);
  case 3 %both found.  All variables initialized so we just need to build up one return
    %note: sndrMsgLineEnd goes to the end of the line such 
    %  that it contains ] and anything else that might be on the line.
    sndrMsgNmText = sprintf('%s: [%s%s', sndrMsgNmText, origMsgNum, sndrMsgLineEnd);
  otherwise
  end % switch found
end %if (found > 9) else
    
