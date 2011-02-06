function [err, errMsg, printedName, printedNamePath, form] = resourceRequestForm9A(fid, fname, receivedFlag, PathConfig, printMsg, printer);

% !PACF! origMsg#_U/P_ResRec9_REQUESTING FACILITY
% # RESOURCE REQUEST FORM #9A 
% # JS-ver. 1.1, 03-29-10
% # FORMFILENAME: ResourceReq9A.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% A.: [sndrMsg#]
% MsgNo: [origMsg#]
% C.: [rcvrMsg#]
% D.: [URGENT]
% E.: [PRIORITY]
% F.: [Yes]
% replyby: [then]
% 1.: [04/16/2010]
% 2.: [2107]
% 3.: [REQUESTING FACILITY]
% 4.: [CONTACT]
% 5.: [PHONE]
% 6.: [FAX]
 

[err, errMsg, modName] = initErrModName(mfilename) ;
[form, printedName, printedNamePath] = clearFormInfo;

% skip through the comment/heading
textLine = '#' ;
while (1==findstrchr('#', textLine) & ~feof(fid))
  textLine = fgetl(fid);
end

while 1 % read & detect the field for each line of the entire message
  % clear the print line so the line will not be altered unless the field
  %   has an entry. 
  printLine = 0;
  if (1 == findstrchr(textLine, '#EOF'))
    break
  end
  textLine = readPACFLine(textLine, fid);
  if feof(fid)
    err = 1 ;
    errMsg = sprintf('%s: incomplete message: End-of-message but no "#EOF"', modName);
    break
  end
  [fieldText, fieldID] = extractPACFormField(textLine) ;
  % Decode the information for the Packet Log:
  %ID/names as contained within the Outpost form of the message
  fT = strtrim(fieldText);
  switch fieldID
  case 'facnam' %
    form.subject = fT ;
  case '1.' %
    form.date = fT;
  case '2.' %
    form.time = fT;
  case '3.' % requesting facility
    form.comment = fT;
  case 'A.'
    form.senderMsgNum = fT ;
  case 'MsgNo'
    form.MsgNum = fT ;
  case 'C.'
    form.receiverMsgNum = fT ;
  case 'D.'
    form.sitSevere = fT ;
  case 'E.'
    form.handleOrder = fT ;
  case 'F.'
    form.replyReq = fT; 
  case 'replyby'
    form.replyWhen = fT ;
  otherwise
  end
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message

fcloseIfOpen(fid);
