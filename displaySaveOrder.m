function [err, errMsg] = displaySaveOrder(path, h_)

% h_.dispColHdg
% h_.dispColOrdr
% h_.dispColFName
% h_.opCall
[err, errMsg, modName] = initErrModName(mfilename) ;

suffix = '_monitor.txt';
if ~length(h_.dispColFName)
  h_.dispColFName = sprintf('%s_Default', h_.opCall);
end
while 1
  prompt  = {'Enter name for file: (suffix of "_monitor.txt" will be added)'};
  title   = 'Save Column Order';
  lines= 1;
  def     = {h_.dispColFName};
  answer  = inputdlg(prompt,title,lines,def);
  if ~length(answer)
    err = 1;
    errMsg = sprintf('%s: user cancel.', modName);
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
    return
    %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
  end
  h_.dispColFName = char(answer(1)) ;
  fname = sprintf('%s%s_monitor.txt', path, h_.dispColFName);
  if ~length(dir(fname))
    break
  else %if ~length(dir(fname))
    qstring = sprintf('The specified file \n"%s"\n already exists.', fname) ;
    str1 = 'OK: overwrite/replace';
    str2 = 'No: new name';
    str3 = 'Cancel';
    button = questdlg(qstring,'Confirm Save Column Order Name', str1, str2, str3, str1);
    if strcmp(button, str1) %'OK: overwite/replace'
      break
      %elseif strcmp(button, str2) % 'No: new name';
    elseif strcmp(button, str3) % 'Cancel';
      err = 1;
      errMsg = sprintf('%s: user cancel.', modName);
      %%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%
      return
      %%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%
    end %if strcmp(button, str1) %'OK: overwite/replace' elseif strcmp(button, str3) % 'Cancel';
  end % if ~length(dir(fname))
end % while 1


fid = fopen(fname,'w');
if fid < 1
  err = 1; 
  errMsg = sprintf('%s: unable to open "%s" to write.', modName, strcat(path,h_.dispColFName));
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
  return
  %%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%
end

fprintf(fid,'Column order for Packet Log Monitor written by "displaySaveOrder"\r\n');
fprintf(fid,'Do not alter the Heading entries - they are just here as a guide.  Take care if you change the order:\r\n');
fprintf(fid,' limited error checking! Order < 1 or > number of headings invalid; do not duplicate order #.\r\n');
fprintf(fid,' Visibility <0 or > 1 invalid; \r\n');
fprintf(fid,' Order & Visible must have at least same number of entries as original # of headings (erasing a line is bad)\r\n');
fprintf(fid,'Order, Visible, Heading ** do not alter this line **\r\n');
fprintf(fid,'fileRev,0,** do not alter this line **\r\n');
for itemp = 1:length(h_.dispColHdg)
  fprintf(fid,'%i,%i,"%s"\r\n', h_.dispColOrdr(itemp,1), h_.dispColOrdr(itemp,2), char(h_.dispColHdg(itemp)) );
end
fclose(fid);