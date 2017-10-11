function p = ND_SwitchEpoch(p, epochName)
% change trial epoch and keep track of epoch timings

% update previous epoch
if(p.trial.EV.epochCnt > 0)
    p.trial.EV.epochTimings{p.trial.EV.epochCnt, 3} = p.trial.CurTime;
end

p.trial.EV.epochCnt = p.trial.EV.epochCnt + 1;

% get timings for new epoch
p.trial.EV.epochTimings{p.trial.EV.epochCnt, 1} = epochName;
p.trial.EV.epochTimings{p.trial.EV.epochCnt, 2} = p.trial.CurTime;
p.trial.EV.epochTimings{p.trial.EV.epochCnt, 3} = NaN;

