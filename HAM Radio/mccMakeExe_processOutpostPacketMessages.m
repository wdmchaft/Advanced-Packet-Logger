function [err, errMsg] = mccMakeExe_processOutpostPacketMessages(fulltargetDir, originalPWD, exeName, h_progress);
% **** DO NOT ALTER THIS MODULE:  IT IS CREATED BY "makeexe_general" SO CHANGES HERE ARE LOST!! ****
err = 0;
errMsg = '' ;
try 
  fprintf('\n')
  progress('listboxMsg_Callback', 'Compiling: mcc -v -B sgl processOutpostPacketMessages.m ');
  mcc -v -B sgl processOutpostPacketMessages.m 
catch
  progress('listboxMsg_Callback', sprintf('%s', lasterr));
  progress('listboxMsg_Callback', sprintf('*=*=*= Returning from directory "%s" to "%s"', fulltargetDir, originalPWD));
  cd(originalPWD);
  progress('editCurDir_Callback', originalPWD);
  progress('listboxMsg_Callback', sprintf ('*********** %s.exe NOT created! ************', exeName));
  err = 1;
end