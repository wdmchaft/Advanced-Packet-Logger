function [figFillPos, figMenuNoBrd, figMenu] = screenSize(h_infig);
%figFillPos: in pixels, position such that figure internal to fill screen
%  without anything been hidden behind the Windows taskbar - no l/r borders
%figMenuFit: in pixels, position that figure menu & title bar are also present
%figMenu: figure fits on screen including borders; 
%          (5) = height of menu (pixels); 
%          (6) = size of borders (a.k.a. frame) used l, r, b - top is menu
%    therefore image width = (3) - 2*(6); height = (4) - (5) - (6)

h_fig = figure;

origUnits = get(h_fig, 'Units');
%fill the screen: 
%  the menu & title bar are positioned off the top
%  the figure itself fills the wdith - not border
%  the bottom will have a border but it is just above the Windows task bar - not extending behind
set(h_fig, 'Units','normalized','Position',[0 0 1 1],'visible','off');
set(h_fig, 'Units','pixels');
figFillPos = get(h_fig,'position');
%the figure is more than full size so the following call
%  results in an auto-fit where there are borders but the bottom
%  extends to the bottom of the screen even though the Windows task bar is there
movegui(h_fig,'northwest')
posit = get(h_fig,'position');
set(h_fig, 'Units', origUnits);
positFull = get(0,'screensize');
menuHi = positFull(4) - (posit(4) + posit(2)) - positFull(2);
botBord = figFillPos(2) - 2*posit(2) + positFull(2) ;
%            no left frame  no bot frame touch taskbar no rht frame  menu & title on screen
figMenuNoBrd = [figFillPos(1) botBord figFillPos(3) (positFull(4) - menuHi - botBord)];
%add in bottom frame as well as l & r frames
botBord = botBord + posit(2);
% % figMenu = [posit(1) botBord  posit(3) (positFull(4) - menuHi - botBord)];
maximize(h_infig);
figMenu = get(h_infig,'position');
figMenu(5) = menuHi;
figMenu(6) = posit(2);
close(h_fig);