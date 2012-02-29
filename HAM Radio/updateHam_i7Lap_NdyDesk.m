function updateHam_i7Lap_NdyDesk
%updateHam_i7Lap_NdyDesk.m

% should ask if backup of compiled code is desired
% flash drive's "pathToOutpost.txt" contains the path when
%   the flash drive was installed on its first backup computer
%   That letter may not work on this machine -> findOutpostINI has the issue
% flash drive should be remembered & possibly the file chosen by the user last
%   time on this machine.
% Needs upgrade so it can run without network: code needs two
%   sets of paths: local vs network

fprintf('updateHam_i7Lap_NdyDesk');

[status,result] = dos('set COMPUTERNAME');

fid = fopen(strcat(mfilename, '.mat'), 'r');
if (fid > 0)
  fclose(fid);
  load(mfilename);
else
  fname = '*.*';
  pname = pwd;
end;

listItem = [];

listItem.prompt = 'i7 Laptop';
listItem.rootPath =   'c:\';
listItem.mFiles = 'mfiles\';
listItem.PDA = 'C:\Users\Owner\Documents\Documents on arose''s SmartphoneB\Documents';
listItem.c_root = listItem.rootPath;

itemp = 2;
listItem(itemp).prompt = 'Andy''s desktop';
listItem(itemp).rootPath =   '\\AndyDesktop\';
listItem(itemp).c_root = strcat(listItem(itemp).rootPath, 'c\');
listItem(itemp).mFiles = 'New80G (D)\mfiles\';
listItem(itemp).PDA = '\\AndyDesktop\c\Documents and Settings\Andy\My Documents\WINDOWSMOBILE4 My Documents\Documents';

itemp = itemp + 1;
if ~findstrchr('HPLAPW2K', result)
  listItem(itemp).prompt = 'W98 HP laptop';
  listItem(itemp).rootPath =   '\\HPLapW2k\';
  listItem(itemp).c_root = strcat(listItem(itemp).rootPath, 'c\');
  listItem(itemp).mFiles = 'd\mfiles\';
  listItem(itemp).PDA = '\\HPLapW2k\C\My Documents\Ham Radio\Programming';
else
  listItem(itemp).prompt = 'W98 HP laptop';
  listItem(itemp).rootPath =   'C:';
  listItem(itemp).c_root = listItem(itemp).rootPath ;
  listItem(itemp).mFiles = 'D:\mfiles\';
  listItem(itemp).PDA = 'C:\My Documents\Ham Radio\Programming';
end
itemp = itemp + 1;
listItem(itemp).prompt = 'Sony Viao';
listItem(itemp).rootPath =   '\\sonyviao\';
listItem(itemp).c_root = strcat(listItem(itemp).rootPath, 'c\');
listItem(itemp).mFiles = 'd\mfiles\';
listItem(itemp).PDA = '\\sonyviao\D\ham';

itemp = itemp + 1;
listItem(itemp).prompt = 'Gateway Laptop (andy old)';
listItem(itemp).rootPath =   '\\Gateway_laptop\';
listItem(itemp).c_root = strcat(listItem(itemp).rootPath, 'c\');
listItem(itemp).mFiles = 'c\mfiles\';
listItem(itemp).PDA = '\\Gateway_laptop\c\Ham Radio Docs';

itemp = itemp + 1;
flashNdx = itemp;
listItem(itemp).prompt = 'Flash drive';
listItem(itemp).rootPath =   '';
listItem(itemp).c_root = listItem(itemp).rootPath;
listItem(itemp).mFiles = '';
listItem(itemp).PDA = '';

listIn = {};
for itemp = 1:length(listItem)
  listIn(itemp) = {sprintf('%s (%s)', char(listItem(itemp).prompt), char(listItem(itemp).rootPath))};
end
fromChoice = userChoice(listIn, 'Source computer', 1);
if fromChoice < 1
  fprintf('\r\nUser canceled!');
  return
end

if (fromChoice == flashNdx)
  [listItem] = learnFlash(listItem, flashNdx, fname, pname);
end
if ~length(listItem)
  return
end
%read the "c:\pathToOutpost.txt" from the actual system
[err, errMsg, presentDrive, fPath, inThisDirFlg] = findOutpostINI(listItem(fromChoice).c_root);
listItem(fromChoice).scripts = strcat(fPath, 'scripts');
listItem(fromChoice).addOns =  strcat(fPath, 'AddOns');

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
if (listInNdx(toChoice) == flashNdx)
  [listItem] = learnFlash(listItem, flashNdx, fname, pname);
  if ~length(listItem)
    return
  end
  a = dir(strcat(listItem(flashNdx).rootPath,'pathToOutpost.txt'));
  if ~length(a)
    fid = fopen(strcat(listItem(flashNdx).rootPath,'pathToOutpost.txt'), 'w');
    fprintf(fid, '%sSCCo Packet\\\r\n', listItem(flashNdx).rootPath);
    fclose(fid);
    [err, errMsg, status, msg] = mkdirExt(sprintf('%sSCCo Packet\\AddOns\\Programs', listItem(flashNdx).rootPath), 1);
    [err, errMsg, status, msg] = mkdirExt(sprintf('%sSCCo Packet\\scripts', listItem(flashNdx).rootPath), 1);
    a = dir(sprintf('%sSCCo Packet\\outpost.ini', listItem(flashNdx).rootPath));
    if ~length(a)
      fid = fopen(sprintf('%sSCCo Packet\\outpost.ini', listItem(flashNdx).rootPath), 'w');
      fprintf(fid,'dummy file created only for code copy utility: can be replaced with a real file at any time');
      fclose(fid);
    end
  end
  [err, errMsg, status, msg] = mkdirExt(sprintf('%s%s', listItem(flashNdx).rootPath, listItem(flashNdx).mFiles), 1);
  [err, errMsg, status, msg] = mkdirExt(listItem(flashNdx).PDA, 1);
end
%read the "c:\pathToOutpost.txt" from the actual system
[err, errMsg, presentDrive, fPath, inThisDirFlg] = findOutpostINI(listItem(listInNdx(toChoice)).c_root);
listItem(listInNdx(toChoice)).scripts = strcat(fPath, 'scripts');
listItem(listInNdx(toChoice)).addOns =  strcat(fPath, 'AddOns');
toChoice = listInNdx(toChoice);

% fromChoice toChoice
% 
% listItem(itemp).prompt = 'Sony Viao';
% listItem(itemp).rootPath =   '\\sonyviao\';
% listItem(itemp).mFiles = 'd\mfiles\';
% listItem(itemp).PDA = '\\sonyviao\D\ham';
% listItem(itemp).scripts =  'D\Program Files\Outpost\scripts';

if ~findstrchr(':', listItem(fromChoice).mFiles) & ~findstrchr('\\', listItem(fromChoice).mFiles)
  fromPath = strcat(listItem(fromChoice).rootPath, listItem(fromChoice).mFiles );
else
  fromPath = listItem(fromChoice).mFiles ;
end
if ~findstrchr(':', listItem(toChoice).mFiles) & ~findstrchr('\\', listItem(toChoice).mFiles)
  toPath = strcat(listItem(toChoice).rootPath, listItem(toChoice).mFiles );
else
  toPath = listItem(toChoice).mFiles ;
end

if ~findstrchr(':', listItem(fromChoice).scripts) & ~findstrchr('\\', listItem(fromChoice).scripts)
  fromScripts = strcat(listItem(fromChoice).rootPath, listItem(fromChoice).scripts );
else
  fromScripts = listItem(fromChoice).scripts ;
end
if ~findstrchr(':', listItem(toChoice).scripts) & ~findstrchr('\\', listItem(toChoice).scripts)
  toScripts = strcat(listItem(toChoice).rootPath,  listItem(toChoice).scripts );
else
  toScripts = listItem(toChoice).scripts ;
end

if ~findstrchr(':', listItem(fromChoice).addOns) & ~findstrchr('\\', listItem(fromChoice).addOns)
  fromAddOns = strcat(listItem(fromChoice).rootPath, listItem(fromChoice).addOns );
else
  fromAddOns = listItem(fromChoice).addOns ;
end
if ~findstrchr(':', listItem(toChoice).addOns) & ~findstrchr('\\', listItem(toChoice).addOns)
  toAddOns  = strcat(listItem(toChoice).rootPath,  listItem(toChoice).addOns );
else
  toAddOns  = listItem(toChoice).addOns ;
end

a = dir(listItem(toChoice).c_root)
if ~length(a)
  fprintf('\n**** Unable to access "%s".', listItem(toChoice).rootPath);
  return
end
a = dir(listItem(fromChoice).c_root);
if ~length(a)
  fprintf('\n**** Unable to access "%s".', listItem(fromChoice).rootPath);
  return
end

[err, errMsg, numFiles, copied, errors, copyupdateList, errorList] = bacHamRadio(fromPath, toPath);
[err1, errMsg1, numFiles1, copied1, errors1, copyupdateList1, errorList1] = bac_it_askuser(listItem(fromChoice).PDA, listItem(toChoice).PDA,'*.m');
copyupdateList(length(copyupdateList)+[1:length(copyupdateList1)]) = copyupdateList1;
errorList(length(errorList)+[1:length(errorList1)]) = errorList1;
numFiles = numFiles + numFiles1;

mkDirIfNeeded(toScripts);
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
mkDirIfNeeded(toAddOns);
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
%%% ------------------------------------------------------------------------------- %%%
function [listItem] = learnFlash(listItem, flashNdx, fname, pname);
origPWD = pwd;
a = dir(pname);
if length(a)
  cd(pname);
else
  cd('\');
end
[fname, pname] = uigetfile(fname,'Pick any file');
cd(origPWD)
if isequal(fname,0) | isequal(pname,0)
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
  listItem = {} ;
  return
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
end
a = findstrchr(':',pname);
listItem(flashNdx).rootPath = endWithBackSlash(pname(1:a));
listItem(flashNdx).c_root = strcat(listItem(flashNdx).rootPath, '');
listItem(flashNdx).mFiles = 'mfiles';
listItem(flashNdx).PDA = sprintf('%sMy Documents\\Ham Radio\\Programming', listItem(flashNdx).rootPath);
save(mfilename, 'fname', 'pname');
%%% ------------------------------------------------------------------------------- %%%
