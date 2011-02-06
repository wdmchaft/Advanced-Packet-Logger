function [err, errMsg, status, msg] = mkdirExt(dirToMake, makeNotFromCurrent)
%function [err, errMsg, result] = mkdirExt(dirToMake[, makeNotFromCurrent])
%Performs the gymastics to make a directory off the root if makeNotFromCurrent is set.
% uses the MatLab 'mkdir' function in all cases
%INPUTS
%dirToMake: path including all directories which need to be made in the tree
%  note: if ":" is in second position or '\' in first, directory(ies) are 
%   detected as not being relative to the existing.  Equivalent to setting "makeNotFromCurrent"
%        otherwise, the directoy(ies) are relative to the current directory.
%makeNotFromCurrent[optional]: 
%   if clear or absent, call mkdir directly
%   if set, the beginning of 'dirToMake' is interpretted:
%      \\ = network drive
%      \  = this drive, root directory
%      if ':' present = local drive 
%      anything else (as long as greater than one character): off root directory
%OUTPUT
%  err & errMsg are set if the make directory fails
%  status & msg are returned from mkdir if we got that far: 0 = fail; 1 = OK; 2 = existed all ready
%VSS revision   $Revision: 6 $
%Last checkin   $Date: 6/16/08 8:01p $
%Last modify    $Modtime: 10/29/07 4:29p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

err =0;
errMsg = '';
modName = '>mkdirExt';
msg = '';

%if flag is not passed in
if nargin < 2
  makeNotFromCurrent = 0;
  %look to see if this is implied by a drive letter or network path being included
  %...drive? ":" in 2nd position
  a = findstrchr(':', dirToMake);
  makeNotFromCurrent = (a(1) == 2);
  if ~makeNotFromCurrent
    %..not drive - is it network: "\" in first position
    a = findstrchr('\', dirToMake) ;
    makeNotFromCurrent = (a(1) == 1);
  end
end

parentExists = 0;
if makeNotFromCurrent == 0
  [status, msg] = mkdir_local(dirToMake);
else
  % Use \ unless a local drive is specifed (:) or a network path (\\) is specified.
  parentDir = '\';
  thisDir = dirToMake;
  %local drive specified?
  c = findstrchr(':', dirToMake);
  if ~c
    %network path specified?
    c = findstrchr('\\', dirToMake);
    if c > 1 %if \\ doesn't start the string, not a netpath
      c = 0;
    end
  end
  if c
    backSlashAt = findstr(dirToMake, '\');
    %if dirToMake doesn't end w/ a '\', we want the last '\' found
    if backSlashAt(length(backSlashAt)) < length(dirToMake) 
      Ndx = length(backSlashAt);
    else%.. otherwise the next to last
      Ndx = length(backSlashAt) - 1;
    end
    if backSlashAt(Ndx) > 0
      %the function mkDir will make multiple directory layers but only if the directory tree as far
      % as it exists is passed via "parentDir" and the directories which need to be created come in via "thisDir"
      %We'll determine which exist here.  start at the deepest assuming one directory is needed
      while Ndx
        parentDir = dirToMake([1:backSlashAt(Ndx)]);
        if 1
          if (7 == exist(parentDir))
            parentExists = 1;
            break
          end
        else
          a = dir(parentDir);
          if length(a)
            parentExists = 1;
            break
          end
        end
        %back up one directory and try again
        Ndx = Ndx - 1;
      end
      if ~Ndx
        errMsg = sprintf('%s: unable to find the existence of the root in "%s"', modName, dirToMake);
        err = 1;
        if nargout < 1 
          fprintf('\nErr %i: %s', err, errMsg);
          clear err
        end
        return
      end
      thisDir = dirToMake([backSlashAt(Ndx)+1:length(dirToMake)]);
    end
  end%if length(c)
  
  if length(dirToMake) > 0
    b = thisDir;
    %if dirToMake is not just '\' & if it ends w/ '\', pull the last '\'
    while length(b) > 2 & strcmp(b([length(b)]),'\')
      b = b([1:length(b) - 1]);
    end
    if length(b) > 1
      [status, msg] = mkdir_local(parentDir, b, parentExists);%0= err, 1=created, 2=exists all ready
    else
      status = 0;
    end
  end
end

if status < 1
  errMsg = sprintf('%s: unable to create "%s" (%s)', modName, dirToMake, msg);
  err = 1;
end
if nargout < 1 
  if err
    fprintf('\nErr %i: %s', err, errMsg);
  else
    fprintf('\nCreated "%s"', dirToMake);
  end
  clear err errMsg
end


function varargout = mkdir_local(varargin);
%Adapted from Matlab's MKDIR which does not compile because it
%  requires both returned variables from the DOS command.
%mkdir_local Make directory.
%   mkdir_local('DIRNAME') will create the directory DIRNAME in the current
%   directory.
%
%   mkdir_local('PARENTDIR','NEWDIR') will create the directory NEWDIR in the
%   already existing directory PARENTDIR.
%
%   STATUS = mkdir_local(...) will return 1 if the new directory is created
%   successfully, 2 if it already exists, and 0 otherwise.
%
%   [STATUS,MSG] = mkdir_local(...) will return a non-empty error
%   message string if an error occurred.
%
Status = 1; %initial "good" value.  Will be changed if bad conditions detected.
parentExists = 0;
if nargin==1,
  DirName = pwd;
  NewDirName = varargin{1};
  
elseif nargin == 2,
  DirName = varargin{1};
  NewDirName = varargin{2};
elseif nargin == 3,
  DirName = varargin{1};
  NewDirName = varargin{2};
  parentExists = varargin{3};

end % if nargin

NewDirectory = fullfile(DirName, NewDirName);

%% Check to see if the parent directory exists
if ~parentExists
  parentExists = exist(strcat(DirName,'.')) 
  %pullled this 10-apr-12 because of errors when run compiled "not supported" & replaced with line above: parentExists = exist(DirName,'dir'),
end
if ~parentExists
  % The directory does not exist
  Status = -1;
else
  %% Check to see if the directory to be created exists as a
  %% directory or file
  if 1
    a = exist(strcat(DirName,NewDirName));
    if a
      if (7 == a)
        Status = 2;
      else
        Status = -2;
      end
    end % if a
  else
    Files = dir(DirName);
    if any(strcmpi({Files.name}, NewDirName)),
      if ~any(strcmpi({Files([Files.isdir]).name}, NewDirName)),
        Status=-2;
      else,
        Status = 2;
      end
    end
  end
end % if ~exist

% if Status is 1 then everything is good up to this point.
if Status == 1
  % DOS returns a zero status if the shell executed successfully which does
  % not necessarily mean that the command given to DOS was successful.  
  % Since we cannot have the second output from DOS or we won't compile, we'll test
  % using a "cd" followed by a "pwd".
  
  Status = dos(['mkdir "' NewDirectory '"']);

  %remember where we are
  originalPWD = pwd;
  % try to switch to the new directory
  cd (NewDirectory);
  % see where we are
  currentDir = pwd;
  %return
  cd(originalPWD);
  %did we get there?
  if strcmp(NewDirectory, currentDir)
    %we got there -> directory was made
    Status = 1;
  else
    %didn't get to the directory....
    Status = 0;
    %... or maybe we did
    a = findstrchr(':',currentDir);
    b = findstrchr(':',NewDirectory);
    c = findstrchr('\',NewDirectory);
    if ( (a==2) & ~b & (c(1) == 1) )
      a = (length(c) < 2);
      if ~a
        if (c(2) ~= 2)
          a = 1;
        end
      end
      if a
        if strcmp(strcat(currentDir([1:2]), NewDirectory), currentDir)
          %we got there -> directory was made
          Status = 1;
        end
      end
    end
  end
end % if Status == 1
% Check to see if output arguments are to be returned.  If an arg.
% is not returned then cause errors if necessary.
ErrMsg='';
switch Status,
  case -2,
    ErrMsg = ['Cannot make directory ' NewDirName ' because a file ' ...
	      'in ' DirName ' already exists by that name.'];
  case -1,
    ErrMsg = ['Cannot make directory ' NewDirName ' because ' DirName ...
	      ' does not exist.'];
  case 0,
    ErrMsg = ['Cannot make directory ' NewDirName '.'];
  case 1,
    ErrMsg = ['Directory or file ' NewDirName ' created in ' ...
	       DirName];
  case 2,
    ErrMsg = ['Directory or file ' NewDirName ' already exists in ' ...
	       DirName];
end % if Status checking
  
if nargout == 0,
  error(ErrMsg)
else,
  % % if Status==-1|Status==-2,Status=0;end
  varargout{1} = Status;
  varargout{2} = ErrMsg;
end % if nargout

  

