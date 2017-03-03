function p = give(p, amount)
% pds.behavior.reward.give(p, amount)    give a certain amount of reward
% handles reward for newEraSyringePumps and via TTL over datapixx. Also
% send a reward bit via datapixx (if datapixx is used).
% stores the time and amount in p.trial.behavior.reward.timeReward
% If no amount is specified, the value set in
% p.trial.behavior.reward.defaultAmount will be used
%
% modified by wolf zinke, Feb. 2017

    % set default parameters
    if(nargin < 2)
        amount = p.trial.behavior.reward.defaultAmount;
    end

    if(p.trial.datapixx.use && p.trial.datapixx.useForReward)
        %% datapixx analog output is used
        pds.datapixx.analogOut(amount, p.trial.datapixx.adc.RewardChannel, p.trial.datapixx.adc.TTLamp);
    end

   % send event code for reward    
   pds.tdt.strobe(p.trial.event.REWARD);
   
    %%sound
    if(p.trial.sound.use && p.trial.sound.useForReward)
        PsychPortAudio('Start', p.trial.sound.reward);
        pds.datapixx.flipBit(p.trial.event.AUDIO_REW);
    end
    
    %% store data
    p.trial.behavior.reward.timeReward(:,p.trial.behavior.reward.iReward) = [GetSecs amount];
    p.trial.behavior.reward.iReward = p.trial.behavior.reward.iReward + 1;
    