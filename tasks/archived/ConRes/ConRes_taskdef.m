% John Amodeo, May 2023

% Function to define task parameters
function p = ConRes_taskdef(p)


    % Setting time window for fixation before trial marked as 'NoStart'
    p.trial.task.Timing.WaitFix = 0.25;

    % Storing expected latency of stim presentation to use for trial timing calculations
    p.trial.task.stimLatency = ND_GetITI(0.75, 1.5);
    
    % Setting time stimuli are left on screen after correct trial before task ends
    p.trial.task.Timing.WaitEnd = 0.25;
    
    % Selecting inter-trial interval (ITI)
    p.trial.task.Timing.ITI = ND_GetITI(1.25, 1.75, [], [], 1, 0.10);
    
    % Setting time-out(s) for incorrect response
    p.trial.task.Timing.TimeOut = 1;   


    % Setting properties for fixation point
    p.trial.stim.FIXSPOT.type = 'rect';    
    p.trial.stim.FIXSPOT.color = 'dRed';
    p.trial.stim.FIXSPOT.size = 0.25;
    p.trial.stim.FIXSPOT.fixWin = 1.75;


    % Assigning parameters to ring
    p.trial.stim.RING.lineWeight = [0.3, 0.3];
    p.trial.stim.RING.flash_screen = 1;

    % Creating duration for stimulus presentation
    p.trial.task.presDur = 2;

    % Creating trial increments to scale size of reward based on good performance
    p.trial.reward.IncrementTrial = [50, 150, 300, 400, 500, 600, 650];
    p.trial.reward.Continuous = 1;
    p.trial.reward.duration = 0.015;
    p.trial.reward.Period = 0.5;
    p.trial.reward.jackpotnPulse = 1;
    

    % List of increasing durations of juice flow for reward
    % This list is linked to trial increments for scaling size of reward
    p.trial.reward.IncrementDur = [0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03];
    %p.trial.reward.IncrementDur = [0.1, 0.15, 0.175, 0.2, 0.225, 0.25, 0.3];

    % Degree to which current reward decreased for bad performance 
    p.trial.reward.DiscourageProp = 0.8;
    
end

