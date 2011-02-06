cd(currentDir)
dbstop if error
dbstop if warning
progress('listboxMsg_Callback', sprintf('****** Breakpoints re-established: ****** '));
dbstatus
