function [err, errMsg, text] = extractTextFromCSVText(textLine, commasAt, commaToUse)
%function [err, errMsg, text] = extractFromCSVText(textLine, commasAt, commaToUse)
%extracts the specified value from 'textLine' 
%INPUT:
% textLine: contains the information
% commasAt: numerical array containing the locations of all the commas in 'textLine'
%    If the information in 'textLine' is separated by something other than commas,
%    this variable would contain the location of what ever is used as a separator
% commaToUse: the indexs array into 'commasAt' that is at the value of interest
%    if == 0 will extract the text starting at the beginning and going to before the 1st comma
%    If invalid (i.e. < 1, > length(commasAt), or commasAt(commaToUse) > length(textLine)), function will return non-zero err
%OUTPUT:
% text: the extracted text string or a null string if commaToUse is invalid or if the specified 
%   location is beyond the end of 'textLine'  These last two cases will return a non-zero 'err' as well.
%VSS revision   $Revision: 3 $
%Last checkin   $Date: 11/27/02 3:04p $
%Last modify    $Modtime: 11/27/02 3:03p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

err = 0;
errMsg = '';
modName = '>extractTextFromCSVText';

text = '';
if (commaToUse > -1 )
  if (length(commasAt) < commaToUse)
    err = 1;
    errMsg = sprintf('%s: specified comma (%i) is beyond the last comma (%i) in [%s]', modName, commaToUse, length(commasAt), textLine);
  else
    if (commaToUse+1 > length(commasAt) )
      last = length(textLine) ;
    else
      last = commasAt(commaToUse+1) - 1;
    end
    if (commaToUse > 0 )
      if (commasAt(commaToUse) < length(textLine) )
        %if not the first column of data (where commaToUse == 0)
        text = textLine([commasAt(commaToUse)+1:last]);
      else %if (commasAt(commaToUse) < length(textLine) )
        if (commasAt(commaToUse) > length(textLine) )
          %comma doesn't exist in textLine: formatting problem
          err = 1;
          errMsg = sprintf('%s: specified comma (%i) is beyond the length of [%s]', modName, commaToUse, length(commasAt), textLine);
        else %if (commasAt(commaToUse) > length(textLine) )
          %last entry is blank
          text = '';
        end %if (commasAt(commaToUse) > length(textLine) ) else
      end %if (commasAt(commaToUse) < length(textLine) ) else
    else
      text = textLine([1:last]) ;
    end
  end
else
  err = 1;
  errMsg = sprintf('%s: invalid specified comma (%i) for [%s]', modName, commaToUse, textLine);
end
