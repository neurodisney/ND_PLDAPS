function readSpikes(p)
% This function reads in spike data from the Sort Binner Gizmo transmitted over UDP from the TDT system.
% A few notes:
%
% The following variables should match their counterparts in the Sort Binner in Synapse
% p.trial.tdt.channels
% p.trial.tdt.sortCodes 
% p.trial.tdt.bitsPerSort
%
% Furthermore, the Sort Binner should take its strobe in from UDP_Recv.NewPacket
% Thus, Synapse will transmit the spike counts every time it receives a packet.
% Everytime this program is run, it will get a count of all the spikes that have occured (on the various channels and sort
% units) since the last time the program was run.
%
% Nate Faber, August 2017

nChannels   = p.trial.tdt.channels;
nSorts      = p.trial.tdt.sortCodes;
bitsPerSort = p.trial.tdt.bitsPerSort;

% Initialize the return array
% Array contains for each of the units
% Channels x SortCodes
spikeCounts = zeros(nChannels, nSorts);


udp = p.trial.tdt.UDP;


% Flush the input buffer if there is any data waiting
if(udp.U.BytesAvailable > 0)
    udp.read
end

% Signal to TDT to send a count of spikes
udp.write(0);

% Read back the data TDT sends back
udp.read;
data = udp.data;

% Data returned is in 32 bit words, as uint32. Turn them into arrays of bits
% The array is transposed to align the bits properly for reshaping
bits = de2bi(data, 32)';

% Reshape the bits array into a 3D matrix (bits, sortCodes, Channels)
reshaped = reshape(bits, [bitsPerSort, nSorts, nChannels]);

% change the order of the dimensions so that bi2de can function
binaryCounts = permute(reshaped, [2,1,3]);

% For each channel compute the number of spiked that have occured in each sort unit
for(iChannel = 1:nChannels)
    spikeCounts(iChannel,:) = bi2de(binaryCounts(:,:,iChannel));
end

% Save the data back into p
p.trial.tdt.spikes = spikeCounts;
    
    