function [err, errMsg] = installELogger


%program to perform the installion.  Too much stuff
%  that can change to do this with BAT files!  The best example
% is the location where Outpost has been installed & the impact on BAT files:
%   if it is a single word directory, that is one passed variable %1
%   if it a two word directory, that is two passed variables: %1 %2

debug = 0;
%#IFDEF debugOnly
debug = 1;
%#ENDIF

% learn which directry we are in
% get the operator to point to 'outpost.ini'
a = 'When you close this window, another window will open.  Use that window to select the location of Outpost.ini you want these files associated with.';
a = sprintf('%s\n\nNote: if you have more than one installation of Outpost, please be sure to select the desired installation.', a);
uiwait(helpdlg(a,'Locating Outpost.ini'));
[err, errMsg, presentDrive, fPath] = findOutpostINI;
inThisDirFlg = 0;
while ~inThisDirFlg
  origDir = pwd;
  cd(fPath)
  [fname, DirOutpost] = uigetfile('outpost.ini','Location of Outpost.ini');
  cd(origDir)
  if isequal(fname,0) 
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
    fprintf('\n Installation aborted.');
    errordlg('Installation aborted.','Abort','on')
    return
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
  end
  %do this call just to get the drive decoded . . also confirms outpost.ini is indeed present!
  [err, errMsg, presentDrive, fPath, inThisDirFlg] = findOutpostINI(DirOutpost);
end % while ~inThisDirFlg

%if on development system computer with the software to write all this code....
if findstrchr('mfiles', lower(pwd)) & findstrchr('ham radio', lower(pwd))
  fromDir = strcat(pwd, '\ShipPackage\');
else
  %user computer
  fromDir = pwd;
end
fromDir = endWithBackSlash(fromDir);

% start the process
%  install OutpostINIToScript so we use it
%    to get the rest of the information we need.
name = 'OutpostINItoScript';
tempDir = fromDir;
fid = fopen(sprintf('%sinstall_01.bat', tempDir),'w');
while fid < 1
  prompt  = {sprintf('Unable to create a necessary temporary file on the current drive.\nThis problem will occur if you are installing from a CD. \n\nPlease enter a path where the file can be created.')};
  title   = 'Temporary file location.';
  lines= 1;
  def     = {tempDir};
  answer  = inputdlg(prompt,title,lines,def);
  if ~length(a)
    %user abort
    return
  end
  tempDir =  endWithBackSlash(char(answer(1)));
  fid = fopen(sprintf('%sinstall_01.bat', tempDir),'w');
end %while fid < 1
% .exx files are actually .exe files renamed by makeShip so security
%   software, such as gmail's, aren't upset.
% Need to rename them back so we can use them.
exxList = dir(sprintf('%s%s.exx', fromDir, name) );
if length(exxList)
  %if source files are not in same location as temp file, source isn't
  %  writable so we need to copy the files before we can rename them.
  if ~strcmp(tempDir, fromDir)
    fprintf(fid, 'copy "%s%s.exe" "%s\\*.*"\r\n', fromDir, name, tempDir);
  end
  %first time through - .exx needs to be renamed
  fprintf(fid, 'del "%s%s.exe"\r\n', tempDir, name);
  fprintf(fid, 'ren "%s%s.exx" %s.exe\r\n', tempDir, name, name);
end % if length(exxList)
fprintf(fid, 'copy "%s%s.exe" "%s*.*"\r\n', tempDir, name, DirOutpost);
fcloseIfOpen(fid);
if ~debug
  err = dos(sprintf('"%sinstall_01.bat"', tempDir));
  if err
    fprintf('\r\nerror attempting run of "%sinstall_01.bat"', tempDir);
    return
  end
end

%Now it is installed so let's use it - learn the locations:  
% need bookmark file since Outpost's scripting isn't stable as far as its
%  active directory -> place in root.
fp = strcat(endWithBackSlash(presentDrive), 'pathToOutpost.txt') ;
fid = fopen(fp, 'w');
if (fid > 0)
  fprintf(fid,'%s', DirOutpost );  
  fclose(fid);
end % if (fid > 0)
[err, errMsg, outpostNmNValues] = OutpostINItoScript(DirOutpost); 
% we'll call it a second time so it will write "pathToOutpost.txt"
%  to all the locations it wants to.  Currently that includes the root directory
%  of the current drive, the root directory of the drive with Outpost's scripts
%  directory, and the root of C:
OutpostINItoScript(DirOutpost); 
DirAddOns = outpostValByName('DirAddOns', outpostNmNValues);
DirAddOnsPrgms = outpostValByName('DirAddOnsPrgms', outpostNmNValues);
DirArchive = outpostValByName('DirArchive', outpostNmNValues);
DirScripts = outpostValByName('DirScripts', outpostNmNValues);

%create the new directories - note that 'mkdirExt' will create the specified directory as well
% as any missing directories in the tree above it.  For example, if we have
%  c:\Program Files\Outpost & are trying to add InTray to Archive under Outpost,
% the program will create c:\Program Files\Outpost\Archive & c:\Program Files\Outpost\Archive\InTray
[err, errMsg, status, msg] = mkdirExt(strcat(DirArchive, 'InTray'), 1)
[err, errMsg, status, msg] = mkdirExt(strcat(DirArchive, 'SentTray'), 1)
[err, errMsg, status, msg] = mkdirExt(DirAddOnsPrgms, 1)
fprintf('\nRenaming the executables from .exx to .exe & copying to working location.');
exxFiles = dir(sprintf('%s*.exx',fromDir));
fid = fopen(sprintf('%sinstall_01.bat', tempDir),'w');
if length(exxFiles)
  fprintf(fid, 'rem Rename .exx to .exe\r\n');
end
for itemp = 1:length(exxFiles)
  [pathstr,name,ext,versn] = fileparts(char(exxFiles(itemp).name));
  if ~strcmp(tempDir, fromDir)
    fprintf(fid, 'copy "%s%s.exx" "%s\\*.*"\r\n', fromDir, name, tempDir);
  end
  fprintf(fid, 'if EXIST "%s%s.exe" del "%s%s.exe"\r\n', tempDir, name, tempDir, name);
  fprintf(fid, 'ren "%s%s.exx" "%s.exe"\r\n', tempDir, name, name);
end
fprintf(fid, 'rem \r\n');

fid_in = fopen(sprintf('%sexeToPrgm.txt', fromDir),'r');
while ~feof(fid_in)
  textLine = fgetl(fid_in);
  if length(textLine)
    fprintf(fid, 'copy "%s%s" "%s*.*"\r\n', tempDir, textLine, DirAddOnsPrgms);
    if ~strcmp(tempDir, fromDir)
      % clean up the temp directory
      fprintf(fid, 'del "%s%s"\r\n', tempDir, textLine);
    end
  end
end
fcloseIfOpen(fid_in);
% % ren mglinstaller.exx mglinstaller.exe
% rem Copy INI & support files to working location(s)
fprintf(fid, 'rem \r\n');
fprintf(fid, 'copy "%s*.fig" "%s*.*"\r\n', fromDir, DirAddOnsPrgms);
fprintf(fid, 'copy "%s*.dll" "%s*.*"\r\n', fromDir, DirAddOnsPrgms);
fprintf(fid, 'copy "%s*.osl" "%s*.*"\r\n', fromDir, DirScripts);
fprintf(fid, 'rem \r\n');

%read in the "addOns" file list.  This was created by "makeShip"
[err, errMsg] = batLineCopy_ifNewer(sprintf('%sfilesToAddOns.txt', fromDir), DirAddOns, fid);
%read in the "Programs" file list
[err, errMsg] = batLineCopy_ifNewer(sprintf('%sfilesToPrgm.txt', fromDir), DirAddOnsPrgms, fid);
fprintf(fid, 'echo Ready to exit\r\n');
fprintf(fid, 'pause\r\n');
fprintf(fid, 'exit\r\n');
fcloseIfOpen(fid);

if ~debug
  err = dos(strcat(tempDir,'install_01.bat'));
  if err
    fprintf('\r\nerror attempting installation of "%sinstall_01.bat"', tempDir);
    return
  end
  fprintf('\nInstallation complete.')
  if ~strcmp(tempDir, fromDir)
    %finish cleaning up the temp directory
    delete(strcat(tempDir,'install_01.bat'));
  end
end

uiwait(helpdlg('Installation/upgrade done'));

%----------------------------------------------------------------------------
function [err, errMsg] = batLineCopy_ifNewer(listFileName, toDir, fid);
%Only copy file(s) which are newer than those in the target or do not exist in the target
err = 0;
errMsg = '';
fid_2 = fopen(listFileName, 'r');
while 1
  textLine = fgetl(fid_2);
  if length(textLine) & ~isnumeric(textLine)
    a = dir(textLine);
    %textLine may contain wild cards so there may be more than one source file:
    % go through each explicitly
    for aNdx = 1:length(a)
      thisName = char(a(aNdx).name);
      b = dir(strcat(toDir, thisName));
      if length(b)
        %file exists in target: copy if newer
        for bNdx = 1:length(b)
          if ( (datenum(a(aNdx).date) > datenum(b(bNdx).date) ))
            fprintf(fid, 'copy "%s" "%s*.*"\r\n', thisName, toDir);
          elseif ( (datenum(a(aNdx).date) < datenum(b(bNdx).date) ))
            fprintf(fid, 'rem "%s%s" is newer.\r\n', toDir, thisName);
          else
            fprintf(fid, 'rem "%s%s" is current.\r\n', toDir, thisName);
          end % if ( (datenum(a.date) > datenum(b(bNdx).date) ))
        end %for bNdx = 1:length(b)
      else % if length(b)
        % file does not exist in target: copy!
        fprintf(fid, 'copy "%s" "%s*.*"\r\n', thisName, toDir);
      end % if length(b) else
    end %for aNdx = 1:length(a)
  end %if length(textLine)
  if feof(fid_2)
    break
  end
end %while 1
fprintf(fid, 'rem \r\n');
fcloseIfOpen(fid_2);
%----------------------------------------------------------------------------

