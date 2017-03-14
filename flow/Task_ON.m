function p = Task_ON(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

pds.tdt.strobe(p.trial.event.TASK_ON);

p.trial.EV.StartRT = p.trial.CurTime - p.trial.EV.TaskStart;

if(p.trial.datapixx.TTL_trialOn)
    pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan,1);
end
