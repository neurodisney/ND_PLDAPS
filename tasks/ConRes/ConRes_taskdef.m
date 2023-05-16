% John Amodeo, May 2023

% Function to define task parameters
function p = ConRes_taskdef(p)


    % Setting time window for fixation before trial marked as 'NoStart'
    p.trial.task.Timing.WaitFix = 2;

    % Storing expected latency of stim presentation to use for trial timing calculations
    p.trial.task.stimLatency = ND_GetITI(0.75, 1.5);
    
    % Setting time stimuli are left on screen after correct trial before task ends
    p.trial.task.Timing.WaitEnd = 0.25;
    
    % Selecting inter-trial interval (ITI)
    p.trial.task.Timing.ITI = ND_GetITI(1.25, 1.75, [], [], 1, 0.10);
    
    % Setting time-out(s) for incorrect response
    p.trial.task.Timing.TimeOut = 1;   

    % Setting number of trials per block
    p.trial.Block.maxBlockTrials = 5;


    % Setting properties for fixation point
    p.trial.stim.FIXSPOT.type = 'rect';    
    p.trial.stim.FIXSPOT.color = 'dRed';
    p.trial.stim.FIXSPOT.size = 0.25;
    p.trial.stim.FIXSPOT.fixWin = 2;


    % Assigning lineweight (thickness) to rings
    p.trial.stim.RING.lineWeight = [0.3, 0.3];

    % Creating flat-hazard function from which to pull out time of wait before stim change
    p.trial.task.presDur = 1.5;

    % Creating trial increments to scale size of reward based on good performance
    p.trial.reward.IncrementTrial = [50, 150, 300, 400, 500, 600, 650];    
    

    % List of increasing durations of juice flow for reward
    % This list is linked to trial increments for scaling size of reward
    %p.trial.reward.IncrementDur = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
    p.trial.reward.IncrementDur = [0.1, 0.15, 0.175, 0.2, 0.225, 0.25, 0.3];

    % Degree to which current reward decreased for bad performance 
    p.trial.reward.DiscourageProp = 0.8;
    
end

