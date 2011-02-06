function [err, errMsg, fPathName] = write213Alignment(pathName, top_fromMsgHdrBtm, left_fromMsgHdr, right_fromMsgHdr, bottom_fromOpratrUseBtm, isImage)
% see also read213Alignment
%isImage: if set, name prefix is "formAlign_ICS213_"; otherwise "printerAlign_ICS213_"
[err, errMsg, modName] = initErrModName(mfilename);

fPathName = '';
if nargin < 5
  isImage = 0;
end

[pathstr,name,ext,versn] = fileparts(pathName);

answer  = inputdlg({'File name, no extenstion (& no path) ("printerAlign_ICS213_" will be pre-pended)'},'Name for Printer Alignment', 1, {name});
if ~length(answer);
  err = 1;
  return
end
[p,name,ext,versn] = fileparts(answer{1});
fname = name;
if isImage
  prefix = 'formAlign_ICS213';
else
  prefix = 'printerAlign_ICS213';
end
b = findstrchr(prefix, fname);
%if default is anywhere in the user response, remove it: re-format afterwards
if b
  c = [1:b-1 b+length(prefix):length(fname)];
  fname = fname(c);
end
if length(fname)
  fname = sprintf('%s_%s.txt', prefix, fname);
else
  fname = prefix;
end
%user is not allowed to change the path
fPathName = strcat(endWithBackSlash(pathstr), fname);

[err, errMsg, fidOut] = fOpenToWrite(fPathName, 'w', mfilename);
varargout{1} = err;
varargout{2} = errMsg;
if err
  errordlg(errMsg,'Unable to save','modal');
  return
end

fprintf(fidOut, '%%"calibration" in terms of Rows & Columns - by inspection of a printout of rows & columns onto a Form\r\n');
fprintf(fidOut, 'top_fromMsgHdrBtm = %.4f;          %% Row\r\n', top_fromMsgHdrBtm );
fprintf(fidOut, 'left_fromMsgHdr = %.4f;            %% Column\r\n', left_fromMsgHdr );
fprintf(fidOut, 'right_fromMsgHdr = %.4f;         %% Column\r\n', right_fromMsgHdr );
fprintf(fidOut, 'bottom_fromOpratrUseBtm = %.4f;   %% Row\r\n', bottom_fromOpratrUseBtm );
% % fprintf(fidOut, 'pathNameOfWord = %s;   \r\n', handles.pathToWord );
fcloseIfOpen(fidOut);
