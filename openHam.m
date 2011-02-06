%openHam
%When MATLAB fails to re-start properly, this procedure loads the basic modules for the
% ham radio modules.  Of course this needs to be manually invoked...

%all the ToDo's: they are placed in a location to facilitate copying to PDA phone
a = dir('C:\Users\Owner\Documents\Documents on arose''s Smartphone\Documents\todo*.m');
for itemp=1:length(a);
  edit (sprintf('C:\\Users\\Owner\\Documents\\Documents on arose''s Smartphone\\Documents\\%s',a(itemp).name));
end

cd('C:\mFiles\HAM Radio')
edit ('outpostHistory.txt')
edit ('updateHam_i7Lap_NdyDesk.m')