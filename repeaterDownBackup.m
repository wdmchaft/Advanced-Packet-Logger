function [err, errMsg, totalAddedMemories, currentLines] = repeaterDownBackup(thisLine, totalAddedMemories, thisOriginalMemory, lastMemoryUsed)

% FT8900:  809 memories
% FT60   1,000
%check if this is a repeater.  If it is, we'll end up with the following lines:
%    1) recv on the repeater input frequency & xmt on output.  BOTH OUR RIGS SUPPORT
%      THIS THROUGH SIMPLE KEYSTROKES- this is a reverse of the normal operation. NO 
%      NEED TO USE MEMORY!
%      This will normally not enabled for scanning
%      If radio supports it, perhaps would be good to receive on this frequency and 
%      transmit on the normal repeater output frequency -> why: if repeater is down,
%      we want to be able to communicate with an operator who is trying to use the repeater.
%      They will be transmitting on the repeater input so we need to listen there &
%      they will be listening on the repeater output so we need to transmit there.
%                 recv            xmt
%          they   rptr out       rptr in
%          us     rprt in        rptr out
%        Anybody set up for the repeater can hear us (if in range) and we can hear them
%        but they cannot hear each other.
%      Possibility: set up a "repeater" channel that has the opposite offset from normal.
%    2) the normal repeater configuration
%    3) simplex on repeater output frequency.  Why here & not repeater input?  Anybody listening
%       to the normal repeater output frequency will hear us & with appropriate NC comments, they'll
%       know to switch.
%       
%  Programming notes:
%    a) need to detect if #1 is already implemented: requires comparing two lines.
%    b) scanning will normally only include the conventional repeater configuration.  Even if the radio
%      supports multiple banks, not sure how to configure in advance the banks since some repeaters may
%      be working and others may have failed.
%    c) we are adding memory locations.  
%         * One implementation is to have these 3 locations adjacent.  A disadvantage is this creates 
%         different memory number between the radios in the shack as *presently* configured.  However, 
%         it tends to make a physical sense.
%           ** example, if W6ASH is in memory 1 and all memories at least through 011 are used with 011 being 
%           the N6NFI repeater , the new configuration might have memory 1 set for the repeater input, memory 2 the 
%           standard repeater setup, and memory 3 would be the repeater output (perhaps 2 would be output
%           & 3 normal).  If originally 002 thru 010 were simplex, we'd need only these 2 additional channels so
%           002 would be re-assigned to 004, etc until we get to N6NFI.  It would move from 011 to
%           013.  N6NFI is a repeater so we'd need to add two more configurations & N6NFI would occupy
%           memories 013, 014, and 015.  Whatever has been in 012 would now move up 4 memory locations to 016.  
%           Currently memory locations 27 through 39 are vacant.  We could either keep the same number
%           vacant or give up some or all of the vacant channels to minimize the shift for subsequent
%           memory locations
%         * Another implementation is to place the additional channels in a significant different memory
%         location that is a fixed memory offset from the original repeater memory location.  
%           ** example, if W6ASH is in memory 1, memory 201 could be the repeater input, and 301 the output.
%           Whatever was in memory 002 all the way through 200 would remain in these locations.
%         The disadvantage is we currently have simplex and repeater configurations intermixed in the memory
%         locations (ex 1-10: R,s,R,s,s,s,R,R,R,R).  The memory locations between the new setups might
%         be confusing to assign.
        