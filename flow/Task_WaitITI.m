function p = Task_WaitITI(p)
% Wait until the defined trial start time is reached
%
%
% wolf zinke, Oct 2017

if (p.trial.reward.earlyFlag)
    p.trial.EV.PlanStart = p.trial.EV.PlanStart + 2.5;
    disp(5)
    p.trial.reward.earlyFlag = 0;
end

if(p.trial.CurTime >= p.trial.EV.PlanStart || isnan(p.trial.EV.PlanStart))
    
    Tdiff =  p.trial.CurTime - p.trial.EV.PlanStart;

    if(Tdiff >= 2*p.trial.display.ifi)
    % if ITI was longer than 2 frames shoot a warning message    
        warning('ITI exceeded intended duration of by %.2f seconds!', Tdiff)
    end

    ND_SwitchEpoch(p,'TrialStart');
end
