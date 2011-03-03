function testForm(fpathName);

%for HP W7 laptop:
% testform('C:\Outpost Oct 2010 drills\XSC\archive\InTray\R_101023_145451_XSC021_O~R_ICS213_Version_Info.mss')

%for HP W98 laptop:
% testform('D:\Outpost Oct 2010 drills\XSC\archive\InTray\R_101023_145451_XSC021_O~R_ICS213_Version_Info.mss')

%     'S_100628_154942_SER224;_CITY-SCAN_UPDATE_FLASH_REPORT.txt'
% ans = 
%     'S_100628_160751_SER225;_SC_COUNTY_LOGISTICS_REQUEST_FORM.txt'

[err, errMsg, outpostNmNValues, outpostVarNameList] = OutpostINItoScript;
if (nargin < 1)
  %list of all formats supported by "imread"
  a = {'*.mss','Logger messages',...
      '*.txt','Windows Cursor resources',...
    };
  b = char(a(1));
  for itemp = 3:2:length(a)
    b = sprintf('%s;%s', b, char(a(itemp)) );
  end
  fileMask = {b,sprintf('All supported PACF text (ASCII) files (%s)',b)};
  for itemp = 1:2:length(a)
    b = size(fileMask,1)+1 ;
    c = char(a(itemp));
    fileMask(b,1) = {sprintf('%s', c) };
    fileMask(b,2) = {sprintf('%s (%s)',char(a(itemp+1)), c) };
  end
  
  fid = fopen(strcat(mfilename,'.mat'));
  if fid < 0
    pacfTxtDir = outpostValByName('DirArchive', outpostNmNValues);
  else
    fclose(fid)
    load(strcat(mfilename,'.mat'));
    pacfTxtDir = pname;
  end
  
  origDir = pwd;
  cd(pacfTxtDir)
  [fname,pname] = uigetfile(fileMask, 'PACF ASCII File');
  cd(origDir)
  if isnumeric(fname);
    if fname < 1
      fprintf('\nUser cancel.');
      return
    end
  end
  
  fpathName = strcat(pname,fname);
  save(strcat(mfilename,'.mat'), 'fpathName', 'pname','fname');
end

%someday will replace this with actual extractor, currently located in "processOutpostPacketMessages"
%  Need to move that to its own routine so manual printing is available.
outpost.dateTime = '';

receivedFlag = (0 < findstrchr(lower('InTray'), lower(fpathName)));
pathAddOns = outpostValByName('DirAddOns', outpostNmNValues);
pathPrgms = outpostValByName('DirAddOnsPrgms', outpostNmNValues);
printEnable = 3;
printer.printEnable = 1;
printMsg = printEnable;

pathDirs.addOns = pathAddOns;
pathDirs.addOnsPrgms = pathPrgms;
pathDirs.DirPF = outpostValByName('DirPF', outpostNmNValues);
fprintf('\n''%s''', fpathName);
edit(fpathName)
fprintf('\nOpening: %s', fpathName);
fid = fopen(fpathName,'r');
if fid<1
  fprintf('\n Unable to open %s', fpathName);
  return
end
[PACF, linesRead] = detectPacFORM(fid, 0, 100);

if ~PACF
  %not a PACForm
  
  % log as a "simple" message
  form.type = 'Simple' ;
  % % form.time = 'n/a';
  if printMsg 
    %the process of checking if PACF moved us within the file - restore
    fseek(fid, fpPosition, 'bof');
    [err, errMsg, printedNamePath, printedName] = printSimple(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, form, outpost);
  end  
  % print (if enabled)
else % if ~PACF
  %This is a PACF:
  [err, errMsg, pacfListNdx, thisForm, textLine] = getPACFType(fid);
  fpPACPosition = ftell(fid);
  %needs to be same order as List in "getPACFType"
  switch pacfListNdx
  case 1 % 'CITY-SCAN UPDATE FLASH REPORT'
    [err, errMsg, printedName, printedNamePath, form] = cityScanFlash(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost);
  case 2 % 'SC COUNTY LOGISTICS', ...
    [err, errMsg, printedName, printedNamePath, form] = logisticsRequest(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost);
  case 3 % 'EOC MESSAGE FORM',  ...
    [err, errMsg, printedName, printedNamePath, form] = print_ICS_213(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost, outpostNmNValues);
  case 4 % 'CITY MUTUAL AID REQUEST',  ...
    [err, errMsg, printedName, printedNamePath, form] = cityMAR(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost);
  case 5 % 'SHORT FORM HOSPITAL STATUS',  ...
    [err, errMsg, printedName, printedNamePath, form] = shortHospitalStatus(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost);
  case 6 % 'HOSPITAL STATUS',  (see also #10 which is the next version of this PacFORM)
    [err, errMsg, printedName, printedNamePath, form] = doc9HospitalStatus(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost);
  case 7 % 'HOSPITAL-BEDS',  ...
    [err, errMsg, printedName, printedNamePath, form] = doc9BedStatus(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost);
  case 8 % 'OES MISSION REQUEST',  ...  strcmp
    [err, errMsg, printedName, printedNamePath, form] = oesMissionRequest(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost);
  case 9 % 'SEMS SITUATION'
    [err, errMsg, printedName, printedNamePath, form] = semsSitReport(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost, outpostNmNValues);
  case 10 % FORM DOC-9 HOSPITAL-STATUS REPORT  (see also #6 which is the previous version of this PacFORM)
    [err, errMsg, printedName, printedNamePath, form] = doc9HospitalStatusReport(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost);
  case 11 % RESOURCE REQUEST FORM #9A
    [err, errMsg, printedName, printedNamePath, form] = resourceRequestForm9A(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost, outpostNmNValues);
  case 12 % 'FORM DOC-9 BEDS HOSPITAL-STATUS REPORT'
    [err, errMsg, printedName, printedNamePath, form] = doc9bedsHospitalStatusReport(fid, fpathName, receivedFlag, pathDirs, printMsg, printer, outpost, outpostNmNValues);
  otherwise
    %form not in recognized list.  We'll log it even though we don;t know how to extract information from it
    err = 0;
  end % switch pacfListNdx
  form.type = thisForm ;
  if err
    errMsg = strcat(mfilename, errMsg);
    if (nargout < 1)
      fprintf('Error: %i %s', err, errMsg);
      clear err
    end
    break
  end
end % if ~PACF else
fcloseIfOpen(fid);
