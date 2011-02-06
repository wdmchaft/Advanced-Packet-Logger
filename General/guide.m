function varargout = guide(varargin);
%Pre-call for Matlab's "guide": confirms that the figure
% file is not locked/read-only.  The Matlab "guide" does
% not check this information and allows modifications to the
% figure but then generates errors when saving.  The work-around
% is clumsy: save under a different name -> checkout -> erase the
% file with the original name -> rename the different name file to
% the original name.

if nargin
  fileName = char(varargin{1});
  %does the file exist?
  [pathstr, name, ext,versn] = fileparts(fileName);
  if length(ext) < 1
    fileName = strcat(name,'.fig');
  end
  fid = fopen(fileName, 'r');
  %if file exists
  if fid > 0
    %test if read-only
    fclose(fid);
    %is write access possible?
    fid = fopen(fileName, 'a');
    fcloseIfOpen(fid);
    if (fid < 1)
      errMsg = sprintf('>guide: "%s" is read-only.  You may need to perform a VSS check-out.', fileName);
      if nargout
        varargout{1} = 1;
        varargout{2} = errMsg;
      else
        fprintf('\nError: %s', errMsg);
      end
      %%%%
      return
      %%%%
    end
  end
end
%now grab the real one
% real path... without the drive letter !!
a = 'MATLAB6p1\toolbox\matlab\uitools';
%get the complete path -> it will contain the drive letter to the above directory
b = path;
c = findstrchr(lower(a), lower(b));
if ~c
  errMsg = sprintf('>guide: unable to find the path to Matlab''s "guide.m"');
  if nargout
    varargout{1} = 1;
    varargout{2} = errMsg;
  else
    fprintf('\nError: %s', errMsg);
  end
  %%%%
  return
  %%%%
end %if ~c
d = findstrchr(';', b);
e = find(d<c);
e = e(length(e));
desiredPath =  b(d(e)+1:d(e+1)-1);
originalPWD = pwd;
try
  a = sprintf('guide');
  for itemp = 1:length(varargin)
    if itemp > 1
      a = sprintf('%s %s', a, char(varargin(itemp)));
    else
      a = sprintf('%s ''%s\\%s''', a, originalPWD, char(varargin(itemp)));
    end
  end
  fprintf('\nSwitching to %s', desiredPath);
  cd (desiredPath);
  if nargout
    varargout = evalin('base',a);
  else
    evalin('base',a);
  end    
catch
end
fprintf('\nReturning to %s', originalPWD);
cd (originalPWD)
  
