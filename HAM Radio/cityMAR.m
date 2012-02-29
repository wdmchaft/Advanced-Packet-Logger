function [err, errMsg, printed, form] = cityMAR(fid, msgFname, receivedFlag, pathDirs, printer, outpostHdg, h_field);
% !PACF!
% # CITY MUTUAL AID REQUEST 
% # JS-ver. 1.1, 10-17-09
% # FORMFILENAME: CityMAReq.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% agency: [Requesting City/Agency]
% actno: [Requesting Agency RACES Activation]
% dtprep: [11/14/2009 @ 0859]
% prepby: [Prepared by]
% evtname: [Event name]
% reqname: [requester name]
% reqpos: [requester position]
% authname: [city authorizing official name]
% authpos: [city authorizing official position]
% resource: [resources required]
% dtrequired: [11/14/2009]
% timetofrm: [time from/to]
% location: [location]
% travelrt: [travel route information]
% trfreq: [travel frequency]
% arrinstruc: [arrival instructions]
% complan: [communications plan]
% briefing: [responder briefing time/place]
% #EOF

[err, errMsg, modName, form, printed, printer,  ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint, addressee, originator]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printer, 'CityMAReq', msgFname, fid, outpostHdg);

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
  case 'dtprep'
    % format is "[11/14/2009 @ 0859]" & is in 24 hour format
    [err, errMsg, form.date, form.time] = dateTimeSplit(fT) ;
    fieldsFound = fieldsFound + 1;
  case 'resource'
    form.comment = fT ;
    fieldsFound = fieldsFound + 1;
  case 'agency' 
    form.subject = fT ;
    fieldsFound = fieldsFound + 1;
  case 'timetofrm' % when
    if ~length(form.replyWhen)
      %this is for pre-2/17/2010 form
      form.replyWhen = sprintf('travel=%s',fT) ;
      fieldsFound = fieldsFound + 1;
    end
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
  case 'reqname'
    %only needed for printing - don't use counter
    originator = fT;
  otherwise
  end
  if printer.printEnable 
    [err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '') ;
  else % if printMsg 
    %If we are not printing and we've found all the desired fields
    %  presuming each fieldID occurs only once in the message
    if fieldsFound > 9
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
end % if (~err & printEnable)
