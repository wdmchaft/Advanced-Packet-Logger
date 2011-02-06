function [oldfigName] = expandAdjPageNum(formField, h_field, newPageNdx, oldPageNdx);
% function [oldfigName] = expandAdjPageNum(formField, h_field, newPageNdx[, oldPageNdx]);
%oldPageNdx [optional]: 
%     if not present, the figure on "newPageNdx" has it's page number, embedded in
%           Name, incremented.
%     if present, the Name for the figure of "newPageNdx" will be the same as
%           on oldPageNdx with the page number updated to equal newPageNdx.

if nargin < 4
  oldPageNdx = newPageNdx;
end
% % formField(itemp, :)

%update the page # portion of the figure name:
a = size(h_field, 2);
oldfigName = get(h_field(oldPageNdx,  a), 'Name');
%find the Page # & updated
c = 'page ';
b = findstrchr(c, lower(oldfigName));
if length(b)
  set(h_field(newPageNdx, a), 'Name', sprintf('%s%i', oldfigName(1:(b + length(c)-1)), newPageNdx));
end
