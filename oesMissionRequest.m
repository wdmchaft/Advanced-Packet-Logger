function [err, errMsg, printedName, printedNamePath, form] = oesMissionRequest(fid, fname, receivedFlag, pathDirs, printEnable, printer, outpost, h_field);

% !PACF!
% # OES MISSION REQUEST 
% # PACRIMS JS-ver. 4.1, 10-17-09
% # FORMFILENAME: OESMissionReq.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% A: [mission number]
% B: [Black-Flash]   % threat
% C: [Purple-Coordinating] % status
% D: [11/16/2009 07:04 PM]
% 1a: [City]
% 1b: [use this field]  % If City or Special District Use This Field 
% 1c: [Requestor Agency: Name: Position: Phone: Fax: Pager: Cell:
% ]
% 1d: [Situation: Related Event/ Incident/Activity:]
% 2a: [Requested Mission]
% 2b: [Flood Fight]
% 2c: [needed by date]
% 2d: [checked]
% 2e: [checked]
% 2f: [checked]
% 2g: [checked]
% 2h: [checked]
% 2i: [checked]
% 2j: [checked]
% 2k: [other]
% 4a: [Site Name]
% 4b: [Site Type]
% 4c: [Street Address]
% 4d: [Apt]
% 4e: [city]
% 4f: [CA]
% 4g: []
% 4h: [United States]
% 4i: [Intersection - Street 1]
% 4j: [Intersection - Street 2]
% 4k: [county]
% 4l: [Geographic Area]
% 4m: [Additional Location Information]
% 5a: [Geo Located By]
% 5b: [Latitude]
% 5c: [Longitude]
% 5d: [Contact on scene]
% 6: [Special Instructions]
% 7a: [OES Individual]
% 7b: [Organization/Location]
% 7c: [Position]
% 7d: [Agency]
% 7e: [Summary of OES actions taken]
% 8a: [CAL TRANS]
% 8b: [RESPONDING Agency other]
% 8c: [Agency POC]
% 8d: [phone]
% 8e: [Fax Number]
% 8f: [Pager/Alt#]
% 8g: [other]
% 8h: [Summary of actions taken]
% 8i: [Est.Cost]
% 9a: [distribution group]
% 9b: [distribution individual]
% 10a: [No]
% 10b: [NOTIFICATION Message]
% 10c: [List Recipients]
% 10d: [Notification List]
% 10e: [Other Email addresses]
% 11: [DATA SHARING Comment]
% 12: [ATTACHMENTS Web Pages]
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
  case 'A' 
    % activation number
  case 'B' 
    form.comment = sprintf('%sThreat:%s ', form.comment, fT);
  case 'C' 
    form.comment = sprintf('%sStatus:%s ', form.comment, fT);
  case 'D'
    % format is "[11/16/2009 07:04 PM]" & is in 12 hour format: decode & convert to 24 hour
    [err, errMsg, form.date, form.time] = dateTimeSplit(fT) ;
  case {'1a', '1b', '2b'} % City, If City or Special District Use This Field, WHAT IS BEING REQUESTED? *Type
    form.subject = sprintf('%s%s; ', form.subject, fT);
  case 'A.0'
    form.senderMsgNum = fT ;
  case 'MsgNo'
    form.MsgNum = fT ;
  case 'C.0'
    form.receiverMsgNum = fT ;
  case 'D.0'
    form.sitSevere = fT ;
  case 'E.0'
    form.handleOrder = fT ;
  case 'F.0'
    form.replyReq = fT; 
  case 'replyby'
    form.replyWhen = fT ;
  otherwise
  end
  %determine where this fieldID is in our list:
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message

fcloseIfOpen(fid);
