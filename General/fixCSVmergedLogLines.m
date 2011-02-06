function [fixedLines, numLines, stAt] = fixCSVmergedLogLines(textLine, fileID_eleAt);
%function [fixedLines, numLines, stAt] = fixCSVmergedLogLines(textLine, fileID_eleAt);
%Intended to repair line from the standard log.  Each line of the standard log
% begins with a date_time stamp.
%Determines how many date stamps are in "textLine". If more than one is detected, 
%separates the line into multiple lines, defining each date_time as the start of a new
%line.  Each line other than the last is tested for an even number of text Field Quotes &
%if necessary a quote is added to terminate that line.  (Uses findValidCommas.m for
%that determination)
%INPUT
% textLine: the line or line fragment of interest.
% fileID_eleAt[optional]: locations within "textLine" of characters that could
%  make up a valid date_time stamp -> the digits 1-0 & the underscore.  This module
%  determines its clustering and organization: must be YrMoDa_HrMnSe (or more specifically
%  nnnnnn_nnnnnn where n is a digit): 13 or mare characters with the 7th being "_"
%  If not present, this module will perform the detection.  THIS IS THE NORMAL METHOD TO USE.
%OUTPUTS
% fixedLines: cell array of repaired or fixed lines where each line other than the first line
%    begins with a date_time stamp.  
%    * If there are no date_time stamps or only one, this will be identical to the input 
%      string (except for being a cell)
%    * The first line will start with the first character, regardless whether it is part of
%      a time stamp.  It will end one character before the next time stamp.
% numLines: number of lines containing a date stamp. Can be zero in which case "fixedLines"
%    will be the same as the input line.
% stAt: array of the starting positions of each line in the original input "textLine".  Convenient
%    to validate &/or understand the parsing process.
%TYPICAL USE:
% There is no way to reconstruct all the information on a bad line.  If the date stamp is valid one
% could use that to access the waveform file.  To avoid the confusion which can easily result from 
% a partial line, a typical use is to eliminate all bad lines.  The following code fragment achieves
% this:
%     %if line is corrupted
%     [fixedLines, numLines, stAt] = fixCSVmergedLogLines(textLine);
%     if numLines > 1
%       %if line is from a log
%       if stAt(1) == 1
%         textLine = char(fixedLines(numLines));
%         [commasAt, textFieldQuotesAt, spacesAt]  = findValidCommas(textLine);
%         for itemp = 1:numLines-1
%           fprintf('\nTossing invalid line "%s"', char(char(fixedLines(item))));
%         end
%       end
%     end
%VSS revision   $Revision: 4 $
%Last checkin   $Date: 7/31/07 2:36p $
%Last modify    $Modtime: 7/31/07 2:34p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

persistent fileIDelements

if length(fileIDelements) < 1
  fileIDelements = '01234567890_';
end

if nargin < 2
  %find all locations with member of the fileID
  fileID_eleAt = ismember(textLine,fileIDelements);
end

fixedLines = {};
%find elements which are not time stamps
c = find(fileID_eleAt<1);
numLines = 0;
stAt = 1;
%detect if line is starting with a time stamp
%  occurs when the first non-time stamp character is at least 13 characters in...
if (c(1) > 12)
  % if only one "_" and it is in the correct location
  a = findstrchr(textLine(stAt:c(1)-1), '_');
  if ( (length(a) < 2) & (a == 7) )
    %line is beginning cleanly
    numLines = numLines + 1;
  end
end
%detect all remaining time stamps, if any
d = [2:length(c)];
e = c(d) - c(d-1);
f = find(e>12); 
if length(f)
  %first ignore timestamps after the first that end with "measLLD" - these are not new lines but a part of the returned text from measLLD
  % when diagnostic dumps are turned on
  h = 'measLLD';
  itemp = 1 ;
  while (itemp <= length(f))
    g = f(itemp);
    a = findstrchr(textLine(c(g+1)+[0:length(h)]), h);
    if (a(1) == 1)
      f = f([1:itemp-1 itemp+1:length(f)]);
    else
      itemp = itemp + 1;
    end
  end %while itemp <= length(f)
  %end of using "h"
  for itemp = 1:length(f)
    g = f(itemp);
    st = c(g)+1;
    timeText = textLine(c(g)+1:c(g+1)-1);
    a = findstrchr(timeText, '_');
    % if only one "_" and it is in the correct location
    if ( (length(a) < 2) & ((length(timeText)-a) > 5) & (a >= 7) )
      if a > 7
        b = (a-7);
        st = st + b;
        c(g) = c(g) + b;
      end
      if numLines
        fixedLines(numLines) = {textLine(stAt(numLines):c(g))};
      end
      numLines = numLines + 1;
      stAt(numLines) = st;
    end % if ( (length(a) < 2) & ((length(timeText)-a) > 5) & (a >= 7) )
  end %for itemp = 1:length(f)
end % if length(f)
if numLines
  fixedLines(numLines) = {textLine(stAt(numLines):length(textLine))};
else 
  fixedLines = {textLine};
end
%do not force the last line to end with a quote: we might have a CR/LF embedded
% with a quoted field: allow "fgetl_valid.m" to deal with that.
for itemp = 1:numLines-1
  a = char(fixedLines(itemp));
  [commasAt, textFieldQuotesAt, spacesAt] = findValidCommas(a);
  % % quotesAt = findstrchr('"', a);
  if mod(length(textFieldQuotesAt), 2)
    %not much we can do - line is broken.  Damage control is to end it with a quote
    a(length(a)+1) = '"';
  end
  fixedLines(itemp) = {a};
end %for itemp = 1:numLines

