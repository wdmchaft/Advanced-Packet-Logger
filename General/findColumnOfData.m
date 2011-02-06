function [err, errMsg, dataComma] = findColumnOfData(textLine, ColumnHeadingText, commasAt, quotesAt, spacesAt, err, errMsg)
%function [err, errMsg, dataComma] = findColumnOfData(textLine, ColumnHeadingText[, commasAt, quotesAt, spacesAt[, err, errMsg]])
% returns the comma # (i.e. the column) where 'ColumnHeadingText' is within 'textLine'. 
%Result used by 'extractFromCSVText' and 'extractTextFromCSVText'
%  dataComma = -1 & err non-zero if not found .
%  dataComma = 0 if the first column (i.e.: in front of the 1st comma)
% The 'ColumnHeadingText' must immediately follow a comma in 'textLine' although 
%  leading quotes and spaces in 'textLine' are ignored.  This prevents mis-detection when
%  ColumnHeadingText is a subset of another item within textLine. Does NOT protect (yet?)
%  if the heading has addition text in the column before the next comma.
% textLine: the heading line as read from the file
% ColumnHeadingText: the text defining the column of interest. Must contain
%  something other than spaces and quotes.
%The optional commasAt, quotesAt & spacesAt are those returned by a
%  call to findValidCommas on textLine.  If not present their 
%  values will be established here.
% If the optional err, errMsg pair are passed in, 
%  'err' will be checked for non-zero & the pare will be wrapped back
%  but an extraction attempt for dataComma will still be performed.
%  That way multiple calls can be stacked & if any cause an error, the err flag
% will be set yet during debug all the returned 'dataComma' can be checked
% Note on commas:
% commas between a pair of quotes are ignored. Quotes are paired and the comma(s)
%  between an odd # & even # quote are ignored but even # to odd # are included:
%  "this, a test, is a test", 75, "more"   <- only the commas before & after 75 are in
%  1   no      no          2      3    4
%OUTPUT
% dataComma: the # of the comma where the data of interest is found
%   will be < 0 if the heading was not found

dataComma = -1 ;

%make sure there is something other than quotes or spaces in the heading
b = find(ColumnHeadingText ~= ' ' & ColumnHeadingText ~= '"'); %b contains the locations of all characters other than quotes & spaces
if length(b)
  %pull leading & trailing quotes & spaces from ColumnHeadingText
  if b(1) > 1 | b(length(b)) < length(ColumnHeadingText)
    ColumnHeadingText = ColumnHeadingText([b(1):b(length(b))]);
  end
  a = findstrchr(textLine, ColumnHeadingText);
  if nargin < 5
    [commasAt, quotesAt, spacesAt]  = findValidCommas(textLine);
  end
  if a > 0
    for itemp = 1:length(a)
      d = find(commasAt > a(itemp));
      if length(d)
        d = d(1) - 1;
        if d %if not the first column, get the position
          d = commasAt(d);
        end
        b = find(quotesAt < a(itemp) & quotesAt > d );
        c = find(spacesAt < a(itemp) & spacesAt > d );
        e = length(b) + length(c);
        d = find(commasAt == a(itemp) - 1 - e); %ColumnHeadingText
        if length(d)
          dataComma = d(1);
        else
          if a(itemp) - 1 - e == 0 %if first column
            dataComma = 0;
          end
        end%if length(d)
        %if something found, make sure full phrase & nothing more present
        if dataComma > -1
          %position of the last valid character of ColumnHeadingText w/in textLine
          e = a(itemp) + length(ColumnHeadingText); %ColumnHeadingText has no leading or trailing quotes or spaces
          %The position in the string just before the comma after the phrase found
          d = commasAt(dataComma+1);
          %find the quotes and commas that are after the phrase & before the next comma
          b = find(quotesAt > e & quotesAt < d );
          c = find(spacesAt > e & spacesAt < d );
          if (length(b) + length(c) + e) == d 
            break
          else
            dataComma = -1 ;
          end
        end
      end
    end %for itemp = 1:length(a)
  end %if a > 0
end %if length(b)

if nargin < 6 %if err was not passed in. . .
  if dataComma > -1
    err = 0 ;
    errMsg = '' ;
  else
    err = 1;
    errMsg = sprintf('>%s: unable to find [%s] in [%s]', mfilename, ColumnHeadingText, textLine);
  end
end
