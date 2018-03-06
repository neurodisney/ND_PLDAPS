function p = give(p, amount, nPulse)
% pds.reward.give(p, amount)    give a certain amount of reward
% handles reward for newEraSyringePumps and via TTL over datapixx. Also
% send a reward bit via datapixx (if datapixx is used).
% stores the time and amount in p.trial.reward.timeReward
% If no amount is specified, the value set in
% p.trial.reward.defaultAmount will be used
%
% modified by wolf zinke, Feb. 2017

    % set default parameters
    if(nargin < 2)
        amount = p.trial.reward.defaultAmount;
    end
    
    sampleRate = 1000; % p.trial.datapixx.adc.dataSampleTimes.srate;
    
    if(nargin < 3)
        nPulse = 1;
        pulse_gap = 0.002;
    elseif(nPulse>1)
        pulse_gap = 0.1;  % hardcoded gap between subsequent pulses (ToDo: make it default setting variable)
    else
        nPulse = 1;
        pulse_gap = 0.002;
    end
        
    if(p.trial.datapixx.useForReward)
        %% datapixx analog output is used
        bufferData = repmat(p.trial.datapixx.adc.TTLamp * ...
                     [ones(1,round(amount*sampleRate)), zeros(1,round(pulse_gap*sampleRate))], 1, nPulse);
        pds.datapixx.analogOut(bufferData, p.trial.datapixx.adc.RewardChannel);
    end

    % send event code for reward
    pds.datapixx.strobe(p.trial.event.REWARD);

    %% store data
    for(i=1:nPulse)
        p.trial.reward.iReward = p.trial.reward.iReward + 1;
        % p.trial.reward.timeReward(p.trial.reward.iReward,:) = [(GetSecs + (i-1)*(pulse_gap+amount)), amount]; % WZ: currently not pre-allocated    
    end
    
    
