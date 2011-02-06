%Rules
% grammar:  no fields are allowed to be empty
%        Rx & Tx, Offset Frequency and offset direct must all make sense
%
% simplex: one frequency
% duplex: requires three memory locations
%         store in one channel, allowed in memory scan
%         channel before: operate as simplex on input frequency, disabled in scan
%         channel after: operate as simplex on output frequency, disabled in scan
%  determine duplex if R Hz != Tx Hz
%