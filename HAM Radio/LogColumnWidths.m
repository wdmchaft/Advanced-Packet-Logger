% Log column widths
% Font: Arial 10 pt
% 
% LOCAL	SENDER	     OUTPOST	FORM	    	  	         	       	       	REPLY
% MsgNo	MsgNo   BBS	    TIME  	TIME	FROM	TO	FORM TYPE	SUBJECT	COMMENT	 RQD.
% 
% 10.71	8.43	8.29    9.14	6.43	9.86	8.43	15.71	42.14	17.57	10.71
%                      13.29 full date & time
%This gets a figure whose active area fills the screen where the title, menu bar, etc.
%  are off the top and the bottom is just above Window's bottom bar
%
% figure('Units','normalized','Position',[0 0 1 1])
% get(1,'position')
% ans = 0 0.0723809523809524 1 0.927619047619048
% >> set(1,'units','pixels')
% >> get(1,'position')
% ans =  1          77        1680         974
% >> 974+77 = 1051
%
% >> figure(2)
% >> get(2,'position')
% ans = 560   540   560   420
% >> get(2,'units')
% ans = pixels
% >> movegui(2,'northeast')
% >> get(2,'position')
% ans = 1112         550         560         420
% >> 550+420
% ans = 970

