function [hCancel] = cancelCheckIfOpen;
%Checks if the "Cancel" figure is all ready open.
% Returns the handle if it is & zero if not open
%VSS revision   $Revision: 1 $
%Last checkin   $Date: 6/28/07 9:37a $
%Last modify    $Modtime: 6/28/07 9:31a $
%Last changed by$Author: Arose $
%  $NoKeywords: $
wasHidden = get(0,'ShowHiddenHandles'); %temp stor current status
set(0,'ShowHiddenHandles','on'); %turn on
hlist = get(0,'children'); %get full list
set(0,'ShowHiddenHandles', wasHidden) %restore status from tmp
hCancel = 0;
for itemp = 1:length(hlist) %close
  a = get(hlist(itemp),'Tag');
  if findstrchr('Cancel', a)
    hCancel = hlist(itemp);
    break; % only 1 possible
  end % if findstrchr('Cancel', a) 
end %for itemp = 1:length(hlist) 
