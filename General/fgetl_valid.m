function [textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fid, textLine);
%function [textLine, commasAt, textFieldQuotesAt, spacesAt] = fgetl_valid(fid[, textLine]);
% The basic "fgetl" stops reading at a CR yet sometimes messages within a line
% include a CR -> this function will continue reading until a CR outside
% of a measage is encountered.  Messages are surrounded by ," and then ",
%INPUT
% textLine[optional]: the line read so far.  Some modules read only the beginning of the line
%    when from a log & check that the line starts with a date stamp.  If that fragment isn't
%    passed in AND the line doesn't end properly, line recovery can be an issue.
%VSS revision   $Revision: 8 $
%Last checkin   $Date: 3/06/07 5:20p $
%Last modify    $Modtime: 3/06/07 5:20p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

global userCancel hCancel %for the GUI 'cancel': this will be set if the user hits cancel, 0 otherwise

%we've got some log file corruption problems that is starting a new line in the 
% middle fo the comment field & wiping out that field's closing quote.  As a resuit, this routing
% keeps reading, looking for the missing quote.
%Solution: 
% 1) make sure the line we are dealing with is a line from a log & set a flag
% 2) if the line fails the quote test, check if there is a 2nd line beginning time stamp.  
% 3) if there is, we're going to drop the part of the line leading up to that 2nd time stamp which includes that orphaned quote

commasAt = 0;
textFieldQuotesAt = 1;
spacesAt = 0;
if nargin < 2
  textLine = '';
end
looped = 0;
while mod(length(textFieldQuotesAt), 2)
  a = fgetl(fid);
  if ~ischar(a) | length(a) < 1
    return
  end
  textLine = strcat(textLine, a);
  [commasAt, textFieldQuotesAt, spacesAt]  = findValidCommas(textLine);
  %if odd number of quotes...
  if mod(length(textFieldQuotesAt), 2) | looped
    looped = 1;
    %if line is corrupted
    [fixedLines, numLines, stAt] = fixCSVmergedLogLines(textLine);
    if numLines > 1
      %if line is from a log
      if stAt(1) == 1
        textLine = char(fixedLines(numLines));
        [commasAt, textFieldQuotesAt, spacesAt]  = findValidCommas(textLine);
        for itemp = 1:numLines-1
          fprintf('\nTossing invalid line "%s"', char(char(fixedLines(itemp))));
        end
      end
    end
  end
  if userCancel
    break
  end
end
