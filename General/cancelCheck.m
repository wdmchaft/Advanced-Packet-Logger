function [nextCancelCheck] = cancelCheck(nextCancelCheck, checkCancelSec, hCancel);
%function [nextCancelCheck] = cancelCheck(nextCancelCheck, checkCancelSec, hCancel);

if (nextCancelCheck > toc)
  return
end

nextCancelCheck = toc + checkCancelSec;
a = toc + 0.1; %check/wait for 100mS
while toc < a
  figure (hCancel)
end
  