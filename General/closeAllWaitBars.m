function [figPosition] = closeAllWaitBars(varargin);
%function [ [figPosition] ] = closeAllWaitBars( [varargin] );
%Close any and ALL "waitbar" figures and optionally
% any figures whose 'tag' property string is in the optionally
% passed-in list OR who's user data is a structure with
% a field "creator" (ex: ud.creator).
%If that list exist and a figure of that list is found, its
% position on the screen before it was deleted is returned.
%figPosition([position], count in original list).  Not sure the count
% in the original list is the right index to use!  
%VSS revision   $Revision: 2 $
%Last checkin   $Date: 5/11/07 4:44p $
%Last modify    $Modtime: 5/07/07 12:35p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

a = get(0,'ShowHiddenHandles'); %temp stor current status
set(0,'ShowHiddenHandles','on'); %turn on
hlist = get(0,'children'); %get full list
set(0,'ShowHiddenHandles', a) %restore status from tmp
if nargout
  figPosition = [];
end
for itemp = 1:length(hlist) %close
  a = get(hlist(itemp),'tag');
  b = findstrchr('Waitbar', a);
  if ~b
    %in case it is not in the tag
    ud = get(hlist(itemp),'userdata');
    for jtemp = 1:nargin
      if nargin > 1
        c = char(varargin{jtemp});
      else
        c = char(varargin) ;
      end
      b = findstrchr(c, a);
      if ~b
        if isfield(ud, 'creator')
          b = findstrchr(c, ud.creator);
        end % if isfield(ud, 'creator')
      end % if ~b
      if b
        b = b + 10;
        break
      end % if b
    end %for jtemp = 1:nargin
  end %if ~b
  if b
    if b > 10 & nargout
      b = get(hlist(itemp),'Position');
      figPosition([1:length(b)], hlist(itemp)) = b';
    end
    close (hlist(itemp))
  end
end
