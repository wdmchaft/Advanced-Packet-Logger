function [dataArray, fid] = readArrayKeyText(varName, fid, nameForReload)
%function [dataArray, fid] = readArrayKeyText(varName, fid, nameForReload)
%See also writeArrayKeyText
%Reads the single dimension elements of 'dataArray'
% from the all ready open file in text format.
%The reading will continue until the no more
% elements are found.  The returned 'dataArray' is therefor
% self-dimensioning.
%  <varName>(n) = <dataArray(n)
% example:
%  waveguide(1) = 3.1415
%VSS revision   $Revision: 2 $
%Last checkin   $Date: 12/23/03 5:09p $
%Last modify    $Modtime: 12/18/03 5:24p $
%Last changed by$Author: Arose $
%  $NoKeywords: $
err = 0;
itemp = 1;
while (err == 0)
  [err, errMsg, a, fid, text] = findKeyNumber(sprintf('%s(%i)', varName, itemp), fid, nameForReload);
  if err == 0
    if length(a)
      if itemp < 2
        dataArray = -1;
      end
      dataArray(itemp) = a;
    else
      if itemp < 2
        dataArray = cellstr('');
      end
      dataArray(itemp) = cellstr(text);
    end
    itemp = itemp + 1;
  end
end
if itemp == 1 & err
  dataArray = 0;
else
  if iscell(dataArray)
    dataArray = char(dataArray);
  end
end
