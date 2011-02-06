function [err, errMsg, printedName, printedNamePath, form] = doc9BedStatus(fid, fname, receivedFlag, pathDirs, printEnable, printer, outpost, h_field);

%used for the pre-03-30-10 version
% for later "doc9bedsHospitalStatusReport" is used

% !PACF!
% # HOSPITAL-BEDS AVAILABILITY STATUS REPORT FORM DOC-9
% # JavaScript - ver. 3.2, 10-17-09
% # FORMFILENAME: doc9-beds-js.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% FACILITY NAME:  [FACILITY NAME]
% DATE:  [11/16/2009]
% TIME:  [1814]
% CONTACT NAME:  [Contact Name]
% PHONE #:  [Phone #]
% FAX #:  [Fax #]
% Other Phone, Fax, Cell Phone, Radio:  []
% 
% HOSPITAL OPERATIONAL STATUS
%  1.  :  [Checked]
%  2.  :  [NOT Checked]
%  3.  :  [NOT Checked]
% 
%       8 Hr.    Check if Staffed     24 Hrs  BED AVAILABILITY
% 33.   [Critical Care Beds (Adult)] Checked      NOT Checked [Critical Care Beds (Adult)]
% 34.   [Medical Beds] Checked      Checked     [Medical Beds]
% 35.   [Surgical Beds] NOT Checked  Checked     [Surgical Beds]
% 36.   [OB/GYN Beds] NOT Checked  NOT Checked [OB/GYN Beds]
% 37.   [Burn Beds] NOT Checked  NOT Checked [Burn Beds]
% 38.   [Pediatric Beds (Including NICU/PICU)] NOT Checked  NOT Checked [Pediatric Beds (Including NICU/PICU)]
% 39.   [Psychiatric Beds] NOT Checked  NOT Checked [Psychiatric Beds]
% #EOF

[err, errMsg, modName, form, printedName, printedNamePath, printEnable, copyList, numCopies, ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printEnable, '-no form', fname, fid);

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
  case 'DATE' %
    form.date = fT;
  case 'TIME' %
    form.time = fT;
  case '1.' %
    if strcmp('checked', lower(fieldText))
      form.comment = sprintf('Not Functional');
    end
  case '2.' %
    if strcmp('checked', lower(fieldText))
      form.comment = sprintf('Partially Functional');
    end
  case '3.' %
    if strcmp('checked', lower(fieldText))
      form.comment = sprintf('Fully Functional');
    end
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
