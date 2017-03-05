function p = Task_OFF(p)
% default actions when the task ends
%
%
% wolf zinke, March 2017

pds.tdt.strobe(p.trial.event.TASK_OFF);

if(p.trial.datapixx.TTL_trialOn)
    pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan,0);
end
