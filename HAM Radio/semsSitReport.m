function [err, errMsg, printedName, printedNamePath, form] = semsSitReport(fid, msgFname, receivedFlag, pathDirs, printMsg, printer, outpost, outpostNmNValues, h_field);

% !PACF!
% # SEMS SITUATION REPORT 
% # PACRIMS JS-ver. 3.3, 10-17-09
% # FORMFILENAME: Sit-Rpt-js.html
% # Form Item numbers are followed by a colon (:)
% # Answers are enclosed in brackets ( [ ] )
% 1.: [City]    % Juristiction
% 2.: [Santa Clara - Mountain View]
% 3.: [Red-Assistance Required]
% 4.: [Improving]
% 5.: [Related Event/ Incident/Activity]
% 5a.: [11/19/2009 08:19 AM]
% 6.: [INITIAL SITUATION SUMMARY]
% 7.: [Road Problem Summary's]
% 8.: [Communications Problem]
% 9.: [Other Concerns/Problems]
% 10a.: [Local Date Requested]
% 10b.: [Intermediate Date Requested]
% 10c.: [Gubernatorial Date Requested]
% 10d.: [Presidential Date Requested]
% 11a.: [Local Date Granted]
% 11b.: [Intermediate Date Granted]
% 11c.: [Gubernatorial Date Granted]
% 11d.: [Presidential Date Granted]
% 12.: [Intermediate Level]
% 13a.: [EstFatalities]
% 13b.: [CnfFatalities]
% 13c.: [Comments Fatalities]
% 14a.: [EstimInjuries]
% 14b.: [CnfInjuries]
% 14c.: [Comments Injuries]
% 15a.: [DesResidences]
% 15b.: [MajResidences]
% 15c.: [MinResidences]
% 15d.: [AffResidences]
% 15e.: [CostResidences]
% 15f.: [InsuredResidences]
% 16a.: [DestrBusiness]
% 16b.: [MajorBusiness]
% 16c.: [MinorBusiness]
% 16d.: [AffecBusiness]
% 16e.: [CostBusiness]
% 16f.: [InsuredBusiness]
% 17a.: [DesGovernment]
% 17b.: [MajGovernment]
% 17c.: [MinGovernment]
% 17d.: [AffGovernment]
% 17e.: [CostGovernment]
% 17f.: [InsuredGovernment]
% 18.: [$0]
% CATAa.: [#Debris Rem]
% CATAb.: [Debris Remova]
% CATBa.: [#Protective]
% CATBb.: [Protective Me]
% CATCa.: [#Road Bridge]
% CATCb.: [Road and Bri]
% CATDa.: [#WaterCntrl]
% CATDb.: [Water Contro]
% CATEa.: [#PublicBuild]
% CATEb.: [Public Buildi]
% CATFa.: [#Public Util]
% CATFb.: [Public Utili]
% CATGa.: [#Park/Rec]
% CATGb.: [Park/Rec]
% 19a.: [0]
% 19b.: [$0]
% 20.: [Number of People Evacuated]
% 21.: [Number of People in Shelters]
% 22.: [Comments]
% 23.: [EOC(s) ACTIVATED ?  Comments]
% 24.: [EOC(s) ACTIVATED ?  Contact Info: (Name, Phone, etc.)]
% 25.: [Site Name]
% 26.: [Executive Home]
% 27.: [Street Address]
% 28.: [Apt o]
% 29.: [City]
% 30.: [CA]
% 31.: [94040]
% 32.: [Intersection - Street 1]
% 33.: [Intersection - Street 2]
% 34.: [County]
% 35.: [Geographic Area (Region, District, Campus, etc)]
% 36.: [Additional Location Information]
% 37a.: [Geo Located By]
% 37b.: [Latitude]
% 37c.: [Longitude]
% 38.: [Branch Managers, Coastal Region, Duty Officers - 4C Exec
% ]
% 39.: [Individual]
% 40.: [No]
% 41.: [Message 	(max. 140 characters for mobile users)]
% 42.: [Notification List]
% 43.: [Other Email addresses]
% 44.: [DATA SHARING Comment]
% 45.: [Supporting File(s): Web Pages]
% #EOF

[err, errMsg, modName, form, printedName, printedNamePath, printEnable, copyList, numCopies, ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint]...
  = startReadPACF(mfilename, receivedFlag, pathDirs, printMsg, 'RIMS SITUATION REPORT', msgFname, fid);

addressee = '';
originator = '';

while 1 % read & detect the field for each line of the entire message
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
  case '2.'  %report jurisdiction:
    % If City, enter County and City; 
    % if County, enter County; 
    % if OES Region, Enter OES Region. 
    form.subject = fT ;
    fieldsFound = fieldsFound + 1;
  case {'3.','4.'} %
    form.comment = sprintf('%s%s; ', form.comment, fT);
    fieldsFound = fieldsFound + 1;
  case '5a.' %
    % format is "[11/16/2009 07:04 PM]" & is in 12 hour format: decode & convert to 24 hour
    [err, errMsg, form.date, form.time] = dateTimeSplit(fT) ;
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
  if printEnable
    [err, errMsg, textToPrint, h_field, formField, moveNeeded] = fillFormField(fieldID, fieldText, formField, h_field, textToPrint, spaces, outpostNmNValues);
  else %if printEnable
    %not printing - exit when we've extracted all we need
    if fieldsFound > 10
      break
    end
  end % if printEnable else
  
  textLine = fgetl(fid);
end % while 1 % read & detect the field for each line of the entire message

fcloseIfOpen(fid);

if (~err & printEnable)
  [err, errMsg, printedNamePath, printedName] = ...
    formFooterPrint(printer, printEnable, copyList, numCopies, h_field, formField, msgFname, originator, addressee, textToPrint, outpost, receivedFlag);
end % if (~err & printEnable)
