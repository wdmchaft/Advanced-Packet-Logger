function [pos] = findstrLen(matchTxt, strToSearch)
if (length(matchTxt) > length(strToSearch))
  pos = 0;
else
  pos = findstrchr(matchTxt, strToSearch);
  if pos
    rej = 0;
    for itemp = 1:length(pos)
      if ~strcmp(matchTxt, strToSearch(pos(itemp)+[0:length(matchTxt)-1]) )
        pos(itemp) = 0;
        %flag rejected a location
        rej = 1;
      end
    end
    %if any were rejected...
    if rej 
      %if any found
      if any(pos)
        %keep only the found positions
        pos = pos(find(pos));
      else %if any(pos)
        %none found - return one valure == 0
        pos = 0;
      end % if any(pos) else
    end % if rej 
  end % if pos
end % if (length(matchTxt) > length(strToSearch)) else
