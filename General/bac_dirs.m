function [err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bac_dirs(root_from, root_to, fileMask);

root_from = endWithBackSlash(root_from);
root_to = endWithBackSlash(root_to);

[err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bac_it(root_from, root_to, fileMask);
if err
  return
end

thisList = dir(strcat(root_from, '*.*'));
b=[];
for itemp = 1:length(thisList);
  if thisList(itemp).isdir
    if ~findstrchr('.',thisList(itemp).name)
      thisFrom = strcat(root_from, thisList(itemp).name);
      thisTo = strcat(root_to, thisList(itemp).name);
      [err, errMsg, numFiles1, copied, errors, copyupdateList1, errorList1] = bac_dirs(thisFrom, thisTo, fileMask);
      if err
        break
      end
      copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
      errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
      numFiles = numFiles + numFiles1;
    end
  end
end