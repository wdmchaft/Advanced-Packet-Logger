function [err, errMsg, h_field, formField, printed] = viewToPrintPACF(pathDirs, fname, printer, outpostHdg)
% fall back for PACF that are unsupported:
%  (1) brings up form in browser as specified in pac-read.ini.
%  (2) brings up a routing slip that will be printed when formFooterPrint is called.
%  (3) calls formFooterPrint.

[err, errMsg] = viewPACF(pathDirs.DirPF, pathDirs.addOnsPrgms, fname);
h = helpdlg(sprintf('Manual printing needed for \n"%s"', fname),'Manual Print');
movegui(h, 'northwest')

[err, errMsg, h_field, formField] = routingSlip(outpostHdg);
if (~err & printer.printEnable)
  % addressee, originator, textToPrint, & receivedFlag have no meaning in this context
  [err, errMsg, printed] = ...
    formFooterPrint(printer, h_field, formField, fname, '', '', '', outpostHdg, 0);
end % if (~err & printer.printEnable)
printed.Name = 'manual print';