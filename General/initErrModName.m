function [err, errMsg, modName] = initErrModName(callerMfilename)
%function [err, errMsg, modName] = initErrModName(callerMfilename)
%Simple process: allows one line to replace 3.
% Sets err = 0, errMsg = '', and modName = strcat('>', callerMfilename)
% Usage example:  [err, errMsg, modName] = initErrModName(mfilename);
%VSS revision   $Revision: 1 $
%Last checkin   $Date: 7/27/04 1:23p $
%Last modify    $Modtime: 6/24/04 11:24a $
%Last changed by$Author: Arose $
%  $NoKeywords: $

err = 0 ;
errMsg = '';
modName = strcat('>', callerMfilename);
%fprintf('\r\n: %s', callerMfilename);