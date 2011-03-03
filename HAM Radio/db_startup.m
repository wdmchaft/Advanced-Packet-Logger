cd(currentDir)
dbstop in 'C:\mFiles\HAM Radio\dispScoreboard2Msg' at 35
dbstop in 'C:\mFiles\HAM Radio\startReadPACF' at 63
dbstop if error
dbstop if warning
progress('listboxMsg_Callback', sprintf('****** Breakpoints re-established: ****** '));
dbstatus
