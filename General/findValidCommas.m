function [commasAt, textFieldQuotesAt, spacesAt] = findValidCommas(textLine);
%function [commasAt] = findValidCommas(textLine);
%Returns array of locations of commas in 'textLine'
% excluding commas that are within a CSV defined text field.
%Also return the location of quotes that begin or end a text field.
% Such a field starts with ," and ends with ",   i.e: start at
% delimiter-quote and end quote-delimiter. For example, a Comment field from
% the log with commas as part of the comment will have those commas ignored
% by this routine.  This preserves the alignment of the columns using the
% commas as column separators.  Format consistent w/ Excel & latest LV upgrade.
%VSS revision   $Revision: 10 $
%Last checkin   $Date: 4/23/07 8:37a $
%Last modify    $Modtime: 4/19/07 10:34a $
%Last changed by$Author: Arose $
%  $NoKeywords: $
global userCancel hCancel %for the GUI 'cancel': this will be set if the user hits cancel, 0 otherwise

commasAt = findstr(textLine,',');
if ~length(commasAt)
  commasAt(length(commasAt)+1)=length(textLine) + 1 ;
else %if ~length(commasAt)
  if commasAt(length(commasAt)) < length(textLine)
    commasAt(length(commasAt)+1)=length(textLine) + 1 ;
  end
end %if ~length(commasAt) else
textFieldQuotesAt = findstr(textLine,'"');
spacesAt = findstr(textLine,' ');
%#IFDEF debugOnly  
%in case we've got a super long line, it appears that the code is hung.
if length(textLine) > 1000
  t = cputime; 
  h_waitBar = 0;
  lastRatio = 0;
  last_itemp = 1;
else 
  t = 0;
end
%#ENDIF

%find any message/text fields: use the rules of Excel
itemp = 1 ;
%look for text field beginnings: itemp is adjusted as text endings are found
while itemp <= length(textFieldQuotesAt)
  %#IFDEF debugOnly  
  if t
    checkCancel;
    if userCancel
      break;
    end
    if ~h_waitBar
      if itemp < last_itemp + 100 % check every 100
        if (cputime - t) > 0.5
          [nextWaitScanUpdate, h_waitBar] = initWaitBar(mfilename);
          [nextWaitScanUpdate, lastRatio] = checkUpdateWaitBar(itemp/length(textFieldQuotesAt), h_waitBar, lastRatio, 0.2, nextWaitScanUpdate);
        end
      end
    else %if ~h_waitBar
      [nextWaitScanUpdate, lastRatio] = checkUpdateWaitBar(itemp/length(textFieldQuotesAt), h_waitBar, lastRatio, 0.2, nextWaitScanUpdate);
    end %if ~h_waitBar else
  end
  %#ENDIF
  %find if this is a beginning quote
  %    if first quote   is   at beginning of line   |  this quote is preceded by a comma
  if ((itemp < 2) & (textFieldQuotesAt(itemp) < 2)) | (any(textFieldQuotesAt(itemp) == commasAt+1))
    %beginning found! locate the matching end
    jtemp = itemp+1;
    a = length(textFieldQuotesAt);
    while jtemp <= a
      %if text ending found
      if any(textFieldQuotesAt(jtemp) == commasAt-1);
        %drop out any commasAt between the quotes by only keeping those that aren't
        commasAt = commasAt(find(commasAt < textFieldQuotesAt(itemp) | commasAt > textFieldQuotesAt(jtemp)));
        %and drop any quotes that are within the message by only keeping those that aren't
        textFieldQuotesAt = textFieldQuotesAt([1:itemp, jtemp:a]);
        %increment the beginning search pointer
        itemp = jtemp;
        break % break out of the jtemp loop
      end %if any(textFieldQuotesAt(jtemp) == commasAt+1);
      jtemp = jtemp + 1;
    end  %for jtemp = itemp+1:length(textFieldQuotesAt)
    %if we didn't find a text ending, we are still in the text field
    if jtemp > itemp
      % only keep the commasAt that precede the beginning
      commasAt = commasAt(find(commasAt < textFieldQuotesAt(itemp)) );
      textFieldQuotesAt = textFieldQuotesAt([1:itemp]);
      itemp = jtemp;
    end
  end;%if any(textFieldQuotesAt(itemp) == commasAt-1)
  itemp = itemp + 1;
end
if length(commasAt)
  if (commasAt(length(commasAt)) < length(textLine) )
    commasAt(length(commasAt) + 1) = length(textLine) + 1;
  end
end
%#IFDEF debugOnly  
if t
  if h_waitBar
    close(h_waitBar);
  end
end
%#ENDIF
