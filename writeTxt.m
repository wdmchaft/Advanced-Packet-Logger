function writeTxt(var, key, verbose, DirWrite)

fpathname = sprintf('%sini_%s.txt', endWithBackSlash(DirWrite), key);
fidOut = fopen(fpathname,'w');
if fidOut > 0
  fprintf(fidOut,'%s', var);
  fclose(fidOut);
  a = dir(fpathname);
  if verbose
    logSession(sprintf('\r\nWrote "%s" containing "%s"', fpathname, var), verbose);
    % %     fprintf('\r\n dir length: %i', length(a));
    % %     if length(a)
    % %       fprintf('  %s, %s, %s', fpathname, a(1).name, a(1).date);
    % %       fid = fopen(fpathname,'r');
    % %       textLine = fgetl(fid);
    % %       fclose(fid);
    % %       fprintf('*** %s', textLine);
    % %     end
  end
else
  if verbose
    logSession(sprintf('\r\nUnable to write "%s" ', fpathname), verbose);
  end
  
end