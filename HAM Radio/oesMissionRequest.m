function [err, errMsg, printed, form] = oesMissionRequest(fid, msgFname, receivedFlag, pathDirs, printer, outpostHdg, h_field);

% !PACF! MSG#_E/I_OESMis_City of Mountain View if city or special
% # OES MISSION REQUEST 
% # JS-ver. 4.3.2, 07-23-10, PR34
% # FORMFILENAME: OESMissionReq.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% # Note: The symbol ¿ is NOT a bug. It is used in Textarea formatting.
% A.0: [SNDR#]
% MsgNo: [MSG#]
% C.0: [RECVR#]
% D.0: [EMERGENCY]
% E.0: [IMMEDIATE]
% F.0: [Yes]
% replyby: [reply by]
% A: [mission numer]
% B: [Black-Flash]
% C: [Purple-Coordinating]
% D: [03/11/2011 07:20 PM]
% 1a: [City of Mountain View]
% 1b: [if city or special]
% 1c: [¿Agency:¿Name:¿Position:¿Phone:¿Fax:¿Pager:¿Cell:]
% 1d: [related event/incident]
% 2a: [¿requested mission]
% 2b: [Base Camp]
% 2c: [Needed By Date]
% 2d: [checked]
% 2e: [checked]
% 2f: [checked]
% 2g: [checked]
% 2h: [checked]
% 2i: [checked]
% 2j: [checked]
% 2k: [Other:]
% 4a: [Site Name]
% 4b: [Site Type]
% 4c: [Street Address]
% 4d: [Apt o]
% 4e: [City]
% 4f: [CA]
% 4g: [Zip]
% 4h: [United States]
% 4i: [Intersection - Street 1]
% 4j: [Intersection - Street 2]
% 4k: [County]
% 4l: [Geographic Area]
% 4m: [¿Additional Location Information]
% 5a: [Geo Located By]
% 5b: [Latitude]
% 5c: [Longitude]
% 5d: [¿Contact on scene]
% 6: [¿Special Instructions]
% 7a: [Individual]
% 7b: [Organization/Location:]
% 7c: [Position]
% 7d: [Agency]
% 7e: [¿Summary of OES¿actions taken]
% 8a: [AFRCC]
% 8b: [If selection not in list above, enter here]
% 8c: [Agency POC]
% 8d: [Phone]
% 8e: [Fax Number]
% 8f: [Pager/Alt#]
% 8g: [8gOther]
% 8h: [¿Summary of¿actions taken]
% 8i: [Estimated Res]
% 9a: [¿Group]
% 9b: [¿Individual]
% 10a: [No]
% 10b: [¿Message]
% 10c: [¿List Recipients]
% 10d: [¿Notification List]
% 10e: []
% 11: [¿Comment]
% 12: [¿Web Pages]
% #EOF
% 


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

[err, errMsg, modName, form, printed, printer ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint, addressee, originator]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printer, 'OESMissionReq', msgFname, fid, outpostHdg);

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
  if printer.printEnable 
    [err, errMsg, textToPrint] = fillFormField(fieldID, fieldText, formField, h_field, '', '') ;
  end % if printer.printEnable
  %determine where this fieldID is in our list:
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message

fcloseIfOpen(fid);

if (~err & printer.printEnable)
  addressee = 'Planning';
  [err, errMsg, printed] = ...
    formFooterPrint(printer, h_field, formField, msgFname, originator, addressee, textToPrint, outpostHdg, receivedFlag);
end % if (~err & printer.printEnable)
