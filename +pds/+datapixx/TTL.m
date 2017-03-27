function timings = TTL(chan, EV, dur)
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
if(nargin > 1)
    if(~isempty(EV))
    % encode an event code
        evntmask = dec2bin(EV, 16);
    end
end

if(nargin < 2)
    dur = 0.0001; % a minimal time delay might be required to be detected by the TDT system
end

%% select channels for the DIO TTL pulse
chanmask = zeros(1,8);
chanmask(9-chan) = 1; % add 16 to skip the first 16 bits used for event codes (reverse order)

% needs to be a string
chanmask = sprintf('%d',chanmask);
chanmask = bin2dec([chanmask, evntmask]); % use full 24 bits

if(nargout == 0)
    %% just send TTL pulse and event code for efficiency 
    Datapixx('SetDoutValues', chanmask);
    Datapixx('RegWrRd');   
else
    %% get time stamp back, might impair performance
    t = nan(2,1);

    oldPriority = Priority;

    if(oldPriority < MaxPriority('GetSecs'))
        Priority(MaxPriority('GetSecs'));
    end

    Datapixx('SetDoutValues', chanmask);
    Datapixx('SetMarker');

    t(1)=GetSecs;
    Datapixx('RegWrRd');
    t(2)=GetSecs;

    dpTime = Datapixx('GetMarker');

    if(Priority ~= oldPriority)
        Priority(oldPriority);
    end

    timings = [mean(t), dpTime, diff(t)];
end

% a minimal time delay might be required to be detected 
WaitSecs(dur); 

%% reset channels to low again
Datapixx('SetDoutValues', 0, chanmask);
Datapixx('RegWr');

% send event code for active digital output channel
% for(i=1:length(chan))
%     pds.datapixx.flipBit(p.trial.event.(['DO_',int2str(chan(i))]));
% end

