% Function to define task parameters
function p = ViewScene_taskdef(p)

    % Setting time window for fixation before trial marked as 'NoStart'
    p.trial.task.Timing.WaitFix = 2;
    % Selecting inter-trial interval (ITI)
    p.trial.task.Timing.ITI = ND_GetITI(1.25, 1.75, [], [], 1, 0.10);
    % Setting time-out(s) for incorrect response
    p.trial.task.Timing.TimeOut = 1; 

    % fill in with task parameters
        %video size
        %video fix size
end

