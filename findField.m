function findField(keyTerm, handles);

fn = fieldnames(handles);
for fieldNdx = 1:length(fn)
  %get the name of a variable in the structure "logged"
  thisField = char(fn(fieldNdx));
  %if this item is on the pane of interest...
  if findstrchr(keyTerm, thisField)
    fprintf('\nFound %s', thisField);
  end % if findstrchr(thisPane, thisField)
end %for fieldNdx = 1:length(fn)

