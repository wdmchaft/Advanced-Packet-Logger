%updateHam_i7Lap_NdyDesk.m
fprintf('updateHam_i7Lap_NdyDesk');

listItem = [];

listItem.prompt = 'i7 Laptop';
listItem.rootPath =   'c:\';
listItem.mFiles = 'mfiles\';
listItem.PDA = 'C:\Users\Owner\Documents\Documents on arose''s Smartphone\Documents';
%listItem.scripts = 'Program Files (x86)\Outpost\scripts';
%listItem.addOns = 'Program Files (x86)\Outpost\AddOns';
listItem.scripts = 'SCCo Packet\scripts';
listItem.addOns = 'SCCo Packet\AddOns';

itemp = 2;
listItem(itemp).prompt = 'Andy''s desktop';
listItem(itemp).rootPath =   '\\arose_h\';
listItem(itemp).mFiles = 'f\mfiles\';
listItem(itemp).PDA = '\\AROSE_H\c$\Documents and Settings\arose\My Documents\WINDOWSMOBILE4 My Documents\Documents';
listItem(itemp).scripts = 'f\Program Files\Outpost\scripts';
listItem(itemp).addOns =  'f\Program Files\Outpost\AddOns';

itemp = itemp + 1;
listItem(itemp).prompt = 'W98 HP laptop';
listItem(itemp).rootPath =   '\\hplapw98\';
listItem(itemp).mFiles = 'd\mfiles\';
listItem(itemp).PDA = '\\hplapw98\C\My Documents\Ham Radio\Programming';
listItem(itemp).scripts =  'c\Program Files\Outpost\scripts';
listItem(itemp).addOns =  'c\Program Files\Outpost\AddOns';

itemp = itemp + 1;
listItem(itemp).prompt = 'Sony Viao';
listItem(itemp).rootPath =   '\\sonyviao\';
listItem(itemp).mFiles = 'd\mfiles\';
listItem(itemp).PDA = '\\sonyviao\D\ham';
listItem(itemp).scripts =  'D\Program Files\Outpost\scripts';
listItem(itemp).addOns =  'D\Program Files\Outpost\AddOns';

listIn = {};
for itemp = 1:length(listItem)
  listIn(itemp) = {sprintf('%s (%s)', char(listItem(itemp).prompt), char(listItem(itemp).rootPath))};
end
fromChoice = userChoice(listIn, 'Source computer', 1);
if fromChoice < 1
  fprintf('\r\nUser canceled!');
  return
end

listIn = {};
listNdx = 0;
for itemp = 1:length(listItem)
  if itemp ~= fromChoice
    listNdx = listNdx + 1;
    listIn(listNdx) = {sprintf('%s (%s)', char(listItem(itemp).prompt), char(listItem(itemp).rootPath))};
    listInNdx(listNdx) = itemp;
  end
end
toChoice = userChoice(listIn, 'Destination computer', 1);
if toChoice < 1
  fprintf('\r\nUser canceled!');
  return
end
toChoice = listInNdx(toChoice);

% fromChoice toChoice
% 
% listItem(itemp).prompt = 'Sony Viao';
% listItem(itemp).rootPath =   '\\sonyviao\';
% listItem(itemp).mFiles = 'd\mfiles\';
% listItem(itemp).PDA = '\\sonyviao\D\ham';
% listItem(itemp).scripts =  'D\Program Files\Outpost\scripts';

fromPath = strcat(listItem(fromChoice).rootPath, listItem(fromChoice).mFiles );
toPath   = strcat(listItem(toChoice).rootPath,  listItem(toChoice).mFiles );

fromScripts = strcat(listItem(fromChoice).rootPath, listItem(fromChoice).scripts );
toScripts   = strcat(listItem(toChoice).rootPath,  listItem(toChoice).scripts );

fromAddOns = strcat(listItem(fromChoice).rootPath, listItem(fromChoice).addOns );
toAddOns  = strcat(listItem(toChoice).rootPath,  listItem(toChoice).addOns );


[err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bacHamRadio(fromPath, toPath);
[err1, errMsg1, numFiles1, copied1, errors1, copyupdateList1, errorList1] = bac_it_askuser(listItem(fromChoice).PDA, listItem(toChoice).PDA,'*.m');
copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
numFiles = numFiles + numFiles1;

[err1, errMsg1, numFiles1, copied1, errors1, copyupdateList1, errorList1] = bac_it_askuser(fromScripts, toScripts,'*.osl');
copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
numFiles = numFiles + numFiles1;

%the forms have background jpg images: learn their names....
formCoreNames = dir(sprintf('%s\\Programs\\*.jpg', fromAddOns));
%... the other related files have the same core name: <name>.mat is the digitized field locations
%    formAlign<name>.txt is the low res / high res (print quality) alignment values
%    printAlign<name>.txt may not exist; if it does, it is the alignment to the pre-printer form in the printer.
nmLst = {};
clear a
a = {'.mat','*.jpg'};
for itemp = 1:length(formCoreNames)
  [pathstr,name,ext,versn] = fileparts(formCoreNames(itemp).name);
  for jtemp = 1:length(a)
    nmLst((itemp-1)*2+jtemp)={sprintf('%s%s', name, char(a(jtemp)))};
  end
end
[err1, errMsg1, numFiles1, copied1, errors1, copyupdateList1, errorList1] = bac_it_askuser(fromAddOns, toAddOns, nmLst);
copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
numFiles = numFiles + numFiles1;

[err1, errMsg1, numFiles1, copied1, errors1, copyupdateList1, errorList1] = bac_it_askuser(fromAddOns, toAddOns,'Tac call alias.txt');
copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
numFiles = numFiles + numFiles1;

fprintf('\nTotal files checked: %i.', numFiles);
if length(copyupdateList)
  fprintf('\n Files copies/updated:');
  for itemp = 1:length(copyupdateList)
    fprintf('\n %i: %s', itemp, char(copyupdateList(itemp)));
  end
end
if length(errorList)
  fprintf('\n Errors:');
  for itemp = 1:length(errorList)
    fprintf('\n %i: %s', itemp, char(errorList(itemp)));
  end
end
