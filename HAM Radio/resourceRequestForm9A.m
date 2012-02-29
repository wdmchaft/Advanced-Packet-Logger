function [err, errMsg, printed, form] = resourceRequestForm9A(fid, fname, receivedFlag, pathDirs, printer, outpostHdg, outpostNmNValues);

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

[err, errMsg, modName, form, printed, printer ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint, addressee, originator]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printer, 'Resource Request #9A', fname, fid, outpostHdg);

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
    fieldsFound = fieldsFound + 1;
  case '1.' %
    form.date = fT;
    fieldsFound = fieldsFound + 1;
  case '2.' %
    form.time = fT;
    fieldsFound = fieldsFound + 1;
  case '3.' % requesting facility
    form.comment = fT;
    fieldsFound = fieldsFound + 1;
  case 'A.'
    form.senderMsgNum = fT ;
    fieldsFound = fieldsFound + 1;
  case 'MsgNo'
    form.MsgNum = fT ;
    fieldsFound = fieldsFound + 1;
  case 'C.'
    form.receiverMsgNum = fT ;
    fieldsFound = fieldsFound + 1;
  case 'D.'
    form.sitSevere = fT ;
    fieldsFound = fieldsFound + 1;
  case 'E.'
    form.handleOrder = fT ;
    fieldsFound = fieldsFound + 1;
  case 'F.'
    form.replyReq = fT; 
    fieldsFound = fieldsFound + 1;
  case 'replyby'
    form.replyWhen = fT ;
    fieldsFound = fieldsFound + 1;
  otherwise
  end
  if printer.printEnable
    [err, errMsg, textToPrint, h_field, formField, moveNeeded] = fillFormField(fieldID, fieldText, formField, h_field, textToPrint, spaces, outpostNmNValues);
  else %if printer.printEnable
    %not printing - exit when we've extracted all we need
    if fieldsFound > 11
      break
    end
  end % if printEnable else
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message

fcloseIfOpen(fid);

if (~err & printer.printEnable)
  [err, errMsg, printed] = ...
    formFooterPrint(printer, h_field, formField, fname, originator, addressee, textToPrint, outpostHdg, receivedFlag);
end % if (~err & printEnable)
