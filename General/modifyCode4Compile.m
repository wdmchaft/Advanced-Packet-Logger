function [err, errMsg, linesRead, linesWritten, keysFound, figFound] = modifyCode4Compile(desktopSourceFileName, compileSourceFileName, debugCode, keysToFind, noPrint, moduleAlias, fileListName)
%function [err, errMsg, linesRead, linesWritten, keysFound, figFound] = modifyCode4Compile(desktopSourceFileName, compileSourceFileName, debugCode[, keysToFind[, noPrint[, moduleAlias[, fileListName]]]])
%Part of code obfuscating
%INPUT
%desktopSourceFileName, compileSourceFileName: path and name as indicated for input
%  and output files.
%debugCode: flag, "1" to generate debug version, "0" for release version
%keysToFind[optional]: cell list of #IFDEF key phrase(s).  The returned flag "keysFound"
%  will be set to the key(s) found after the Debug/Release code conditioning has occurred
%  This flag allows the passes for those phrases to be limited to the affected modules.
%noPrint[optional]: if not present or set to 0, prints out to monitor the lines read & written
%moduleAlias[optional]: if present, "modName" & "mfilename" replace with this text.  Otherwise they
% are both blank (NULL string).  Having this available helps with error message with release code.  
%  NOTE: this cannot be null when any GUI .fig needs to be available.
%RETURNED:
% All self-explanatory
%OPERATION:
% a) Copies "desktopSourceFileName" to "compileSourceFileName" including only lines 
%   associated with the indicated mode for the compile: "debug" mode includes
%   debug lines and excludes release lines.  The lines are identified by
%   an if/else/end structure and associated global as shown below.  The rules
%   associated are:
%   1a) the "if testDEBUGrelease" or "if ~testDEBUGrelease" starts the conditionally
%      included line region.  This declaration has to be the first on the
%      line excluding leading spaces.  It can be the first part of a phrase althought "|" or
%      "&" must be AFTER and no parenthesis can be in *this* part of the phrase.
%   1b) The phrase can be a comment as long as it is a single "%" (spaces ignored)
%       This feature allows sub functions with in a module to be removable: functions
%       cannot be defined within an active "if" structure.  By allowing a commented
%       "if" structure to be detected, we can have the auto-removability feature.
%   2) Both the "else" and the "end' must be followed by "% if testDEBUGrelease" or 
%      "% if ~testDEBUGrelease" as consistent with the associated "if"  Spaces are 
%      allowed as separators and addtional information can be in the comment after
%      the word testDEBUGrelease.
%   The variable "testDEBUGrelease" will be used in the Matlab desktop IDE to allow
%   testing of each code type.
% b) copies & renames any GUI .fig file associated with the .m file (as determined by an 
%    "openfig(mfilename..." statement in the .m file name).  The copied name is the <moduleAlias>
%    text.  
% c) Release code: replaces all references to the Matlab keyword "mfilename" with and empty string
%    because the ML converter replaces this variable with text when it creates the .c & .h code:
%    no obfuscation would occur as the existing file names/function names would be present!
% d) Release code: alters all "modName = " with "modName = '' ".  This will obfuscate the content
%    of "modName" as long as the assignment is not as a returned parameter in a parameter
%    list such as [err, errMsg, modName].  The only time we appear to use that is style
%    is with the call to "initErrModName" so that is handled seperately.
% e) Release code: The parameter passed to "initErrModName" will be change to an empty string.
% %   
% % EXAMPLES: note that "else" isn't required
% global testDEBUGrelease %place nothing else on this line: only for use on desktop 
%
% if testDEBUGrelease
%   %code for use in debug compile mode is here
% else % if testDEBUGrelease
%   %code for use in release compile mode is here
% end % if testDEBUGrelease else
%
% if ~testDEBUGrelease
%   %code for use in release compile mode is here
% else % if ~testDEBUGrelease
%   %code for use in debug compile mode is here
% end % if ~testDEBUGrelease else
%Inserts a warning comment at the beginning of the file after the first blank line
% if testDEBUGrelease
% else % if testDEBUGrelease
% end % if testDEBUGrelease else
%VSS revision   $Revision: 12 $
%Last checkin   $Date: 3/08/07 11:11a $
%Last modify    $Modtime: 3/08/07 11:11a $
%Last changed by$Author: Arose $
%  $NoKeywords: $

[err, errMsg, modName] = initErrModName(mfilename);
keysFound = 0;
figFound = 0; %flag if call back figure found
if nargin < 4
  keysToFind ={}; 
end
if nargin < 5
  noPrint = 0;
end
if nargin < 6
  moduleAlias = '';
end
if nargin < 7
  fileListName = '';
end

lengthkeysToFind = length(keysToFind);
%flag array of the phrases that need to be checked & haven't yet been found
keysNotDetectedNdx = ones(size(keysToFind));
% array of indices to the phrases which need to be found
keysStill2Search = find(keysNotDetectedNdx);
length_keysStill2Search = length(keysStill2Search);

lengthkeysFound = 0;
pauseIt = 0;

fidIn = fopen(desktopSourceFileName, 'r');
if fidIn < 1
  err = 1;
  errMsg = sprintf('%s: unable to open for reading "%s"', modName, desktopSourceFileName);
  if nargout < 1
    fprintf('\n Error: %s', errMsg);
  end
  return
end
fidOut = fopen(compileSourceFileName, 'w');
if fidOut < 1
  fclose(fidIn);
  err = 1;
  errMsg = sprintf('%s: unable to open for writing "%s"', modName, compileSourceFileName);
  if nargout < 1
    fprintf('\n Error: %s', errMsg);
  end
  return
end
[sourceDir,debugSourceName,sourceExt,versn] = fileparts(desktopSourceFileName);
debugSourceNameLength = length(debugSourceName);
sourceDir = endWithBackSlash(sourceDir);
[targetDir,releaseSourceName,targetExt,versn] = fileparts(compileSourceFileName);
targetDir = endWithBackSlash(targetDir);
if strcmp(desktopSourceFileName, compileSourceFileName);
  err = 1;
  errMsg = sprintf('%s: input & output files requested are in the same directory and have the same name. %s', modName, compileSourceFileName)
  if nargout < 1
    fprintf('\n *** Error: %s', errMsg);
  end
  return
end

withIn_IF = 0; %flag set when 'if testDEBUGrelease' found
skipLines = 0;
skipThisLine = 0;
linesRead = 0;
linesWritten = 0;
warningNotWritten = 1 ;
% the order IS important.  when "debugCode" is zero, the first statement is considered a match when found
%    debugCode == 0: release code
%    debugCode == 1: debug code
keyPhrase = {'if ~testDEBUGrelease','if testDEBUGrelease'};
lengthKeyPhrase = length(keyPhrase);
keyPhraseFound = 0;
globalKeyPhrase = 'global testDEBUGrelease';
globalKeyPhraseFound = 0;
openfigLen = length('openfig(');
while 1
  thisTextLine = fgetl(fidIn);
  %when last line is empty which happens id the next to last line ends w/ a CR/LF
  if ~ischar(thisTextLine)
    if feof(fidIn);
      break
    end
  end
  linesRead = linesRead + 1;
  if ~debugCode
    %release code desired
    %we need to replace any references to the Matlab-defined variable "mfilename" because the ML converter
    % replaces this variable with text when it creates the .c & .h code. Ignore occurances where mfilename
    %   is a part of a variable name and not a word by itself
    a = findWordInText('mfilename', thisTextLine);
    if a 
      %There is an exception where we cannot replace mfilename without more effort.  Matlab GUIs.  
      % The GUI file itself, .fig, has the same name as the control code .m file and the
      %figure is opened by a command using "mfilename".  We'll detect this event and copy the figure
      % with the new name (example: readparmloadwave_param.fig -> 00141.fig)
      %This serves a secondary purpose as well: it makes sure any needed GUI figures are copied!
      % %      openfig(mfilename,
      b = length('mfilename') - 1;
      %the phrase may occur more than once!
      for itemp = 1:length(a)
        %test if we're dealing with a figure reference
        c = findstrchr('openfig(', thisTextLine);
        if c
          %make sure it isn't part of a comment
          d = findstrchr('%', thisTextLine);
          if d
            if find(c < d(1))
              c = c(1);
            else
              c = 0;
            end
          end
        end
        if c
          %if the "openfig(" found is associated with the "mfilename" occurance we're processing...
          if (c + openfigLen) == a(itemp)
            %copy the figure....renaming as we go from <sourceDir><original name>.fig to <targetDir><moduleAlias>.fig
            if length(moduleAlias)
              progress('listboxMsg_Callback', sprintf('Copying & renaming figure "%s%s.fig" to "%s%s.fig"', sourceDir, debugSourceName, targetDir, moduleAlias));
              [err, errMsg] = dosIt(sprintf('copy "%s%s.fig" "%s%s.fig"', sourceDir, debugSourceName, targetDir, moduleAlias), '', nargout);
            else
              errMsg = sprintf(': Unable to copy figure associated with "%s" because no alias was provided.', debugSourceName);
              err = 1;
            end
            if err
              errMsg = strcat(modName, errMsg);
              fcloseIfOpen(fidIn);
              fcloseIfOpen(fidOut);
              %%%%%%%%
              %%%%%%%%
              return;
              %%%%%%%%
              %%%%%%%%
            end
            figFound = 1; %flag that a callback type was found
            if length(fileListName)
              %add the figure to the list of "must have" files 
              fidFileList = fopen(fileListName, 'a');
              fprintf(fidFileList, '%s.fig\r\n', moduleAlias);
              fclose(fidFileList);
            end %if length(fileListName)
          end%if (c + openfigLen) == a(itemp)
        end %if c
        if length(thisTextLine) == (a(itemp) + b)
          thisTextLine = sprintf('%s''%s''', thisTextLine([1:a(itemp)-1]), moduleAlias);
        else %if length(thisTextLine) == (a(itemp) + b)
          if length(thisTextLine) > (a(itemp) + b)
            thisTextLine = sprintf('%s''%s''%s', thisTextLine([1:a(itemp)-1]), moduleAlias, thisTextLine([a(itemp)+b+1:length(thisTextLine)]));
          end
        end %if length(thisTextLine) == (a(itemp) + b) else
      end % for itemp = 1:length(a)
    end %if a
    %pull all spaces
    denseTextLine = strrep(thisTextLine, ' ', '');
    %is there an assignment to the value of the variable "modName"?
    if findstrchr('modName=', denseTextLine) == 1
      a = findstrchr('=', thisTextLine);
      a = a(1); % only care about the "=" associated with the "modName" term
      b = findstrchr(';', thisTextLine);
      %if there is a ";" and it is before the end of the line...
      if b & b(1) < length(thisTextLine)
        %replace everthing between the "=" and the ";" with the contents of "moduleAlias"
        thisTextLine = sprintf('%s ''%s''%s', thisTextLine(1:a), moduleAlias, thisTextLine(b:length(thisTextLine))) ;
      else
        thisTextLine = sprintf('%s ''%s'';', thisTextLine(1:a), moduleAlias);
      end
      %update: pull all spaces again
      denseTextLine = strrep(thisTextLine, ' ', '');
    else  %if findstrchr('modName=', denseTextLine)
      a = findstrchr('initErrModName', thisTextLine);
      a = a(1);
      if a
        c = findstrchr('function', thisTextLine);
        d = findstrchr('%', strrep(thisTextLine,' ',''));
        %if ("function" isn't on line or it is after "initErrModName") AND this isn't a comment line 
        if (~c | (c > a)) & (d(1) ~= 1)
          b = findstrchr('(', thisTextLine);
          if b(1) > a
            c = findstrchr(')', thisTextLine);
            if c(1) > b(1)
              thisTextLine = sprintf('%s''%s''%s', thisTextLine([1:b]), moduleAlias, thisTextLine([c:length(thisTextLine)]) );
              %update: pull all spaces again
              denseTextLine = strrep(thisTextLine, ' ', '');
            end %if c(1) > b(1)
          end %if b(1) > a
        end %if ~c | (c > a)
      end % if a  %a = findstrchr('initErrModName', thisTextLine);
    end %if findstrchr('modName=', denseTextLine) else
  else %if ~debugCode
    %debug code desired:
    %pull all spaces
    denseTextLine = strrep(thisTextLine, ' ', '');
  end %if ~debugCode else
  %   a = 'errMsg = sprintf(''%s: 2 %i'', modName, itemp);';
  %   if findstrchr(a, thisTextLine) & length(thisTextLine) >= length(a)
  %     pauseIt = 1;
  %   end
  %   if pauseIt
  %     fprintf('\n%s', thisTextLine);
  %   end
  %%%%%%%% here's the "if (~)testDEBUGrelease/else/end" portion %%%%%%%%%%
  [foundRlsDbg] = isValid_if_else_end(thisTextLine, keyPhrase, 0, denseTextLine);
  % % might be nested.  Only the outer pair should define the skip range
  % % so we'll use withIn_IF as a counter and not just a simple flag
  % % if withIn_IF
  if foundRlsDbg
    withIn_IF = withIn_IF + 1;
    activeIf = foundRlsDbg - 1; 
    skipThisLine = 1; %flag for pulling the if/else/end lines that are marked with the keyPhrase
    %set general skip if debugcode is cleared
    skipLines = (activeIf ~= debugCode);
    keyPhraseFound = 1;
  else
    skipThisLine = isValid_if_else_end(thisTextLine, globalKeyPhrase, 0, denseTextLine);
    if skipThisLine
      globalKeyPhraseFound = 1;
    end
  end %if foundRlsDbg
  if withIn_IF & ~skipThisLine
    [whichPhrase, ifELSEend] = isValid_if_else_end(thisTextLine, keyPhrase, 1, denseTextLine);
    if whichPhrase
      skipThisLine = 1; %flag for pulling the if/else/end lines that are marked with the keyPhrase
      if (ifELSEend == 3) %if "end%<keyPhrase>", back out of this if/end
        withIn_IF = withIn_IF - 1;
        skipLines = 0;
      else
        %found "else" so toggle the rule & update the skipLines flag as appropriate
        activeIf = (activeIf < 1);
        skipLines = (activeIf ~= debugCode); 
      end
    end
  end
  %if we want to write this line:
  if ~skipThisLine & ~skipLines
    skipThisLine = 0; %clear flag for pulling the if/else/end lines that are marked with the keyPhrase
    fprintf(fidOut,'%s\r\n', thisTextLine);
    % if we've not found all the keys we're to search for. . .
    if lengthkeysFound < lengthkeysToFind
      % loop through the available keys
      for itemp = 1:length_keysStill2Search
        % if this key is in the line. . .
        if findstrchr(char(keysToFind(keysStill2Search(itemp))),thisTextLine) & length(thisTextLine) >= length(char(keysToFind(keysStill2Search(itemp))));
          %increment the counter
          lengthkeysFound = lengthkeysFound + 1;
          %store for return the index to the key found
          keysFound(lengthkeysFound) = itemp ;
          %remove the found phrase from the to-be-searched-for list
          keysNotDetectedNdx(itemp) = 0;
          %update the variables for the next search
          keysStill2Search = find(keysNotDetectedNdx);
          length_keysStill2Search = length(keysStill2Search);
          break
        end
      end
    end
    linesWritten = linesWritten + 1;
    if warningNotWritten
      %if line is blank
      if length(thisTextLine) < 1 | length(find(isspace(thisTextLine))) == length(thisTextLine)
        fprintf(fidOut,'%%********************* WARNING ****************************\r\n');
        fprintf(fidOut,'%%********************* WARNING ****************************\r\n');
        fprintf(fidOut,'%% DO NOT EDIT THIS FILE. IT IS CREATED AUTOMATICALLY FROM\r\n');
        fprintf(fidOut,'%%     "%s".  \r\n', desktopSourceFileName);
        fprintf(fidOut,'%%  Any edits here will be over written during the compile.\r\n');
        fprintf(fidOut,'%%  Instead, you should edit that file. \r\n');
        fprintf(fidOut,'%%********************* WARNING ****************************\r\n');
        fprintf(fidOut,'%%********************* WARNING ****************************\r\n');
        fprintf(fidOut,'\r\n');
        warningNotWritten = 0 ;
      end
    end %if warningNotWritten
  end
  if feof(fidIn)
    break
  end
end %while 1
keysFound = sort(keysFound);
fcloseIfOpen(fidIn);
fcloseIfOpen(fidOut);
if keyPhraseFound & ~globalKeyPhraseFound
  err = 1;
  errMsg = sprintf('%s: line missing: "if testDEBUGrelease" found but "global testDEBUGrelease" was NOT found. "%s"', modName, desktopSourceFileName);
  if nargout < 1
    fprintf('\n Error: %s', errMsg);
  end
  return
end
if noPrint
  return
end
fprintf('\n lines read = %i', linesRead);
fprintf('\n lines written = %i', linesWritten);


%%%%%%%%%%%%%%%%
function [whichPhrase, ifELSEend] = isValid_if_else_end(thisTextLine, keyPhrase, look4ElseOrEnd, denseTextLine);
%whichPhrase: 0 if not found, number of the choices within "keyPhrase" if present
%  ex: when keyPhrase = {'if testDEBUGrelease', 'if ~testDEBUGrelease'};
%   returns "1" when 'if testDEBUGrelease' is found and "2" when 'if ~testDEBUGrelease' is found.
%ifELSEend: type found: 1: "if", 2:"else%<keyPhrase>"; 3:"end%<keyPhrase>"
%   note: 2 & 3 can only occur if "look4ElseOrEnd" flag is set & 1 only if it isn't

ifELSEend = 0;
whichPhrase = 0;
%For speed we'll first look if the phrase is present: it generally isn't
if iscell(keyPhrase)
  for itemp = 1:length(keyPhrase)
    if findstrchr(char(keyPhrase(itemp)),thisTextLine);
      whichPhrase = itemp;
      break
    end
  end
  %whichPhrase = ismember(keyPhrase,thisTextLine);
else
  whichPhrase = findstrchr(keyPhrase,thisTextLine);
end
if any(whichPhrase)
  %may be present: pull spaces
  if iscell(keyPhrase)
    for itemp = 1:length(keyPhrase)
      denseKeyPhrase = strrep(char(keyPhrase(itemp)), ' ', '');
      if findstrchr(denseKeyPhrase,denseTextLine);
        whichPhrase = itemp;
        break
      end
    end
  else
    denseKeyPhrase = strrep(keyPhrase, ' ', '');
    whichPhrase = findstrchr(denseKeyPhrase,denseTextLine);
  end
  %if phrase still present now that spaces are gone...
  if whichPhrase
    %is present: test if valid and not in an *invalid* comment: valid comments are only on the same line as "else" or "end"
    if (length(denseTextLine) >= length(denseKeyPhrase))
      c = findstrchr(denseKeyPhrase, denseTextLine);
      if look4ElseOrEnd
        a = 'else%' ;
        b = findstrchr(a, denseTextLine);
        if b & (b <= 2)
          ifELSEend = 2 * ((c == (length(a) + 1)) | (c == (length(a) + 2)));
        else %if b & (b <= 2)
          a = 'end%' ;
          b = findstrchr(a, denseTextLine);
          if b & (b <= 2)
            ifELSEend = 3 * ((c == (length(a) + 1)) | (c == (length(a) + 2)));
          end %if b & (b <= 2)
        end %if b & (b <= 2) else
      else %if look4ElseOrEnd
        ifELSEend = (c <= 2);
      end %if look4ElseOrEnd else
    end %if (length(denseTextLine) >= length(char(denseKeyPhrase(whichPhrase))))
  end %if any(whichPhrase)
end%if any(whichPhrase)
whichPhrase = whichPhrase(1) * (ifELSEend > 0);
%*************** function [isValid] = isValidIForEND(thisTextLine, keyPhrase, keyPhrasePrefix);
%***************************
