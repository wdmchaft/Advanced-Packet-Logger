function [tacAlias, tacCall, txtLineArray, errMsg, fname] = readTacCallAlias(pathToFile, fName);
%function [tacAlias, tacCall, txtLineArray, errMsg, fname] = readTacCallAlias(pathToFile[, fName]);
% Reads "TAC Call Alias.txt" located at <pathToFile> & extracts
%the tactical call sign and the English alias into two separate arrays.
%  ex:  tacCall(n) -> "MTVEOC", tacAlias(n) -> "City of Mountain View EOC"
%format:
%All lines that start with "#" or "%" as well as empty lines are ignored
%TacCall
%  |   +-- token  (any member of ', :;-')
%  |   |   +-Descriptor
%XSCEOC Santa Clara County EOC
%
%INPUT
%  pathToFile: path to tactical call & alias file.
%  fName [optional]: name of the file containing the information if
%     not 'TAC Call Alias.txt'
%OUTPUT
%  tacAlias: cell array of the aliases read from the file. 1:1 
%            relationship with "tacCall"
%  tacCall: cell array of the tactical call signs read from the file. 1:1 
%            relationship with "tacAlias"
%  txtLineArray: array containing all the lines of the file including
%    blank lines and comment lines.

if nargin < 2
  fName = '';
end
if ~length(fName)
  fName = 'TAC Call Alias.txt';
end

fname = strcat(endWithBackSlash(pathToFile), 'TAC Call Alias.txt');
%format 0:
%All lines that start with "#" or "%" are ignored
%TacCall
%  |   +-- token
%  |   |   +-Descriptor
%XSCEOC Santa Clara County EOC

%format 1:
%  has heading:
% #Tactical	Agency Name			Pfx	Pri	Sec
% #--------	--------------------------	---	---	---
%  and data entries:
% XSCEOC		Santa Clara County		XSC	SCC	MTV


tacAlias ={};
tacCall = {};
tacNdx = 0;
lineNdx = 0;
errMsg = '';
txtLineArray = {};
fid = fopen(fname, 'r');
if (fid < 1)
  errMsg = sprintf('The tactical call file was not found: "%s".', fname);
  return
end
fileFormat = 0;
decideFormat = 1;
while ~feof(fid)
  textLine = fgetl(fid);
  if ~lineNdx & isnumeric(textLine)
    errMsg = sprintf('The tactical call file is empty: "%s".', fname);
    return
  end
  lineNdx = lineNdx + 1 ;
  txtLineArray(lineNdx) = {textLine};
  if length(textLine)
    a = find(ismember(textLine,'%#')) ;
    if ~length(a)
      a = 0;
    end
    if (a(1) == 1)
      switch decideFormat
      case 0
      case 1
        if 1 == findstrchr('#Tactical', textLine) & length(textLine) > length('#Tactical')
          textLine = tabToSpaces(textLine);
          agency = findstrchr('Agency Name', textLine);
          pfx = findstrchr('Pfx', textLine);
          pri = findstrchr('Pri', textLine);
          sec = findstrchr('Sec', textLine);
          if any([agency, pfx, pri, sec])
            decideFormat = 2;
            tacLine = lineNdx;
          end %if any(agency, pfx, pri, sec)
        end %if 1 == findstrchr('#Tactical', textLine)
      case 2
        decideFormat = 1;
        if lineNdx == (1 + tacLine)
          if 1 == findstrchr('#--------', textLine)
            fileFormat = 1;
            decideFormat = 0;
          end
        end
      end %switch
    else
      decideFormat = 0;
      tacNdx = tacNdx + 1;
      %find first token in the line (XSCEOC Santa Clara County EOC)
      if fileFormat
        textLine = tabToSpaces(textLine);
      end        
      a = find(ismember(textLine,', :;-') | isspace(textLine) ) ;
      if a
        tacCall(tacNdx) = {strtrim(textLine(1:(a(1)-1)))};
        if fileFormat
          c = find(a < pfx);
          c = a(c(length(c)));
          b = strtrim(textLine((a(1)+1):c));
        else
          b = strtrim(textLine((a(1)+1):length(textLine)));
          a = find(~isspace(b));
          b = b(a(1):a(length(a)));
        end
        tacAlias(tacNdx) = {b};
      else
        tacCall(tacNdx) = {strtrim(textLine)};
        tacAlias(tacNdx) = {''};
      end
    end
  end
end
fclose(fid);      
