%Purpose: create a .zip file containing all the files & instructions for the
%  packet logging and monitoring programs & script.
%updates the copies of the files in "shipDir" from Outpost\AddOns & Outpost\AddOns\Programs
%  and certain Outpost\Scripts\*.osl files.
%For those files that end .exe, erases any previous copies that have the .exx extension
%  and then copy all those .exe to .exx.  Because this 3 step process starts by only pulling
%  in .exe files that are newer than the same named .exe in shipDir, the copying of .exe
%  to .exx may include files that aren't new.
%Next we build a complete list of what files will go into the autoLog.zip file which
%  includes all the files that may have been updated plus those in a list "uniqueFromShipDir"
%"7z.exe" is used to create the zip file.  This module will locate that program by searching
%  the \Program Files\ directory on each dir.
%A batch file is written to delete .exx, copy .exe to .exx, and then call 7z to make
%  a .zip file containing all the desired files.

%files that only exist in the Ship directory
uniqueFromShipDir = {'readme.doc', '"Sample of real time packet log display.doc"'};

% target directory 
shipDir = 'C:\mFiles\HAM Radio\ShipPackage\';

% location of Outpost
[err, errMsg, outpostNmNValues] = OutpostINItoScript; 
DirOutpost = outpostValByName('DirOutpost', outpostNmNValues);
prompt  = {'Confirm location of Outpost where the source files are linked:'};
title   = 'Outpost Location';
lines= 1;
def     = {DirOutpost};
answer  = inputdlg(prompt,title,lines,def);
if ~length(answer)
  return
end
DirOutpost = endWithBackSlash(char(answer));
shipDir = endWithBackSlash(shipDir);

% files desired from the ...\Outpost\AddOns\Programs directory
filesFromPrgm = {'*.fig','*.jpg','grayMap.mat','*.dll'};  %also *.exe but renamed and don't want in zip so handled separately
% files desired from the ...\Outpost\AddOns
filesFromAddOns = {'ICS213.mat', 'ICS213_crossRef.csv', 'print_ICS_213.ini', ...
    'inTray_copies.txt', 'outTray_copies.txt','Tac call alias.txt'};

% background images for printed forms . . .
formCoreNames = dir(sprintf('%sAddOns\\Programs\\*.jpg', DirOutpost));
% . . . the associated layout and alignment files
for itemp = 1:length(formCoreNames)
  [pathstr,name,ext,versn] = fileparts(formCoreNames(itemp).name);
  filesFromAddOns(length(filesFromAddOns)+1) = {sprintf('%s.mat', name)};
  filesFromAddOns(length(filesFromAddOns)+1) = {sprintf('*%s.txt', name)};
end

% we'll prefix all of these with a '*' later  NOTE: do NOT include ANY .exe: emails are rejecting these!
archiveAll = {'.dll', '.mat', '.csv', '.ini', '.txt', '.exx'};

scriptsNeeded = {'sendRec*.osl', 'startUp.osl'};

%^^^^^^^^^^^^^^^^^^^^ end of setup ^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^ end of setup ^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^ end of setup ^^^^^^^^^^^^^^^^^^^

%Create a batch file that will be called by the installer to places the form image & related files 
%  in their respective proper directories:
% fid = fopen('instFormSuprt.bat', 'w');
% for itemp = 1:length(formCoreNames)
%   thisName = char(formCoreNames(itemp).name);
%   fprintf(fid, 'copy %s "%%1 %%2 %%3 %%4 %%5 %%6\\%s\r\n', thisName, thisName);
% 


%update/copy all .exe files to the shipDir
exeFiles = dir(sprintf('%sAddOns\\Programs\\*.exe', DirOutpost));
fid = fopen(strcat(shipDir, 'exeToPrgm.txt'),'w');
for itemp = 1:length(exeFiles)
  fprintf(fid, '%s\r\n', char(exeFiles(itemp).name));
end %for itemp = 1:length(filesFromAddOns)
fclose(fid) ;
bac_It( sprintf('%sAddOns\\Programs\\', DirOutpost), shipDir, '*.exe');
%OutpostToINIScript is in a special location in an effort to get scripts to find it!
bac_It( DirOutpost, shipDir, 'outpostINItoScript.exe');

%update/copy all the files specified in "filesFromPrgm" to the ship dir
fileNames2Incl = {};
for itemp = 1:length(filesFromPrgm)
  a = char(filesFromPrgm(itemp));
  bac_It( sprintf('%sAddOns\\Programs\\', DirOutpost), shipDir, a);
  incl = 1;
  %if the current file has an extension that is in the list
  %  of files that will be zipped regardless of name, don't add the
  %  file explicitly
  for jtemp = 1:length(archiveAll)
    if findstrchr(char(archiveAll(jtemp)), a)
      incl = 0;
      break
    end
  end
  if incl
    fileNames2Incl(1+length(fileNames2Incl)) = {a};
  end
end %for itemp = 1:length(filesFromPrgm)

%update/copy all the files specified in "filesFromAddOns" to the ship dir
for itemp = 1:length(filesFromAddOns)
  a = char(filesFromAddOns(itemp));
  bac_It( sprintf('%sAddOns\\', DirOutpost), shipDir, char(filesFromAddOns(itemp)));
  incl = 1;
  %if the current file has an extension that is in the list
  %  of files that will be zipped regardless of name, don't add the
  %  file explicitly
  for jtemp = 1:length(archiveAll)
    if findstrchr(char(archiveAll(jtemp)), a)
      incl = 0;
      break
    end
  end
  if incl
    fileNames2Incl(1+length(fileNames2Incl)) = {a};
  end
end %for itemp = 1:length(filesFromAddOns)

%update/copy the relevant scripts
for itemp = 1:length(scriptsNeeded)
  a = char(scriptsNeeded(itemp));
  bac_It( sprintf('%sScripts\\', DirOutpost), shipDir, char(scriptsNeeded(itemp)));
end

% create some files that will be used during the installation process:
fid = fopen(strcat(shipDir, 'filesToAddOns.txt'),'w');
for itemp = 1:length(filesFromAddOns)
  fprintf(fid, '%s\r\n', char(filesFromAddOns(itemp)));
end %for itemp = 1:length(filesFromAddOns)
fclose(fid);
fid = fopen(strcat(shipDir, 'filesToPrgm.txt'),'w');
for itemp = 1:length(filesFromPrgm)
  fprintf(fid, '%s\r\n', char(filesFromPrgm(itemp)));
end %for itemp = 1:length(filesFromAddOns)
fclose(fid);

for itemp = 1:length(archiveAll)
  archiveAll(itemp) = {sprintf('*%s', char(archiveAll(itemp)))};
end

fileNames2Incl = [archiveAll scriptsNeeded fileNames2Incl uniqueFromShipDir, {'filesToAddOns.txt', 'filesToPrgm.txt'}];

%create a batch file that will 
%  1) delete any old/existing *.exx files
%  2) copy the .exe files to .exx files . . .
%  <more follows>
a = dir(sprintf('%s*.exe', shipDir) );
fid = fopen(sprintf('%smakeShip.bat', shipDir),'w');
for itemp = 1:length(a)
  [pathstr,name,ext,versn] = fileparts(char(a(itemp).name));
  fprintf(fid,'del "%s%s.exx" \r\n', shipDir, name);
  fprintf(fid,'copy "%s%s.exe" "%s%s.exx"\r\n', shipDir, name, shipDir, name);
end

% locate the program "7z.exe"
c = char([double('C')+[0:23]]); %check on drive C: -> Z:
for itemp = 1:length(c)
  b = sprintf('%s:\\Program Files\\7-Zip\\7z.exe', c(itemp));
  a = dir(b);
  if length(a)
    break
  end
end
if ~length(a)
  %just post a warning....compression process will fail but other actions will work
  fprintf('\r\n***** unable to find the compression program "7z.exe".');
  b = sprintf('%s:\\Program Files\\7-Zip\\7z.exe', c(1));
  fcloseIfOpen(fid);
  return
end
% name the zip, including the path where the zip will be
[err, errMsg, date_time] = datevec2timeStamp(now);
a = findstrchr('_', date_time);
dateIs = date_time(1:a-1);
BATcommand = sprintf('"%s" a autoLog%s.zip', b, dateIs);

%make sure all files that we bothered to check out are included in the archival ZIP
%  note that if this loop executes and "fileNames2CheckOut" has any null string entries, the command to ZIP will be seen as asking ZIP to include ALL files!
for itemp = 1:length(fileNames2Incl)
  BATcommand = sprintf('%s %s', BATcommand, char(fileNames2Incl(itemp)) );
end
fprintf(fid, '%s\r\n', BATcommand);

%2nd zip is almost the same as the first - it excludes the Matlab libraries
fprintf(fid, 'del autologUpgrade.zip\r\n');
% delete the .exx version of the installer - we do not zip and .exe files
fprintf(fid, 'del mglinstaller.exx\r\n');
BATcommand = sprintf('"%s" a autologUpgrade%s.zip', b, dateIs);


%make sure all files that we bothered to check out are included in the archival ZIP
%  note that if this loop executes and "fileNames2CheckOut" has any null string entries, the command to ZIP will be seen as asking ZIP to include ALL files!
for itemp = 1:length(fileNames2Incl)
  BATcommand = sprintf('%s %s', BATcommand, char(fileNames2Incl(itemp)) );
end
fprintf(fid, '%s\r\n', BATcommand);
fprintf(fid, '@echo off\r\n');
fprintf(fid, 'echo Ready to exit\r\n');
fprintf(fid, 'pause\r\n');
fprintf(fid, 'exit\r\n');
fcloseIfOpen(fid);


origDir = pwd;
cd(shipDir)
%call the full install .bat 
[err, errMsg] = dosIt(sprintf('makeShip.bat &'), '', 0, 'makeShip.m', 1);
cd(origDir)
if err
  fprintf('\nError: %i %s', err, errMsg);
  return
end
