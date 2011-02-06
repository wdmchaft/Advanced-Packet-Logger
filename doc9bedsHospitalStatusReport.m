function [err, errMsg, printedName, printedNamePath, form] = doc9bedsHospitalStatusReport(fid, fname, receivedFlag, pathDirs, printEnable, printer, outpost, h_field);

%used for the 03-30-10 & later version
% for earlier, "doc9BedStatus" is used

% !PACF! origMsg#_U/I_Doc9beds_FACILITY NAME
% # FORM DOC-9 BEDS HOSPITAL-STATUS REPORT 
% # Js-ver. 3.4, 03-30-10
% # FORMFILENAME: doc9-beds.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% A.: [sndrMsg#]
% MsgNo: [origMsg#]
% C.: [rcvrMsg#]
% D.: [URGENT]
% E.: [IMMEDIATE]
% F.: []
% replyby: []
% facnam: [FACILITY NAME]
% date: [04/16/2010]
% time: [1423]
% contact: [Contact Name]
% phone: [Phone #]
% fax: [Fax #]
% other: []
% stat: [1]
% 

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
  case 'facnam' %
    form.subject = fT ;
  case 'date' %
    form.date = fT;
  case 'time' %
    form.time = fT;
  case 'stat' %
    switch fT
    case '1'
      form.comment = 'Not Functional';
    case '2'
      form.comment = 'Partially Functional';
    case '3'
      form.comment = 'Fully Functional';
    otherwise
      form.comment = sprintf('status "%s" unrecognized', fT);
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
