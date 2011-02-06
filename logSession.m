function logSession(logLine, fidLogThis);
%prints "logLine" to the display and to fidLogThis.
fprintf('%s', logLine);
if fidLogThis>1
  fprintf(fidLogThis, '%s', logLine);
end

