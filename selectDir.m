function [pathstring, choice] = selectDir(currentDir)

if nargin < 1
  currentDir = pwd;
  fprintf('starting');
end
choice = 1;
while choice %& (choice ~= takeThisDir)
  currentDir = endWithBackSlash(currentDir);
  a = dir(strcat(currentDir,'*.'));
  listIn = {a.name};
  takeThisDir = find(ismember(listIn,'.'));
  listIn(takeThisDir) = {'[this dir]'};
  upOne = find(ismember(listIn,'..'));
  listIn(upOne) = {'[up one]'};
  prompt = currentDir;
  [choice] = userChoice(listIn, prompt, 1);
  if choice
    switch choice
    case takeThisDir
      pathstring = currentDir;
      choice = 0;
      break
    case upOne
      a = findstrchr('\', currentDir);
      b = find(a > 2);
      if ~length(b)
      elseif (length(b) < 2)
      else
        currentDir = currentDir(1:a(length(b)-1));
      end
    otherwise
      currentDir = sprintf('%s%s', currentDir, char(listIn(choice))) ;
    end
  else
    pathstring = '';
  end
end