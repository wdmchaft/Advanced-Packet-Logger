function [err, errMsg, presentDrive, fPath, inThisDirFlg] = findOutpostINI(thisDir);
%function [err, errMsg, presentDrive, fPath] = findOutpostINI([thisDir]);
% Locates the drive and path where Outpost is installed.
%INPUTS 
%  thisDir [optional]: path to outpost.ini 
%  if empty, not present, or outpost.ini isn't in "thisDir", attempts different methods:
%    #1: look for 'pathToOutpost.txt' in the current directory
%        to declare location of outpost.ini & confirm outpost.ini is there
%    #2: if #1 fails, look for 'pathToOutpost.txt' in the root directory
%        to declare location of outpost.ini & confirm it is there
%    #3: if #2 doesn't locate outpost.ini, search starting in the present
%        directory and work upward through the directory tree to try to locate 
%        'outpost.ini'. 
%    #4: if #3 doesn't work, search in the root directory of drives C: through J:
%        for 'pathToOutpost.txt'
%    #5: if #4 fails, using a built-in list of
%        directories in drives C: thru J:.  Search starts with the current drive,
%        progresses through all the listed directories and the attempts a different drive.
%OUTPUT
% inThisDirFlg: 1 if 'thisDir' is passed in and 'outpost.ini' is present in that dir

[err, errMsg, modName] = initErrModName(mfilename);

%We need to find the OUTPOST.INI file.  If the operator did not set the "Open in" directory explicitly, this
%  assures we'll get there.

if nargin < 1
  thisDir = '';
end
notPassedIn = ~length(thisDir);
inThisDirFlg = 0;

if notPassedIn
  %first approach: look for a definition file
  %read the path & confirm "outpost.ini" is present where indicated
  [netDrive, presentDrive, slashAt, fPath] = lcl_readPathOut('pathToOutpost.txt');
  if ~length(fPath)
    %not found: try the root directory of the current drive
    [netDrive, presentDrive, slashAt, fPath] = lcl_readPathOut('\pathToOutpost.txt');
  end %if ~length(fPath)
  if length(fPath)
    %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%
    return
    %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%
  end % if length(fPath)
  %second approach: one installation location of the logging program
  % places it in a directory somewhere below the directory contain Outpost.ini
  % We'll search upward until we find it or reach the root
  thisDir = endWithBackSlash(pwd);
  [netDrive, presentDrive, slashAt] = lcl_getDrive(thisDir);
  found = 0;
  %don't want the root directory
  slashAt = slashAt(find(slashAt > 3)) ;
  %start with the current directory and search upward in the tree
  for slashNdx = length(slashAt):-1:1
    a = dir(strcat(thisDir(1:slashAt(slashNdx)), 'outpost.ini'));
    fprintf('\nLook for "outpost.ini" in %s. . .', thisDir(1:slashAt(slashNdx)));
    if length(a)
      fPath = thisDir(1:slashAt(slashNdx));
      % %     fprintf('\nFound in tree!');
      %%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%
      return
      %%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%
    end % if length(a)
  end % for slashNdx = length(slashAt):-1:1
else % if notPassedIn
  [netDrive, presentDrive, slashAt] = lcl_getDrive(thisDir);
  a = dir(strcat(thisDir, 'outpost.ini'));
  if length(a)
    fPath = thisDir ;
    inThisDirFlg = 1;
    return
  end
end % if notPassedIn else

validDrives = {'C:','D:','E:','F:','G:','H:','I:','J:'} ;
%exclude the current drive so we don't double search it - the current drive is
% the first drive searched.
validDrives = validDrives(find(ismember(validDrives,upper(presentDrive) )==0));
%search the root directory for 'pathToOutpost.txt'
%   don't repeat search the presentDrive
for driveNdx = 1:length(validDrives)
  %attempt to open file in the root directory of presentDrive
  %read the path & confirm "outpost.ini" is present where indicated
  a = sprintf('%spathToOutpost.txt', endWithBackSlash(char(validDrives(driveNdx))) );
  [netDrive, pD, slashAt, fPath] = lcl_readPathOut(a);
  fprintf('\nLook for "%s". . .', a);
  if length(fPath)
    % found! Good return
    %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%
    presentDrive = pD ;
    return
    %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%
  end % if length(a)
end % for driveNdx = 1:length(validDrives)

%default value:
fPathList = {'\Program Files\Outpost\', '\Program Files (x86)\Outpost\', ...
    '\Program Files\SCCo Packet\', '\Program Files (x86)\SCCo Packet\', '\SCCo Packet\'};
%first time through we'll use the existing presentDrive which is established above
for driveNdx = 0:length(validDrives)
  if driveNdx
    presentDrive = char(validDrives(driveNdx));
  end % if driveNdx
  for listNdx = 1:length(fPathList)
    fPath = strcat(presentDrive, char(fPathList(listNdx))) ;
    netDrive = lcl_getDrive(endWithBackSlash(fPath));
    fid = fopen(sprintf('%sOutpost.ini', fPath), 'r');
    fprintf('\nLook for "outpost.ini" in %s. . .', fPath);
    if (fid > 0) | netDrive
      fprintf('found!');
      break
    end % if (fid > 0) | netDrive
  end % for listNdx = 1:length(fPathList)
  if (fid > 0) | netDrive
    break
  end % if (fid > 0) | netDrive
end % for driveNdx = 0:length(validDrives)

if (fid < 1)
  err= 1;
  errMsg = '';
  for itemp = 1:length(validDrives)
    errMsg = sprintf('%s %s', errMsg, char(validDrives(itemp)));
  end
  errMsg = sprintf('%s: unable to locate "%s" on drive %s', modName, fPath, errMsg);
  presentDrive = '';
end
fcloseIfOpen(fid);
%-----------------------------------
function [netDrive, presentDrive, slashAt] = lcl_getDrive(presentDrive);
slashAt = findstrchr('\', presentDrive);
%if \ in first position, must be a network drive: have no clue how to search so we won't try
if slashAt(1) == 1
  if slashAt(2) == 2
    netDrive = 1;
    presentDrive = presentDrive(1:slashAt(4)-1);
  else
    % incomplete path passed in.  Will use letter from pwd although this may be wrong
    netDrive = 0;
    presentDrive = presentDrive(1:slashAt(1)-1);
  end
else
  netDrive = 0;
  presentDrive = presentDrive(1:slashAt(1)-1);
end
%-------  end function [netDrive, presentDrive] = lcl_getDrive(endWithBackSlash(thisDir));
%-----------------------------------------------------------------
function [netDrive, presentDrive, slashAt, fPath] = lcl_readPathOut(fpathName);
netDrive = 0;
presentDrive = '';
slashAt = 0;
fPath = '';
fid = fopen(fpathName, 'r');

if (fid > 0)
  textLine = fgetl(fid);
  fclose(fid);
  if length(textLine);
    textLine = endWithBackSlash(textLine);
    a = dir(strcat(textLine, 'outpost.ini'));
    if length(a)
      [netDrive, presentDrive, slashAt] = lcl_getDrive(textLine);
      fPath = textLine;
      %%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%
      return
      %%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%
    end % if length(a)
  end % if length(textLine)
end % if (fid > 0)
%-------  end [netDrive, presentDrive, slashAt, fPath] = lcl_readPathOut(fid);
%-----------------------------------------------------------------
