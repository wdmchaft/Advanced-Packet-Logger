function [codeVersion, reply] = about_processOutpostPacketMessa()
%function [codeVersion, reply] = about_processOutpostPacketMessa()
% codeVersion: version number in floating point xx.yyy where X is major & yyy is minor
%reply: string including some text, the date & time of creation & the above version number
% Note: this function is generated by "makeabout_diag" & therefore
%this file should not be editted.

codeVersion = 0.000000;
if codeVersion
  reply = sprintf('processOutpostPacketMessages Version %.3f (Debug) created 21-Jan-2011 16:45:25.', codeVersion);
else % if codeVersion
  reply = sprintf('processOutpostPacketMessages created  (Debug)21-Jan-2011 16:45:25.');
end % if codeVersion