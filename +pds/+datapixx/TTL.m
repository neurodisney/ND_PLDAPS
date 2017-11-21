function  timings = TTL(chan, state, dur)
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
% Nate Faber, May 2017

% If dur is unspecified, just change the bit indefinitely
if nargin < 3
    dur = [];
    
    if nargin < 2
        state = 1;
    end
    
end

%% generate a mask covering the 16 bits used for TDT communication
evntmask = '0000000000000000'; % hardcode for efficiency %repmat('0',1,16);

%% select channels for the DIO TTL pulse
chanmask = zeros(1,8);
chanmask(9-chan) = 1; % add 16 to skip the first 16 bits used for event codes (reverse order)

% needs to be a string
chanmask = sprintf('%d',chanmask);
chanmask = bin2dec([chanmask, evntmask]); % use full 24 bits

%% Get the current state of the channel
currentStates = de2bi(Datapixx('GetDoutValues'),24);
initialState = currentStates(16 + chan);

if state == initialState
    warning(['TTL channel ' num2str(chan) ' attempted to be changed to ' num2str(state) ', but was already ' num2str(state)]);
end

%% set the state oft the DIO channel
if(nargout == 0)
    if(state == 1)
        Datapixx('SetDoutValues', chanmask);
    else
        Datapixx('SetDoutValues', 0, chanmask);
    end
    Datapixx('RegWrRd');   
else
    % get time stamp back, might impair performance
    t = nan(2,1);

    oldPriority = Priority;

    if(oldPriority < MaxPriority('GetSecs'))
        Priority(MaxPriority('GetSecs'));
    end

    if(state == 1)
        Datapixx('SetDoutValues', chanmask);
    else
        Datapixx('SetDoutValues', 0, chanmask);
    end
    
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

% reset the channel to its initial state if a dur is specified
if ~isempty(dur) && state ~= initialState
    WaitSecs(dur);
    
    if(initialState == 1)
        Datapixx('SetDoutValues', chanmask);
    else
        Datapixx('SetDoutValues', 0, chanmask);
    end
    
    Datapixx('RegWrRd');
end


