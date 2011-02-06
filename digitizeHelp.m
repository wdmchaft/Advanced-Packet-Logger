function digitizeHelp
fprintf('\n Mouse actions:');
fprintf('\n   left button: digitize current location & "pin" the rubber band.');
fprintf('\n   right button: remove the most recent digitized point of the current group.');
fprintf('\n                 Same action with ctrl+left and alt+left.');
%double click: unused
%shift+left: unused
fprintf('\n Key definitions (not case sensitive):')
fprintf('\n   (P)ause digitizer: mouse buttons have no effect.');
fprintf('\n   (R)esume digitizer: mouse buttons enabled.');
fprintf('\n   (M)odify an exiting group/field. Lists all existing groups & asks which to modify.');
fprintf('\n   (N)ew group: close the area of the existing group & start a new one');
fprintf('\n   (G)rab the nearest, all ready digitized point (from another group) and');
fprintf('\n     add to the current group. (Only works if more than one group. The grabbed');
fprintf('\n     point must be visible on the magnified figure.)');
fprintf('\n   (C)hange color for current group.');
fprintf('\n   (Q)uit the procedure.  The points are still in memory.');
fprintf('\n   (?) display this list again.');
