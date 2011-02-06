function [err, errMsg, date_time, prettyDateTime, Yr, Mo, Da, Hr, Mn, Sc] = datevec2timeStamp(A, secPrecision, yrPrecision)
%function [err, errMsg, date_time, prettyDateTime, Yr, Mo, Da, Hr, Mn, Sc] = datevec2timeStamp([A [, secPrecision[, yrPrecision]]])
%Converts the input 'A' into a string 'YrMoDa_HrMnSeconds' where
% Seconds is at least 2 characters. if more than 2, there
% is an implied decimal point before the 3rd: 3rd+ are fractions
%The string is suitable for inclusion in a file name.
%
%INPUTS:
%'A'[optional]: can be in various formats: see 'datevec'; When not present,
%      returns the current time/date with the seconds to 4 decimal place (0.1 mS)
%secPrecision[optional]: maximum number of places after the decimal for seconds as
%    applied to the date_time. The double 'Sc' is always full precision.  Default is 4.
%    If 3rd variable is passed in, setting this to <0 invokes default
%yrPrecision[optional]: precision for the year. Default is 2 & max is 4.
%OUTPUTS
%date_time: 'YrMoDa_HrMnSeconds' where Seconds is at least 2 characters. if more 
% than 2, there is an implied decimal point before the 3rd: 3rd+ are fractions
%prettyDateTime: is easier to read: Mo/Da/Yr Hr:Mn:Se.conds  ex:"01/26/05 15:49:22.252"
% Yr, Mo, etc are doubles
%The function 'timeStamp2datenum' is the reciprocal of this function.
%VSS revision   $Revision: 2 $
%Last checkin   $Date: 1/26/05 4:03p $
%Last modify    $Modtime: 1/26/05 4:01p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

err = 0;
errMsg = '';
if nargin < 1
  A = now;
end
if nargin < 2
  secPrecision = -1;
end
if nargin < 3
  yrPrecision = -1;
end
if secPrecision < 0
  secPrecision = 4;
end
if yrPrecision < 0
  yrPrecision = 2;
end

[y,Mo,Da,Hr,Mn,Sc] = datevec(A);
year = num2str2char(y);
if (yrPrecision < 4)
  yrStr = year([(length(year)-yrPrecision+1):length(year)]);
else
  yrStr = year;
end
Yr = str2num(yrStr);
moStr = num2str2char(Mo);

daStr = num2str2char(Da);
hrStr = num2str2char(Hr);
mnStr = num2str2char(Mn);

aa = sprintf('%%.%if', secPrecision);
scStr = sprintf(aa,Sc);
a = findstrchr('.', scStr);
%need two characters for seconds (i.e. to 10's of seconds)
if (length(scStr) < 2) | ((a < 3) & a)
  scStr = strcat('0', scStr);
end
a = findstrchr('.', scStr);
prettyDateTime = sprintf('%s/%s/%s %s:%s:%s', moStr, daStr, yrStr, hrStr, mnStr, scStr);
if a
  b = length(scStr);
  %pull insignificant 0's
  while scStr([b:b]) == '0'
    b = b - 1;
    scStr = scStr([1:b]);
  end
  %if everything after the decimal within the above specified precision is 0, toss the decimal
  if b == a
    scStr = scStr([1:a-1]);
  else
    scStr = strcat(scStr([1:a-1]), scStr([a+1:length(scStr)]) );
  end
end
date_time = sprintf('%s%s%s_%s%s%s', yrStr, moStr, daStr, hrStr, mnStr, scStr);

%*****
function [string] = num2str2char(num);
string = num2str(num);
if length(string) < 2
  string = strcat('0', string);
end
