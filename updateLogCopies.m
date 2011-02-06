function [err, errMsg, Ndx, notNdx] = updateLogCopies(logPaths, masterLogPath, masterName, dir4Batch);
%function [err, errMsg] = updateLogCopies(logPaths, masterLogPath, masterName, dir4Batch)
% Copies the packet log to all accessible locations for the copies
%INPUT:
% logPaths: cell list of all the locations where the operator wants copies. If empty
%   no action will occur.
% masterLogPath: full path to the master log
% masterName: name but no extension

[err, errMsg, modName] = initErrModName(mfilename);

% 1) confirm all the requested locations can be accessed - exclude
%    from only from this run any that cannot be accessed.  We'll try them next time
[Ndx, notNdx] = validateLogCopyLocations(logPaths);
if length(Ndx)
  % 2) create the copies in the accessible locations
  [err, errMsg] = createLogCopies(logPaths(Ndx), masterLogPath, masterName, dir4Batch);
end
