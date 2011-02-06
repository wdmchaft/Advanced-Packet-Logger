function [err] = fcloseIfOpen(fid);
%function [err] = fcloseIfOpen(fid)
% Avoids error when closing an all ready closed file
% returns: 1 = file was not open; 0 = was open & now closed; -1 = open but unable to close
%VSS revision   $Revision: 3 $
%Last checkin   $Date: 1/17/03 3:53p $
%Last modify    $Modtime: 1/17/03 2:47p $
%Last changed by$Author: Arose $
%  $NoKeywords: $
  a = fopen('all');
  err = 1;
  if (size(a,1) )
    for (i=1:1:size(a,2))
      if (a(i) == fid)
        err = fclose(fid);
        break;
      end
    end
  end

