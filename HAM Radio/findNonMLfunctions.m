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
