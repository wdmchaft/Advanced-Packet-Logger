function [codeVersion, reply] = about_dispNghbrhdSmry_private()
%function [codeVersion, reply] = about_dispNghbrhdSmry_private()
% codeVersion: version number in floating point xx.yyy where X is major & yyy is minor
%reply: string including some text, the date & time of creation & the above version number
% Note: this function is generated by "makeabout_diag" & therefore
%this file should not be editted.

codeVersion = 0.000000;
if codeVersion
  reply = sprintf('dispNghbrhdSmry Version %.3f (Debug) created 07-Feb-2011 20:24:03.', codeVersion);
else % if codeVersion
  reply = sprintf('dispNghbrhdSmry created  (Debug)07-Feb-2011 20:24:03.');
end % if codeVersion
