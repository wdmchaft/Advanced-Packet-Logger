function [var, errMsg] = outpostValByName(varName, outpostNmNValues);
% function var = outpostValByName(varName, outpostVarNameList);
%
%Looks through the named list of variable from Outpost.INI
%  which has been read and loaded by "OutpostINItoScript"
%  from Outpost.ini

Ndx = find(ismember(outpostNmNValues, varName));
if Ndx
  var = char(outpostNmNValues(Ndx+1));
  errMsg = '';
else
  var = '';
  errMsg = sprintf('unknown-"%s" not found in Outpost.INI', varName) ;
end
