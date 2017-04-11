function p = Task_ON(p)
% default actions when the task starts
%
%
% wolf zinke, March 2017

tms = pds.tdt.strobe(p.trial.event.TASK_ON); % WZ ToDo: Utilize the other timings for TDT synch?
p.trial.EV.DPX_TaskOn = tms(1);
p.trial.EV.TDT_TaskOn = tms(2);

p.trial.EV.StartRT   = p.trial.CurTime - p.trial.EV.TaskStart;

p.trial.EV.Initiated = p.trial.CurTime;

p.trial.task.Good = 1;

if(p.trial.datapixx.TTL_trialOn)
    pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan, 1);
end
