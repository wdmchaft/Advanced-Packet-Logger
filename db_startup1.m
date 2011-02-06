cd(currentDir)
fprintf('\ndbstop in C:\\mFiles\\HAM Radio\doit at 137');
dbstop in 'C:\mFiles\HAM Radio\doit' at 137
fprintf('\ndbstop in C:\\mFiles\\HAM Radio\\doit at 185');
dbstop in 'C:\mFiles\HAM Radio\doit' at 185
fprintf('\ndbstop in C:\\mFiles\\HAM Radio\\processOutpostPacketMessages at processMessages');
dbstop in 'C:\mFiles\HAM Radio\processOutpostPacketMessages' at processMessages
fprintf('\ndbstop in C:\mFiles\\HAM Radio\\packetLogSettings at packetLogSettings_OpeningFcn');
dbstop in 'C:\mFiles\HAM Radio\packetLogSettings' at packetLogSettings_OpeningFcn
fprintf('\n');
dbstop if error
progress('listboxMsg_Callback', sprintf('****** Breakpoints re-established: ****** '));
dbstatus
