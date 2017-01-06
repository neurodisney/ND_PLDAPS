function p = ND_GiveReward(p, amount, chan, TTLamp)
% Function to deliver reward via analogue DataPixx output.
% This function is a modification of the pds.behavior.reward.give function
%
%
% wolf zinke, Jan. 2017


if(~exist('amount', 'var') || isempty(amount))
    amount = p.trial.behavior.reward.defaultAmount;
end

if(~exist('chan', 'var') || isempty(chan))
    chan = 3;  % PLDAPS default for reward channel is channel 3
end

if(~exist('TTLamp', 'var') || isempty(TTLamp))
    TTLamp = 3;  % PLDAPS default amplitude is 3
end


% determine the reward TTL pulse


if(p.trial.datapixx.use)
    if(p.trial.datapixx.useForReward)
        %% This chunk comes from pds.datapixx.analogOut    
        
        % pds.datapixx.analogOut(amount, chan, TTLamp);

        % sampleRate = 1000; % WZ: This value is hardcoded in PLDAPS analogue out, not sure what determines it.
        sampleRate = p.trial.datapixx.adc.srate;
        
        bufferData = [TTLamp * ones(1, round(amount*sampleRate)), 0] ;
        maxFrames = length(bufferData);

        Datapixx('WriteDacBuffer', bufferData ,0 ,chan);

        Datapixx('SetDacSchedule', 0, sampleRate, maxFrames ,chan);
        Datapixx StartDacSchedule;
        Datapixx RegWrRd;
    end


end



% %% store data
% p.trial.behavior.reward.timeReward(:,p.trial.behavior.reward.iReward) = [GetSecs amount];
% p.trial.behavio