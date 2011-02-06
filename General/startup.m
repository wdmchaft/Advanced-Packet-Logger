%
% written by Andy Rose (aroseorama@gmail.com)

format compact %in command window, removes the blank lines in the display of variables
format long g
tic 

fid = fopen(strcat(endWithBackSlash(pwd), 'db_startup.m'),'r');
if (fid > 0)
  fclose(fid);
  try
    fprintf('\nEstablishing debug breakpoints from last session from "db_startup.m" in %s...', pwd);
    db_startup %This file is written/created when "shutDown" is run
  catch
    fprintf('\n error setting breakpoint(s) from "db_startup.m" in %s (%s)', pwd, lasterr);
    dbstop if error
  end
end

initGlobalGraphics

fprintf('\n **********************');
fprintf('\nIf Matlab fails to reload the Editor with the files you had open last time &');
fprintf('\ninstead posts a warning about problems with the configuration file, run "fixconfiguration".')
fprintf('\nThis will reload the editor but not the Preferences you may have set.  Check especially');
fprintf('\nGeneral->Source Control');
fprintf('\nCommand Window: (including the slider for the buffer size - I use the maximum)');
fprintf('\nEditor/Debugger: Most recently used file list (I use the maximum)');
fprintf('\nEditor/Debugger -> Keyboard & Indenting: I use 2 because the default of 4 spreads the code out a lot.');
fprintf('\n  If problems occur, recovery can be attempted by run fixConfiguration (located in Matlab''s Work directory.');
fprintf('\nThe Help window will also not be opened under this conditions.\n');