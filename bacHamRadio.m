function [err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bacHamRadio(fromCPU, toCPU)

fromCPU = endWithBackSlash(fromCPU);
toCPU = endWithBackSlash(toCPU);

fileSpec = {'*.txt','*.m','*.fig','*.doc','*.inc'};
ignoreList = {'diary*.txt','progress.txt', 'db_startup.m', 'makediagnostics.txt','moduleAlias.txt'};
limitedMsgs = 0;
minDate = '';
minDate = '1-Jan-0000';

[err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bac_it_askuser(strcat(fromCPU, 'ham radio\'), strcat(toCPU, 'HAM Radio'), fileSpec, limitedMsgs, minDate, ignoreList);
if err
  fprintf('\n%s', errMsg);
  return
end

[err1, errMsg1, numFiles1, copied1, errors1, copyupdateList1, errorList1] = bac_it_askuser(fromCPU, toCPU, fileSpec, limitedMsgs, minDate, ignoreList);
if err1
  fprintf('\n%s', errMsg1);
  return
end
copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
numFiles = numFiles + numFiles1;

[err1, errMsg1, numFiles1, copied1, errors1, copyupdateList1, errorList1] = bac_it_askuser(strcat(fromCPU, 'general\'), strcat(toCPU, 'general'), fileSpec, limitedMsgs, minDate, ignoreList);
if err1
  fprintf('\n%s', errMsg1);
  return
end
copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
numFiles = numFiles + numFiles1;


% % bac_it_askuser('\\hplapw98\d\matlab6p1\work\', 'C:\matlab6p1\work','*.m');