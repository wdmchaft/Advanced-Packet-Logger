%testPACF
fprintf('\n=================================================');
dirsToCheck = {'C:\Program Files (x86)\Outpost\archive\SentTray\',...
    'C:\Program Files (x86)\Outpost\archive\InTray\'} ;
dirsToCheck = {'F:\Program Files\Outpost\archive\TestFiles\'};
typeFound = [];

receivedFlag = 1;
PathConfig = '';
printMsg = 0; 
printer = '';

for itemp = 1:length(dirsToCheck)
  thisDir = char(dirsToCheck(itemp));
  dirList = dir(strcat(thisDir,'*.mss')) ;
  d = dir(strcat(thisDir,'*.txt'));
  dirList(length(dirList)+[1:length(d)]) = d;
  for fileNdx = 1:length(dirList)
    if findstrchr('.', dirList(fileNdx).name) ~= 1
      fname = dirList(fileNdx).name;
      fpathName = strcat(endWithBackSlash(thisDir), fname);
      fid = fopen(fpathName,'r');
      textLine = '';
      while ~findstrchr('subject', lower(textLine)) & ~feof(fid)
        textLine = fgetl(fid);
      end
      if feof(fid)
        fprintf('\r\n*** No "subject" found in %s ', dirList(fileNdx).name);
        edit(fpathName);
      else
        PACF = detectPacFORM(fid);
        % this will get overridden if the form has a module here to reformat it. 
        if PACF
          [err, errMsg, pacfListNdx, thisForm, textLine] = getPACFType(fid);
          if ~length(find(pacfListNdx == typeFound))
            typeFound(length(typeFound)+1) = pacfListNdx;
            fprintf('\r\nFile "%s". . ', dirList(fileNdx).name);
            % % fprintf('\r\n  PACF = %i', PACF);
            fprintf('\r\n  pacfListNdx = %i', pacfListNdx);
            fprintf(' err = %i, errMsg = %s, thisForm = %s', err, errMsg, thisForm);
      %needs to be same order as List in "getPACFType"
      switch pacfListNdx
      case 1 % 'CITY-SCAN UPDATE FLASH REPORT'
        [err, errMsg, printedName, printedNamePath, form] = cityScanFlash(fid, fpathName, receivedFlag, PathConfig, printMsg, printer);
      case 2 % 'SC COUNTY LOGISTICS', ...
        [err, errMsg, printedName, printedNamePath, form] = logisticsRequest(fid, fpathName, receivedFlag, PathConfig, printMsg, printer);
      case 3 % 'EOC MESSAGE FORM',  ...
        [err, errMsg, printedName, printedNamePath, form] = print_ICS_213(fid, fpathName, receivedFlag, PathConfig, printMsg, printer);
      case 4 % 'CITY MUTUAL AID REQUEST',  ...
        [err, errMsg, printedName, printedNamePath, form] = cityMAR(fid, fpathName, receivedFlag, PathConfig, printMsg, printer);
      case 5 % 'SHORT FORM HOSPITAL STATUS',  ...
        [err, errMsg, printedName, printedNamePath, form] = shortHospitalStatus(fid, fpathName, receivedFlag, PathConfig, printMsg, printer);
      case 6 % 'HOSPITAL STATUS',  (see also #10 which is the next version of this PacFORM)
        [err, errMsg, printedName, printedNamePath, form] = doc9HospitalStatus(fid, fpathName, receivedFlag, PathConfig, printMsg, printer);
      case 7 % 'HOSPITAL-BEDS',  ...
        [err, errMsg, printedName, printedNamePath, form] = doc9BedStatus(fid, fpathName, receivedFlag, PathConfig, printMsg, printer);
      case 8 % 'OES MISSION REQUEST',  ...  strcmp
        [err, errMsg, printedName, printedNamePath, form] = oesMissionRequest(fid, fpathName, receivedFlag, PathConfig, printMsg, printer);
      case 9 % 'SEMS SITUATION'
        [err, errMsg, printedName, printedNamePath, form] = semsSitReport(fid, fpathName, receivedFlag, PathConfig, printMsg, printer);
      case 10 % FORM DOC-9 HOSPITAL-STATUS REPORT  (see also #6 which is the previous version of this PacFORM)
        [err, errMsg, printedName, printedNamePath, form] = doc9HospitalStatusReport(fid, fname, receivedFlag, PathConfig, printMsg, printer);
      case 11 % RESOURCE REQUEST FORM #9A
        [err, errMsg, printedName, printedNamePath, form] = resourceRequestForm9A(fid, fname, receivedFlag, PathConfig, printMsg, printer);
      case 12 % 'FORM DOC-9 BEDS HOSPITAL-STATUS REPORT'
        [err, errMsg, printedName, printedNamePath, form] = doc9bedsHospitalStatusReport(fid, fname, receivedFlag, PathConfig, printMsg, printer);
      otherwise
        %form not in recognized list.  We'll log it even though we don;t know how to extract information from it
        err = 0;
      end % switch pacfListNdx
      form.type = thisForm ;
      form
            if err
              edit(fpathName);
            end
          end
        end
      end
      fcloseIfOpen(fid);
    end
  end
end

% pacfList(1,:) = {...,
%     'CITY-SCAN UPDATE FLASH REPORT', ...
%     'SC COUNTY LOGISTICS', ...
%     'EOC MESSAGE FORM',  ...
%     'CITY MUTUAL AID REQUEST',  ...
%     'SHORT FORM HOSPITAL STATUS',  ...
%     'HOSPITAL STATUS',  ...
%     'HOSPITAL-BEDS',  ...
%     'OES MISSION REQUEST',  ...
%     'SEMS SITUATION'
% };
