function [err, errMsg, targetDir, nonMLFunctionNames, modulesModName, modulesByKey, fileListName]...
  = preCompileCopy(debugCode, targetDir, coreModules, justCopyModules, keysToFind, sourceAlias, printDetail, outputFileName, outputFileExt)
% function [err, errMsg, targetDir] = preCompileCopy(debugCode, targetDir[, coreModules[, justCopyModules[, keysToFind[, sourceAlias[, printDetail]]]]])
%if called without input parameters, will copy from pwd to pwd\debug & create debug style .m files
% Copies all files containing functions 
%which are called by any of the procedures specified in the "coreModules" list.  These files
%are the only files which will be compiled & this procedure uses the Matlab procedure "depfun"
%to make the determination.  The files are copied from the present directory and are modified
%as directed by any #IFDEF/ENDIF statements.  In other words, the source files in the present
%working directory are copied with the same name but may have modified contents.
%
%coreModules: this is the list of all modules that are called from a higher level:
%  wrapper, LabVIEW, etc. They will be compiled and all modules they call as well.
%  This program developes a list of ALL those modules and pre-processes them as needed
%  before conversion to 'C' and compiling.
%VSS revision   $Revision: 30 $
%Last checkin   $Date: 6/28/07 3:40p $
%Last modify    $Modtime: 6/28/07 3:23p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

global userCancel

%2) want somewhere the ability to easily conditionally compile special code such as the focus scan testing

%http://127.0.0.1:9000/obf-ui/ui.xpl/none/"

[err, errMsg, modName] = initErrModName(mfilename);
nonMLFunctionNames = {};
modulesModName = {}; 
modulesByKey = 0;
fileListName = '';

if nargin < 1
  debugCode = 1;
  targetDir = 'Debug';
end
compileType = targetDir;
if nargin < 3
  %this is the list of all modules that are called from a higher level: wrapper, LabVIEW, etc.
  coreModules = {'profileplate.m','measLiqDynamics.m','startLLD.m','measLLD.m','ABOUTLLD.m'};
end
if nargin < 4
  justCopyModules = {'LLDHistory.txt'};
end
if nargin < 5
  keysToFind = {'#IFDEF debugOnly','#IFDEF FocusScan'} ;
end
% "debugOnly" lines must be removed: make sure they were specified:
a = 0;
for itemp = 1:length(keysToFind)
  if findstrchr('#IFDEF debugOnly', char(keysToFind(itemp)))
    a = 1;
    break
  end
end%for itemp = 1:length(keysToFind)
if ~a
  keysToFind(length(keysToFind)+1) = {'#IFDEF debugOnly'};
end
modulesByKey(length(keysToFind)+1) = 0;
if nargin < 6
  %paired list of master source name/to-be-compiled source name
  sourceAlias = {''};
  %   sourceAlias = {...
  %       'measLiqDynamics','measLiqDynamics_debug', ...
  %       'liqDynm_fastSearch', 'liqDynm_fastSearch_debug'...
  %     };
end

if nargin < 7
  printDetail = 0;
end
if nargin < 8
  outputFileName = '';
  outputFileExt = '';
end

%flag array for the files as they are copied.  This allows the list to include files that are
% either not function files or aren't called.  Either way they won't be compiled but we want them 
% copied so they will be archived.  The called functions in the list are copied and we'll clean up
% the rest afterwards.
justCopyModulesCopied(length(justCopyModules)) = 0;

%convert to lower case: all testing is done case insensitive
for itemp = 1:length(coreModules)
  coreModules(itemp) = lower(coreModules(itemp));
end

%location of the master source files
fromDir = endWithBackSlash(pwd);
%location for the source files that will be compiled:
% configure the directory tree: is it a sub directory?  
%  local drive?
a = findstrchr(':', targetDir);
if (~a)
  %not local: network drive?
  a = findstrchr('\\', targetDir);
  if (~a)
    %neither local nor network: must be a sub directory off the present working directory: 
    %  create the full path
    targetDir = sprintf('%s%s', endWithBackSlash(pwd), targetDir);
  end %if (~a)
end %if (~a)

% 1) create a directory for the renamed and/or renamed files
[err, errMsg, status, msg] = mkdirExt(targetDir, 1);
% created successfully, 2 if it already exists. Otherwise, it returns 0.
if err
  errMsg = sprintf('%s%s', modName, errMsg);
  if nargout < 1
    fprintf('\n %s', errMsg);
  end
  return
end

if length(outputFileName) 
  %create a file that will contain all the files needed to operate the compiled code
  %  this is basically the <name>.exe and all associated figures.  Don't have a clever idea for the name
  fileListName = sprintf('%s%s_filelist.txt',  endWithBackSlash(targetDir), outputFileName);
  fidFileList = -1;
  while fidFileList < 1
    fidFileList = fopen(fileListName, 'w');
    if fidFileList < 1
      button = questdlg(sprintf('Please close the application that has "%s" open.', fileListName), 'File Error', 'Retry','Cancel','Retry');
      if strcmp(button,'Cancel')
        err = 1;
        errMsg = strcat(modName, ': user abort - unable to write summary file.');
        progress('listboxMsg_Callback', sprintf('Error: %s', errMsg));
        %turn off diary:
        progress('checkDiaryOn_Callback', 0);
        cancelClose;
        progress('updateStatusCurrent', 'Fail');
        return
      end % if strcmp(button,'Cancel')
    end % if fidFileList < 1
  end %while fidFileList < 1
  fprintf(fidFileList, '%s%s\r\n', outputFileName, outputFileExt);
  fcloseIfOpen(fidFileList);
  progress('listboxMsg_Callback', sprintf('Created %s', fileListName));
end

%learn the names of all the files.  We'll later act only on those in the master source directory (meaning nonMATLAB files)
if ~exist('list')
  a = 1;
else
    try
        a = (length(list) < 1);
    catch
        a = 1;
    end
end %if ~exist('list') else
if a
  %find the nonMATLAB functions which are used:
  %  (calling without an existing list makes a fresh list)
  [err, errMsg, nonMLFunctionNames, nonMLFunctionCount, moduleAlias]...
    = expandList(fromDir, coreModules, targetDir, modName);
  if err | userCancel
    progress('updateStatusCurrent', 'Fail');
    return
  end
end

%process the nonMATLAB list
progress('updateStatusNext', 'running'); %'Creating source .m code'
closeAllWaitBars
[nextWaitScanUpdate, h_waitBar] = initWaitBar(sprintf('Creating %s version of all non-MATLAB .m modules', compileType));
targetDir = endWithBackSlash(targetDir);
anyAdded = 0;
listNdx = 0;
%the list length can change if we are uncommenting (a.k.a. activating) lines
while listNdx < length(nonMLFunctionNames)
  checkCancel;
  listNdx = listNdx + 1;
  a = char(nonMLFunctionNames(listNdx));
  [pathstr,name,ext,versn] = fileparts(a);
  pathstr = endWithBackSlash(pathstr) ; 
  nameExt = strcat(name, ext);
  a = ismember(nameExt, justCopyModules);
  if ~a 
    a = ismember(sourceAlias, name);
    if any(a) & ~mod(a-1,2) 
      a = find(a);
      sourceNameExt = sprintf('%s%s', char(sourceAlias(a+1)), ext);
      nameExt = sprintf('%s%s', char(sourceAlias(a)), ext);
      if printDetail
        fprintf('\nCreating "%s" from "%s" ', nameExt, sourceNameExt);
      end
    else
      if printDetail
        fprintf('\nWorking on "%s"', nameExt);
      end
      %fragment for debugging: change the name, remove the comment markers, activate a break point
      %       if strcmp('startlld.m',lower(nameExt))
      %         fprintf('\nasdljasjld');
      %       end
      sourceNameExt = nameExt;
    end
    
    % 090828 modified: now pulls file from whereever it was located by the "depfun" operation.  Was only pulling from "fromDir"
    desktopSourceFileName = char(nonMLFunctionNames(listNdx));% % OLD strcat(fromDir, sourceNameExt) ;
    compileSourceFileName = strcat(targetDir, nameExt);
    [err, errMsg, linesRead, linesWritten, keysFound, figFound] = ...
      modifyCode4Compile(desktopSourceFileName, compileSourceFileName, debugCode, keysToFind, 1, char(moduleAlias(listNdx)), fileListName);
    %if this .m file is opening a gui figure and Release compile
    if figFound & ~debugCode
      %. . . we need to preserve the function names
      [err, errMsg, listAddedfunctions] = addSubfuncReservedList(compileSourceFileName);
      progress('listboxMsg_Callback', sprintf('Added %i sub-function names to "ReservedNames.txt".', length(listAddedfunctions)));
    end %if figFound & ~debugCode
    if (linesRead ~= linesWritten)
      if printDetail
        fprintf(' New number of lines: lines read %i, lines written %i, difference (read-write) = %i', linesRead, linesWritten, linesRead - linesWritten);
      end
      modulesByKey(length(modulesByKey)) = modulesByKey(length(modulesByKey)) + 1 ;
      modulesModName(length(modulesByKey), modulesByKey(length(modulesByKey))) = {nameExt};
    end
    if err
      errMsg = strcat(modName, errMsg);
      if nargout < 1
        fprintf('\n **** Error: %s', errMsg);
      end %if nargout < 1
      closeAllWaitBars
      %%%%%%%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%%%%%%
      return       %%%%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%%%%%%
    end % if err
    %if any of the additional key phrases were found, we need to further process this file.
    if any(keysFound)
      if printDetail
        fprintf('\n  Additional pass (%s):', compileSourceFileName);
      end
      dosCommand_delTmp= sprintf('del "%s%s.tmp"', targetDir, name);
      %if the .tmp all ready exist, we need to delete it before the rename command will work
      fid = fopen(sprintf('%s%s.tmp', targetDir, name), 'r');
      if fid > 0
        fclose(fid);
        [status,result] = dos(dosCommand_delTmp);
      end
      %rename the .m file to .tmp so the result/ most correct file is always .m: the calls below will copy&update from .tmp to .m
      dosCommand = sprintf('ren "%s" "%s.tmp"', compileSourceFileName, name);
      [status,result] = dos(dosCommand);
      if status
        err =  1;
        errMsg = sprintf('%s: %s attempting [%s].', modName, result, dosCommand);
        if nargout < 1
          fprintf('\n **** Error: %s', errMsg);
        end
      end
      a = 0;
      initLinesRead = linesRead;
      anyChange = 0;
      for keysFoundNdx = 1:length(keysFound)
        checkCancel;
        if userCancel
          break
        end
        if findstrchr(char(keysToFind(keysFound(keysFoundNdx))), '#IFDEF debugOnly') 
          if printDetail
            fprintf('\n   removing lines for desktop only ("#IFDEF debugOnly/#ENDIF" pairs)');
          end
          [err, errMsg, linesRead, linesWritten] = debug2release(sprintf('%s%s.tmp', targetDir, name), strcat(targetDir, nameExt), 1);
          if (linesRead ~= linesWritten)
            a = 1;
            modulesByKey(keysFound(keysFoundNdx)) = modulesByKey(keysFound(keysFoundNdx)) + 1;
            modulesModName(keysFound(keysFoundNdx), modulesByKey(keysFound(keysFoundNdx))) = {nameExt};
          end
        end %if findstrchr(char(keysToFind(keysFoundNdx)), '#IFDEF debugOnly')
        if findstrchr(char(keysToFind(keysFound(keysFoundNdx))), '#IFDEF FocusScan') 
          if printDetail
            fprintf('\n   activating/uncommenting lines for special code ("#IFDEF FocusScan/#ENDIF" pairs)');
          end
          [err, errMsg, linesRead, activatedLineCount] = activateCommentedLines(sprintf('%s%s.tmp', targetDir, name), strcat(targetDir, nameExt), 'FocusScan', printDetail);
          if (activatedLineCount)
            %because lines have been activated, we likely have added modules that are called:
            progress('listboxMsg_Callback', sprintf('Re-checking for included modules: activated/uncommented lines in %s for special code ("#IFDEF FocusScan/#ENDIF" pairs)', name));
%            [err, errMsg, nonMLFunctionNames, nonMLFunctionCount, moduleAlias, numAdded]...
%              = expandList(fromDir, name, targetDir, modName, nameExt, nonMLFunctionNames, nonMLFunctionCount, moduleAlias);
            [err, errMsg, nonMLFunctionNames, nonMLFunctionCount, moduleAlias, numAdded]...
              = expandList(pathstr, name, targetDir, modName, nameExt, nonMLFunctionNames, nonMLFunctionCount, moduleAlias);
            if printDetail
              fprintf('\n   Number of lines activated: lines read & written %i, lines activated %i', linesRead, activatedLineCount);
              fprintf('\n     %i new modules added', numAdded);
            end
            anyAdded = anyAdded + numAdded;
            modulesByKey(keysFound(keysFoundNdx)) = modulesByKey(keysFound(keysFoundNdx)) + 1;
            modulesModName(keysFound(keysFoundNdx), modulesByKey(keysFound(keysFoundNdx))) = {nameExt};
          end
        end % if findstrchr(char(keysToFind(keysFoundNdx)), '#IFDEF FocusScan') 
        if a & (linesRead ~= linesWritten)
          a = 0;
          anyChange = 1;
          if printDetail
            fprintf('\n   New number of lines: lines read %i, lines written %i, difference (read-write) = %i', linesRead, linesWritten, linesRead - linesWritten);
          end
        end
      end % for keysFoundNdx = 1:length(keysToFind)
      if anyChange
        if printDetail
          fprintf('\n   Total change in number of lines: initial lines %i, final lines %i, difference (iniital - final) = %i', initLinesRead, linesWritten, initLinesRead - linesWritten);
        end
      end
      %remove the .tmp file that was the temporary source
      [status,result] = dos(dosCommand_delTmp);
    end % if any(keysFound)
  else %if ~ismember(nameExt, justCopyModules); 
    [thisFileBytesRead, thisFileBytesWritten] = justCopy(nameExt, pathstr, targetDir);
    justCopyModulesCopied(find(a)) = 1;
  end %if ~ismember(nameExt, justCopyModules);  else
  checkUpdateWaitBar(listNdx/length(nonMLFunctionNames), h_waitBar);
  if userCancel
    break
  end
end %while listNdx < length(nonMLFunctionNames)
closeAllWaitBars;
if userCancel
  err = 1;
  errMsg = sprintf('%s: user cancel', modName);
  return
end

a = find(justCopyModulesCopied < 1);
itemp = 0;
if a
  justCopyModules = justCopyModules(a);
  for itemp = 1:length(justCopyModules)
    if length(char(justCopyModules(itemp)) )
      [thisFileBytesRead, thisFileBytesWritten] = justCopy(char(justCopyModules(itemp)), fromDir, targetDir);
    end
  end %for itemp = 1:length(justCopyModules)
end %if a
if debugCode
  a = '"Debug" & uses mfilename/modName';
else
  a = '"Release" & replaced mfilename/modName with number from "moduleAlias.txt"';
end
% % %code is almost identical except for the fprintf statements
% % if ~h_progress
% %   fprintf('\n%i function files copied and modified as directed by #IFDEF statements, %i total files copied', nonMLFunctionCount, nonMLFunctionCount+itemp);
% %   fprintf('\n   %i files modified for "if testDEBUGrelease" structures for', modulesByKey(length(modulesByKey)));
% %   fprintf('\n   %s.', a);
% %   for jtemp = 1: modulesByKey(length(modulesByKey))
% %     if 1 == mod(jtemp,5)
% %       fprintf('\n     ');
% %     else
% %       fprintf(', ');
% %     end
% %     fprintf('%s', char(modulesModName(length(modulesByKey),jtemp)));
% %   end
% %   for itemp = 1:length(keysToFind) 
% %     fprintf('\n   %i files also modified for "%s" structures.', modulesByKey(itemp), char(keysToFind(itemp)) );
% %     for jtemp = 1: modulesByKey(itemp)
% %       if 1 == mod(jtemp,5)
% %         fprintf('\n     ');
% %       else
% %         fprintf(', ');
% %       end
% %       fprintf(' [%s]', char(modulesModName(itemp,jtemp)));
% %     end
% %   end % for itemp = 1:length(keysToFind) 
% % else %if ~h_progress
  progress('listboxMsg_Callback', ...
    sprintf('%i function files copied to compile directory and then modified if needed per #IFDEF statements, %i total files copied.', nonMLFunctionCount, nonMLFunctionCount+itemp));
  progress('listboxMsg_Callback', sprintf('   %i files modified for "if testDEBUGrelease" structures for', modulesByKey(length(modulesByKey))));
  progress('listboxMsg_Callback', sprintf('   %s.', a));
  aLine = '     ';
  for jtemp = 1: modulesByKey(length(modulesByKey))
    if 1 == mod(jtemp,5)
      progress('listboxMsg_Callback', aLine);
      aLine = '     ';
    else
      aLine =sprintf('%s, ', aLine);
    end
    aLine = sprintf('%s%s', aLine, char(modulesModName(length(modulesByKey),jtemp)));
  end
  for itemp = 1:length(keysToFind) 
    if length(aLine)
      progress('listboxMsg_Callback', aLine);
    end
    aLine = '     ';
    progress('listboxMsg_Callback', sprintf('   %i files also modified for "%s" structures.', modulesByKey(itemp), char(keysToFind(itemp)) ));
    for jtemp = 1: modulesByKey(itemp)
      if 1 == mod(jtemp,5)
        progress('listboxMsg_Callback', aLine);
        aLine = '     ';
      else
        aLine =sprintf('%s, ', aLine);
      end
      aLine =sprintf('%s[%s]', aLine, char(modulesModName(itemp,jtemp)));
    end
  end % for itemp = 1:length(keysToFind) 
  if length(aLine)
    progress('listboxMsg_Callback', aLine);
  end
% % end %if ~h_progress else

if nargout < 1
  progress('listboxMsg_Callback', sprintf(' error %i, %s', err, errMsg));
  clear err
else %if nargout < 1
  if err
    errMsg = strcat(modName, errMsg);
  end
end %if nargout < 1 else
if anyAdded
  %Re-alphabetize: when lines that are uncommented result in new modules, the new
  % new modules HAVE to be added to the end so the list could be out of order.
  %NOTE: this is duplicated just before the local function "findNonMLfunctions" (below)
  %alphabetize to make it easier for the user to review the satus from the screen
  % obtain the indices based on one case and then...
  [a, Ndx] = sort(lower(nonMLFunctionNames));
  % apply the indices to the possibly mixed case actual names
  nonMLFunctionNames = nonMLFunctionNames(Ndx);
end
closeAllWaitBars

%%%%% MAIN END %%%%%
%%%%% MAIN END %%%%%
%%%%% MAIN END %%%%%


%%%%%%%%%%%%%%%%%%%%%%%
function [thisFileBytesRead, thisFileBytesWritten] = justCopy(nameExt, fromDir, targetDir)
%if "nameExt includes a path, it will be used.  Otherwise "fromDir" is used
global userCancel
%%%%%%%%%%%%%%%%%%%%%%%
progress('listboxMsg_Callback', sprintf('Copying without modification "%s"', nameExt));
%if a bindary file, use the DOS copy.  Opening the DOS is slow so we don't use it for .m
[pathstr,name,ext,versn] = fileparts(nameExt);
if ~length(pathstr)
  fromDirNameExt = strcat(fromDir, nameExt);
end
binaries = {'.exe','.bin','.dll','.fig','.mat'};
if any(ismember(binaries, lower(ext)))
  [err, errMsg] = dosIt(sprintf('copy %s %s%s', fromDirNameExt, targetDir, nameExt), '', nargout);
  if err
    thisFileBytesRead = 0;
  else
    a = dir(fromDirNameExt);
    thisFileBytesRead = a.bytes;
  end
  thisFileBytesWritten = thisFileBytesRead;
else %if any(ismember(binaries, ext))
  fidIn = fopen(fromDirNameExt,'r');
  fidOut = fopen(strcat(targetDir, nameExt),'w');
  thisFileBytesRead = 0 ;
  thisFileBytesWritten = 0;
  while ~feof(fidIn);
    textLine = fgetl(fidIn);
    thisFileBytesRead = thisFileBytesRead + length(textLine);
    %line processing goes here
    thisFileBytesWritten = fprintf(fidOut,'%s\r\n', textLine) + thisFileBytesWritten - 2;
    checkCancel;
    if userCancel
      break
    end
  end
  fcloseIfOpen(fidIn);
  fcloseIfOpen(fidOut);
end %if any(ismember(binaries, ext))
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function [nonMLFunctionCount, nonMLFunctionNames] = findNonMLfunctions(list, fromDir, enableWaitBar);
% "fromDir" no longer used
global userCancel

MLRoot = 'MATLAB';
if nargin < 3 
  enableWaitBar = 1;
end
if enableWaitBar
  closeAllWaitBars
  initWaitBar(sprintf('Finding the non-MATLAB modules'));
end
%search the list of all functions to find only the non-MATLAB functions
nonMLFunctionCount = 0;
for listNdx = 1:length(list)
  a = char(list(listNdx));
  [pathstr,name,ext,versn] = fileparts(a);
  nameExt = strcat(name, ext);
  if strcmp('.m', lower(ext))
    %if this Listed function is one of our modules (not in <drive>\MATLAB*\... directory tree)
    % OLD: (is in the present directory defines it as one of our modules and not a ML module)
    %                     AND if this is an M file 
    slashAt = findstrchr('\', a);
    if slashAt(1) > 1
      compareStart = 1 + slashAt(1) ;
    else
      %network naming: \\<name>\<drive>\<path>\... or 
      %                \\<name>\<path>\...
      compareStart = 1 + slashAt(4);
    end
    % OLD if findstrchr(fromDir, a)
    b = findstrchr(MLRoot, pathstr);
    % if MLRoot isn't in the path or isn't the root
    if ~b | (b > compareStart) 
      nonMLFunctionCount = nonMLFunctionCount + 1;
      nonMLFunctionNames(nonMLFunctionCount) = list(listNdx);
    end
  end % if strcmp('.m', lower(ext))
  if enableWaitBar
    checkUpdateWaitBar(listNdx/length(list));
  end
  checkCancel;
  if userCancel
    break
  end
end %for listNdx = 1:length(list)
if userCancel
  return
end
%NOTE: this is duplicated just before the main RETURN
%alphabetize to make it easier for the user to review the satus from the screen
% obtain the indices based on one case and then...
[a, Ndx] = sort(lower(nonMLFunctionNames));
% apply the indices to the possibly mixed case actual names
nonMLFunctionNames = nonMLFunctionNames(Ndx);
if enableWaitBar
  closeAllWaitBars
end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function [err, errMsg, nonMLFunctionNames, nonMLFunctionCount, moduleAlias, numAdded]...
  = expandList(fromDir, name, targetDir, modName, nameExt, nonMLFunctionNamesIn, nonMLFunctionCountIn, moduleAliasIn); 
% function [err, errMsg, nonMLFunctionNames, nonMLFunctionCount, moduleAlias]...
%   = expandList(fromDir, name, targetDir, nameExt, modName[, nonMLFunctionNamesIn, nonMLFunctionCountIn, moduleAliasIn]); 
%Create or expand "nonMLFunctionNames", "nonMLFunctionCount", & "moduleAlias"
%If nargin stops at "modName", we are creating the list for the first time.  Otherwise we are
% appending to it.

global userCancel

if nargin < 6
  addToList = 0;
else
  addToList = 1;
end
nonMLFunctionNames = {''} ;
nonMLFunctionCount = 0 ;
moduleAlias = {''} ;
numAdded = 0;


if addToList
  % we need to review the dependent functions & expand as necessary
  %First we need to make a temporary copy that is in the main source directory:
  %  so all modules can be found/identified
  tmpCopy = sprintf('%s%s_tmp.m', fromDir, name);
  dosCommand = sprintf('copy "%s" "%s"', strcat(targetDir, nameExt), tmpCopy);
  [status,result] = dos(dosCommand);
  if status
    err =  1;
    errMsg = sprintf('%s: %s attempting [%s].', modName, result, dosCommand);
    if nargout < 1
      fprintf('\n **** Error: %s', errMsg);
    end
    %%%%%%
    return
    %%%%%%
  end
else
  tmpCopy = name;
end %if addToList
% second: determine the dependencies:
if iscell(tmpCopy)
  [list,builtins,classes,prob_files,prob_sym,eval_strings,...
      called_from,java_classes] = depfun(tmpCopy{:},'FigureToolBar.fig','FigureMenuBar.fig');
else
  [list,builtins,classes,prob_files,prob_sym,eval_strings,...
      called_from,java_classes] = depfun(tmpCopy,'FigureToolBar.fig','FigureMenuBar.fig');
end
if length(prob_files)
  if length(prob_files) > 1
    errMsg = sprintf('%s: "depfun" reported problems with %i files.  Possibly syntax error(s): set breakpoints in: ', modName, length(prob_files));
  else
    errMsg = sprintf('%s: "depfun" reported problems with %i file.  Possibly syntax error(s): set breakpoints in: ', modName, length(prob_files));
  end
  for itemp = 1:length(prob_files)
    errMsg = sprintf('%s %s', errMsg, char(prob_files(itemp).name));
  end
  errMsg = sprintf('%s.', errMsg);
  err = 1;
  if nargout < 1
    fprintf('\n **** Error: %s', errMsg);
  end
  %%%%%%
  return
  %%%%%%
end % if length(prob_files)

if addToList
  %third remove the temporary copy
  dosCommand = sprintf('del "%s"', tmpCopy);
  [status,result] = dos(dosCommand);
  if status
    err =  1;
    errMsg = sprintf('%s: %s attempting [%s].', modName, result, dosCommand);
    if nargout < 1
      fprintf('\n **** Error: %s', errMsg);
    end
    %%%%%%
    return
    %%%%%%
  end
end %if addToList
checkCancel;
if userCancel
  return
end

%'Creating source .m code'

%find those which are ours:
if ~addToList
  progress('updateStatusNext', 'running'); %'Determining which modules are non-MATLAB'
end
[nonMLFunctionCount, nonMLFunctionNames] = findNonMLfunctions(list, fromDir, 0);
numAdded = nonMLFunctionCount;
if addToList
  %check for functions we all ready have in our list: they are duplicates so skip those
  % initialize a flag array
  new = ones(1,nonMLFunctionCount);
  %loop through the new list & adjust the flag as needed
  for itemp = 1:length(nonMLFunctionNames)
    [pathstr,n,e,versn] = fileparts(char(nonMLFunctionNames(itemp)));
    nE = strcat(n, e);
    %loop through the old list looking for duplicates
    for jtemp = 1:length(nonMLFunctionNamesIn)
      if findstrchr(char(nonMLFunctionNamesIn(jtemp)), nE)
        %clear the flag for this new function: it isn't new!
        new(itemp) = 0;
        break
      end
      checkCancel;
      if userCancel
        break
      end
    end %for jtemp = 1:length(nonMLFunctionNamesIn)
    if userCancel
      break
    end
  end %for itemp = 1:length(nonMLFunctionNames)
  if userCancel
    return
  end
  %The temporary file created for the dependency determination IS in the list 
  % but we don't want it to be: find its position in the list & clear that flag.
  for itemp = 1:length(nonMLFunctionNames)
    if findstrchr(tmpCopy, char(nonMLFunctionNames(itemp)));
      %Found!  clear & bounce out of here
      new(itemp) = 0;
      break
    end
    checkCancel;
    if userCancel
      break
    end
  end % for itemp = 1:length(nonMLFunctionNames)
  %extend the list with the new functions
  nonMLFunctionNames = [nonMLFunctionNamesIn nonMLFunctionNames(find(new))];
  nonMLFunctionCount = length(nonMLFunctionNames);
  numAdded = length(find(new));
end % if addToList else
if userCancel
  return
end
%update the "moduleAlias" list: lazy: review the entire list
[err, errMsg, moduleAlias] = moduleAliasFromList(nonMLFunctionNames, 0);
%%%%%% function expandList
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
