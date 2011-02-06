function initGlobalGraphics
%
% written by Andy Rose (aroseorama@gmail.com)

%Set some of the figure properties
set(0,'DefaultFigurePaperPositionMode','manual')
%Makes printing more convenient & larger
set(0,'DefaultFigurePaperOrientation','landscape') %this is not MatLab's default
set(0,'DefaultFigurePaperUnits', 'inches')
set(0,'DefaultFigurePaperPosition', [0.25 0.25 10.5 8])  %this is not MatLab's default
set(0,'DefaultFigurePaperSize', [11 8.5])
set(0,'DefaultFigurePaperType', 'usletter')
%reduces the black on problem when Matlab screws up with OpenGL
set(0,'DefaultFigureRenderer','zbuffer')
%set the line style order to {solid line, dotted line, dash-dot line, dashed line}  
% these are all that are supported.  Not clear why this isn't invoked to begin with!  
%"Legend" uses a solid for BOTH solid and dashed so dash is moved to last/least likely
% Has effect when plotting multiple lines with one plot command: "plot" cycles through 
%the default colors and then changes line type
set(0,'DefaultAxesLineStyleOrder',{'-',':','-.','--'})
%turn off 'tex' on graphics, i.e. interpretation of text as embedded font, super/sub/symbols
%  Otherwise cannot have "_" in text
set(0,'DefaulttextInterpreter','none') ;
[colorOrder, colorOrderText] = initColorOrder;