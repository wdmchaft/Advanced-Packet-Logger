function [err, errMsg] = dosIt(dosCommand, dos_arg2, nargout_caller, modName_caller, echoCommand);
%function [err, errMsg] = dosIt(dosCommand[, dos_arg2[, nargout_caller[, modName_caller[, echoCommand]]]);
%Saves lines when DOS is called: requires only one line in caller if no 
% error check, 3 if error check & return is desired (see exmaples below).
%
%Calls DOS and checks the return status.  If bad status, builds up
% an error message "<modName_Caller>: error with "<dosCommand>": "<dos reply>"
%INPUT
% dosCommand: the command string to be passed to DOS
% dos_arg2[optional]: 2nd argument to the DOS command such as '-echo'.  If
%    empty or not present, no 2nd argument is passed.
% nargout_caller[optional]: for this module to print a detected error when the
%    caller is not passing message back up.  Prints if this is 0 or if absent and
%    this module is called without output argument usage.
% modName_caller[optional]: the module name of the routine calling this.  Used
%    in contruction error messages: one here versus 1 line per call!
% echoCommand[optional]: flag that when present & non-zero cases a message to
%    appear on the monitor "OK with <dosCommand>"
%OUTPUT:
% err: 0 if DOS successful, DOS error number otherwise
% errMsg: empty if DOS successful, otherwise: "<modName_Caller>: error with "<dosCommand>": "<dos reply>"
%
%example usage #1:
% [err, errMsg] = dosIt('del "*.c_orig"', '', nargout, modName);
% if err
%   return %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end
%
%example usage #2:
% [err, errMsg] = dosIt(sprintf('DMSFormat C~VisualC6 @"%sObfuscate.fpf" +Obfuscate', fulltargetDir), '-echo', nargout, modName);
% if err
%   return %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end
%
%VSS revision   $Revision: 4 $
%Last checkin   $Date: 1/23/07 1:08p $
%Last modify    $Modtime: 1/23/07 1:08p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

switch nargin
case 1
  dos_arg2 = '';
  nargout_caller = 1;
  modName_caller = strcat('>', mfilename);
  echoCommand = 0;
case 2
  nargout_caller = nargout;
  modName_caller = strcat('>', mfilename);
  echoCommand = 0;
case 3
  modName_caller = strcat('>', mfilename);
  echoCommand = 0;
case 4
  echoCommand = 0;
otherwise
end %switch nargin

if length(dos_arg2)  %don;t know that we need to make this distinction: don't know action if 2nd argument is null/empty
  [status, result] = dos(dosCommand, dos_arg2);
else
  [status, result] = dos(dosCommand);
end
if status
  errMsg = sprintf('%s: error with "%s": "%s".', modName_caller, dosCommand, result);
  err = status;
  if nargout_caller < 1
    fprintf('\n Error: %i %s', err, errMsg);
  end
else % if status
  err = 0;
  errMsg = '';
  if echoCommand
    progress('listboxMsg_Callback', sprintf('OK with %s', dosCommand))
  end % if echoCommand
end %if status else
