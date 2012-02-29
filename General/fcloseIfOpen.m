function [status] = fcloseIfOpen(fid);
%function [status] = fcloseIfOpen(fid)
% Avoids status error when closing an all ready closed file
% returns: 1 = file was not open; 0 = was open & now closed; -1 = open but unable to close
%INPUT
% fid: single or list of file IDs that are to be closed
%OUTPUT
% status:
%   1 = file(s) were not open; 
%   0 = all files in the list now closed (either not opened initially or successfully closed)
%  -1 = at least one file in list was open but unable to close.

%find all open files
a = fopen('all');
%default status set to "file not open"
status = 1;
%if any open files. . .
if (size(a,1) )
  % go through list of all open files..
  for (i=1:1:size(a,2))
    if (a(i) == fid)
      st = fclose(fid);
      switch st
      case -1
        status = st;
      case 0
        if st > 0
          status = 0;
        end
      end
    end % if (a(i) == fid)
  end % for (i=1:1:size(a,2))
end % if (size(a,1) )

