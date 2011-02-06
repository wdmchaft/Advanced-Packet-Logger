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

[err, errMsg, modName] = initErrModName(mfilename_caller) ;
[form, printedName, printedNamePath] = clearFormInfo;

spaces = '';
textToPrint = {};
% % if nargin < 7
% %   h_field = 0;
% % end

[err, errMsg, printEnable, copyList, numCopies, formField, h_field] = readPrintCnfg(receivedFlag, pathDirs, printMsg, formCoreName, msgFname);
if err
  printEnable = 0;
  errMsg = strcat(modName, errMsg);
  fprintf('\n%s', errMsg);
end
fieldsFound = 0;

% skip through the comment/heading
textLine = '#' ;
while (1==findstrchr('#', strtrim(textLine)) & ~feof(fid))
  textLine = fgetl(fid);
end

if printEnable
  spaces([1:80]) = ' ';
  % initialize the text output array used in pre-printed forms
  textToPrint([1:ceil(formField(find( ismember({formField.digitizedName}, 'Footer') )).lftTopRhtBtm(4))]) = {''};
end

