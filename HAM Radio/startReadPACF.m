function [err, errMsg, modName, form, printedName, printedNamePath, printEnable, copyList, numCopies, ...
    formField, h_field, textLine, fieldsFound, spaces, textToPrint]...
  = startReadPACF(mfilename_caller, receivedFlag, pathDirs, printMsg, formCoreName, msgFname, fid);
% function [err, errMsg, modName, form, printedName, printedNamePath, printEnable, copyList, numCopies, ...
%     formField, h_field, textLine, fieldsFound, spaces, textToPrint]...
%   = startReadPACF(mfilename_caller, receivedFlag, pathDirs, printMsg, formCoreName, msgFname, fid);
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
[form, printedName, printedNamePath] = clearFormInfo;

spaces = '';
textToPrint = {};
% % if nargin < 7
% %   h_field = 0;
% % end

fCoreName.image = formCoreName;
fCoreName.formAlign = formCoreName;
fCoreName.printerAlign = formCoreName;
fCoreName.mat = formCoreName;


%perform a directory listing for each file type to determine dates
[matList] = dirFileList(sprintf('%s%s*.mat', pathDirs.addOns, formCoreName));
[formAlignList] = dirFileList(sprintf('%sformAlign_%s*.txt', pathDirs.addOns, formCoreName));
[printerAlignList] = dirFileList(sprintf('%sprinterAlign_%s*.txt', pathDirs.addOns, formCoreName));
[imageList] = dirFileList(sprintf('%s%s*.jpg', pathDirs.addOnsPrgms, formCoreName));

% get the version and skip through the comment/heading
textLine = '#' ;
while (1==findstrchr('#', strtrim(textLine)) & ~feof(fid))
  textLine = fgetl(fid);
  if findstrchr('# JS-ver', textLine)
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
    [err, errMsg, pacfVer] = extractTextFromCSVText(textLine, commasAt, 2);
    pacfInfo.textLine = textLine;
    pacfInfo.pacfVer = strtrim(pacfVer);
    pacfInfo.pacfYrMoDa = yrmoda;
  end % if findstrchr('# JS-ver', textLine)
end % while (1==findstrchr('#', strtrim(textLine)) & ~feof(fid))

[err, errMsg, printEnable, copyList, numCopies, formField, h_field] = readPrintCnfg(receivedFlag, pathDirs, printMsg, fCoreName, msgFname);
if err
  printEnable = 0;
  errMsg = strcat(modName, errMsg);
  fprintf('\n%s', errMsg);
end % if err
fieldsFound = 0;


if printEnable
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
end % if printEnable

if ~err & ~length(errMsg)
  errMsg = pacfInfo;
end

%--------------------------
function fnameToUse = dateNameToUse(nameList, yrmoda)
if iscell(nameList)
  for itemp = 2:2:length(nameList)
    if yrmoda < nameList{itemp};
      itemp = itemp - 2;
      break
    end
  end %for itemp = 2:2:length(nameList)
  fnameToUse = nameList{itemp-1};
else
  fnameToUse = nameList;
end
%--------------------------
