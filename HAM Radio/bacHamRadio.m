function [err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bacHamRadio(fromCPU, toCPU)

fromCPU = endWithBackSlash(fromCPU);
toCPU = endWithBackSlash(toCPU);

coreFileSpec = {'*.txt','*.m','*.fig','*.doc','*.inc','*.xls','*.cfg'};
fid = fopen(sprintf('%s_ignoreList.txt'),'r');
if (fid < 1)
  ignoreList = {'diary*.txt','progress.txt', 'db_startup.m', 'makediagnostics.txt','moduleAlias.txt'};
else
  ignoreList = {};
  while ~feof(fid)
    textLine = fgetl(fid);
    if (findstrchr('%', strtrim(textLine)) ~= 1) & length(textLine)
      if ischar(textLine)
        ignoreList(length(ignoreList)+1) = {textLine};
      end % if ischar(textLine)
    end % if (findstrchr('%', strtrim(textLine)) ~= 1) & length(textLine)
  end % while ~feof(fid)
  fcloseIfOpen(fid);
end
limitedMsgs = 0;
minDate = '';
minDate = '1-Jan-0000';
mkDirIfNeeded('HAM Radio', toCPU);

thisFrom = strcat(fromCPU, 'ham radio\');

[fileSpec] = addIncList(thisFrom, coreFileSpec);
[err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bac_it_askuser(thisFrom, strcat(toCPU, 'HAM Radio'), fileSpec, limitedMsgs, minDate, ignoreList);
if err
  fprintf('\n%s', errMsg);
  return
end

thisFrom = fromCPU ;
[fileSpec] = addIncList(thisFrom, coreFileSpec);
[err1, errMsg1, numFiles1, copied1, errors1, copyupdateList1, errorList1] = bac_it_askuser(thisFrom, toCPU, fileSpec, limitedMsgs, minDate, ignoreList);
if err1
  fprintf('\n%s', errMsg1);
  return
end
copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
numFiles = numFiles + numFiles1;

mkDirIfNeeded('general', toCPU);
thisFrom = strcat(fromCPU, 'general\');
[fileSpec] = addIncList(thisFrom, coreFileSpec);
[err1, errMsg1, numFiles1, copied1, errors1, copyupdateList1, errorList1] = bac_it_askuser(thisFrom, strcat(toCPU, 'general'), fileSpec, limitedMsgs, minDate, ignoreList);
if err1
  fprintf('\n%s', errMsg1);
  return
end
copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
numFiles = numFiles + numFiles1;


% % bac_it_askuser('\\hplapw98\d\matlab6p1\work\', 'C:\matlab6p1\work','*.m');

% ----------------------------------------------
