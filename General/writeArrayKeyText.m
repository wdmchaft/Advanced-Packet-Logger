function writeArrayKeyText(varName, dataArray, fid)
%function writeArrayKeyText(varName, dataArray, fid)
%See also readArrayKeyText
%Writes the single dimension elements of 'dataArray'
% to the all ready open file in text format.
%  <varName>(n) = <dataArray(n)>
% example:
%  waveguide(1) = 3.1415
%VSS revision   $Revision: 3 $
%Last checkin   $Date: 9/11/06 11:09a $
%Last modify    $Modtime: 9/11/06 11:09a $
%Last changed by$Author: Arose $
%  $NoKeywords: $
if fid < 1
  return
end
if iscell(dataArray)
  b = char(dataArray);
  clear dataArray;
  dataArray = b;
end
if ischar(dataArray)
  sizeOfdataArray = size(dataArray);
  for itemp = 1:sizeOfdataArray(1)
    fprintf(fid, '\r\n%s(%i) = %s', varName, itemp, dataArray(itemp, :));
  end
else
  for itemp = 1:length(dataArray)
    fprintf(fid, '\r\n%s(%i) = %i', varName, itemp, dataArray(itemp));
  end
end