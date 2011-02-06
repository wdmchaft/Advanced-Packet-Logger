function outpost = getOpstMsgNum(outpost, outpostNmNValues, receivedFlag);
%function outpost = getOpstMsgNum(outpost, outpostNmNValues, receivedFlag);
%use by processOutpostPacketMessages
%  Fills in the field "outpost.logMsgNum"
%Must be called after the Outpost heading information (BBS, Subject, To, From, etc
%  are loaded
%If this is a message sent from this station, extracted from the subject line IFF
%  operator turned on AutoMsgNum in Outpost
%If this is a message received by this station, creates a message number iff this station's version
% of Outpost doesn't support LMI (Local Message Indexing).
%   <TacID>-P<number>: where 
%      * TacID is the 3 letter ID set by the operator in Outpost (Tools\Report Settings)
%      * number comes from a file "_log_recvMsg_count.ini" in DirAddOns (typically ...Outpost\AddOns)
%        The number is incremented before use and the number number is saved to the file.
if receivedFlag
  %if the station's version of outpost supports LMI, we will not create a number here nor
  % load it -> it has been loaded by the routine that calls this one: processOutpostPacketMessages
  if ~length(outpostValByName('LMIflag', outpostNmNValues))
    %need to create a number for the received message
    %Per Scott Morse Jan 2010: XSC-P###
    cnt = readRecvMsgNum(outpostNmNValues);
    leadZeros = '0000';
    a = sprintf('%i', cnt);
    outpost.logMsgNum = sprintf('%s-P%s%s', outpostValByName('TacID', outpostNmNValues), leadZeros(1:(4-length(a))), a);
    cnt = cnt + 1 ;
    writeRecvMsgNum(cnt, outpostNmNValues);
  end % if ~length(outpostValByName('LMIflag', outpostNmNValues)) 
else % if receivedFlag
  %sent messages may have the msg number embedded.
  %flag that indicates when autonumbering is on -> affects Subject information for
  %  outgoing messages.
  %**** no longer the relevant test: Outpost+PACF now upgraded so the msg # from the PACF is
  %  passed back to Outpost which then places it on the subject line -> AutoMsgNum is disabled
  %  yet a valid msgnumber is present.
  %A thorough test would be to test the version of Outpost & the current PACF message.  If
  % both are suitable for the Msg# passing, enable searching; otherwise look at the flag "AutoMsgNum"
  if 1 % outpostValByName('AutoMsgNum', outpostNmNValues)
    %pulled the following - we're now requiring the ID format to be xxx??NNNN (x = don't care, ? optional, N required to be numbers
    % %     %Outpost ends the ID it creates with a ":".  Manually entered
    % %     % numbers may end the ID and start the subject with some other punctuation
    % %     delimAt = find(ismember(outpost.subject, '_ :,;'));
    % %     if length(delimAt)
    % %       %set to the first punctuation
    % %       endID = delimAt(1);
    % %     else  
    % %       %no punctuation so take the first 7 characters of the subject....
    % %       %   likely a manual modification of the numbering
    % %       endID = min(7, length(outpost.subject));
    % %     end
    endID = 0;
    %However, the number may have been manually created/modified...
    % general format is <tacID><punctuation><number><subject>
    % where the <tacID> is generally 3 characters, punctuation may not exist
    % or might be "-" or "-P"  Example: XSC-P10002
    %There is no guarantee that the tacID doesn't include numbers.
    %We'll use the rules
    %  mask/ignore the first 3 characters
    %  find contiguous positions containing numbers.
    %  last position with a number ends the ID
    %  a number must be present in the 4th, 5th, 6th, or 7th position
    %                 xxx####
    numsAt = find(ismember(outpost.subject, '0123456789'));
    if length(numsAt) %if numbers
      %ignore the first three character positions
      numsAt = numsAt(find(numsAt>3));
      %if numbers after the first 3 characters
      if length(numsAt)
        %a number must be present in the 4th, 5th, 6th, or 7th position
        %  this means we'll take a long sequence of numbers, just that it
        %  must start by the 7th position.
        if (numsAt(1) < 8)
          %find a string of contiguous positions that are numbers
          %  set up an index array
          b = (2:length(numsAt));
          %  determine the spacing between them - "1" means they're adjacent
          c = numsAt(b) - numsAt(b-1);
          % find where end of contiguous number locations are
          contig = find(c>1);
          %Found at least one number but.... no contiguous numbers
          if ~length(contig)
            %go to the first nummber (that is after the 1st 3 characters)
            contig = length(c) + 1;
          end
          %go to the last contiguous number 
          endID = numsAt(contig(1));
        end % if (numsAt(1) < 8)
      end % if length(numsAt)
    end % if length(numsAt) %if numbers
    if endID
      outpost.logMsgNum = outpost.subject(1:endID);
    end
% % thus seems redundant: variable is pre-cleared by calling program processOutpostPacketMessages  else % if outpostValByName('AutoMsgNum', outpostNmNValues)
% %     outpost.logMsgNum = '';
  end % if outpostValByName('AutoMsgNum', outpostNmNValues) else
  % AutoMsgNum
  % SLS=0 without hypenation 
  % SLS=1 with hypenation
  % SLS=2 date time format
end %  if receivedFlag else
