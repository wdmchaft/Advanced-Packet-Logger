function [list, err, errMsg] = readRecipients(filePathName);
% accesses the specified file & reads the list of intended recipients ->
%   a copy will be printed for each recipient.
% If the specified file does not exist, it will be created & populated
%   with the default recipients.  This writing is to make it easier for
%   the operator to alter the list.
err = 0;
errMsg = '';
if findstrchr(lower(filePathName), 'outtray')
  defaultList = {'RADIO','PLANNING','ORIGINATOR'};
else
  defaultList = {'ADDRESSEE','RADIO','PLANNING'};
end

fid = fopen(filePathName,'r');
if fid < 1
  list = defaultList;
  [err, errMsg] = writeRecipients(filePathName, list);
  if err
    errMsg = sprintf('>%s%s', mfilename, errMsg);
    return
  end
else %if fid < 1
  itemp = 1;
  list = {};
  while ~feof(fid)
    textLine = fgetl(fid);
    if ischar(textLine)
      if length(textLine)
        list(itemp) = {textLine};
        itemp = itemp + 1;
      end % if length(textLine)
    end % if ischar(textLine)
  end % while ~feof(fid)
end % if fid < 1 else
% if (length(list) < 1)
%   err =  1;
%   errMsg = sprintf(': file "%s" was empty', filePathName);
% end %if length(list) < 1
fcloseIfOpen(fid);