function [err, errMsg, field] = readICS213crossRef(filePathName);
%INPUT
% filePathName: either the path or the path+name of the xref file
[err, errMsg, modName] = initErrModName(mfilename);

field = [];

if nargin < 1
  filePathName = '';
else
  filePathName = endWithBackSlash(filePathName);
end
[pathstr,name,ext,versn] = fileparts(filePathName);

if length(name) < 1
  if length(pathstr)
    filePathName = sprintf('%s\\ICS213_crossRef.csv', pathstr);
  else
    filePathName = 'ICS213_crossRef.csv';
  end
end
fid = fopen(filePathName,'r');
if fid < 1
  err = 1;
  errMsg = sprintf('%s: unable to open "%s"', modName, filePathName) ;
  return
end
itemp = 1 ;
while ~feof(fid)
  textLine = fgetl(fid) ;
  commasAt = findstrchr(',', textLine) ;
  if commasAt(1) > 1
    [err, errMsg, field(itemp).digitizedName] = extractTextFromCSVText(textLine, commasAt, 0);
    if ~err
      [err, errMsg, a] = extractTextFromCSVText(textLine, commasAt, 1);
      field(itemp).PACFormTagPrimary = lower(a) ;
    end
    if ~err
      [err, errMsg, a] = extractTextFromCSVText(textLine, commasAt, 2);
      field(itemp).PACFormTagSecondary = lower(a);
    end
    if ~err
      [err, errMsg, field(itemp).HorizonJust] = extractTextFromCSVText(textLine, commasAt, 3);
    end
    if ~err
      [err, errMsg, field(itemp).VertJust] = extractTextFromCSVText(textLine, commasAt, 4);
    end
    if err
      errMsg = strcat(modName, errMsg);
      break;
    end
    itemp = itemp + 1;
  end % if commasAt(1) > 1
end

fcloseIfOpen(fid);