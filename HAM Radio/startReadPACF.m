function [err, errMsg, modName, form, printed, printer,...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint, addressee, originator]...
  = startReadPACF(mfilename_caller, receivedFlag, pathDirs, printer, formCoreName, msgFname, fid, outpostHdg);
% function [err, errMsg, modName, form, printed, printEnable, copyList, numCopies, ...
%     formField, h_field, textLine, fieldsFound, spaces, textToPrint]...
%   = startReadPACF(mfilename_caller, receivedFlag, pathDirs, printer, formCoreName, msgFname, fid);
%Common function used by all PACF decoder modules:
%  skips through the PACF file header - returns "textLine" with the contents of the first
%   line that doesn't start with "#".
%  modName set to ">(mfilename_ caller)"
%  loads the on-screen form for the given form via readPrintCnfg (& whatever it calls).  
%    * If the form is a multiple page form, that routine will load all pages each into its own form.
%    * Loads the structures "formField" & "h_field"
%  reads in the desired printing conditions.
%  initializes the structure "form" which is the information that is pulled from the form for
%    display in the eLogger.
%  for use with pre-printed forms, loads the string "spaces" & the array "textToPrint"
%    (only implemented in the calling program that handles ICS213 as of 12/10)
%INPUT
%  formCoreName: core name for .mat, .jpg, & alignment<core>.txt
%    The proper "current" file(s) for the PACF are automatically detected 
%     & used because the file format of the stored files is 
%     <formCoreName>[_yrmoda]<.ext> or *Align<formCoreName>[_yrmoda]<.ext>
%     where _yrmoda is optional & if present is first year month and day
%       contained in the PACF ASCII text that uses this file.
%    The file <formCoreName><.ext> is used if:
%      (1) the PACF doesn't contain a date
%      (2) there are no files containing _yrmoda in their name
%      (3) the PACF date is earlier than any _yrmoda file
%    ex: caller: 'Resource Request #9A', 
%        2 files found: 'Resource Request #9A.mat' & 'Resource Request #9A_110226.mat' 
%        will cause either 'Resource Request #9A_110226.mat' when form's revision date is on or after 110226,
%                  or 'Resource Request #9A.mat' otherwise
%errMsg is set the revision statement line in the header of the PACFORM unless there is an error:
%     errMsg.textLine = textLine;
%     errMsg.pacfVer char as extract from textLine
%     errMsg.pacfYrMoDa  # as extracted
%  ex: textLine = '# JS-ver. 1.1, 03-29-10'  -> pacfVer ='', pacfYrMoDa = 100329
%  ex: textLine = '# JS-ver. 1.1.2, 07-23-10, PR34'  -> pacfVer ='PR34', pacfYrMoDa = 100329

[err, errMsg, modName] = initErrModName(mfilename_caller) ;
[form, printed] = clearFormInfo;

spaces = '';
textToPrint = {};
addressee = '';
originator = '';

% % if nargin < 7
% %   h_field = 0;
% % end

fCoreName.image = formCoreName;
fCoreName.formAlign = sprintf('formAlign_%s', formCoreName);
fCoreName.printerAlign = sprintf('printerAlign_%s', formCoreName);
fCoreName.mat = formCoreName;


%perform a directory listing for each file type to determine dates
% The function returns a list of the file names & the yrMoDa extracted 
%  from the name.  This is a cell where the odd entries are the names
%  and the even the numbers (dates).  If there is only one file found,
%  the returned variable is a simnple char.  
% The results are used below by the local function "dateNameToUse"
[matList] = dirFileList(sprintf('%s%s*.mat', pathDirs.addOns, formCoreName));
[formAlignList] = dirFileList(sprintf('%sformAlign_%s*.txt', pathDirs.addOns, formCoreName));
[printerAlignList] = dirFileList(sprintf('%sprinterAlign_%s*.txt', pathDirs.addOns, formCoreName));
[imageList] = dirFileList(sprintf('%s%s*.jpg', pathDirs.addOnsPrgms, formCoreName));

% get the version and skip through the comment/heading
textLine = '#' ;
while (1==findstrchr('#', strtrim(textLine)) & ~feof(fid))
  textLine = fgetl(fid);
  if findstrchr('# js-ver', lower(textLine))
    commasAt = findstrchr(',', textLine);
    [err, errMsg, pacfDate] = extractTextFromCSVText(textLine, commasAt, 1);
    if length(pacfDate)
      dashAt = findstrchr('-', pacfDate);
      [err, errMsg, mo] = extractTextFromCSVText(pacfDate, dashAt, 0);
      [err, errMsg, da] = extractTextFromCSVText(pacfDate, dashAt, 1);
      [err, errMsg, yr] = extractTextFromCSVText(pacfDate, dashAt, 2);
      [yrmoda] = dateYrMoDaStr2Val(yr, mo, da);
    else
      yrmoda = 0;
    end %if length(pacfDate) else
    fCoreName.image = dateNameToUse(imageList, yrmoda);
    fCoreName.formAlign = dateNameToUse(formAlignList, yrmoda);
    fCoreName.printerAlign = dateNameToUse(printerAlignList, yrmoda);
    fCoreName.mat = dateNameToUse(matList, yrmoda);
    [err, errMsg, pacfVer] = extractTextFromCSVText(textLine, commasAt, 0);
    a = '# js-ver';
    b = findstrchr(a, lower(pacfVer));
    pacfInfo.textLine = textLine;
    pacfInfo.pacfVer = strtrim(pacfVer(b(1)+length(a)+1:length(pacfVer)));
    pacfInfo.pacfYrMoDa = yrmoda;
  end % if findstrchr('# JS-ver', textLine)
end % while (1==findstrchr('#', strtrim(textLine)) & ~feof(fid))

[err, errMsg, formField, h_field, printed, printer] = readPrintCnfg(receivedFlag, pathDirs, printer, fCoreName, msgFname, outpostHdg);
if err
  printer.printEnable = 0;
  errMsg = strcat(modName, errMsg);
  fprintf('\n%s', errMsg);
end % if err
fieldsFound = 0;


if printer.printEnable
  spaces([1:80]) = ' ';
  % initialize the text output array used in pre-printed forms
  a = 0;
  for pgNdx = 1:size(formField, 1)
    b = find(ismember({formField(pgNdx,:).digitizedName}, 'Footer'));
    if length(b)
      a = max(a, b);
    end
  end
  textToPrint([1:ceil(formField(a).lftTopRhtBtm(4))]) = {''};
end % if printer.printEnable

if ~err & ~length(errMsg)
  errMsg = pacfInfo;
end

%--------------------------
function fnameToUse = dateNameToUse(nameList, yrmoda)
% Given a list of the file names & the yrMoDa extracted 
%  from the name, returns the file name with a date
%  not later than the passed in yrMoDa.  Note: file name
%  without path & without extension!
%INPUT:
%  nameList: This is a cell where the odd entries are the names
%    and the even the numbers (dates).  If there is only one file found,
%    it is a simnple char. (Comes from function "dirFileList")
%  yrmoda: PACF revision date as number for the current PACF

if iscell(nameList)
  %look at the YrMoDa entries...
  for itemp = 2:2:length(nameList)
    % if the YrMoDa of (itemp) is newer than this message...
    if yrmoda < nameList{itemp};
      %... form is newer than message: use previous form!
      itemp = itemp - 2;
      break
    end
  end %for itemp = 2:2:length(nameList)
  % name is the odd entry & we've been looking at the evens
  fnameToUse = nameList{itemp-1};
else
  fnameToUse = nameList;
end
%--------------------------
