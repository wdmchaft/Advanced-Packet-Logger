function [err, errMsg, printed, form] = logisticsRequest(fid, msgFname, receivedFlag, pathDirs, printer, outpostHdg, h_field);

% !PACF!
% # SC COUNTY LOGISTICS REQUEST FORM
% # JS-ver. 2.2, 10-17-09
% # FORMFILENAME: logistics-request.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% 1.: [Urgent]
% 2.: [requesting agency]
% 3.: [point of contact]
% 4.: [poc 000-000-0000]
% 5.: [eoc poc]
% 6.: [approved by]
% 7.: [11/16/2009 @ 0828]
% 8.: [local incident number]
% 9.: [local request]
% 10.: [resources required]
% 11.: [quantity]
% 12.: [why needed? to do what?]
% 13.: [how long needed]
% 14.: [when needed (mm/dd/yyyy @ hhmm -24 hour time)]
% 15.: [deliver to]
% 16.: [deliver to 000-000-0000]
% 17.: [delivery location]
% 18.: []
% 31.: [delivery time]
% 32.: [verified by]
% 33.: [remarks]
% 34.: [finance remarks]
% #EOF

[err, errMsg, modName, form, printed, printer ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint, addressee, originator]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printer, 'scLogisticsReq', msgFname, fid, outpostHdg);

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
  switch fieldID
  case {'1.', '2.'} % Priority, requesting agency 
    form.subject = multiField('', form.subject, fieldText);
    %two calls here!
    fieldsFound = fieldsFound + 1;
  case '7.'
    % format is "[11/14/2009 @ 0859]" & is in 24 hour format
    [err, errMsg, form.date, form.time] = dateTimeSplit(fieldText) ;
    fieldsFound = fieldsFound + 1;
  case '8.' 
    %this is the incident number
    form.comment = sprintf('%s Lcl Incident # %s', form.comment, fieldText);
    fieldsFound = fieldsFound + 1;
  case '9.' 
    %this is the incident number
    form.comment = sprintf('%s Lcl Rqst # %s', form.comment, fieldText);
    fieldsFound = fieldsFound + 1;
  case '14.' % when
    form.replyWhen = multiField('Needed', form.replyWhen, fieldText);
    fieldsFound = fieldsFound + 1;
  case 'A.'
    form.senderMsgNum = fieldText ;
    fieldsFound = fieldsFound + 1;
  case 'MsgNo'
    %     form.MsgNum = multiField('Msg #', form.MsgNum, fieldText);
    form.MsgNum = fieldText ;
    fieldsFound = fieldsFound + 1;
  case 'C.'
    form.receiverMsgNum = fieldText ;
    fieldsFound = fieldsFound + 1;
  case 'D.'
    form.sitSevere = fieldText ;
    fieldsFound = fieldsFound + 1;
  case 'E.'
    form.handleOrder = fieldText ;
    fieldsFound = fieldsFound + 1;
  case 'F.'
    form.replyReq = fieldText; 
    fieldsFound = fieldsFound + 1;
  case 'replyby'
    form.replyWhen = multiField('Reply by', form.replyWhen, fieldText);
    fieldsFound = fieldsFound + 1;
  case '3.'
    %only used if printing is enabled so 'fieldsFound' isn't incremented
    originator = fieldText ;
  otherwise
  end
  if printer.printEnable 
    [err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '') ;
  else % if printer.printEnable 
    %If we are not printing and we've found all the desired fields
    %  presuming each fieldID occurs only once in the message
    if (fieldsFound > 12)
      break
    end
  end % if printMsg else
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message

fcloseIfOpen(fid);
if (~err & printer.printEnable)
  addressee = 'Planning';
  [err, errMsg, printed] = ...
    formFooterPrint(printer, h_field, formField, msgFname, originator, addressee, textToPrint, outpostHdg, receivedFlag);
end % if (~err & printer.printEnable)
