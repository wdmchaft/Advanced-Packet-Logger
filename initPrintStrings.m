function [initString, EjectPageTxt] = initPrintStrings(draftLETR, portraitLANDSCAPE);
%function [initString, EjectPageTxt] = initPrintStrings(draftLETR, portraitLANDSCAPE);
%  Configured for HPL3 printer command strings.
%Creates the "initString" to be sent to the printer at the start of print event.  
%  Does NOT send this string.  Calling program's code must send it:
%  ex:         fprintf(fid, '%s', initString);    <--- note there is no CR/LF
%              fprintf(fid, '%s\r\n', textToPrint );
%Additionally creates the string to be sent at the end to cause the printer to
%eject the page.
%
%INPUT
% draftLETR: flag, 0=draft, 1=letter quality as part of initString
% portraitLANDSCAPE: flag, 0=portrait, 1=landscape orientation as part of initString
%OUTPUT
% initString: enables bidirectional printing, sets paper orientation & print quality
%    per the passed in flags.
%    Does not alter: margins (top, bottom, left, right), font, pitch, number of lines
%    lines per inch, bold/italics/underline, etc.
% EjectPageTxt: the string which will cause the printer to eject the page.  Use this
%  at the end of a print operation.

%when combining, simple concatenation works as long as all sets
%  except for the last are lower case:
%  ex: sprintf('%s%s%s', lower(bidirectionalTxt), lower(SpacingFixedTxt), DraftQuality)
bidirectionalTxt = char([027 038 107 049 087]); %       1B 26 6B 31 57
SpacingFixedTxt = char([027 040 115 048 080]); %       1B 28 73 30 50
EjectPageTxt = char([027 038 108 048 072]); %       1B 26 6C 30 48

%	Print Quality
qualityLetter = char([027 040 115 050 081]); % 1B 28 73 32 51
qualityDraft = char([027 040 115 049 081]); % 1B 28 73 31 51
%	Page Orientation
orientLandscape = char([027 038 108 049 079]); % 1B 26 6C 31 4F
orientPortrait = char([027 038 108 048 079]); % 1B 26 6C 30 4F

if draftLETR
  qu = qualityLetter;
else
  qu = qualityDraft;
end
if portraitLANDSCAPE
  or = orientLandscape;
else
  or = orientPortrait;
end
 %NOTE: order may be critcal: see comment list below  (orientation ahead of spacing & quality)
initString = sprintf('%s%s%s%s', lower(bidirectionalTxt), lower(or), lower(SpacingFixedTxt), qu);

%Here is the complete HPL3 command set:
% 	Printer Control
% Reset EscE 027 069 1B 45
% Self test Escz 027 122 1B 7A
% 	Paper Input Control
% Eject page Esc&l0H 027 038 108 048 072 1B 26 6C 30 48
% Feed from tray Esc&l1H 027 038 108 049 072 1B 26 6C 31 48
% Envelope Feed Esc&l3H 027 038 108 051 072 1B 26 6C 33 48
% 	Text Print Mode
% Unidirectional left to right Esc&k0W 027 038 107 048 087 1B 26 6B 30 57
% Bidirectional EC&k1W 027 038 107 049 087 1B 26 6B 31 57
% Unidirectional right to left EC&k2W 027 038 107 050 087 1B 26 6B 32 57
% 	Color Text (graphics)
% Foreground color Esc*v#S 027 042 118 # 083 1B 2A 76 # 53
% 	Underline
% Single fixed Esc&d1D 027 038 100 049 068 1B 26 64 31 44
% Double fixed Esc&d2D 027 038 100 050 068 1B 26 64 32 44
% Single floating Esc&d3D 027 038 100 051 068 1B 26 64 33 44
% Double floating Esc&d4D 027 038 100 052 068 1B 26 64 34 44
% Turn off Esc&d@ 027 038 100 064 1B 26 64 40
% 	Line Termination
% CR=CR, LF=LF, FF=FF Esc&k0G 027 038 107 048 071 1B 26 6B 30 47
% CR=CR+LF, LF=LF, FF=FF Esc&k1G 027 038 107 049 071 1B 26 6B 31 47
% CR=CR, LF=CR+LF, FF=CR+FF Esc&k2G 027 038 107 050 071 1B 26 6B 32 47
% CR=CR+LF, LF=CR+LF,
% FF=CR+FF
% Esc&k3G 027 038 107 051 071 1B 26 6B 33 47
% 	End-of-line Wrap
% Turn on Esc&s0C 027 038 115 048 067 1B 26 73 30 43
% Turn off Esc&s1C 027 038 115 049 067 1B 26 73 31 43
% 	Transparent Print Mode
% No. of bytes Esc&p#X[data] 027 038 112 # 088 [data] 1B 26 70 # 58 [data]
% 	Display Functions Mode
% Turn on EscY 027 089 . 1B 59
% Turn off EscZ 027 090 . 1B 5A
% 	Media Type
% Plain paper Esc&l0M 027 038 108 048 077 1B 26 6C 30 4D
% Bond paper Esc&l1M 027 038 108 049 077 1B 26 6C 31 4D
% Premier paper Esc&l2M 027 038 108 050 077 1B 26 6C 32 4D
% Glossy film Esc&l3M 027 038 108 051 077 1B 26 6C 33 4D
% Transparency film Esc&l4M 027 038 108 052 077 1B 26 6C 34 4D
% 
%====================================================================================
%====================================================================================
% *These printer conmmands are listed in the order in which they must be sent.
%====================================================================================
%====================================================================================
% #Indicates the command parameter value field.- values are entered as ASCII (representations of numerics. E.G. "250" would be
% entered as ASCII "2", "5", "0" ("050 053 048" decimal, or "32 35 30" hex)
% Strana 1
% 	Page Orientation
% Landscape Esc&l1O 027 038 108 049 079 1B 26 6C 31 4F
% Portrait Esc&l0O 027 038 108 048 079 1B 26 6C 30 4F
% 	Paper Size
% Default size Esc&l0A 027 038 108 048 065 1B 26 6C 30 41
% Executive Esc&l1A 027 038 108 049 065 1B 26 6C 31 41
% US Letter Esc&l2A 027 038 108 050 065 1B 26 6C 32 41
% US Legal Esc&l3A 027 038 108 051 065 1B 26 6C 33 41
% A5 ISO/JIS Esc&l25A 027 038 108 050 055 065 1B 26 6C 32 37 41
% A4 ISO/JIS Esc&l26A 027 038 108 050 054 065 1B 26 6C 32 36 41
% B5 JIS Esc&l45A 027 038 108 052 053 065 1B 26 6C 34 35 41
% Custom Esc&l101A 027 038 108 049 048 049 065 1B 26 6C 31 30 31 41
% No. 10 envelope (landscape) Esc&l-81A 027 038 108 056 045 049 065 1B 26 6C 38 2D 31 41
% No. 10 envelope (portrait) Ecs&l81A 027 038 108 056 049 065 1B 26 6C 38 31 41
% International DL envelope EC&l90A 027 038 108 057 048 065 1B 26 6C 39 30 41
% International C6 envelope EC&l92A 027 038 108 057 050 065 1B 26 6C 39 32 41
% Index card 4x6 Esc&l74A 027 038 108 055 052 065 1B 26 6C 39 32 41
% Index card 5x8 Esc&l75A 027 038 108 055 053 065 1B 26 6C 37 35 41
% A6 ISO/JIS (105x148mm) Esc&l24A 027 038 108 050 052 065 1B 26 6C 32 34 41
% Hagaki card (100x148mm) Esc&l71A 027 038 108 055 049 065 1B 26 6C 37 31 41
% 	Line Spacing
% Lines per inch no. of lines Esc&l#D 027 038 108 # 068 1B 26 6C # 44
% 	Page Length
% Number of lines Esc&l#P 027 038 108 # 080 1B 26 6C # 50
% 	Performation Skip Mode
% On Esc&l1L 027 038 108 049 076 1B 26 6C 31 4C
% Off Esc&l0L 027 038 108 048 076 1B 26 6C 30 4C
% 	Top Margin
% Number of lines Esc&l#E 027 038 108 # 069 1B 26 6C # 45
% 	Text Length
% Number of lines Esc&l#F 027 038 108 # 070 1B 26 6C # 46
% 	Side Margins
% Clear Esc9 027 057 1B 39
% Left (column no.) Esc&a#L 027 038 097 # 076 1B 26 61 # 4C
% Right (column no.) Esc&a#M 027 038 097 # 077 1B 26 61 # 4D
% 	Text Scake Mode
% Off Esc&k5W 027 038 107 053 087 1B 26 6B 35 57
% On Esc&k6W 027 038 107 054 087 1B 26 6B 36 57
% 	Cursor Positioning
% Horizontal motion index no. of
% 1/120th inch moves Esc&k#H 027 038 107 # 072 1B 26 6B # 48
% Move to column no. Esc&a#C 027 038 097 # 067 1B 26 61 # 43
% Horizontal no. (decipoints) Esc&a#H 027 038 097 # 072 1B 26 61 # 48
% Horizontal no. (dots) Esc*p#X 027 042 112 # 088 1B 2A 70 # 58
% Vertical motion index no. of 1/48
% inch moves Esc&l#C 027 038 108 # 067 1B 26 6C # 43
% Move to row no. Esc&a#R 027 038 097 # 082 1B 26 61 # 52
% Vertical no. (decipoints) Esc&a#V 027 038 097 # 086 1B 26 61 # 56
% Vertical no. (dots) Esc*p#Y 027 042 112 # 089 1B 2A 70 # 59
% 	Character Set
% PC-8 Esc(10U 027 040 049 048 085 1B 28 31 30 55
% HP Roman8 Esc(8U 027 040 056 085 1B 28 38 55
% PC-8 Danish/Norwegian Esc(11U 027 040 049 049 085 1B 28 31 31 55
% PC 850 Esc(12U 027 040 049 050 085 1B 28 31 32 55
% PC 852 Esc(17U 027 040 049 055 085 1B 28 31 37 55
% ECMA-94 Latin 1 Esc(0N 027 040 048 078 1B 28 30 4E
% German (ISO 21) Esc(1G 027 040 049 071 1B 28 31 47
% French (ISO 69) Esc(1F 027 040 049 070 1B 28 31 46
% Italian (ISO 15) Esc(0I 027 040 048 073 1B 28 30 49
% Spanish (ISO 17) Esc(2S 027 040 050 083 1B 28 32 53
% Swedish Names (ISO 11) Esc(0S 027 040 048 083 1B 28 30 53
% Swedish (ISO 10) Esc(3S 027 040 051 093 1B 28 33 53
% Norwegian 1 (ISO 60) Esc(0D 027 040 048 068 1B 28 30 44
% Norwegian2 (ISO 61) Esc(1D 027 040 049 068 1B 28 31 44
% Portuguese (ISO 16) Esc(4S 027 040 052 083 1B 28 34 53
% United Kingdom (ISO 4) Esc(1E 027 040 049 069 1B 28 31 45
% ANSI ASCII (ISO 6) Esc(0U 027 040 048 085 1B 28 30 55
% JIS ASCII Esc(0K 027 040 048 075 1B 28 30 4B
% HP Legal EscC(1U 027 040 049 085 1B 28 31 55
% ISO IRV Esc(2U 027 040 051 085 1B 28 32 55
% Line Draw (optional) Esc(0L 027 040 048 076 1B 28 30 4C
% Math 7 (optional) Esc(0M 027 040 048 077 1B 28 30 4D
% Math 8 (optional) Esc(8M 027 040 056 077 1B 28 38 4D
% Math8a (optional) Esc(0Q 027 040 048 081 1B 28 30 51
% Math8b (optional) Esc(1Q 027 040 049 081 1B 28 31 51
% PIFont (optional) Esc(15U 027 040 049 053 085 1B 28 31 35 55
% PIFonta (optional) Esc(2Q 027 040 050 081 1B 28 32 51
% 	Spacing
% Proportional Esc(s1P 027 040 115 049 080 1B 28 73 31 50
% Fixed Esc(s0P 027 040 115 048 080 1B 28 73 30 50
% 	Print Pitch
% Number of characters per inch Esc(s#H 027 040 115 # 072 1B 28 73 # 48
% 	Point Size (Character Height)
% Number of 1/72nd inch Esc(s#V 027 040 115 # 086 1B 28 73 # 56
% 	Style
% Upright Esc(s0S 027 040 115 048 083 1B 28 73 30 53
% Italic Esc(s1S 027 040 115 049 083 1B 28 73 31 53
% 	Stroke Weight
% Bold Esc(s3B 027 040 115 051 066 1B 28 73 33 42
% Normal EscC(s0B 027 040 115 048 066 1B 28 73 30 42
% Extra bold (optional) Esc(s7B 027 040 115 055 066 1B 28 73 37 42
% 	Typeface
% Courier Esc(s3T 027 040 115 051 084 1B 28 73 33 54
% CG Times Esc(s4101T 027 040 115 052 049 048 049 084 1B 28 73 34 31 30 31 54
% Letter Gothic Esc(s6T 027 040 115 054 084 1B 28 73 36 54
% Univers Esc(s52T 027 040 115 053 050 084 1B 28 73 35 32 54
% Pica (optional) Esc(s1T 027 040 115 049 084 1B 28 73 31 54
% Line Printer (optional) Esc(s0T 027 040 115 048 084 1B 28 73 30 54
% Prestige (optional) Esc(s8T 027 040 115 056 084 1B 28 73 38 54
% Elite (optional) Esc(s2T 027 040 115 050 084 1B 28 73 32 54
% Script (optional) Esc(s7T 027 040 115 055 084 1B 28 73 37 54
% Helvetica (optional) Esc(s4T 027 040 115 052 084 1B 28 73 34 54
% Presentations (optional) Esc(s11T 027 040 115 049 049 084 1B 28 73 31 31 54
% Times Roman ( optional) Esc(s5T 027 040 115 053 084 1B 28 73 35 54
% CG Century Schoolbook (optional) Esc(s23T 027 040 115 050 051 084 1B 28 73 32 33 54
% Brush (optional) Esc(s32T 027 040 115 051 050 084 1B 28 73 33 32 54
% Dom Casual (optional) Esc(s61T 027 040 115 054 049 084 1B 28 73 36 31 54
% Univers Condensed (optional) Esc(s85T 027 040 115 056 053 084 1B 28 73 38 35 54
% Garamond (optional) Esc(s101T 027 040 115 049 048 049 084 1B 28 73 31 30 31 54
% CG Triumvirate (optional) Esc(s4T 027 040 115 049 084 1B 28 73 34 54
% 	Print Quality
% Letter Esc(s2Q 027 040 115 050 081 1B 28 73 32 51
% Draft (economode) Esc(s1Q 027 040 115 049 081 1B 28 73 31 51
% 	Download Font Management
% Font ID no. Esc*c#D 027 042 099 # 068 1B 2A 63 # 44
% ASCII code no. Esc*c#E 027 042 099 # 069 1B 2A 63 # 45
% Delete All Esc*c0F 027 042 099 048 070 1B 2A 63 30 46
% Delete temporary Esc*c1F 027 042 099 049 070 1B 2A 63 31 46
% Delete last Esc*c2F 027 042 099 050 070 1B 2A 63 32 46
% Make temporary Esc*c4F 027 042 099 052 070 1B 2A 63 34 46
% Make permanent Esc*c5F 027 042 099 053 070 1B 2A 63 35 46
% Create font number of bytes EC)s#W[Data] 027 041 115 # 087 [data] . 1B 29 73 # 57 [data]
% Download chr. No. of bytes EC(s#W[Data] 027 040 115 # 087 [data] . 1B 28 73 # 57 [data]
% 
% 		Raster Graphics
% 	Start Raster Graphics
% At left most position Esc*r0A 027 042 114 048 065 1B 2A 72 30 41
% Current cursor position Esc*r1A 027 042 114 049 065 1B 2A 72 31 41
% 	End Raster Graphics
% End Graphics Esc*rbC 027 042 114 098 067 1B 2A 72 62 43
% 	Resolution
% 75 dots per inch Esc*t75R 027 042 116 055 053 082 1B 2A 74 37 35 52
% 100 dots per inch Esc*t100R 027 042 116 049 048 048 082 1B 2A 74 31 30 30 52
% 150 dots per inch Esc*t150R 027 042 116 049 053 048 082 1B 2A 74 31 35 30 52
% 300 dots per inch Esc*t300R 027 042 116 051 048 048 082 1B 2A 74 33 30 30 52
% 	Set Raster Graphics Width
% Number of pixels Esc*r#S 027 042 114 # 083 1B 2A 72 # 53
% 	Print Mode
% Graphics default (no break) Esc*p0N 027 042 112 048 78 1B 2A 70 30 4E
% Bidirectional Esc*p1N 027 042 112 049 78 1B 2A 70 31 4E
% Left to right Esc*p2N 027 042 112 050 78 1B 2A 70 32 4E
% Right to left Esc*p3N 027 042 112 051 78 1B 2A 70 33 4E
% Conditional bidirectional Esc*p4N 027 042 112 052 78 1B 2A 70 34 4E
% 	Transfer Raster Graphics
% Number of bytes Esc*b#W[data] 027 042 098 # 087 [data] 1B 2A 62 # 57 [data]
% Transfer graphics data by plane Esc*b#V[data] 027 042 098 # 086 [data] 1B 2A 62 # 56 [data]
% 	Relative Verical Pixel MOvement (formerly known as Y Offset)
% Number of dots Esc *b#Y 027 042 098 # 089 1B 2A 62 # 59
% 	Set Graphics Quality
% Quality draft Esc*r1Q 027 042 114 049 081 1B 2A 72 31 51
% Similar to letter quality Esc*r2Q 027 042 114 050 081 1B 2A 72 32 51
% 	Set NUmber of Raster Planes Per Row
% Single plane palette Esc*r1U 027 042 114 049 085 1B 2A 72 31 55
% 3 planes, CMY palette Esc*r-3U 027 042 114 045 051 085 1B 2A 72 2D 33 55
% 3 planes, RGB palette Esc*r3U 027 042 114 051 085 1B 2A 72 33 55
% 4 planes, KCMY palette Esc*r-4U 027 042 114 045 052 085 1B 2A 72 2D 34 55
% 	Graphics Image IMprovement
% Raster graphics shingling Esc*o#Q 027 042 111 # 081 1B 2A 6F # 51
% Raster graphics depletion Esc*o#D 027 042 111 # 068 1B 2A 6F # 44
% 
