function [err, errMsg, targetDir] = makeExe_general(coreModules, progJustOpened);
%targetDir does not end with a '\'
%
%General Make file for building stand-alone executables.
%Performs the following tasks:
% a) interacts with the user to determine if "Debug" or "Release"
%   version is to be developed.
% b) creates the source code suitable for Debug or Release from the general source code,
%   processing each function file suitably.  The new source code will be placed
%   in a directory off the current directory: either ReleaseF:\cpack200\EDC\dataF:\cpack200\EDC\data or Debug
% c) For the release form, performs obfuscation.
% d) Compiles the code
% e) If successfuly, places all the new source code and the compiled executable into 
%   a zip file with a name based on the first name in the coreModules list.  The name includes
%   the date & time of the compile,
%INPUT
% coreModules: a cell list of all modules which need to be compiled and
%              accessible.
%
%
%M. Herrmann
%EDC Biosystems
%VSS revision   $ $
%Last checkin   $ $
%Last modify    $ $
%Last changed by $$
%  $NoKeywords: $

global userCancel hCancel

err = 0;
errMsg = '';
modName = '>makeExe_general';

%TODO:
%"Cancel" button caused: Warning: One or more output arguments not assigned during call to 'precompilecopy (expandList)'.

% check for write capable for .exe
%need to erase the .exe from the first compile!
%need to checkout moduleAlias and possibly reservedNames.txt. . . and test for writing
%  perhaps have a "debuggin" option so files don't have to be checked out but read-only will be turned
%  off AND the code will know this!
%include ZIP name on panel?
%displaying/fprintf of changing dir could be done in the make current directory call: both the current & to-be-current are there!
%cd could be via a call: saves one line per operation

%add confirmation of del *.c_tmp

% This may become a passed in parameter.  It could then also have a flag for
% when we're calling this repeatedly to update a number of modules: the flag
% would be used so the user is only asked once & then that answer is apllied 
% to all calls
%set the default key to be highlight appropriately:

%progress:
% * save debug & release seperately?
% * add ability to clear all code break points not just figure's.  Could have two: all code; all code + system(err, warning, etc)
%    heck, while we're at it, we could have a restore code & restore system breakpoints!
% * add "try again"?
% * breakpoints set/cleared or enabled/disabled while release/debug/cancel is up are lost!

% why is compiled fig 1 not waiting for user reponse??? Annoying!!

% preCompileCopy if main function is bad/not compilable or no edcfunctions detected!!
% prob_files = 
% name: 'D:\Cpack200\EDC\data\extractExperimentsFromLog.m'
% listindex: 1
% errmsg: 'Problem compiling file'
% action if user changes breakpoint while debug/release/cancel is up!

if nargin < 2
  progJustOpened = -1;
else
  %if flag is set, make its value suitable for progress to act appropriately
  if progJustOpened == 1;
    progJustOpened = -2;
  end
end

if ~iscellstr(coreModules)
  coreModules = {coreModules};
end
[pathstr, outputFileName, ext,versn] = fileparts(char(coreModules(1)));
outputFileExt = '.exe';
outputFileNameExt = strcat(outputFileName, outputFileExt);

%file(s) that are copied to the release directory without modification
files2CopyToReleaseDir = {...
    'ReservedNames.txt'
};

% some files are of interest for both forms of compilaton & some only for Release...
%Here is a list of both:
%for check-in, these files will be not be from the working Matlab source directory but
% from the post-manipulation directory - either \Debug or \Release
files2CopyBackFromCompileDir = {...
    outputFileNameExt
};
%Here is a list of \Release only:
%for check-in, these files will be not be from the working Matlab source directory but
% from the post-manipulation Release directory - these are NOT involved in Debug compile
filesFromReleaseDir = {...
    'Obfuscate.fpf',...
  };
doNotDeleteButCheckout = {
    'moduleAlias.txt',...
    'lldHistory.txt'
};

%these are checked out....and will be deleted from \debug or \release at the start unless in the "doNotDeleteButCheckout" list
fileNames2CheckOut = [...
    doNotDeleteButCheckout...
    files2CopyBackFromCompileDir...
    filesFromReleaseDir...
    {...
    }];


%first call to progress figure
namesOfSteps = {...
    'Program initialization',...
    'Configuration by user',...
    'Determining all modules used',...
    'Identifying Custom modules',...
    'Creating source .m code',...
    'Deleting old C code',...
    'M->C convert, compile, & link',...
};%  program status identifier 

cancel;
compiledName = mfilename;


debugCode = 0;
%just some junk as a reminder of how to use:
debugRuleList = {'including focus scan','exciting features'};
originalPWD = endWithBackSlash(pwd);
%first call of 2
%list steps, debug/release not known: don't display
[h_progress, err, maxStepLabels] = progress(namesOfSteps, progJustOpened, strcat(outputFileName, '.exe'), originalPWD, debugRuleList);
progress('updateStatus', 1, 'running');
%while this same routine is called in the general prupose caller "makeDiagnostics", perhaps the user 
%  has directly called this module directly.  It doesn't hurt to double check.
[err, errMsg] = compileDirectoryConfirm;

%The diary name will include the name of the first module: unique diary for call
% from each compile.
diaryFileName = sprintf('diary%s.txt', outputFileName);
%create diary, after deleting any same-named diary, and turn it on
[err, errMsg] = progress('checkDiaryOn_Callback', 1, diaryFileName);
if err
  progress('listboxMsg_Callback', errMsg);
  progress('updateStatusCurrent', 'Fail');
  return
end

if debugCode
  a = 'Debug Code';
else
  a = 'Obfuscated Release code';
end
progress('updateStatusNext', 'running');
button = questdlg('Generate debug code or release code',...
  'Compile Type','Debug Code','Obfuscated Release code','Cancel', a);
if strcmp(button,'Cancel')
  errMsg = 'User cancel';
  progress('listboxMsg_Callback',errMsg);
  progress('checkDiaryOn_Callback', 0);
  progress('updateStatusCurrent', 'Fail');
  err = 1;
  return
end
a = strcmp(button,'Debug Code');
debugCode = a;
%do a screen print for the diary
if debugCode
  progress('listboxMsg_Callback', 'Generating Debug Code');
  debugRuleList = {};  %focus scan would go here.. if it were relevant
else
  progress('listboxMsg_Callback', 'Generating Release code');
  %add the additional steps associated with release compile
  namesOfSteps = [namesOfSteps ...
      {...
      'Copying *.c, etc to *.c_tmp',...
      'Creating obfuscated names',...
      'Recover *.c_tmp, etc. to *.c',...
      'Obfuscate non-user literals',...
      'Obfuscating *.c code',...
      'Compiling obfuscated',...
    }...
  ]; % program status identifier and the
  debugRuleList = {};  %ignored by fig in release mode
end
%finalize by adding the closing steps common to debug and release
%       
%%% ********* WARNING ********
%%% ********* WARNING ********
%%%
%%% One of the names in this list is used in "makeCompiled_zip.m"
%%%  do NOT change it here without changing it there as well
%%%        'Creating archive ZIP: all'
%%%      
%%% ********* WARNING ********
%%% ********* WARNING ********
namesOfSteps = [namesOfSteps ...
    {...
      'Creating archive ZIP: all',...
      'Creating archive ZIP: source',...
    }...
  ];
%2 of 2 calls, passing just the updated list in "namesOfSteps" & debug/release
h_progress = progress(namesOfSteps, debugCode, strcat(outputFileName, '.exe'), originalPWD, debugRuleList, guidata(h_progress));
button = questdlg('Pausing to allow you to condition breakpoints.','Breakpoints','Ready','Cancel','Ready')
%a = helpdlg('Pausing to allow you to condition breakpoints. <enter> or click OK when satisfied.','Pause')
if strcmp(button,'Cancel')
  errMsg = 'User cancel';
  progress('listboxMsg_Callback',errMsg);
  progress('checkDiaryOn_Callback', 0);
  progress('updateStatusCurrent', 'Fail');
  err = 1;
  return
end %if strcmp(button,'Cancel')

keysToFind = {'#IFDEF debugOnly'} ; %pulls the IDE-only code segments
justCopyModules = {''};

[err, errMsg] = makeAbout_diag(debugCode, keysToFind, outputFileName, 0);

if debugCode
  targetDir = 'Debug';
else
  targetDir = 'Release';
  justCopyModules = [justCopyModules files2CopyToReleaseDir];
end
targetDir = sprintf('%s_%s', targetDir, outputFileName);
%paired list of master source name/to-be-compiled source name
sourceAlias = {};
progress('updateStatusNext', 'running'); %Determining all modules used
[err, errMsg, fulltargetDir, nonMLFunctionNames, modulesModName, modulesByKey, fileListName]...
  = preCompileCopy(debugCode, targetDir, coreModules, justCopyModules, keysToFind, sourceAlias, 0, outputFileName, '.exe');
if err | userCancel
  progress('listboxMsg_Callback', sprintf('Error: %s', errMsg));
  %turn off diary:
  progress('checkDiaryOn_Callback', 0);
  cancelClose;
  progress('updateStatusCurrent', 'Fail');
  if err
    errMsg = strcat(modName, errMsg);
  else
    errMsg = 'User cancel';
  end
  progress('listboxMsg_Callback', sprintf('%s', errMsg));
  return
end

progress('editTrgDir_Callback', fulltargetDir)
progress('updateStatusCurrent', 'pass');

%write the .m file which contains the exact compiler commands.  We'll call this file 
%  in a few lines to actual perform the compilation.
%We are writing the file rather than having it hard coded so we can have this module
% common for compilations of a number of different "main" files rather than duplicating code
% and all the updating nightmares that imposes!
fid = fopen(sprintf('%smccMakeExe_%s', fulltargetDir, char(coreModules(1))), 'w');
if fid < 1
  %turn off diary:
  progress('checkDiaryOn_Callback', 0);
  cancelClose;
  errMsg = 'Error: unable to open/create "mccMakeExe_general.m"';
  progress('listboxMsg_Callback', errMsg);
  return
end
%done creating the compiler directions

%%% message for the "checkCompilerMessages.m" procedure that is run at the end
progress('listboxMsg_Callback', 'End of actions messages.')

progress('listboxMsg_Callback', sprintf('*=*=*= Switching to directory "%s" from "%s"\n', fulltargetDir, originalPWD));
cd(fulltargetDir);
progress('editCurDir_Callback', fulltargetDir);

fprintf(fid,'function [err, errMsg] = mccMakeExe_%s(fulltargetDir, originalPWD, exeName, h_progress);', outputFileName);
fprintf(fid,'\r\n%% **** DO NOT ALTER THIS MODULE:  IT IS CREATED BY "%s" SO CHANGES HERE ARE LOST!! ****', mfilename);
fprintf(fid,'\r\nerr = 0;');
fprintf(fid,'\r\nerrMsg = '''' ;');
fprintf(fid,'\r\ntry %try/catch to get us back to the original directory when we crash & burn');
fprintf(fid,'\r\n  fprintf(''\\n'')');
a = '';
for itemp = 1:length(coreModules)
  a = sprintf('%s ', char(coreModules(itemp)) );
end
%         verbose: -v -B sgl: Stand-alone C graphics library application
cmp = sprintf('mcc -v -B sgl %s', a);
fprintf(fid,'\r\n  progress(''listboxMsg_Callback'', ''Compiling: %s'');', cmp);
fprintf(fid,'\r\n  %s', cmp);

fprintf(fid,'\r\ncatch');
fprintf(fid,'\r\n  progress(''listboxMsg_Callback'', sprintf(''%%s'', lasterr));');
fprintf(fid,'\r\n  progress(''listboxMsg_Callback'', sprintf(''*=*=*= Returning from directory "%%s" to "%%s"'', fulltargetDir, originalPWD));');
fprintf(fid,'\r\n  cd(originalPWD);');
fprintf(fid,'\r\n  progress(''editCurDir_Callback'', originalPWD);');

fprintf(fid,'\r\n  progress(''listboxMsg_Callback'', sprintf (''*********** %%s.exe NOT created! ************'', exeName));');
fprintf(fid,'\r\n  err = 1;');
fprintf(fid,'\r\nend');
fclose(fid);
% % %make a copy for archiving
% % copyfile('mccMakeExe_general.m', sprintf('mccMake%s', char(coreModules(1)) ) );

progress('updateStatusNext', 'Running'); %deleting old C
%files we want to delete
delFiles = {'*.c', '*.h'};
%write a batch file for speed: only take the time to open dos once
fid = fopen('clearIt.bat', 'w');
fprintf(fid, '@echo off\r\n');
%go through the list adding all from the list
for itemp = 1:length(delFiles)
  a = char(delFiles(itemp));
  fprintf(fid,'echo clearing %s%s\r\n', fulltargetDir, a);
  fprintf(fid,'del "%s%s"\r\n', fulltargetDir, a);
end
%clear all the files in the targetDir we want to copy back just so if the compile process fails the files are gone & we won't be confused
for itemp = 1:length(files2CopyBackFromCompileDir)
  a = char(files2CopyBackFromCompileDir(itemp));
  %append to the list -> we use this list to confirm the operation in a few lines
  delFiles = [delFiles {a}];
  fprintf(fid,'echo clearing %s%s\r\n', fulltargetDir, a);
  fprintf(fid,'del "%s%s"\r\n', fulltargetDir, a);
end
fcloseIfOpen(fid);
%need to check that this worked!
status = dos('clearIt.bat');
%confirm the deletions
err = 0;
for itemp = 1:length(delFiles)
  b = char(delFiles(itemp));
  a = dir(strcat(fulltargetDir, b));
  if length(a)
    err = 1;
    for jtemp = 1:length(a)
      progress('listboxMsg_Callback', sprintf('Unable to delete "%s"', char(a(jtemp).name)));
    end
  else
    fprintf('\n OK with del %s', b);
  end
end %for itemp = 1:length(delFiles)

checkCancel;
if userCancel | err
  cd(originalPWD);
  progress('editCurDir_Callback', originalPWD);
  %turn off diary:
  progress('checkDiaryOn_Callback', 0);
  cancelClose;
  progress('updateStatusCurrent', 'Fail'); %deleting
  if userCancel
    errMsg = 'User cancel';
    progress('listboxMsg_Callback', errMsg);
  end
  return
end % if userCancel

%perform the compilation by calling the module we created above
progress('updateStatusNext', 'Running'); %compiling
[err, errMsg] = feval(sprintf('mccMakeExe_%s', outputFileName), fulltargetDir, originalPWD, outputFileName, h_progress);

compilerProblems = 0;
if err
  progress('updateStatusCurrent', 'Fail'); %compiling
end
if (~err)  
  secPrecision = 3;
  [err, errMsg, date_time] = datevec2timeStamp(now, secPrecision);
  %always want the "date_time" string the same length so all directory viewing, such as with Explorer,
  %  doesn't get confused.  Add trailing zeros as required.  NOTE: I'm pulling trailing zeroes in 'datevec2timeStamp'
  % but I have no comment on why!!! AR
  a = (13+secPrecision) - length(date_time);
  for itemp = 1:a
    date_time = strcat(date_time, '0');
  end
  progress('listboxMsg_Callback', sprintf(' "%s.exe" compilation done!', outputFileName));
  
  progress('listboxMsg_Callback', sprintf('*=*=*= Returning from directory "%s" to "%s"', fulltargetDir, originalPWD));

  cd(originalPWD);
  progress('editCurDir_Callback', originalPWD);
  
  %turn off diary:
  progress('checkDiaryOn_Callback', 0);% paritally done writing to diary, so close it.
  %check for errors.  If we are in Release mode, only display error messages -> this is not the final call
  [compilerProblems, errMsg, badNewsText] = checkCompilerMessages(diaryFileName, ~debugCode);
  %turn on diary:
  progress('checkDiaryOn_Callback', 1);%%esume the diary for the rest of the action
  if compilerProblems
    progress('updateStatusCurrent', 'Fail'); %compiling
  else
    progress('updateStatusCurrent', 'Pass'); %compiling
    if ~debugCode
      [err, errMsg, listNameAlias] = mbuildAndObfuscate(strcat(originalPWD, diaryFileName), fulltargetDir, nonMLFunctionNames, outputFileName, '.exe');
      checkCancel;
      if userCancel | err
        progress('updateStatusCurrent', 'Fail'); %compiling
        cd(originalPWD);
        progress('editCurDir_Callback', pwd);
        if userCancel
          progress('listboxMsg_Callback', sprintf ('\n*********** user abort after return from "mbuildAndObfuscate" ************'));
        else
          progress('listboxMsg_Callback', sprintf('\n ****** err: %i %s', err, errMsg));
        end
      end %if userCancel | err
      progress('updateStatusCurrent', 'Pass'); %%Creating archive ZIP
      %turn off diary:
      progress('checkDiaryOn_Callback', 0);% paritally done writing to diary, so close it.
      %Release mode final check for errors.
      [compilerProblems, errMsg, badNewsText] = checkCompilerMessages(diaryFileName);
      %turn on diary:
      progress('checkDiaryOn_Callback', 1);%resume the diary for the rest of the action
    end %if ~debugCode
  end % if compilerProblems == 0
end %if ~err
if (~err & (compilerProblems == 0))
  %copy identified files back so VSS can easily check them in
% % %   [err, errMsg] = makeLLD_copyBack(debugCode, files2CopyBackFromCompileDir, filesFromDebugReleaseDir, filesFromReleaseDir, fulltargetDir, originalPWD);
  %turn off diary:
  progress('checkDiaryOn_Callback', 0);% all done writing to diary, so close it.
  [err, errMsg] = makeCompiled_zip(date_time, originalPWD, fulltargetDir, fileNames2CheckOut, '', diaryFileName, outputFileName, '.exe', fileListName, debugCode, nonMLFunctionNames);
  if err
    progress('updateStatusCurrent', 'Fail'); %%Creating archive ZIP
  else
    progress('updateStatusCurrent', 'Pass'); %%Creating archive ZIP
  end
else %if (~err & (compilerProblems == 0))
  progress('updateStatusCurrent', 'Fail'); %%Creating archive ZIP
  %%% message for the "checkCompilerMessages.m" procedure that is run at the end
  progress('listboxMsg_Callback', 'End of actions messages.')
  %turn on diary:
  progress('checkDiaryOn_Callback', 1);%%esume the diary for the rest of the action
  if compilerProblems
    progress('listboxMsg_Callback', sprintf ('*********** "%s.exe" INVALID/risky! NOT copied nor archived! ************', outputFileName) );
  else
    progress('listboxMsg_Callback', sprintf ('*********** "%s.exe" NOT created! ************', outputFileName) );
  end
  %turn off diary:
  progress('checkDiaryOn_Callback', 0)
end %if (~err & (compilerProblems == 0)) else

% % % [err, errMsg] = makeLLD_VSSend(checkoutSuccess, (compilerProblems | err), fileNames2CheckOutAndPath, nameForReload);

progress('listboxMsg_Callback', 'done');
cancelClose;

cd(originalPWD);
progress('editCurDir_Callback', pwd);
