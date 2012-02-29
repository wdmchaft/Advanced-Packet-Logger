function [nameList] = dirFileList(fNameExt)
% Used by startReadPACF
%be sure to include wild card when calling!
%return name w/o extension
% if multiple, ordered pairs: {'name1_yrmoda', yrmoda, 'name2_yrmoda', yrmoda...}
% if one: <name>
%INPUT:
%  fNameExt: <path><name>*.ext
%    expected format of name: <name>[_yrMoDa][_pgNN]
%OUTPUT:
%  if one file found, returns string nameList with the name of the
%    located file without the path and without a page number
%  if more than one file found, cell structure with the odd elements
%    the names without the path and without a page number, & the even
%    elements 6 digits representing the yrMoDay extracted from the file name.
%    Each entry in the list will be unique.  This means that if multiple
%    pages <name>_pg01, <name>_pg02, <name>_pg01, only <name> will be return
%    and only once. Similarly <name_yrMoDa>_pg01 will be returned as <name_yrMoDa> 
%

[pathstr, nameIn, ext, versn] = fileparts(fNameExt);
wildAt = findstrchr('*', nameIn);
if wildAt
  nameIn = nameIn(1:wildAt-1);
end
fileList = dir(fNameExt);
if (length(fileList) < 2)
  if length(fileList) < 1
    nameList = [];
  else
    [pathstr, nameList, ext, versn] = fileparts(fileList.name);
  end
else % if length(fileList) < 2
  nameList = {};
  listNdx = 1;
  digits = '0123456789';
  for fileNdx = 1:length(fileList)
    found = 0;
    [pathstr, name, ext, versn] = fileparts(fileList(fileNdx).name);
    yrMoDa = 0; %used as 0 unless date is in the name!
    % if matches name ("dir" takes care of matching as long as lengths same here)
    if (length(name) == length(nameIn))
      found = 1;
    else %if (length(name) == length(nameIn))
      % find the prefix "_"
      dashAt = findstrchr('_', name);
      % if dash present, look for date defined as "_" followed contiguously by 6 digits 
      if any(dashAt)
        c = (ismember(name, digits));
        % find the first prefix that is followed contiguously by 6 digits
        for itemp = 1:length(dashAt)
          a = dashAt(itemp)+[1:6];
          %don't go beyond end of 'c'
          if a(length(a)) <= length(c)
            if sum(c(a)) == 6
              % found it! get the date:
              yrMoDa = str2num(name(dashAt(itemp)+[1:6])) ;
              found = 1;
              break % out of the "for itemp = 1:length(dashAt)" loop
            end %if sum(c()) == 6
          end % if a(length(a)) <= length(c)
        end % for itemp = 1:length(dashAt)
        % check for "<name>_pgN...."
        a = findstrchr('_pg', name);
        %if page number suffix found....
        if a
          %..look for a digit following the "_pg" to be sure it is a page designation
          if c(a+3)
            % get the core name (page # handled elsewhere): pull off the page number...
            %  because we found a page, we probably found other pages: don't add 'em!
            name = name(1:a-1);
            found = 1;
          end %if c(a+3)
        end %if a
      end %if any(dashAt)
    end %if (length(name) == length(nameIn))
    % only add the core name if not all ready in the list:
    if ismember(name, nameList(1:2:length(nameList)))
      found = 0;
    end % if ~ismember(name, nameList(1:2:length(nameList))) else
    if found
      nameList(listNdx) = {name};
      listNdx = listNdx + 1;
      nameList(listNdx) = {yrMoDa};
      listNdx = listNdx + 1;
    end %if found
  end % for fileNdx = 1:length(fileList)
end % if length(fileList) < 2 else