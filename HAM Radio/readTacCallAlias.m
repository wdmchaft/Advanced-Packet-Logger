function [tacAlias, tacCall, txtLineArray, errMsg, fPathName, tacType] = readTacCallAlias(pathToFile, fName);
%function [tacAlias, tacCall, txtLineArray, errMsg, fname] = readTacCallAlias(pathToFile[, fName]);
% Reads "TAC Call Alias.txt" located at <pathToFile> & extracts
%the tactical call sign and the English alias into two separate arrays.
% An additional array indicates the type/category for the tactical call
%PrimarySCCo, PrimaryNonSCCo, Secondary, or Numbered.
%  ex:  tacCall(n) -> "MTVEOC", tacAlias(n) -> "City of Mountain View EOC"
%Example of a valid tactical list is at the end of this source code.
%format:
%All lines that start with "#" or "%" as well as empty lines are ignored
%TacCall
%  |   +-- token  (any member of ', :;-')
%  |   |   +-Descriptor
%XSCEOC Santa Clara County EOC
%
%INPUT
%  pathToFile: path to tactical call & alias file.
%  fName [optional]: name of the file containing the information if
%     not 'TAC Call Alias.txt'
%OUTPUT
%  tacAlias: cell array of the aliases read from the file. 1:1 
%            relationship with "tacCall"
%  tacCall: cell array of the tactical call signs read from the file. 1:1 
%            relationship with "tacAlias"
% tacType:  cell array containing a descriptor for the type of tactical
%            call: PrimarySCCo, PrimaryNonSCCo, Secondary, Numbered. 1:1 
%            relationship with "tacAlias"
%  txtLineArray: array containing all the lines of the file including
%    blank lines and comment lines.
% errMsg: empty if no error.  Contains err message otherwise.
% fname: path & name of the file actually accessed

%be nice to add an alias for the 001 -> 010 tactical calss.

if nargin < 2
  fName = '';
end

fPathName = strcat(endWithBackSlash(pathToFile), fName);
%format 0:
%All lines that start with "#" or "%" are ignored
%TacCall
%  |   +-- token
%  |   |   +-Descriptor
%XSCEOC Santa Clara County EOC

%format 1:
%  has heading:
% #Tactical	Agency Name			Pfx	Pri	Sec
% #--------	--------------------------	---	---	---
%  and data entries:
% XSCEOC		Santa Clara County		XSC	SCC	MTV


tacAlias ={};
tacCall = {};
tacNdx = 0;
lineNdx = 0;
errMsg = '';
txtLineArray = {};
tacType ={} ;

tacAliasSponsor = '';
if ~length(fName)
  %the name used by JNOS.
  fName = 'TacCalls';
  fid = fopen(strcat(fPathName, fName), 'r');
  if (fid < 1)
    errMsg = fName;
    % for earlier code versions we'd been using this name:
    fName = 'TAC Call Alias.txt';
    fid = fopen(strcat(fPathName, fName), 'r');
    if (fid < 1)
      errMsg = sprintf('The tactical call file was not found: %s.."%s" nor "%s".', fPathName, fName, errMsg);
      %%%%%%%
      return 
      %%%%%%%
    end % if (fid < 1)
  end %if (fid < 1)
  errMsg = '';
  fPathName = strcat(fPathName, fName);
else%if ~length(fName)
  fid = fopen(fPathName, 'r');
  if (fid < 1)
    errMsg = sprintf('The tactical call file was not found: "%s".', fPathName);
    %%%%%%%
    return
    %%%%%%%
  end
end %if ~length(fName) else
%Code flow & the two variables:
%
%readingPriTacCalls   decideFormat
%     0                      1           initial
%     0                      2           heading line found with '#Tactical' and 
%                                           any of 'Agency Name', 'Pfx', 'Pri', or 'Sec'
%     1                      0           line immediately after heading starts '#-----'
%     1                      0           while reading primary tactical calls for SCCo.
%     2                      0           while reading primary tactical calls for non-SCCo.
%     0                      0           found comment 'End Of Primary Tactical Calls'
% OR if file does not have heading
%     0                      1           initial
%     0                      0           non-comment line found
    
readingPriTacCalls = 0;
decideFormat = 1;
while ~feof(fid)
  textLine = fgetl(fid);
  if ~lineNdx & isnumeric(textLine)
    errMsg = sprintf('The tactical call file is empty: "%s".', fPathName);
    return
  end
  lineNdx = lineNdx + 1 ;
  txtLineArray(lineNdx) = {textLine};
  if length(textLine)
    a = find(ismember(textLine,'%#')) ;
    if ~length(a)
      a = 0;
    end
    %if this is a comment line. . . 
    if (a(1) == 1)
      % based on what we've found so far. . .
      switch decideFormat
      case 0 %switch decideFormat
        if (readingPriTacCalls > 0)
          if findstrchr('End Of Primary Tactical Calls', textLine)
            readingPriTacCalls = 0;
            tacTypeText = 'Secondary';
          elseif findstrchr('Primary Tactical Calls for Other (non-SCCo) Agencies', textLine)
            readingPriTacCalls = 2;
            tacTypeText = 'PrimaryNonSCCo';
          end % if findstrchr('End Of Primary Tactical Calls', textLine)
        else % if (readingPriTacCalls > 0)
          if readingPriTacCalls == -1
            tacAliasSponsor = findtacAliasSponsor(textLine, tacAliasSponsor);
          else % if readingPriTacCalls == -2
            if findstrchr('Numbered Tactical Calls', textLine)
              readingPriTacCalls = -1;
              tacTypeText = 'Numbered';
            end % if findstrchr('End Of Primary Tactical Calls', textLine)
          end
        end % if (readingPriTacCalls > 0) else
      case 1 %switch decideFormat
        % initial pass or after (a) heading found AND then (b) line after heading started '#--------'
        if 1 == findstrchr('#Tactical', textLine) & length(textLine) > length('#Tactical')
          textLine = tabToSpaces(textLine);
          agency = findstrchr('Agency Name', textLine);
          pfx = findstrchr('Pfx', textLine);
          pri = findstrchr('Pri', textLine);
          sec = findstrchr('Sec', textLine);
          if any([agency, pfx, pri, sec])
            % set flag heading found
            decideFormat = 2;
            tacLine = lineNdx;
          end %if any(agency, pfx, pri, sec)
        end %if 1 == findstrchr('#Tactical', textLine)
      case 2 % switch decideFormat
        decideFormat = 1;
        if lineNdx == (1 + tacLine)
          if 1 == findstrchr('#--------', textLine)
            readingPriTacCalls = 1;
            tacTypeText = 'PrimarySCCo';
            decideFormat = 0;
          end
        end
      end %switch decideFormat
    else %if (a(1) == 1)
      %not a comment line
      decideFormat = 0;
      tacNdx = tacNdx + 1;
      tacType(tacNdx) = {tacTypeText};
      %find first token in the line (XSCEOC Santa Clara County EOC)
      if (readingPriTacCalls > 0)
        textLine = tabToSpaces(textLine);
      end        
      a = find(ismember(textLine,', :;-') | isspace(textLine) ) ;
      if a
        tacCall(tacNdx) = {strtrim(textLine(1:(a(1)-1)))};
        %         if findstrchr('MTV', textLine);
        %           if findstrchr('CERT', textLine)
        %             fprintf('asdjkl');
        %           end
        %         end
        if (readingPriTacCalls > 0)
          c = find(a < pfx);
          c = a(c(length(c)));
          b = strtrim(textLine((a(1)+1):c));
        else % if (readingPriTacCalls > 0)
          b = strtrim(textLine((a(1)+1):length(textLine)));
          a = find(~isspace(b));
          b = b(a(1):a(length(a)));
        end % if (readingPriTacCalls > 0) else
        tacAlias(tacNdx) = {b};
      else % if a
        tacCall(tacNdx) = {strtrim(textLine)};
        tacAlias(tacNdx) = {tacAliasSponsor};
      end % if a else
    end  %if (a(1) == 1) else  %if this is a comment line ELSE. . . 
  end % if length(textLine)
end % while ~feof(fid)
fclose(fid);   

function tacAliasSponsor = findtacAliasSponsor(textLine, tacAliasSponsor);
%call only when comment line & and type is Numbers
% presumes the last comment line with anything in it contains the sponsor name
txtLn = strtrim(textLine(2:length(textLine)));
if length(txtLn)
  %   if any(findstrchr(' ', txtLn) == 4)
  %     %format ala "# GIL - Gilroy, City of"
  %     % find the first letter after the first space: (ex: first letter in " - Gilroy, City of"
  %     a = find(ismember(double(lower(txtLn(5:length(txtLn)))), [double('a'):double('z')]));
  %     % take from the first letter until the end of the line; (ex: "Gilroy, City of")
  %     tacAliasSponsor = txtLn(4+a(1):length(txtLn));
  a = findstrchr('-', txtLn);
  if a
    tacAliasSponsor = strtrim(txtLn(1+a(1):length(txtLn)));
  else
    % format ala "# Cupertino, City of"
    tacAliasSponsor = txtLn;
  end
end % if length(txtLn)

% # Created:  Fri Jan 14 09:57:11 PST 2011
% #
% #=================================================
% # Santa Clara County Packet Network Tactical Calls
% #=================================================
% #
% # Primary Tactical Calls for Santa Clara County Cities/Agencies
% # Last Revised:  10-Sep-2010  by  Michael Fox - N6MEF
% #
% # Retain a copy of this file on your packet computer.
% #
% # Each line contains:
% # 1)  Primary tactical call assigned to the agency
% # 2)  Agency name
% # 3)  3-letter tactical prefix assigned to agency
% #       - agency may have other tactical calls starting with this prefix
% # 4)  Primary BBS name (agency normally receives mail here)
% # 5)  Secondary BBS name (agency connects here if primary BBS is down)
% #
% # Message Routing:
% # - By default, messages sent to a tactical call are automatically routed
% #   to the primary BBS (the "@" and primary BBS name automatically added)
% #     - Example:  mail sent to "CUPEOC" is routed to CUPEOC@SCC
% # - To override, add "@" followed by alternate BBS name
% #     - Example:  To override, send to:  CUPEOC@MTV
% #
% #Tactical	Agency Name			Pfx	Pri	Sec
% #--------	--------------------------	---	---	---
% CBLEOC		Campbell, City of		CBL	SCC	MTV
% COCOMM		County Comm Center		CCC	SCC	MTV
% CUPEOC		Cupertino, City of		CUP	SCC	MTV
% GILEOC		Gilroy, City of			GIL	SCC	MTV
% HOSDOC		SCCo Hospitals			HOS	W6XSC-2	SCC
% LMPEOC		Loma Prieta Region		LMP	SCC	MTV
% LOSEOC		Los Altos, City of		LOS	MTV	SCC
% LAHEOC		Los Altos Hills, Town of	LAH	MTV	SCC
% LGTEOC		Los Gatos, Town of		LGT	SCC	MTV
% LGREDC		Los Gatos Red Cross		LGR	SCC	MTV
% MLPEOC		Milpitas, City of		MLP	SCC	MTV
% MSOEOC		Monte Sereno, City of		MSO	SCC	MTV
% MRGEOC		Morgan Hill, City of		MRG	SCC	MTV
% MTVEOC		Mountain View, City of		MTV	MTV	SCC
% NAMEOC		NASA - Ames			NAM	MTV	SCC
% PAFEOC		Palo Alto, City of		PAF	MTV	SCC
% PAFARC		Palo Alto Red Cross		PAR	MTV	SCC
% SJCEOC		San Jose, City of		SJC	SCC	MTV
% SJCARC		San Jose Red Cross		SJR	SCC	MTV
% SJWEOC		San Jose Water Co		SJW	SCC	MTV
% SNCEOC		Santa Clara, City of		SNC	SCC	MTV
% XSCEOC		Santa Clara County		XSC	SCC	MTV
% VWDEOC		SC Valley Water District	VWD	SCC	MTV
% SAREOC		Saratoga, City of		SAR	SCC	MTV
% STUEOC		Stanford University		STU	MTV	SCC
% SNYEOC		Sunnyvale, City of		SNY	SCC	MTV
% #
% # Each of the above agencies also has ten (10) numbered tactical calls
% # beginning with their assigned prefix and ending with numbers 001 - 010.
% #
% # Primary Tactical Calls for Other (non-SCCo) Agencies:
% #
% COSEOC		CalEMA - Coastal Region		COS	SCC
% XALEOC		Alameda County			XAL	MTV
% XCCEOC		Contra Costa County		XCC	SCC
% XMREOC		Marin County			XMR	SCC
% XMYEOC		Monterey County			XMY	SCC
% XBEEOC		San Benito County		XBE	SCC
% XSFEOC		San Francisco County		XSF	SCC
% XSMEOC		San Mateo County		XSM	MTV
% XCZEOC		Santa Cruz County		XCZ	SCC
% #
% #======== End Of Primary Tactical Calls ==========
% ##
% #=================================================
% #
% #
% # Campbell Tacticall Call List
% # Revised:  26-July-2010 by Barton Smith N6HDN
% #
% CBLSSV	Campbell ARES Shift Supervisor
% CBLEC1	Campbell Emergency Coordinator
% CBLAEC	Campbell Assistant Emergency Coordinator
% CBLAOC	Campbell Alternate Operations Center
% CBLSH1	Shelter in Campbell
% CBLSH2	Shelter in Campbell
% #
% #=================================================
% #
% #
% # Cupertino Tactical Calls
% # 27-Oct-2010
% #
% # City Facilities
% CUPBBF	Cupertino Blackberry Farm (OES)
% CUPCRE	Creekside Park
% CUPDPW	Cupertino Corp Yard
% CUPEOC	Cupertino EOC
% CUPJOL	Jollyman Park
% CUPMEM	Memorial Park
% CUPOPS	Field Operations
% CUPPOR	Portal Park
% CUPQLN	Quinlan Community Center/Shelter
% CUPWVS	West Valley Service Center
% #
% # Arks
% CUPDZA	DeAnza College Ark
% CUPGGA	Garden Gate Ark
% CUPHYA	Hyde Middle School Ark
% CUPLSA	Larsen School Ark
% CUPMVA	Monta Vista Ark
% CUPSSA	Seven Springs Ark
% CUPSCA	Stevens Canyon Ark
% CUPMBA	Montebello Ridge Ark
% #
% # Public Safety
% CUPCSO	County Sheriffs station, west side
% CUPCUF	Cupertino Fire
% CUPMVF	Monta Vista Fire
% CUPSSF	Seven Springs Fire
% #
% # Services
% CUPMED	Cupertino Medical Center
% CUPSJW	San Jose Water in Cupertino (MOU)
% CUPSAN	Cupertino Sanitary District (MOU)
% #
% #=================================================
% #
% #
% # Hospital Tactical Call List
% # Revised: 14-Jan-2011 by Michael Fox
% #
% HOSDOC	SCCo Hospitals DEOC
% #
% HOSECM	El Camino Hospital Mountain View
% HOSECL	El Camino Hospital Los Gatos
% HOSPAV	Palo Alto Veterns Hospital
% HOSSUH	Stanford University Medical Center
% HOSSLH	St. Louise Hospital
% HOSRSJ	Regional Medical Center San Jose
% HOSKSJ	Kaiser San Jose Medical Center 
% HOSGSH	Good Samaritan Hospital
% HOSOCH	O'Connor Hospital
% HOSVMC	Santa Clara Valley Medical Center
% HOSKSC	Kaiser Permanente Santa Clara Medical Center
% #
% # HOS001 - HOS010 are also available
% #
% #
% #=================================================
% #
% #
% #   Tactical calls for Los Altos Packet
% #   27Jul2010    Tom Smith
% #
% LOSEOC	Los Altos	EOC
% LOSPD1	Los Altos 	Police Station
% LOSRC1	Los Altos	Red Cross COOP @ Los Altos Christian School
% LOSESD	Los Altos	Elementary School District Office
% LOSHS1	Los Altos	High School
% LOSLOG	Los Altos	ICS Logistics @ Recreation Department
% #
% #=================================================
% #
% # 
% # Milpitas Packet Tactical Call List 
% # Revised: 14-Aug-2010 by Tim Howard
% # 
% #  MLPEOC   Milpitas Emergency Operations Center
% #
% MLPFS1		Milpitas Fire Station 1 
% MLPFS2		Milpitas Fire Station 2 
% MLPFS3		Milpitas Fire Station 3
% MLPFS4		Milpitas Fire Station 4
% MLPVAN		Milpitas Communications Van
% MLPSH1		Milpitas Shelter 1 (Sports Center)
% MLPSH2		Milpitas Shelter 2 (High School)
% MLPMCH		Milpitas City Hall
% MLPMSC		Milpitas Senior Center
% MLPMCC		Milpitas Community Center
% MLPUSD		Milpitas Unified School District Office
% #
% #=================================================
% #
% #
% #Mountain View Tactical Call List
% #Revised: 27 Oct 2010
% #
% MTVMOC	Mtn. View Municipal Operations Ctr
% MTVPUB	Mtn. View Public Works Branch
% MTVOPS	Mtn. View Operations Section
% MTVFIR	Mtn. View Fire Branch
% MTVLAW	Mtn. View Law Branch
% MTVPLN	Mtn. View Planning Section
% MTVLOG	Mtn. View Logistics Section
% #
% MTVAPK	Ada Park CERT
% MTVATA	Appletree Area CERT
% MTVCPK	Cuesta Park CERT
% MTVDHN	Dutch Haven CERT
% MTVMLN	Monta Loma CERT
% MTVMVG	Mountain View Gardens CERT
% MTVNWA	North Whisman CERT
% MTVOMV	Old Mtn. View CERT
% MTVREX	Rex Manor CERT
% MTVSFA	Saint Francis Acres CERT
% MTVSHD	Shady Ridge CERT
% MTVSLV	Sylvan Park CERT
% MTVWWN	Wagon Wheel CERT
% MTVXNG	The Crossings CERT
% #
% MTVMLA	Mtn. View-Los Altos H.S. Dist.
% MTVMVW	Mtn. View-Whisman School Dist.
% #
% MTVEVC	Mtn. View Emergent Volunteer Ctr.
% MTVSEN	Mtn. View Senior Ctr.
% MTVCOM	Mtn. View Community Ctr.
% MTVECH	El Camino Hospital-Mtn. View
% MTVYMC	Mtn. View YMCA
% MTVGMS	Graham Middle School
% MTVCMS	Crittenden Middle School
% #
% MTVFS1	MTV Fire Sta. 1
% MTVFS2	MTV Fire Sta. 2
% MTVFS3	MTV Fire Sta. 3
% MTVFS4	MTV Fire Sta. 4
% MTVFS5	MTV Fire Sta. 5
% #
% MTVPAV	Mtn. View Sports Pavilian
% MTVWSC	Whisman Sports Center
% MTVSHR	Shoreline Amphitheater
% #
% #MTV001 thru MTV010 also permissible
% #
% #=================================================
% #
% #
% # City of Palo Alto Tactical Call List
% # Revised: 9-Sep-2010 by Paul Lufkin, K6PML, AEC
% #
% #Auxiliary Command 
% PAFOES	Palo Alto Office of Emergency Services (OES) 
% PAFMOC	Palo Alto Mobile Operations Center
% #
% #=================================================
% #
% #
% # Sunnyvale Tactical Call List
% # Created: 28-Aug-2010 by B Gundrum
% #
% SNYEOC    Sunnyvale EOC
% 
% SNYFS1    Sunnyvale Fire Station 1
% SNYFS2    Sunnyvale Fire Station 2
% SNYFS3    Sunnyvale Fire Station 3
% SNYFS4    Sunnyvale Fire Station 4
% SNYFS5    Sunnyvale Fire Station 5
% SNYFS6    Sunnyvale Fire Station 6
% 
% SNYVC1    Sunnyvale Volunteer Center 1
% SNYVC2    Sunnyvale Volunteer Center 2
% SNYVC3    Sunnyvale Volunteer Center 3
% SNYVC4    Sunnyvale Volunteer Center 4
% 
% SNYS01    Sunnyvale Shelter 01
% SNYS02    Sunnyvale Shelter 02
% SNYS03    Sunnyvale Shelter 03
% SNYS04    Sunnyvale Shelter 04
% SNYS05    Sunnyvale Shelter 05
% SNYS06    Sunnyvale Shelter 06 
% SNYS07    Sunnyvale Shelter 07
% SNYS08    Sunnyvale Shelter 08
% SNYS09    Sunnyvale Shelter 09
% SNYS10    Sunnyvale Shelter 10
% 
% 
% # Plus the 10 "Tactical Calls for Ad Hoc Use" (SNY001 > SNY010)
% #
% #
% #=================================================
% # Numbered Tactical Calls
% #=================================================
% #
% # Extra/Temporary Tactical Calls for Santa Clara County Agencies
% # Last Revised:  04-Aug-2010  by  Michael Fox
% #
% # CBL - Campbell, City of
% #
% CBL001
% CBL002
% CBL003
% CBL004
% CBL005
% CBL006
% CBL007
% CBL008
% CBL009
% CBL010
% #
% # CCC - County Comm Center
% #
% CCC001
% CCC002
% CCC003
% CCC004
% CCC005
% CCC006
% CCC007
% CCC008
% CCC009
% CCC010
% #
% # Cupertino, City of
% #
% CUP001
% CUP002
% CUP003
% CUP004
% CUP005
% CUP006
% CUP007
% CUP008
% CUP009
% CUP010
% #
% # GIL - Gilroy, City of
% #
% GIL001
% GIL002
% GIL003
% GIL004
% GIL005
% GIL006
% GIL007
% GIL008
% GIL009
% GIL010
% #
% # HOS - SCCo Hospitals
% #
% HOS001
% HOS002
% HOS003
% HOS004
% HOS005
% HOS006
% HOS007
% HOS008
% HOS009
% HOS010
% #
% # LMP - Loma Prieta Region
% #
% LMP001
% LMP002
% LMP003
% LMP004
% LMP005
% LMP006
% LMP007
% LMP008
% LMP009
% LMP010
% #
% # LOS - Los Altos, City of
% #
% LOS001
% LOS002
% LOS003
% LOS004
% LOS005
% LOS006
% LOS007
% LOS008
% LOS009
% LOS010
% #
% # LAH - Los Altos Hills, Town of
% #
% LAH001
% LAH002
% LAH003
% LAH004
% LAH005
% LAH006
% LAH007
% LAH008
% LAH009
% LAH010
% #
% # LGT - Los Gatos, Town of
% #
% LGT001
% LGT002
% LGT003
% LGT004
% LGT005
% LGT006
% LGT007
% LGT008
% LGT009
% LGT010
% #
% #LGR - Los Gatos Red Cross
% #
% LGR001
% LGR002
% LGR003
% LGR004
% LGR005
% LGR006
% LGR007
% LGR008
% LGR009
% LGR010
% #
% # MLP - Milpitas, City of
% #
% MLP001
% MLP002
% MLP003
% MLP004
% MLP005
% MLP006
% MLP007
% MLP008
% MLP009
% MLP010
% #
% # MSO - Monte Sereno, City of
% #
% MSO001
% MSO002
% MSO003
% MSO004
% MSO005
% MSO006
% MSO007
% MSO008
% MSO009
% MSO010
% #
% # MRG - Morgan Hill, City of
% #
% MRG001
% MRG002
% MRG003
% MRG004
% MRG005
% MRG006
% MRG007
% MRG008
% MRG009
% MRG010
% #
% # MTV - Mountain View, City of
% #
% MTV001
% MTV002
% MTV003
% MTV004
% MTV005
% MTV006
% MTV007
% MTV008
% MTV009
% MTV010
% #
% # NAM - NASA - Ames
% #
% NAM001
% NAM002
% NAM003
% NAM004
% NAM005
% NAM006
% NAM007
% NAM008
% NAM009
% NAM010
% #
% # PAF - Palo Alto, City of
% #
% PAF001
% PAF002
% PAF003
% PAF004
% PAF005
% PAF006
% PAF007
% PAF008
% PAF009
% PAF010
% #
% # PAR - Palo Alto Red Cross
% #
% PAR001
% PAR002
% PAR003
% PAR004
% PAR005
% PAR006
% PAR007
% PAR008
% PAR009
% PAR010
% #
% # SJC - San Jose, City of
% #
% SJC001
% SJC002
% SJC003
% SJC004
% SJC005
% SJC006
% SJC007
% SJC008
% SJC009
% SJC010
% #
% # SJR - San Jose Red Cross
% #
% SJR001
% SJR002
% SJR003
% SJR004
% SJR005
% SJR006
% SJR007
% SJR008
% SJR009
% SJR010
% #
% # SJW - San Jose Water Co
% #
% SJW001
% SJW002
% SJW003
% SJW004
% SJW005
% SJW006
% SJW007
% SJW008
% SJW009
% SJW010
% #
% # SNC - Santa Clara, City of
% #
% SNC001
% SNC002
% SNC003
% SNC004
% SNC005
% SNC006
% SNC007
% SNC008
% SNC009
% SNC010
% #
% # XSC - Santa Clara County (XSC)
% #
% XSC001
% XSC002
% XSC003
% XSC004
% XSC005
% XSC006
% XSC007
% XSC008
% XSC009
% XSC010
% #
% # VWD - SC Valley Water District
% #
% VWD001
% VWD002
% VWD003
% VWD004
% VWD005
% VWD006
% VWD007
% VWD008
% VWD009
% VWD010
% #
% # SAR - Saratoga, City of
% #
% SAR001
% SAR002
% SAR003
% SAR004
% SAR005
% SAR006
% SAR007
% SAR008
% SAR009
% SAR010
% #
% # STU - Stanford University
% #
% STU001
% STU002
% STU003
% STU004
% STU005
% STU006
% STU007
% STU008
% STU009
% STU010
% #
% # SNYEOC - Sunnyvale, City of
% #
% SNY001
% SNY002
% SNY003
% SNY004
% SNY005
% SNY006
% SNY007
% SNY008
% SNY009
% SNY010
% #
% #================ END OF FILE ====================

