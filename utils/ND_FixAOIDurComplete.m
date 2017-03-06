function isComplete=ND_FixAOIDurComplete(p)
% get fixation duration

if p.trial.task.fixOnDur>p=.trial.task.Timing.
elseif p.trial.Task.fixOnDur<
else
    disp('Error! Invalid fixDur');
end
