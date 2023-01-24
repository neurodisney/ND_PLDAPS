function p = FreeChoice_taskdef(p)

    % Setting reward probabilities for stimuli
    p.trial.reward.probabilities = [0.2, 0.8]; 
    
    % Creating trial increments to scale size of reward based on good performance
    p.trial.reward.IncrementTrial = [50, 150, 300, 400, 500, 600, 650];
    
    % List of increasing durations of juice flow for reward
    % This list is linked to trial increments for scaling size of reward
    p.trial.reward.IncrementDur = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
    %p.trial.reward.IncrementDur = [0.1, 0.15, 0.175, 0.2, 0.225, 0.25, 0.3];

    % Degree to which current reward decreased for bad performance 
    p.trial.reward.DiscourageProp = 1.0;
    
    

    % Setting number of trials per block
    p.trial.Block.maxBlockTrials = 2;
    
    
    
    % Setting time window for fixation before trial marked as 'NoStart'
    p.trial.task.Timing.WaitFix = 2;
    
    % Setting time that must transpire before saccade can be made without being marked as early
    p.trial.task.breakFixCheck = 0.2;
    
   % Setting time for which target must be fixed on before trial marked correct
    p.trial.task.minTargetFixTime = 1; % Changed from 0.1
    
    % Setting time window in which response saccade allowed
    p.trial.task.saccadeTimeout = 1.5;
    


    % Setting properties for fixation point
    p.trial.stim.FIXSPOT.type = 'rect';
    p.trial.stim.FIXSPOT.color = 'green';
    p.trial.stim.FIXSPOT.size = 0.4;
    
    
    
    % Setting properties for stimuli
    p.trial.stim.recParameters.contrast = 0.90; % Changed from 0.96
    p.trial.stim.RECTANGLE.color = 'blue';
    p.trial.stim.recParameters.stim1.coordinates = [4 -1 6 1];
    p.trial.stim.recParameters.stim2.coordinates = [-6 -1 -4 1];

    

    % Storing expected latency of stim presentation to use for trial timing calculations
    p.trial.task.stimLatency = ND_GetITI(0.75, 1.5);
    
    % Setting time stimuli are left on screen after correct trial before task ends
    p.trial.task.Timing.WaitEnd = 0.25;
    
    % Selecting inter-trial interval (ITI)
    p.trial.task.Timing.ITI = ND_GetITI(1.25, 1.75, [], [], 1, 0.10);
    
    % Setting time-out(s) for incorrect responses
    p.trial.task.Timing.TimeOut = 1;
    
end
