function [err, errMsg, printed, form] = cityScanFlash(fid, msgFname, receivedFlag, pathDirs, printer, outpostHdg, outpostNmNValues, h_field);
% !PACF!
% # CITY-SCAN UPDATE FLASH REPORT 
% # JS-ver. 3.3, 10-17-09
% # FORMFILENAME: city-scan.html
% # TO COPY THE TEXT IN THIS WINDOW, FOCUS THIS WINDOW, THEN:
% # Select All ASCII Text by typing Ctrl-A, then Ctrl-C to Copy.
% # Next, RUN WordPad or Notepad and DO Ctrl-V to Paste into the editor body.
% # Then DO Save-As to a TEXT Document file, or Paste directly into Outpost.
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% 1a.: [Mountain View]  (City reporting)
% 1b.: [other - entity]  (if not city, Entity Name)
% 2.: [11/15/2009]  (Date/Time of Contact)
% 3.: [1847]        (Date/Time of Contact)
% 4.: [contact name]  
% 5.: [contact title]
% 6.: [contact phone 000-000-0000]  (method of contact)
% 7.: [radio freq]   (method of contact)
% 8.: [yes]   (city impacted? yes/no)
% 9.: [yes]   (yes/no HAS A LOCAL EMERGENCY BEEN DECLARED? (check one) )
% 10.: [emerg mm/dd/yyyy] (if yes, when emergency declared)
% 11.: [time hhmm] (if yes, when emergency declared 24hr)
% 12.: [signed name] (if yes, who signed emergency declaration)
% 13.: [signed title] (if yes, title of who signed emergency declaration)
% 14.: [no]   ( yes/no)    HAS YOUR EMERGENCY OPERATIONS CENTER BEEN ACTIVTED?
% 15.: [no]   ( yes/no)    Can you tell me what MAJOR INCIDENTS are occurring now? (check one) 
% 16a-I: [incident summary]
% 16a-L: [incident location]
% 16a-S: [incident status]
% 17.: [yes]   ( yes/no)   Are you requesting any ADDITIONAL RESOURCES from the Operation Area?
% #EOF

[err, errMsg, modName, form, printed, printer, ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint, addressee, originator]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printer, 'CityScanFlash', msgFname, fid, outpostHdg);

cityImpacted = '';
emergDeclare = '';

while 1 % read & detect the field for each line of the entire message
  % clear the print line so the line will not be altered unless the field
  %   has an entry. 
  printLine = 0;
  if (1 == findstrchr(textLine, '#EOF'))
    break
  end
  if feof(fid)
    err = 1 ;
    errMsg = sprintf('%s: incomplete message: End-of-message but no "#EOF"', modName);
    break
  end
  textLine = readPACFLine(textLine, fid);
  [fieldText, fieldID] = extractPACFormField(textLine) ;
  % Decode the information for the Packet Log:
  %ID/names as contained within the Outpost form of the message
  switch fieldID
  case {'1a.', '1b.'} % City reporting, if not city - Entity Name
    form.subject = multiField('', form.subject, fieldText);
    fieldsFound = fieldsFound + 1; %two from here
  case '2.'
    form.date = fieldText ;
    fieldsFound = fieldsFound + 1;
  case '3.'
    form.time = fieldText ;
    fieldsFound = fieldsFound + 1;
  case {'4.','5.'}
    %only used if printing is enabled so 'fieldsFound' isn't incremented
    if length(originator)
      originator = sprintf('%s ', originator);
    end
    originator = sprintf('%s%s', originator, fieldText);
  case 'resource'
    %form.comment = fieldText ;
  case '8.' 
    cityImpacted = fieldText;
    fieldsFound = fieldsFound + 1;
  case '9.' 
    emergDeclare = fieldText; 
    fieldsFound = fieldsFound + 1;
  case 'A.'
    form.senderMsgNum = fieldText ;
    fieldsFound = fieldsFound + 1;
  case 'MsgNo'
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
    form.replyWhen = fieldText ;
    fieldsFound = fieldsFound + 1;
  otherwise
  end

  if printer.printEnable 
    [err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '', outpostNmNValues) ;
    if err
      if err == 99
        err = 0;
        msgText = sprintf('>%s%s\r\nmessage: "%s".', mfilename, errMsg, msgFname);
        logErr(msgText, outpostNmNValues)
      else
      end
    end
  else % if printMsg 
    %If we are not printing and we've found all the desired fields
    %  presuming each fieldID occurs only once in the message
    if fieldsFound > 12
      break
    end
  end % if printMsg else
  % next line
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message
form.comment = sprintf('City impacted: %s. Emergency declared: %s', cityImpacted, emergDeclare) ;

fcloseIfOpen(fid);

if (~err & printer.printEnable)
  addressee = 'Planning';
  [err, errMsg, printed] = formFooterPrint(printer, h_field, formField, msgFname, originator, addressee, textToPrint, outpostHdg, receivedFlag);
end % if (~err & printer.printEnable)
%------------------------------
function logErr(msgText, outpostNmNValues)
  %just in case we cannot open the log file we'll use try/catch
  try
    [err, errMsg, date_time] = datevec2timeStamp(now);
    fid = fopen(sprintf('%s%s_%s.log', outpostValByName('DirAddOns', outpostNmNValues), mfilename, date_time),'a');
    if (fid < 1)
      fid = fopen(sprintf('%s%s.log', '', mfilename),'a');
    end % if (fid < 1)
    if fid > 0
      fprintf(fid, '\r\n%s %s', date_time, msgText);
      fprintf('\n%s %s', date_time, msgText);
      fclose(fid);
    end % if fid > 0
  catch
  end
