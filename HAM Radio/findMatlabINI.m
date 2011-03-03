function [fid, pathToINI] = findMatlabINI(wantFIDopened);
%wantFIDopened[optional]: if not present, only returns pathToINI
%  if present and non-zero, opens the file in read mode

if nargin < 1
  wantFIDopened = 0;
end
% for windows7 HP laptop
endOfPath = '\AppData\Roaming\MathWorks\MATLAB\R12\MATLAB.ini';
% % fid = fopen(strcat('C:\Documents and Settings\arose.EDC', endOfPath),'r');
%C:\Users\Owner\AppData\Roaming\MathWorks\MATLAB\R12
pathToINI = strcat('C:\Users\Owner', endOfPath);
fid = fopen(pathToINI,'r');
% % a = upper('D:\Cpack200\EDC\data\');
a = upper(':\');
if fid < 1
  pathToINI = strcat('D:\Documents and Settings\ARose\', endOfPath);
  fid = fopen(pathToINI,'r');
  % %   a = 'D:\EDC\';
end
if ~wantFIDopened
  return
end
fcloseIfOpen(fid)

fid = -1;
origDir = pwd;
[pathstr,name,ext,versn] = fileparts(pathToINI)
cd(pathstr);
[fname,pname] = uigetfile('MATLAB*.ini','Editor State Recovery');
cd(origDir)
pathToINI = strcat(endWithBackSlash(pname), fname);
fid = fopen(pathToINI,'r');
