function [outstring, newpos, lineMergeNdx] = reformatToFit(h_ui, str, newpos, maxHi);
%function [outstring, newpos, lineMergeNdx] = reformatToFit(h_ui, str, newpos, maxHi)
%  Reformat the lines of text by reducing the number of lines until
%a fit is achieved.  The original line breaks are marked with an upside-down question
%mark (¿)
%INPUTS
% h_ui: handle to the UI box in question
% str: cell array of the text to be fitted into the box
% newpos: current required size of box the cell array: [str,newpos] = textwrap(h_ui, str);
% maxHi: maximum height allowed
%OUTPUTS
% outstring: reformat cell array that is best fit; check (lineMergeNdx)
%    to see if fit achieved.
% newpos: size of box with the "outstring" formatting. Height will not
%    be any larger than "maxHi" (see below "lineMergeNdx")
% lineMergeNdx:  
%  0 if fit not achieved & newpos(4) (the height) is set to maxHi which
%       means only the part of the str which fits in maxHi will be visible
%       if/when set(h_ui,'position', newpos) after this function.
%  >0 if fit achieved. Count down number of str's lines that were processed
%       to achieve the fit. 1 => all lines, length(str)-1 => last two lines

%blend a line with the preceeding by inserting <space><upside down question>
%  (a) we'll append this to the end of all existing lines, 
%  (b) combine lines starting at the bottom and working upward until the text fits, and
%  (c) we'll then remove the appended characters present at the end of any line.

%  (a) we'll append this to the end of all existing lines, 
for itemp = 1:length(str)
  str(itemp) = {sprintf('%s %s', str{itemp}, char(191))};
end % for itemp = 1:length(str)

%  (b) combine lines starting at the bottom and working upward until the text fits, and
lineMergeNdx = length(str)-1;
% loop until fit achieved or all lines have been processed
while ( (newpos(4) > maxHi) & lineMergeNdx )
  % merge all the lines from lineMergeNdx until the end into one line
  %   for jtemp = lineMergeNdx+1:length(str)
  %     a = strtrim(str{jtemp});
  a = strtrim(str{lineMergeNdx+1});
  if length(a)
    str(lineMergeNdx) = {sprintf('%s %s', str{lineMergeNdx}, a)};
  else
    str(lineMergeNdx) = {sprintf('%s', str{lineMergeNdx})};
  end
  %   end % for jtemp = lineMergeNdx+1:length(str)
  % shorten the array - delete the lines that have been merged into the current line
  outstring = str(1:lineMergeNdx);
  % try to fit: reformat the array to fit the box -> this will add in lines
  [outstring,newpos] = textwrap(h_ui, outstring);
  lineMergeNdx = lineMergeNdx - 1;
end % while ( (newpos(4) > maxHi) & lineMergeNdx )
%  (c) remove the appended characters present at the end of any line.
for itemp = 1:length(outstring)
  a = strtrim(outstring{itemp});
  b = findstrchr(a, char(191));
  if any(b == length(a))
    outstring(itemp) = {a(1:length(a)-1)};
  end % if any(b == length(a))
end % for itemp = 1:length(str)
if ~lineMergeNdx
  % limit the height to the allowed region
  newpos(4) = maxHi;
end
