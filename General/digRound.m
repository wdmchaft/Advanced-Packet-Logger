function [answer, err, errMsg] = digRound(number, numDigits)
%rounds off 'number' to the specified number of digits 
%Note this is independent of the power-of-ten of the number
%VSS revision   $Revision: 3 $
%Last checkin   $Date: 8/19/05 11:40a $
%Last modify    $Modtime: 8/19/05 11:39a $
%Last changed by$Author: Arose $
%  $NoKeywords: $

err = 0;
errMsg = '';
numberPower = zeros(size(number));
a = find(number);
numberPower(a) = (floor(log10(abs(number(a))) ) + 1);
digitPower = -numDigits;
a = digitPower + numberPower;
answer = round(number ./ 10.^(a)) .* 10.^(a);
