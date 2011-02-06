function [copyDate] = getDateLogCopyLocations(logPaths, logCoreName);
% function [copyDate] = getDateLogCopyLocations(logPaths, logCoreName);
%Returns the date of the copy of the Log in each location & will
% return '0' for each location without a copy. Uses 'dir' so the
% format will be '25-Dec-2009 03:59:02'
%OUTPUT
% copyDate: cell array of date for copy in each location in logPaths.
%   '0' for any location without a copy.  One element for each element
%   in logPaths array.
%INPUT
% logPaths: cell list of all the locations where copies are to be kept. If empty
%   no action will occur.
% logCoreName: core name of the log (i.e.: without _Recd nor _Sent)
[err, errMsg, modName] = initErrModName(mfilename);

copyDate = {};
for itemp = 1:length(logPaths)
  a = dir(sprintf('%s*%s.csv', char(logPaths(itemp)), logCoreName));
  if ~length(a)
    %copy not found: set date to zero
    a(1).date = '1-Jan-0000' ;
  end
  copyDate(itemp) = {a(1).date} ;
end % for itemp = 1:length(logPaths)
% %debug
% fprintf('\r exiting %s', mfilename);