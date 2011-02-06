function outpostNmNValues = postAnalPath(outpostNmNValues)
dirOutpostExpected = outpostValByName('DirFiles', outpostNmNValues);
dirOutpostActual = outpostValByName('DirOutpost', outpostNmNValues);
if strcmp(dirOutpostExpected, dirOutpostActual)
  return
end

oldLen = length(dirOutpostExpected);
newLen = length(dirOutpostActual);

for Ndx = 1:2:length(outpostNmNValues)
  if findstrchr('dir',lower(outpostNmNValues{Ndx})) == 1
    if findstrchr(dirOutpostExpected, outpostNmNValues{Ndx+1}) == 1
      a = outpostNmNValues{Ndx+1};
      outpostNmNValues(Ndx+1) = {sprintf('%s%s', dirOutpostActual, a(oldLen+1:length(a)))};
    end
  end
end
