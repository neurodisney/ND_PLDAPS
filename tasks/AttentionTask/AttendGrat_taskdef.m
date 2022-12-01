% Function to define task parameters
function p = AttendGrat_taskdef(p)

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



    % Storing position of mapped receptive field collected from experimenter
    p.trial.task.RFpos = [-6, 6]; % This should be changed to user input value
    target_posX = p.trial.task.RFpos(1);
    target_posY = p.trial.task.RFpos(2);

    p.trial.task.posList = {[target_posX, target_posY], [-1*target_posX, -1*target_posY], [-1*target_posX, target_posY], [target_posX, -1*target_posY]}; 

    % Storing contrast below threshold response collected from experimenter
    contrast = 0.3; % This should be changed to user input value

    
    
    % Assigning contrast to cue ring
    p.trial.stim.ringParameters.cue.contrast = -1 * contrast;
    
    % Assigning contrast to distractor rings
    p.trial.stim.ringParameters.distractor.contrast = contrast;
    
    % Assigning color (black) to cue ring
    p.trial.stim.ringParameters.cue.color = [0, 1, 1];
    
    % Assigning color (white) to distractor rings
    p.trial.stim.ringParameters.distractor.color = [1, 0, 0];
    
    % Assigning lineweight (thickness) to rings
    p.trial.stim.RING.lineWeight = [0.3, 0.3];
    
    % Assigning radius to rings
    p.trial.stim.RING.radius = 1.5;



    % Storing orientation tuning flanks of recorded cell collected from experimenter
    flank1 = 30; % This should be changed to user input value
    flank2 = 130; % This should be changed to user input value

    % Creating list of orientations to use during task
    % This list includes flanks of recorded cell's orientation tuning curve
    p.trial.task.gratingOriList = [p.defaultParameters.stim.oriList [flank1 flank2]];
    
    
    
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

    p.trial.task.flatHazard = r;
    
    
    
    % Setting time that must transpire before saccade can be made without being marked as early
    p.trial.task.breakFixCheck = 0.2; % Changed from 0.2
    
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

