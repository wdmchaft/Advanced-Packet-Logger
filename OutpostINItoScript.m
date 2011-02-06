function [err, errMsg, outpostNmNValues, outpostVarNameList] = OutpostINItoScript(thisDir, callerModName);
%function [err, errMsg, outpostNmNValues, outpostVarNameList] = OutpostINItoScript([thisDir[, callerModName]]);
%Reads Outpost.INI from the Outpost directory, determines
% StationID, BBS, TNC, etc and if caller isn't asking for return
% variables, writes the variables to separate files
% ini_BBS.txt, ini_TNC.txt, iniMyCall.txt, etc. for subsequent reading by scripts.
% If written, these files are placed in the DirScripts directory as declared in Outpost.INI
%  and an additional copy of ini_DirScripts.txt is written to the directory containing Outpost.exe
% All the files have a common prefix and extension and each name is the variable EXACTLY as it
%  appears is the INI -> that is assured since the name is used to search the INI
%For analysis, if "OutpostINItoScript.dbg" is found & contains "1", verbose logging occurs to
%  <pwd>\OutpostINItoScript.log
%CONFIGURATION
%  Outpost.ini is located in
%    #1: look for 'pathToOutpost.txt' in the current directory
%        to declare location of outpost.ini & confirm it is there
%    #2: if #1 fails, look for 'pathToOutpost.txt' in the root directory
%        to declare location of outpost.ini & confirm it is there
%    #3: if #2 doesn't locate outpost.ini, search starting in the present
%        directory and work upward through the directory tree to try to locate 
%        'outpost.ini'.  In the root directory, look for "pathToOutpost.txt"
%    #4: if #3 doesn't work, search in the root directory of drives C: through J:
%        for 'pathToOutpost.txt'
%    #5: if #4 fails, using a built-in list of
%        directories in drives C: thru J:.  Search starts with the current drive,
%        progresses through all the listed directories and the attempts a different drive.
%   This program will write 'pathToOutpost.txt' to the directory containing the programs
%     so the other logger programs can readily locate it.
%
%Program current decides if it has been called in stand-alone mode when the number of
%  output arguments is less than 3.  In that case, writing of various files including
%  two copies of "pathToOutpost.txt" is enabled.
%
%INPUTS:
%  thisDir[optional]: if present, tested to see if it is the directory containing
%    "Outpost.INI" - if not, establishes the starting drive for the
%    search for the Outpost directory.  If not present, search will start
%    on the current drive.  Search performed by "findOutpostINI"
%  callerModName[optional]: not used
%  addINIPairs[optional]: Additionaly variable(s) desired from that INI that are not in the
%    hard-coded predefined list.  Paired: name of variable exactly as it appears in Outpost.INI to
%    the left of "=" (leading & trailing spaces aren't required) & flag if a file needs
%    to be written.  File can only be written this is called from an Outpost script.
%OUTPUTS:
%  err, errMsg: 0 & null if successful
%  outpostVarNameList: list of the variables we've searched for in Outpost.INI
%    These are declared here and are the exact names that Outpost.INI uses.
%  outpostValues: list of the values of the named variables. 1:1 correspondence
%    with "outpostVarNameList".
%  NOTE: to access any given value, call outpostValByName:
%      value = outpostValByName(<name>, outpostVarNameList, outpostValues) ;
%    example to find "DirArchive":
%      dirArchive = outpostValByName('DirArchive', outpostVarNameList, outpostValues) ;

[err, errMsg, modName] = initErrModName(mfilename);

verbose = 0;
veryVerbose = 0;
%#IFDEF debugOnly
% these only work in IDE... which is also the only time we want them!
verbose = (nargout < 1);
%#ENDIF
if ~verbose
  fid = fopen('OutpostINItoScript.dbg','r');
  if fid > 1
    verbose = fgetl(fid);
    veryVerbose = verbose;
    fcloseIfOpen(fid);
  end % if fid > 1
end % if ~verbose
  
if (nargin < 1)
  thisDir = '';
end % if (nargin < 1)
if (nargin < 2)
  callerModName = '';
end % if (nargin < 2)
if (nargin < 3)
  addINIPairs = {};
end % if (nargin < 3)

%These are the variables as they appear in OUTPOST.INI
%  The expect format in the INI is <variable name>=<value>
%    ex: StationID=KI6SEP
%Each variable in this list will be written to a unique file in the DirScripts directory
%  so the value can be read by a script.  The name of each file will include
%  the name of the variable ("ini_<variable name>.txt").  The value of the variable
%  as read from the OUTPOST.INI file will be the only content of the file
%    ex: ini_StationID.txt will contain only KI6SEP

% Because DirScripts must be first, it is processed independently from this list.
%The order of the variables in this list is not important
%first variable is the name EXACTLY as it appears in Outpost.ini
%second variable is a flag to enable/disable writing of a file 
%   contain the INI value if file writing is generally active.
a = [{...
    'StationID', 1, ...
    'NameID', 1,...
    'TacticalCall', 1,...
    'TCwPEnabled', 1,...
    'TCnPEnabled', 1,...
    'BbsName', 1,...
    'BbsCName', 1,...
    'BbsFName', 1,...
    'TncName', 1, ...
    'DirFiles', 1,...
    'DirArchive', 1,...
    'DirReports', 1,...
    'DirLogs', 1,...
    'DirPF', 1,...
    'GetPrivate', 1,...
    'GetNts', 1,...
    'GetBC', 1,...
    'GetFiltered', 1,...
    'Filters', 1,...
    'SkipMine', 1,...
    'SkipMyNts', 1,...
    'Version', 0, ...
    'City', 0,...
    'State', 0,...
    'County', 0,...
    'TacLoc', 0,...
    'Org', 0,...
    'AutoMsgNum',0,...
    'SLS',0, ...
    'TacID',0, ...
    'ReportMsgNo',0,...
    'LMIflag',0,...
    'PrintOnReceipt',0,...
    'PrintOnSend',0,...
} addINIPairs];
%Tools/Message Settings:
%automatic message numbering (for outgoing messages)
% AutoMsgNum=1
% AutoMsgNum=0 
%
% SLS=0 without hypenation 
% SLS=1 with hypenation
% SLS=2 date time format

outpostVarNameList = a(1:2:length(a));
for itemp = 1:length(outpostVarNameList)
  outpostWriteFileList(itemp) = a{2*itemp};
end % for itemp = 1:length(outpostVarNameList)
%name, writeFile flag, if start Dir == under Outpost, 
notOutpostList = {...
    'DirAddOns',1,'AddOns',...
    'DirAddOnsPrgms',1,'AddOns\Programs'...
  };
    
%initialize the Values list: all values present but null.
% this list is organized  in pairs: <variable name>, <variable value>
Ndx = 1 + 2*[0:(length(outpostVarNameList)-1)];
outpostNmNValues(Ndx) = outpostVarNameList(1:length(outpostVarNameList)) ;

%set flag to write the files if the calling program is NOT asking for the results of the read.
writeFile = (nargout < 3);
outpostWriteFileList = outpostWriteFileList * writeFile ;

prgmDir = endWithBackSlash(pwd);
a = findstrchr(':', prgmDir);
if (a == 2)
  prgmDrive = endWithBackSlash(prgmDir(1:a));
  presentDrive = prgmDrive ;
else % if (a == 2)
  prgmDrive = '';
end % if (a == 2) else
fidLogThis = fopen(sprintf('%s%s.log', prgmDir, mfilename),'w');
if veryVerbose
  logSession(sprintf('\r\nnargin = %i, nargout = %i, writeFile = %i, thisDir = %s', nargin, nargout, writeFile, thisDir), fidLogThis);
end

%If the calling program passed in a path location of "Outpost.INI"...
% . . . is it the full path or merely the drive/starting path for the search?
fid = 0;
if (length(thisDir))
  thisDir = endWithBackSlash(thisDir);
  %test if the passed in 'thisDir' actually points to the directory with 'Outpost.ini'
  fid = fopen(sprintf('%sOutpost.INI', thisDir), 'r');
  if (fid > 0)
    DirOutpost = thisDir;
    %leave file open - should be faster than closing and re-opening
  else % if (fid > 0)
    if veryVerbose
      logSession(sprintf('\r\nCalling "findOutpostINI(%s)', thisDir), fidLogThis);
    end % if veryVerbose
    [err, errMsg, presentDrive, DirOutpost] = findOutpostINI(thisDir);
    if veryVerbose
      logSession(sprintf('\r\n   returned err = %i, errMsg = %s, presentDrive = %s, DirOutpost = %s', err, errMsg, presentDrive, DirOutpost), fidLogThis);
    end %if veryVerbose
  end % if (fid > 0) else
else % if (length(thisDir)
  if veryVerbose
    logSession(sprintf('\r\nCalling "findOutpostINI()'), fidLogThis);
  end %if veryVerbose
  [err, errMsg, presentDrive, DirOutpost] = findOutpostINI;
  if veryVerbose
    logSession(sprintf('\r\n   returned err = %i, errMsg = %s, presentDrive = %s, DirOutpost = %s', err, errMsg, presentDrive, DirOutpost), fidLogThis);
  end %if veryVerbose
end % if (length(thisDir) else
if err
  errMsg = strcat(modName, errMsg);
  if nargout < 1
    logSession(sprintf('\r\n Err %i, %s>%s', err, modName, errMsg), fidLogThis);
  end
  fcloseIfOpen(fidLogThis);
  return
end
%if file isn't open (i.e.: if passed-in "thisDir" didn't point to the directory containing "Outpost.INI")
if (fid < 1)
 fid = fopen(sprintf('%sOutpost.INI', DirOutpost), 'r');
end
%set up a default in case INI doesn't contain this information
DirScripts = endWithBackSlash(sprintf('%sscripts', DirOutpost));
if fid > 0
  if veryVerbose & (fidLogThis > 1)
    verbose = fidLogThis;
  end
  %version 2.4 of Outpost split BbsName into BbsCName & BbsFName & removed BbsName
  %  BbsCName contains the information we want & rather than having the programs
  %  and scripts need to test, we'll do it here.  The code will assure that
  %  both BbsName and BbsCName are available and the same
  BbsNameNotAvail = 0;
  BbsCNameNotAvail = 0;
  % Because DirScripts must be first, it is processed independently from the list.
  DirScripts = findNextract('DirScripts', verbose, 1, fid, DirScripts);
  for NdxList = 1:length(outpostVarNameList)
    % "findNextract" will if "writeFile" is set, call "writeTxt" to write the named variable's value into a file 
    %   named ini_<variable name>.txt in DirScripts.  DirScripts is passed as a global
    [a, foundFlag] = findNextract(char(outpostVarNameList(NdxList)), verbose, outpostWriteFileList(NdxList), fid, DirScripts);
    outpostNmNValues(2*NdxList) = {a};
    if ~foundFlag
      BbsNameNotAvail = BbsNameNotAvail | (findstrchr(char(outpostVarNameList(NdxList)),'BbsName') == 1);
      BbsCNameNotAvail = BbsCNameNotAvail | (findstrchr(char(outpostVarNameList(NdxList)),'BbsCName') == 1);
    end
  end
  fcloseIfOpen(fid);
  %Because "DirScripts" was processed before the loop, we need to add it to the lists
  outpostNmNValues(length(outpostNmNValues)+[1:2]) = {'DirScripts', DirScripts} ;
  outpostVarNameList(1+length(outpostVarNameList)) = {'DirScripts'} ;
  %calling program may want to know where Outpost was found
  outpostNmNValues(length(outpostNmNValues)+[1:2]) = {'DirOutpost', DirOutpost} ;
  outpostVarNameList(1+length(outpostVarNameList)) = {'DirOutpost'} ;
  if writeFile
    % need to write the file indentifying where the scripts are into a
    %   location that is not changed by outpost.ini & that all programs can find: the location of outpost.exe
    writeTxt(endWithBackSlash(DirScripts), 'DirScripts', 1, DirOutpost);
    % ^^^ done writing to ..\Outpost
  end %   if ~writeFile else
  
  %
  for itemp = 1:3:length(notOutpostList)
    nm = char(notOutpostList(itemp));
    wF = writeFile * notOutpostList{itemp+1};
    a = char(notOutpostList(itemp+2));
    if (findstrchr('Dir', nm) == 1)
      %sub directory to DirOutpost
      a = endWithBackSlash(sprintf('%s%s', endWithBackSlash(outpostValByName('DirOutpost', outpostNmNValues)), a) );
    end
    outpostNmNValues(length(outpostNmNValues)+[1:2]) = {nm, a} ;
    outpostVarNameList(1+length(outpostVarNameList)) = {nm} ;
    writeTxt(a, nm, wF, DirScripts);
  end % for itemp = 1:3:length(notOutpostList)
  
  b = 0;
  if verbose
    logSession(sprintf('\r\n BbsNameNotAvail = %i, BbsCNameNotAvail = %i', BbsNameNotAvail, BbsCNameNotAvail), fidLogThis);
  end
  if BbsNameNotAvail
    a = outpostValByName('BbsCName', outpostNmNValues);
    if outpostWriteFileList(find(ismember(outpostVarNameList, 'BbsName')))
      writeTxt(a, 'BbsName', verbose, DirScripts);
    end %   if writeFile
    %fill into the searchaable list
    b = find(ismember(outpostNmNValues, 'BbsName'));
  end
  % the outpost version before 2.4 had neither CName nor FName
  if BbsCNameNotAvail
    a = outpostValByName('BbsName', outpostNmNValues);
    if outpostWriteFileList(find(ismember(outpostVarNameList, 'BbsCName')))
      writeTxt(a, 'BbsCName', verbose, DirScripts);
      writeTxt(a, 'BbsFName', verbose, DirScripts);
    end %   if writeFile
    %fill into the searchaable list
    b = find(ismember(outpostNmNValues, 'BbsCName'));
    b(2) = find(ismember(outpostNmNValues, 'BbsFName'));
  end
  if b
    for itemp = 1:length(b)
      outpostNmNValues(b(itemp)+1) = {a};
    end
  end
  
  %special case. Outpost scripting as of 2.4.0c99 doesn't know the
  % status of the operator seetings for bullentin retrieval.  We'll
  % build it up here
  retrieve = '';
  if str2num(outpostValByName('GetPrivate', outpostNmNValues))
    retrieve = 'P';
  end
  if str2num(outpostValByName('GetNts', outpostNmNValues))
    retrieve = strcat(retrieve, 'N');
  end
  if str2num(outpostValByName('GetBC', outpostNmNValues))
    retrieve = strcat(retrieve, 'B');
  end
  if str2num(outpostValByName('GetFiltered', outpostNmNValues))
    retrieve = strcat(retrieve, 'F');
  end
  if writeFile
    writeTxt(retrieve, 'Retrieve', verbose, DirScripts);
  end
  
  %if called from script and not a program...
  if (nargout < 3)
    %...write a file containing the path to outpost.ini so subsequent calls can quickly locate it
    %& don't need to take the time to perform the search (performed in findOutpostINI)
    % % fp = strcat(outpostValByName('DirAddOnsPrgms', outpostNmNValues), 'pathToOutpost.txt');
    drvList = {prgmDrive};
    %also want the file written in the root of the drive containing the scripts & C:\
    lst = {DirScripts, 'c:'};
    for itemp = 1:length(lst)
      thisLst = char(lst(itemp));
      a = findstrchr(thisLst,':');
      if (a == 2)
        b = endWithBackSlash(thisLst(1:a));
        if ~length(find(ismember(drvList, b)))
          drvList(length(drvList)+1) = {b};
        end
      end % if (a == 2)
    end
    for itemp = 1:length(drvList)
      fp = sprintf('%spathToOutpost.txt', char(drvList(itemp))) ;
      fid = fopen(fp, 'w');
      if (fid > 0)
        fprintf(fid,'%s', outpostValByName('DirOutpost', outpostNmNValues) );  
        fclose(fid);
        logSession(sprintf('\r\nWrote "%s" containing "%s"', fp, outpostValByName('DirOutpost', outpostNmNValues)), fidLogThis);
      else
        logSession(sprintf('\r\nUnable to write "%s" to contain "%s"', fp, outpostValByName('DirOutpost', outpostNmNValues)), fidLogThis);
      end % if (fid > 0)
    end
    %We also want a copy in the scripts directory so the script can read the location
    %  This may have been created during installation and/or by the user.  No harm in re-writing it
    fp = strcat(DirScripts, 'pathToOutpost.txt');
    fid = fopen(fp, 'w');
    if (fid > 0)
      fprintf(fid,'%s', outpostValByName('DirOutpost', outpostNmNValues) );  
      fclose(fid);
    end
    % if the current directory is not the scripts directory (could be because the script is
    %  not in the scripts directory or because we are running in the IDE), make a copy in
    %  the current directory -> so the script can find it!
    origDir = endWithBackSlash(pwd);
    if ~strcmp(lower(DirScripts), lower(origDir) )
      fp = strcat(outpostValByName('DirScripts', outpostNmNValues), 'pathToOutpost.txt');
      fid = fopen(fp, 'w');
      if (fid > 0)
        fprintf(fid,'%s', outpostValByName('DirOutpost', outpostNmNValues) );  
        fclose(fid);
      end
    end % if ~strcmp(DirScripts, origDir)
  end %if (nargout < 3)
else
  err = 1;
  errMsg = sprintf('%s: unable to read "...\Outpost\Outpost.ini"', modName, pwd);
  logSession(sprintf('\r\n\Error %i: %s', err, errMsg), fidLogThis);
end
fcloseIfOpen(fidLogThis);
%----------------------
%----------------------
