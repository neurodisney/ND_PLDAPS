function p = FreeChoice_taskdef(p)

    % Setting sequence in which trial progresses
    % 0 presents grating first and fix point second
    % 1 presents fix point first and grating second
    p.trial.task.sequence = 0;

    % Setting time window for fixation before trial marked as 'NoStart'
    p.trial.task.Timing.WaitFix = 2;

    % Storing expected latency of stim presentation to use for trial timing calculations
    p.trial.task.stimLatency = ND_GetITI(0.75, 1.5);
    
    % Setting time stimuli are left on screen after correct trial before task ends
    p.trial.task.Timing.WaitEnd = 0.25;
    
    % Selecting inter-trial interval (ITI)
    p.trial.task.Timing.ITI = ND_GetITI(1.25, 1.75, [], [], 1, 0.10);
    
    % Setting time-out(s) for incorrect responses
    p.trial.task.Timing.TimeOut = 1;

    % Setting number of trials per block
    p.trial.Block.maxBlockTrials = 2;



    % Setting properties for fixation point
    p.trial.stim.FIXSPOT.type = 'rect';    
    p.trial.stim.FIXSPOT.color = 'red';
    p.trial.stim.FIXSPOT.size = 0.4;
    
    % Storing contrast for cue and distractor rings collected from user or assigning default values
    p.trial.task.contrast = 0.90; % Changed from 0.96
    
    % Assigning color to stimuli
    p.trial.stim.RECTANGLE.color = [0, 1, 1];
    
    % Assigning coordinates to stimuli
    p.trial.stim.recParameters.stim1.coordinates = [4 -1 6 1];
    p.trial.stim.recParameters.stim2.coordinates = [-6 -1 -4 1];
    


    % Creating flat-hazard function from which to pull out time of wait before stim change
    num_range = [1, 1000];
    mean = 2;
    bound1 = 1.25;
    bound2 = 2.75;
    
    r = exprnBounded(mean, num_range, bound1, bound2);
    
    function r = exprnBounded(mean, num_range, bound1, bound2);
    
    minE = exp(-bound1 / mean);
    maxE = exp(-bound2 / mean);
    
    randBounded = minE + (maxE-minE).*rand(num_range);
    r = -mean .* log(randBounded);
    
    end

    p.trial.task.flatHazard = 0.2; % Changed from r
    
    % Setting time that must transpire before saccade can be made without being marked as early
    p.trial.task.breakFixCheck = 0.2;
    
    % Setting time window in which response saccade allowed
    p.trial.task.saccadeTimeout = 1.5;
    
    % Setting time for which target must be fixed on before trial marked correct
    p.trial.task.minTargetFixTime = 1; % Changed from 0.1

    % Creating trial increments to scale size of reward based on good performance
    p.trial.reward.IncrementTrial = [50, 150, 300, 400, 500, 600, 650];

    % List of increasing durations of juice flow for reward
    % This list is linked to trial increments for scaling size of reward
    % p.trial.reward.IncrementDur = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
    p.trial.reward.IncrementDur = [0.1, 0.15, 0.175, 0.2, 0.225, 0.25, 0.3];

    % Degree to which current reward decreased for bad performance 
    p.trial.reward.DiscourageProp = 1.0;
    
end
