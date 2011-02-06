function [err, errMsg, printedName, printedNamePath, form] = shortHospitalStatus(fid, msgFname, receivedFlag, pathDirs, printMsg, printer, outpost, h_field);

% !PACF!
% # SHORT FORM HOSPITAL STATUS 
% # JS-ver. 1.1, 09-28-09
% # FORMFILENAME: DEOC9Short.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% 1.: [facility name]
% 2.: [11/16/2009]
% 3.: [1714]
% 4.: [contact name]
% 5.: [phone #]
% 6.: [fax #]
% 7.: [other phone, fax, cell, radio]
% 8.: [Limited]
% 9.: [HCC MAIN CONTACT NUMBER]
% 10.: [HCC MAIN CONTACT FAX]
% 11.: [NAME LIAISON TO PUBLIC HEALTH/MEDICAL  HEALTH BRANCH]
% 12.: [CONTACT NUMBER]
% 13.: [INFORMATION OFFICER NAME]
% 14.: [CONTACT NUMBER]
% 15.: [CONTACT EMAIL]
% 16.: [IF HCC IS NOT ACTIVATED, WHO  SHOULD BE CONTACTED  FOR QUESTIONS / REQUESTS]
% 17.: [CONTACT NUMBER]
% 18.: [CONTACT EMAIL]
% 19.: [ambul evac]
% 20.: [non-abul evac]
% 21.: [patient treate & release]
% 22.: [patients admitted last 12]
% 23.: [patients not yet seen]
% 24.: [OTHER PATIENT CARE INFORMATION]
% 25.: []
% 26.: [checked]
% 27.: []
% 28.: [checked]
% 29.: []
% 30.: [GENERAL SUMMARY OF SITUATION / CONDITIONS; 25-29 are attachments
%  provided]
% q33_8: [bed adult 8]
% q33_8c: [checked]
% q33_24c: []
% q33_24: [bed adult  24]
% q34_8: [med beds 8]
% q34_8c: [checked]
% q34_24c: [checked]
% q34_24: [med beds 24]
% q35_8: [surg bed 8]
% q35_8c: []
% q35_24c: [checked]
% q35_24: [surg bed 24]
% q36_8: [ob/gyn bed 8]
% q36_8c: []
% q36_24c: []
% q36_24: [ob/gyn bed 24]
% q37_8: [burn bed 8]
% q37_8c: []
% q37_24c: []
% q37_24: [burn bed 24]
% q38_8: [pedia bed 8]
% q38_8c: []
% q38_24c: []
% q38_24: [pedia bed 24]
% q39_8: [psych bed 8]
% q39_8c: []
% q39_24c: []
% q39_24: [psych bed 24]
% #EOF

[err, errMsg, modName] = initErrModName(mfilename) ;
[form, printedName, printedNamePath] = clearFormInfo;
if nargin < 7
  h_field = 0;
end
[err, errMsg, printEnable, copyList, numCopies, formField, h_field] = readPrintCnfg(receivedFlag, pathDirs, printMsg, 'hospitalStatusReportShort', msgFname);
if err
  printEnable = 0;
  errMsg = strcat(modName, errMsg);
  fprintf('\n%s', errMsg);
end
fieldsFound = 0;

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
  case '1.' %
    form.subject = fT ;
    fieldsFound = fieldsFound + 1;
  case '2.' %
    form.date = fT;
    fieldsFound = fieldsFound + 1;
  case '3.' %
    form.time = fT;
    % % form.subject = sprintf('%s %s;', form.subject, fieldText);
    fieldsFound = fieldsFound + 1;
  case '4.' %
    %only for printing - don't count
    originator = fT;
  case '8.' 
    form.comment = fT ;
    fieldsFound = fieldsFound + 1;
    % form.comment = sprintf('Command Center Status: ', fT);
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
  if printEnable 
    [err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '') ;
  else % if printMsg 
    %If we are not printing and we've found all the desired fields
    %  presuming each fieldID occurs only once in the message
    if (fieldsFound > 10)
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
