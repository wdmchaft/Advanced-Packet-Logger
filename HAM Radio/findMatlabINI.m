function [fid, pathToINI] = findMatlabINI;
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
