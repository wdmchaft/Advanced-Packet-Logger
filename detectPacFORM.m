function [PACF, linesRead] = detectPacFORM(fid, linesRead, maxLineSearch);
%function [PACF, linesRead] = detectPacFORM(fid[, linesRead]);
%Support for processOutpostPacketMessage
% determine if it is a PACForm: currently Outpost doesn't include
%  the message date & time so !PACF! is right after Subject.  However, Outpost may add these terms.
%Will prepare for this by reading for a few lines beyond the Subject
%Pre-requisite: file must be open and unless a different value is passed in the 3rd [optional]
%  input paramete, needs to positioned no more than 5 lines before !PAFC! such as
%  at the line starting with "subject:"  Will stop when end of file reached or this count reached.
%INPUTS:
%  fid: pointer to the already opened file
%  linesRead[optional]: nummber of lines read so far.  If not present, 
%    set to zero.  The return "linesRead" will then be the number of lines read here.
%  maxLineSearch[optional]: how many lines this routine will read beyond the current
%    file position for a line starting with !PACF!.  If not found, PACF will == 0.
%    Default is 5 lines

if (nargin < 2)
  linesRead = 0;
end
if (nargin < 3)
  maxLineSearch = 5;
end

for PACF = maxLineSearch:-1:0
  textLine = fgetl(fid);
  linesRead = linesRead + 1;
  %test if the phrase starts the line:
  if (1 == findstrchr('!PACF!', textLine))
    %is a pacform!
    break
  end
  if feof(fid) 
    PACF = 0;
    break
  end
end
