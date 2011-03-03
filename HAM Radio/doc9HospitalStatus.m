function [err, errMsg, printedName, printedNamePath, form] = doc9HospitalStatus(fid, msgFname, receivedFlag, pathDirs, printMsg, printer, outpost, h_field);

%used for the pre-03-30-10 version
% for later "doc9HospitalStatusReport" used


% !PACF!
% # HOSPITAL STATUS REPORT FORM DOC-9
% # JavaScript - ver. 3.2, 10-17-09
% # FORMFILENAME: doc9-js.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% FACILITY NAME:  [FACILITY NAME]
% DATE:  [11/16/2009]
% TIME:  [1744]
% CONTACT NAME:  [contact name]
% PHONE #:  [phone #]
% FAX #:  [fax #]
% Other Phone, Fax, Cell Phone, Radio:  []
% 
% HOSPITAL OPERATIONAL STATUS
%  1.  :  [NOT Checked]
%  2.  :  [Checked]
%  3.  :  [NOT Checked]
% 
% DAMAGE ASSESSMENT YES / NO
%  4.  :  [YES]
%  5.  :  [NO]
%  6.  :  [YES]
%  7.  :  [NO]
%  8.  :  [YES]
%  9.  :  [NO]
% 10.  :  [YES]
% 11.  :  [NO]
% 12.  :  [YES]
% 13.  :  [NO]
% 14.  :  [NO]
% 
% CASUALTY INFORMATION TOTALS
% 15.  :  [ambul evac]
% 16.  :  [non-abul evac]
% 17.  :  [patient treate & release]
% 18.  :  [patients admitted last 12]
% 19.  :  [patients not yet seen]
% 20.  [other information]
% 21. [blank region (additional "other information"?)]
% 
% PERSONNEL ASSESSMENT TOTALS
% 22.  :  [Emergency Department Physicians]
% 23.  :  [	General Surgeons]
% 24.  :  [	Orthopedic Surgeons]
% 25.  :  [	Neurosurgeons]
% 26.  :  [	Registered Nurses]
% 27.  :  [	Physician's Assistants]
% 28.  :  [Nurse Practitioners]
% 29.  :  [	Ancillary Nursing]
% 30.  :  [	Lab Technologists]
% 31.  :  [	Clerical Staff]
% 32.  :  [	Volunteers]
% 
%       8 Hr.    Check if Staffed     24 Hrs  BED AVAILABILITY
% 33.   [	Critical Care Beds (Adult)] Checked      NOT Checked [	Critical Care Beds (Adult)]
% 34.   [Medical Beds] Checked      Checked     [Medical Beds]
% 35.   [	Surgical Beds] NOT Checked  Checked     [	Surgical Beds]
% 36.   [	OB/GYN Beds] NOT Checked  NOT Checked [	OB/GYN Beds]
% 37.   [Burn Beds] NOT Checked  NOT Checked [Burn Beds]
% 38.   [	Pediatric Beds] NOT Checked  NOT Checked [	Pediatric Beds]
% 39.   [Psychiatric Beds] NOT Checked  NOT Checked [Psychiatric Beds]
% 
% EQUIPMENT/SERVICES
% 40.  :  [Checked]
% 41.  :  [NOT Checked]
% 42.  :  [Checked]
% 43.  :  [NOT Checked]
% 44.  :  [Checked]
% 45.  :  [NOT Checked]
% 46.  :  [Checked]
% #EOF

[err, errMsg, modName, form, printedName, printedNamePath, printEnable, copyList, numCopies, ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printMsg, '-old form', msgFname, fid);

addressee = '';
originator = '';
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
  case 'FACILITY NAME' %
    form.subject = fT ;
    fieldsFound = fieldsFound + 1;
  case 'DATE' %
    form.date = fT;
    fieldsFound = fieldsFound + 1;
  case 'TIME' %
    form.time = fT;
    fieldsFound = fieldsFound + 1;
  case '1.' %
    if strcmp('checked', lower(fT))
      form.comment = 'Not Functional';
    end
    fieldsFound = fieldsFound + 1;
  case '2.' %
    if strcmp('checked', lower(fT))
      form.comment = 'Partially Functional';
    end
    fieldsFound = fieldsFound + 1;
  case '3.' %
    if strcmp('checked', lower(fT))
      form.comment = 'Fully Functional';
    end
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
  case 'contact' %
    %only for printing - don't count
    originator = fT;
  otherwise
  end
  if printEnable 
    [err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '') ;
  else % if printMsg 
    %If we are not printing and we've found all the desired fields
    %  presuming each fieldID occurs only once in the message
    if (fieldsFound > 12)
      break
    end
  end % if printMsg else
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message

fcloseIfOpen(fid);
addressee = 'Planning';
if (~err & printEnable)
  [err, errMsg, printedNamePath, printedName] = ...
    formFooterPrint(printer, printEnable, copyList, numCopies, h_field, formField, msgFname, originator, addressee, textToPrint, outpost, receivedFlag);
end % if (~err & printEnable)
