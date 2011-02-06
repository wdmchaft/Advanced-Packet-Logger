function [err, errMsg, incidentName, opCall, opName, tacCall, TCwPEnabled, TCnPEnabled,...
  City, County, State, TacLoc, Org, BBS, nextOutDateNum] = readLogSprt(supportFilePathName, outpostDateTimeTxt) ;
% function [err, errMsg, incidentName, opCall, opName, tacCall, TCwPEnabled, TCnPEnabled,...
%   City, County, State, TacLoc, Org, BBS, nextOutDateNum] = readLogSprt(supportFilePathName, outpostDateTimeTxt) ;
% Reads the log support file that is written & updated by "writePacketLog"
%INPUT
% supportFilePathName
% outpostDateTime[optional] = format is string acceptable to "datenum" such as '6/6/2010  11:06:00 AM'
%  if not present, reads to the end of the file & returns the last value recorded
%   for each variable.
%  if present, returns the values that are current for the outpostDateTime.  (Keeps reading
%    until a time stamp in the file is found that is newer than this value.)
%OUTPUT
%  values as named logged as the Outpost conditions.
%  Any value not logged will be blank.  This happens when reading older versions of the file.

[err, errMsg, modName] = initErrModName(mfilename);

if nargin < 2
  outpostDateTime = 0;
else
  outpostDateTime = datenum(outpostDateTimeTxt);
end

incidentName = '';
opCall = '';
opName = '';
tacCall = '';
TCwPEnabled = '';
TCnPEnabled = '';
City = '';
County = '';
State = '';
TacLoc = '';
Org = '';
BBS = '';
nextOutDateNum = 0;

fidSprt = fopen(supportFilePathName, 'r');
if (fidSprt > 0)
  %stay in loop until EOF... unless the outpostDateTime test causes an exit
  while ~feof(fidSprt)
    textLine = fgetl(fidSprt);
    a = findstrchr('=', textLine);
    %if the line has an "="....
    if a
      %get the key phrase
      b = strtrim(textLine(1:a(1)-1));
      %get the value
      val = strtrim(textLine(a(1)+1:length(textLine)));
      switch b
      case 'outpostDateTime'
        nextOutDateNum = datenum(val);
        %if a message date time has been passed in...
        if outpostDateTime
          %. . . if the next outpost configuration recorded in the file is
          % after the the message, do not read that configuration - use the one just before (which we've read)
          if outpostDateTime > nextOutDateNum
            break
          end
        end %if outpostDateTime
      case 'Incident Name'
        incidentName = val;
      case 'opCall'
        opCall = val;
      case 'opName'
        opName = val;
      case 'tacCall'
        tacCall = val;
      case 'TCwPEnabled'
        TCwPEnabled = val;
      case 'TCnPEnabled'
        TCnPEnabled = val;
      case 'City'
        City = val;
      case 'County'
        County = val;
      case 'State'
        State = val;
      case 'TacLoc'
        TacLoc = val;
      case 'Org'
        Org = val;
      case 'BBS'
        BBS = val;
      otherwise
      end %switch b 
    end %if a
  end % while ~feof(fidSprt)
  fclose(fidSprt);
else
  err = 1;
  errMsg = sprintf('>readLogSprt: unable to open "%s" to read.', supportFilePathName);
end

