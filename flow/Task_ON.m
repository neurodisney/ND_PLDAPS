function p = Task_ON(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

tms = pds.datapixx.strobe(p.trial.event.TASK_ON); % WZ ToDo: Utilize the other timings for TDT synch?

p.trial.EV.DPX_TaskOn = tms(1);
p.trial.EV.TDT_TaskOn = tms(2);

if(p.trial.datapixx.TTL_trialOn)
    pds.datapixx.TTL(p.trial.datapixx.TTL_trialOnChan, 1);
end

