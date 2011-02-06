function [Ndx, notNdx] = validateLogCopyLocations(logPaths);
% function [Ndx, notNdx] = validateLogCopyLocations(logPaths);
%Checks for accessibility to each path in (logPaths) by attempting a "dir"
% (does NOT check if a copy exists in the location) and returns two index arrays:
%OUTPUT
% Ndx: index into logPaths for all accessible paths. Usage: logPaths(Ndx) 
% notNdx: index into logPaths for all unavailable paths. Usage: logPaths(notNdx)
%
%Used by "updateLogCopies" which then performs the copying by calling "createLogCopies"
%   Ndx = validateLogCopyLocations(logPaths);
%   if length(Ndx)
%     % 2) create the copies in the accessible locations
%     [err, errMsg] = createLogCopies(logPaths(Ndx), masterLogPath, masterName);
%   end

[err, errMsg, modName] = initErrModName(mfilename);

Ndx = [] ;
notNdx = [];
for itemp = 1:length(logPaths)
  % % fprintf('\r\nValidating Packet Log location for copy %i: "%s"', itemp, char(logPaths(itemp)) );
  %   fprintf('\r\ncopy %i: "%s"', itemp, char(logPaths(itemp)) );
  %#IFDEF debugOnly
  % actions in IDE only
  %#ENDIF  
  %exist can be much faster than a 'dir' but it doesn't compile
  % dir ('*.') is as fast as exist and it works!
  [err, errMsg, date_time] = datevec2timeStamp(now);
  % %   fprintf('\r\n%s: %s', mfilename, date_time);
  b = dir(strcat(char(logPaths(itemp)),'*.'));
  if length(b)
    Ndx(length(Ndx)+1) = itemp;
    %     fprintf(' -> Available.');
    %#IFDEF debugOnly
    %#ENDIF  
  else
    notNdx(length(notNdx)+1) = itemp;
    %     fprintf(' -> Not available. %i', a);
    %#IFDEF debugOnly
    %#ENDIF  
  end
  %   fprintf('\n   exist=%i dir=%i exist %.3fS dir %.3fS', a, length(b), t1, t2)
end % for itemp = 1:length(logPaths)
% % fprintf('\r\nExiting %s ========================', mfilename);
% % fprintf('\r\n ========================');