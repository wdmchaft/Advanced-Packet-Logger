function forceCloseAllFigs

wasHidden = get(0,'ShowHiddenHandles'); %temp store current status
set(0,'ShowHiddenHandles','on'); %turn on
hlist = get(0,'children'); %get full list
set(0,'ShowHiddenHandles', wasHidden) %restore status from temp store
for itemp = 1:length(hlist) %close
  a = get(hlist(itemp),'FileName');
  if findstr('.fig', a)
    delete(hlist(itemp))
  end
end %for itemp = 1:length(hlist) 
%any left?
wasHidden = get(0,'ShowHiddenHandles'); %temp store current status
set(0,'ShowHiddenHandles','on'); %turn on
hlist = get(0,'children'); %get full list
set(0,'ShowHiddenHandles', wasHidden) %restore status from temp store
for itemp = 1:length(hlist) %close
  a = get(hlist(itemp),'FileName');
  b = get(hlist(itemp),'Type');
  if findstrchr('.fig', a) | findstrchr('figure', b) 
    %probably didn't close because a function has been assigned to perform
    %  the closing operation and there is a problem with that action
    set(hlist(itemp),'CloseRequestFcn', 'closereq')
    delete(hlist(itemp))
  end
end %for itemp = 1:length(hlist) 
