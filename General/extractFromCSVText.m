function [err, errMsg, value] = extractFromCSVText(textLine, commasAt, commaToUse)
%function [err, errMsg, value] = extractFromCSVText(textLine, commasAt, commaToUse)
%extracts the specified value from 'textLine' 
%INPUT:
% textLine: contains the informatio
% commasAt: numerical array containing the locations of all the commas in 'textLine'
%    If the information in 'textLine' is separated by something other than commas,
%    this variable would contain the location of what ever is used as a separator
% commaToUse: the indexs array into 'commasAt' that is at the value of interest
%    If invalid (i.e. < 1), function will return '-1' as the value
%OUTPUT:
% value: the extracted value or
%  -1 if commaToUse is invalid
%   0 if the specified location is beyond the end of 'textLine'  This occurs if there is no vision data.
% err: 0 if valid number
%VSS revision   $Revision: 6 $
%Last checkin   $Date: 12/23/04 1:32p $
%Last modify    $Modtime: 12/23/04 1:31p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

modName = '>extractFromCSVText';
[err, errMsg, text] = extractTextFromCSVText(textLine, commasAt, commaToUse);
if err
  errMsg = strcat(modName, errMsg);
  value = 0;
else
  %if not purely a numeric set
  if find(text == ':')
    text = '';
  end
  value = str2num(text);
  if length(value) < 1
    err = 1;
    errMsg = strcat(modName, ': not a number.');
  end
end