function [err, errMsg] = printRoutingSlip(outpost, form)
% function [err, errMsg] = printRoutingSlip
% For use in autoprinting by any PACFORM that isn't supported
% by the program & is therefore opened in a browser for
% manual printing.
% * opens a Simple form
% * populates the form with the heading information from Outpost
% * message is set to "Routing Slip" and "Form Attached"
% * appropriate number of copies with proper footer printed

%open a "simple" form
[err, errMsg, h_field, formField] = showForm('', '', '');

%populate with the Outpost heading

%create the message

%and print