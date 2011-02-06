function [choice] = userChoice(listIn, prompt, choice, cancelString);
%function [choice] = userChoice(listIn, prompt, choice[, cancelString]);
%Calls MatLab's 'listdlg' that opens a list window
% cancelString [optional]: label for the cancel button.  Default is 'Cancel'
%Sample:
% [choice] = userChoice(stuff, 'Choose Stuff', lastChoice);
% if choice > 0
%   lastChoice = choice;
%   useThis = listIn(choice);
% else
%   (user cancel)
% end
%Returns 0 if user hit Cancel or # of selection otherwise
%VSS revision   $Revision: 5 $
%Last checkin   $Date: 8/11/05 5:32p $
%Last modify    $Modtime: 8/11/05 5:32p $
%Last changed by$Author: Arose $
%  $NoKeywords: $

choice = min(choice, length(listIn));
choice = max(choice, 1);
if nargin < 4
  cancelString = 'Cancel';
end
[selection, ok] = listdlg('ListString', listIn, 'PromptString', prompt, 'InitialValue', choice, ...
  'SelectionMode', 'single', 'CancelString', cancelString, 'ListSize', [300 300]); %default ListSize is [160 300]  [width height]
if ok
  choice = selection;
else
  choice = 0;
end
