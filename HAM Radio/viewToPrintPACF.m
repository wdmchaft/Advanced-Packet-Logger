function [err, errMsg] = viewToPrintPACF(DirPF, addOnsPrgms, fname)

[err, errMsg] = viewPACF(DirPF, addOnsPrgms, fname);
h = helpdlg(sprintf('Manual printing needed for \n"%s"', fname),'Manual Print');
movegui(h, 'northwest')
