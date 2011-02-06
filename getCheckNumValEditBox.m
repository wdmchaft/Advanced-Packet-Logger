function [err, user_entry] = getCheckNumValEditBox(h_obj, stor, handles, lowerLimit, upperLimit);
%Performs the following checks:
% 1) did the user enter a number
% 2) if a "lowerLimit" has been specified, is the user value >= this limit?
% 3) if an "upperLimit"  has been specified, is the user value <= this limit?
%If no errors, the user entry is returned in "user_entry"
%If an error, 
%   a) a detailed Error Dialog will pop up AND 
%   b) the value in the box the user altered will be restored to "existingValue"
%   c) the returned "user_entry" will not be the user response but "existingValue"
user_entry = str2double(get(h_obj,'string'));
err = 0 ;
if isnan(user_entry)
  errordlg('You must enter a numeric value','Bad Input','modal')
  err = 1 ;
end
if nargin > 3 & ~err
  % proceed with callback...
  if (user_entry < lowerLimit)
    errordlg(sprintf('You must enter value greater than %g (%.2f invalid)', lowerLimit, digRound(user_entry, 8)),'Bad Input','modal')
    err = 1 ;
  end
  if nargin > 4 & ~err
    % proceed with callback...
    if (user_entry > upperLimit)
      errordlg(sprintf('You must enter a number no larger than %g (%.2f invalid)', upperLimit, digRound(user_entry, 8)),'Bad Input','modal')
      err = 1 ;
    end
  end %if nargin > 4
end %if nargin > 3
if err
  set(h_obj, 'string', getfield(handles, stor) );
  user_entry = getfield(handles, stor);
else
  handles = setfield(handles, stor, user_entry);
  guidata(handles.figure1, handles);
end

