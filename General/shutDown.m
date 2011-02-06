function shutDown
global h_1 screen_pos

% We want to start next time in the same working directory
%  which is variable.  We'll store the name of the directory in
%  a file in '\matlab6p1\work' which we first need to locate
%  explicitly because it may not be on the current drive!
a = path;
b = findstrchr('\matlab6p1\work', lower(a));
if b
  c = findstrchr(';', a);
  %find the separator before the text
  d = find(c < b);
  %if found, use the last separator in the set
  if length(d)
    d = c(d(length(d)));
  else
    %not found: point just before the first character
    d = 0;
  end
  e = find(c > b);
  %if found, use the last separator in the set
  if length(e)
    e = c(e(1));
  else
    %not found: start with the first character
    e = length(a)+1;
  end
  %Found!
  matlabWork = a(d+1:e-1);
  %learn the current location...
  currentDir = pwd;
  %switch directory
  cd (matlabWork)
  %save the path for the directory we had been using
  fid = fopen('currentDir.txt','w');
  if fid > 0
    fprintf(fid,'%s', currentDir);
    fclose(fid);
  end
end %if b
saveBreakpoints;

%determine figure 1's position as it was when "tileFigs" was last used: can't look for it now because
%it is closed before this function is called :-(
%  This is performed because this the figure the user is asked to position & size as a reference
% location for a lot of figures
% % fig = 1;
% % [flag, h_1] = figflag(fig, 1); %(fig, 1) -> (figure #, flag to NOT bring to forground)
% % if length(h_1)
% %   flag = length(find(fig == h_1));
% %   h_1 = fig;
% % end
% % if flag
% if length(h_1)
%   %if figure was open, write the commands to re-open it to the same size & location 
%   % % screen_pos = get(h_fig,'position');
%   fid = fopen('db_startup.m','a');
%   fprintf(fid, 'figure(%i)\r\n', h_1);
%   fprintf(fid, 'set(%i, ''position'',[%i %i %i %i])\r\n', h_1, screen_pos);
%   fprintf(fid, 'set(%i, ''Selected'',''off'')\r\n', h_1);
% end

forceCloseAllFigs

%quit
  