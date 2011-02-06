function  [err, errMsg] = makeCompiled_zip(date_time, originalPWD, fulltargetDir, fileNames2CheckOut, ...
  startLLDkey_hFileName, diaryFileName, outputFileName, outputFileExt, fileListName, debugCode, nonMLFunctionNames);
% Creates two, slightly different archives, one in the originalPWD and one in the compile directory.
% Copies the compiled code, .dll/.exe, wiht date_time stamp embedded in the name, to the originalPWD.
% Also creates a date_time stamped copy of the .exe/.dll and for "Release" mode, copies with
% date_time stamp of ReservedNames.txt, Obfuscate.fpf, and ObfuscatedNames.txt
% 
% The compile directory's archive is copied to the originalPWD for ease of backing up
%  The archive in the originalPWD includes:
%   * ALL .m files in that directory whether or not they are part of the compiled code.  This
%     assures that we have a copy of all functions and scripts that were affected & controlled the compilation.
%   * The diary created during compilation.
%   * a copy of the .exe/.dll
%   * if "Release", a copy of ReservedNames.txt
%  The archive in the compile directory includes
%   * only the .m files in which were copied.  Might be a few more than were compiled but not many.
%   * The diary created during compilation. (same as in the other archive)
%   * if "Release", a copy of:
%       * ReservedNames_<name>_date_time.txt, 
%       * ObfuscatedNames_<name>_date_time.txt, 
%       * Obfuscate_<name>_date_time.fpf, 
%   * all figures that the compiled code needs other than Matlab figures
%VSS revision   $Revision: 10 $
%Last checkin   $Date: 6/25/07 4:08p $
%Last modify    $Modtime: 6/25/07 4:05p $
%Last changed by$Author: Arose $
%  $NoKeywords: $
[err, errMsg, modName] = initErrModName(mfilename);

if (nargin < 9)
  fileListName = '';
end
if (nargin < 10)
  debugCode = 0;
end

%progress('updateStatusNext', 'Running'); %Creating archive ZIP
progress('updateStatusByName', 'Creating archive ZIP: all', 'running')
fileName = sprintf('%s_source%s.zip', outputFileName, date_time);
progress('listboxMsg_Callback', sprintf('Creating Zip with all master source M files [%s%s]', originalPWD, fileName));
progress('listboxMsg_Callback', sprintf(' & time-stamp copy of %s%s [%s%s%s%s]', ...
  outputFileName, outputFileExt, originalPWD, outputFileName, date_time, outputFileExt));

%the program which will perform the compression may be installed in different locations on different machines:
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
end
% % create archive of master source code & dll/exe
% archive: from originalPWD, will include *.m, all checked out files, startLLDkey_hFileName, the diary, and reservedNames.txt
% name the zip, including the path where the zip will be
BATcommand = sprintf('"%s" a %s', b, fileName);

%include all .m files in the zip
BATcommand = sprintf('%s *.m', BATcommand);

%make sure all files that we bothered to check out are included in the archival ZIP
%  note that if this loop executes and "fileNames2CheckOut" has any null string entries, the command to ZIP will be seen as asking ZIP to include ALL files!
for itemp = 1:length(fileNames2CheckOut)
  a = char(fileNames2CheckOut(itemp));
  skip = 0;
  %skip if .m file: they are all ready included
  %skip if entry is a null string: otherwise the command to ZIP will be seen as asking ZIP to include ALL files!
  if (findstrchr('.m', a) | (length(a) < 1))
    skip = 1;
  end
  if ~skip
    BATcommand = sprintf('%s %s', BATcommand, a);
  end
end
if length(startLLDkey_hFileName)
  BATcommand = sprintf('%s %s', BATcommand, startLLDkey_hFileName);
end
BATcommand = sprintf('%s %s', BATcommand, diaryFileName);

if ~debugCode & ~findstrchr('reservednames.txt', BATcommand)
  BATcommand = sprintf('%s ReservedNames.txt', BATcommand);
end

%make a batch file: this contains the full .m files and not merely
% the compile-type-specific (filtered) .m files.... those are in the other .zip
fid = fopen('copyZipArchive.bat','w');
%from the fulltargetDir, copy the compiled code to originalPWD <name>date_time.<ext>
a = sprintf('%s%s%s', outputFileName, date_time, outputFileExt);
%make a date_time copy of the compiled module in the target directory
fprintf(fid, 'copy "%s%s%s" "%s%s"\r\n' , ...
  fulltargetDir, outputFileName, outputFileExt, ...
  fulltargetDir, a);
%make a date_time copy of the compiled module in the originalPWD
fprintf(fid, 'copy "%s%s%s" "%s%s"\r\n' , ...
  fulltargetDir, outputFileName, outputFileExt, ...
  originalPWD, a);
%include the date_time compiled code in the archive
BATcommand = sprintf('%s %s', BATcommand, a);
%insert the archive zip command
fprintf(fid, '%s\r\n', BATcommand);
%copy the diary from originalPWD to the compiled directory
fprintf(fid, 'copy "%s%s" "%s%s"\r\n', originalPWD, diaryFileName, fulltargetDir, diaryFileName);
fprintf(fid, '@echo off\r\n');
fprintf(fid, 'echo Ready to exit\r\n');
fprintf(fid, 'pause\r\n');
fprintf(fid, 'exit\r\n');
fcloseIfOpen(fid);

%call the .bat (we're in the originalPWD at this point)
[err, errMsg] = dosIt(sprintf('copyZipArchive &'), '', nargout, modName, 1);
if err
  errMsg = strcat(modName, errMsg);
  progress('updateStatusCurrent', 'Fail'); %Creating archive ZIP
  if nargout < 1
    progress('listboxMsg_Callback', sprintf('**** Error: %s', errMsg));
  end
end

%now the target directory action
progress('updateStatusNext', 'Running'); %Creating archive ZIP in the compiled directory
% we want to add a few more items to the archive than we had in the originalPWD archive:
%  * the include files list
%  * the files in the include files list
%  * the obfuscation list (which we also want available, so copy & embed date_time)

if ~debugCode
  obf = sprintf('ObfuscatedNames_%s_%s.txt', outputFileName, date_time);
  obf_fpf = sprintf('Obfuscate_%s_%s.fpf', outputFileName, date_time);
  rsrv = sprintf('ReservedNames_%s_%s.txt', outputFileName, date_time);
end

%include the figures and anything else in the include file
fid = fopen(fileListName, 'r');
if fid > 0
  while ~feof(fid)
    textLine = fgetl(fid);
    %if there is a line and it is not the filename.fileExt
    if length(textLine) & ~findstrchr(strcat(outputFileName, outputFileExt), textLine)
      BATcommand = sprintf('%s %s', BATcommand, textLine);
    end
  end
  BATcommand = sprintf('%s %s', BATcommand, fileListName);
  fcloseIfOpen(fid);
end

progress('listboxMsg_Callback', sprintf('*=*=*= Switching to directory "%s" from "%s"\n', fulltargetDir, originalPWD));
cd(fulltargetDir);
progress('editCurDir_Callback', fulltargetDir);

%make a batch file & give it different name just so we can look at either of them afterwards if we want to
fid = fopen('copyZipArchive_2.bat','w');
% if available, copy some files to the names defined above & include them in the zip
if ~debugCode
  fprintf(fid, 'copy "ObfuscatedNames.txt" "%s"\r\n' , obf);
  BATcommand = sprintf('%s %s', BATcommand, obf);
  fprintf(fid, 'copy "Obfuscate.fpf" "%s"\r\n' , obf_fpf);
  BATcommand = sprintf('%s %s', BATcommand, obf_fpf);
  fprintf(fid, 'copy "ReservedNames.txt" "%s"\r\n' , rsrv);
  BATcommand = strrep(BATcommand, 'ReservedNames.txt', rsrv);
end

% this is the 2nd zip which contains the compile-type-specific m files
% which is different than the above zip which contains the full m files
%want zip to have a different name: replace _source with _compile
BATcommand = strrep(BATcommand, '_source', '_compile');
%insert the archive zip command
fprintf(fid, '%s\r\n', BATcommand);
a = sprintf('%s_compile%s.zip', outputFileName, date_time);
fprintf(fid, 'copy "%s" "%s%s"\r\n', a, originalPWD, a);
fprintf(fid, '@echo off\r\n');
fprintf(fid, 'echo Ready to exit\r\n');
fprintf(fid, 'pause\r\n');
fprintf(fid, 'exit\r\n');
fcloseIfOpen(fid);

%call the .bat, pass it the originalPWD
[err, errMsg] = dosIt(sprintf('copyZipArchive_2 &'), '', nargout, modName, 1);
if err
  errMsg = strcat(modName, errMsg);
  progress('updateStatusCurrent', 'Fail'); %Creating archive ZIP
  if nargout < 1
    progress('listboxMsg_Callback', sprintf('**** Error: %s', errMsg));
  end
end
if ~err
  progress('updateStatusCurrent', 'Pass'); %Creating archive ZIP
end
progress('listboxMsg_Callback', sprintf('*=*=*= Returning from directory "%s" to "%s"', fulltargetDir, originalPWD));

cd(originalPWD);
progress('editCurDir_Callback', originalPWD);
return

