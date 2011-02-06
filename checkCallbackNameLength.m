function checkCallbackNameLength(fileName)
% 'packetLogSettings.m'

if nargin < 1
  fileList = dir('*.fig');
  nameList = {};
  for itemp = 1:length(fileList)
    [pathstr,name,ext,versn] = fileparts(fileList(itemp).name);
    a = dir(strcat(name, '.m'));
    if length(a)
      nameList(length(nameList)+1) = {strcat(name, '.m')};
    end
  end
else
  nameList = {fileName};
end

validNameChar = [char(double('A'):double('Z')) char(double('a'):double('z')) '0123456789_'];

for nameNdx = 1:length(nameList)
  invalidCallBack = {};
  fileName =  nameList{nameNdx};
  fid = fopen(fileName,'r');
  while ~feof(fid)
    textLine = fgetl(fid);
    a = findstrchr('%', lower(textLine));
    if a
      textLine = textLine(1:a-1);
    end
    a = findstrchr('_callback', lower(textLine));
    if a
      b = find(~ismember(textLine, validNameChar));
      c = find(b < a);
      if length(c)
        d = b(c(length(c)))+1;
      else
        d = 1;
      end
      c = find(b > a);
      e = b(c(1))-1;
      len = length(textLine(d:e));
      % % fprintf('\n%s\n    -> %s, length = %i', textLine, textLine(d:e), len);
      if len > 31
        invalidCallBack(length(invalidCallBack)+1) = {textLine(d:e)};
      end % if len > 31
    end % if a
  end % while ~feof(fid)
  invalidCallBack = sort(invalidCallBack);
  fprintf('\n ***** %s *****', fileName);
  for itemp = 1:length(invalidCallBack)
    fprintf('\n#%i, length %i: %s', itemp, length(invalidCallBack{itemp}), invalidCallBack{itemp});
  end
  fcloseIfOpen(fid);
end