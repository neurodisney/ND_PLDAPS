function p = Task_WaitFixStart(p)
% default actions when the task starts
%
%
% wolf zinke & Nate Faber, Oct 2017

% Gaze is outside fixation window
if(p.trial.task.fixFix == 0)

    % Fixation has occured
    if(p.trial.stim.fix.fixating)
        p.trial.task.fixFix = 1;

        % Time to fixate has expired
    elseif(p.trial.CurTime > p.trial.EV.TaskStart + p.trial.task.Timing.WaitFix)
        % Long enough fixation did not occur, failed trial
        p.trial.task.Good = 0;
        p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

        % Go directly to TaskEnd, do not start task, do not collect reward
        ND_FixSpot(p,0);
        ND_SwitchEpoch(p,'TaskEnd');
    end

% If gaze is inside fixation window
elseif(p.trial.task.fixFix == 1)

    % Fixation ceases
    if(~p.trial.stim.fix.fixating)
        p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;
        % Turn off the spot and end the trial
        ND_FixSpot(p,0);
        ND_SwitchEpoch(p,'TaskEnd');

        % Fixation has been held for long enough
    elseif(p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.behavior.fixation.MinFixStart)
        % Transition to the succesful fixation epoch
        ND_SwitchEpoch(p,'Fixating');
    end
end

