function [err, errMsg, Ndx, notNdx] = makeLogCopiesCurrent(h_) 
%function [err, errMsg, Ndx, notNdx] = makeLogCopiesCurrent(h_)
%  Copies the master Packet Log File to any specified location that does
%not have a current copy (+/- 5 seconds) or has no copy at all.  If copy is newer, for example
%because the copy was edited, the copy WILL be replaced.  Why: not only is 
%NOT current but %eventually the master Log will end up being newer & the 
% copy will then take place.
%  Note: overrides any read-only setting on the copies & then establishes 
%read-only on the copies.
%  Uses the following elements of "h_"
%h_.pathsTologCopies: path(s) where operator wants the copies.
%h_.logCoreName: core name of the current master Packet Log (no path)
%h_.header.logFDate: system file date for the current master Packet Log 
%h_.logPath: path to the current master Packet Log
%h_.workingDir: path to where the program 'displayCounts' is located.  This
%  location will be used for the batch file created & called for the actual copy
%  operations.
%
%OUTPUT
%err, errMsg: only error if there is a problem with the operation of the
% batch created & called by createLogCopies.
%Ndx, notNdx are indices into h_.pathsTologCopies such that:
%  h_.pathsTologCopies(Ndx) are those paths which are currently accessible
%  h_.pathsTologCopies(notNdx) are those paths which are currently not accessible
%ADDITIONAL 
% This program determines which copies are not current.  The other steps are performed
% by programs called from this module.
%PROGRAMS CALLED:
% validateLogCopyLocations(): determines which of the specified locations are accessible
% getDateLogCopyLocations(): determines the dates of the copies in each location
% createLogCopies(): performs the copying operation

[err, errMsg, modName] = initErrModName(mfilename);

[Ndx, notNdx] = validateLogCopyLocations(h_.pathsTologCopies);
if length(Ndx)
  logFDateNum = datenum(h_.header.logFDate);
  %note if copy's date is more than 5 seconds different than the current Log
  dayFrac = 5/(24*60*60) ; %5 * 1/(secsPerDay)
  % check the date of the copy in each location.  date will be '0' for a location w/o copy
  logPaths = h_.pathsTologCopies(Ndx) ;
  copyDate = getDateLogCopyLocations(logPaths, h_.logCoreName);
  updateNdx = [];
  for itemp = 1:length(copyDate)
    if abs(logFDateNum - datenum(copyDate(itemp)) ) > dayFrac ; 
      updateNdx(length(updateNdx)+1) = itemp ;
    end
  end % for itemp = 1:length(copyDate)
  if length(updateNdx)
    [err, errMsg] = createLogCopies(logPaths(updateNdx), h_.logPath, h_.logCoreName, h_.workingDir);
  end
end % if length(Ndx)
% %debug
% fprintf('\r exiting %s', mfilename);