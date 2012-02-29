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
printerSetup.printEnable = 1;
printMsg = printEnable;

fprintf('\n''%s''', fpathName);
edit(fpathName)
fprintf('\nOpening: %s', fpathName);
[pathstr,name,ext,versn] = fileparts(fpathName)
pname = endWithBackSlash(pathstr);
fname = sprintf('%s%s', name, ext);

% %use the setup established for automatic printing:
% [err, errMsg, printerSetup] = readPrintINI(outpostValByName('DirAddOns', outpostNmNValues), printerSetup, receivedFlag);
% "printerSetup" structure 
%   printerSetup.HPL3: numeric
%   printerSetup.printerPort: string (eg LPT1:)
%   printerSetup.copyList 
%   printerSetup.printEnable: numeric
%    0: printer disabled
%    1: pre-printed form in printer & printer enabled. may be reset by the INI files - cannot be set by the INI file.
%       i.e.: to print this passed in variable must be set AND if the INI file is found and has a value for print 
%       enable, it must to set.  No printing will occur if the file doesn't exist, doesn't contain printEnable, 
%       or if its value for printEnable is cleared.
%    2: blank paper in printer, printer enable -> data will be loaded into form, printer 
%       activated for <# of copies> (loaded from 'print_ICS_213.ini'), and the form will be closed.
%    3: printer disabled, enable data displayed on screen
%   printerSetup.numCopies 
%   -1: print all in list [default]
%    0: print none regardless of printEnable
%   >0: print that many copies up but no more than in the list

%printerSetup.printEnable = 2 ; printerSetup.numCopies = -1;
[err, errMsg, outpostHdg, printed, form] ...
  = processMessage(pname, fname, '', outpostNmNValues, printerSetup, receivedFlag);
