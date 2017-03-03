function  TTL_state(chan, state)
% pds.datapix.TTL    sends a TTL pulse over one of the last 8 bits of the digital output
% of the DataPixx DB25 connector. If a event code is provided as second 
% argument an additional code is sent via the first 16 bits (check  
% ND_TDTstrobe for details about the 16 bit code). 
%
%    chan   pin
%      1  -   9
%      2  -  22
%      3  -  10
%      4  -  23
%      5  -  11
%      6  -  24
%      7  -  12
%      8  -  25
%
%
% wolf zinke & Kia Banaie, Feb 2017

%% generate a mask covering the 16 bits used for TDT communication
evntmask = '0000000000000000'; % hardcode for efficiency %repmat('0',1,16);

%% select channels for the DIO TTL pulse
chanmask = zeros(1,8);
chanmask(9-chan) = 1; % add 16 to skip the first 16 bits used for event codes (reverse order)

% needs to be a string
chanmask = sprintf('%d',chanmask);
chanmask = bin2dec([chanmask, evntmask]); % use full 24 bits

%% set the state oft the DIO channel

if(state == 1)
    Datapixx('SetDoutValues', chanmask);
else
    Datapixx('SetDoutValues', 0, chanmask);
end

Datapixx('RegWrRd');   

