function p = Task_OFF(p)
% default actions when the task ends.
% Set time for intertrial period
%
%
% wolf zinke, March 2017

tms = pds.datapixx.strobe(p.trial.event.TASK_OFF); 
p.trial.EV.DPX_TaskOff = tms(1);
p.trial.EV.TDT_TaskOff = tms(2);

p.trial.EV.TaskEnd = p.trial.CurTime;

if(p.trial.datapixx.TTL_trialOn)
    pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan,0);
end

% determine ITI
if(p.trial.outcome.CurrOutcome == p.trial.outcome.Correct)
    p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.ITI;
else
    p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.ITI + p.trial.task.Timing.TimeOut;
end

p.trial.Timer.ITI  = p.trial.Timer.Wait;
p.trial.CurrEpoch  = p.trial.epoch.ITI;
