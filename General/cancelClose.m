function cancelClose;
%CLoses the "Cancel" figure if it happens to still be open
%VSS revision   $Revision: 2 $
%Last checkin   $Date: 2/15/07 9:42a $
%Last modify    $Modtime: 2/15/07 9:42a $
%Last changed by$Author: Arose $
%  $NoKeywords: $
wasHidden = get(0,'ShowHiddenHandles'); %temp stor current status
set(0,'ShowHiddenHandles','on'); %turn on
hlist = get(0,'children'); %get full list
set(0,'ShowHiddenHandles', wasHidden) %restore status from tmp
for itemp = 1:length(hlist) %close
  a = get(hlist(itemp),'Name');
  if findstrchr('Cancel', a)
    delete(hlist(itemp))
    break; % only 1 possible
  end % if findstrchr('Cancel', a) 
end %for itemp = 1:length(hlist) 
