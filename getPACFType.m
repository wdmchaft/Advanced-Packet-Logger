function [err, errMsg, pacfListNdx, thisForm, textLine, linesRead] = getPACFType(fid, linesRead);
%function [err, errMsg, pacfListNdx, thisForm, textLine, linesRead] = getPACFType(fid[, linesRead]);
%fid needs to be looking at the line containing !PACF!
%  This module will keep reading until the form is identified (err == 0 )
%  or the end of the file is reached (err ~=0 )
%INPUTS:
%  fid: pointer to the already opened file
%  linesRead[optional]: nummber of lines read so far.  If not present, 
%    set to zero.  The return "linesRead" will then be the number of lines read here.
%OUTPUT:
%  index into the list "pacfList" for this form.  Only valid if err == 0;
%  thisForm: form type in text extracted from the message
%Revision 2: added "FORM DOC-9 HOSPITAL-STATUS REPORT" & "RESOURCE REQUEST FORM #9A"

[err, errMsg, modName] = initErrModName(mfilename);

if nargin < 2
  linesRead = 0;
end

pacfList = {...,
    'CITY-SCAN UPDATE FLASH REPORT', ...
    'SC COUNTY LOGISTICS', ...
    'EOC MESSAGE FORM',  ...
    'CITY MUTUAL AID REQUEST',  ...
    'SHORT FORM HOSPITAL STATUS',  ...
    'HOSPITAL STATUS',  ...
    'HOSPITAL-BEDS',  ...
    'OES MISSION REQUEST',  ...
    'SEMS SITUATION', ...
    'FORM DOC-9 HOSPITAL-STATUS REPORT', ...
    'RESOURCE REQUEST FORM #9A',...
    'FORM DOC-9 BEDS HOSPITAL-STATUS REPORT'...
};
 
textLine = fgetl(fid);
linesRead = linesRead + 1;
found = 0;
pacfListNdx = 0;
thisForm = '';
poundAt = findstrchr('#', textLine);
while ( (1 == poundAt(1)) & ~feof(fid))
  for pacfListNdx = 1:length(pacfList)
    if findstrchr(textLine, char(pacfList(pacfListNdx)))
      thisForm = char(pacfList(pacfListNdx)) ;
      found = 1;
      break
    end % if findstrchr(textLine, char(pacfList(itemp)))
  end % for itemp = 1:length(pacfList)
  if found
    break
  end
  textLine = fgetl(fid);
  poundAt = findstrchr('#', textLine);
  linesRead = linesRead + 1;
end % while ( (1 = findstrchr('#', textLine)) & ~feof(fid))
if feof(fid) | ~found
  err = 1;
  [fname, permission, machineormat] = fopen(fid);
  errMsg = sprintf('%s: no recognized PACForm type in "%s".', modName, fname);
  form.type = 'unknown PACF';
  pacfListNdx = 0;
  return
end
