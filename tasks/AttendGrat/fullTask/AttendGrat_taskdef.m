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
    
    % Setting number of trials per block
    p.trial.Block.maxBlockTrials = 1;
    
    p.trial.task.shuffleRange = [0, 1];
    

    % Setting properties for fixation point
    p.trial.stim.FIXSPOT.type = 'rect';    
    p.trial.stim.FIXSPOT.color = 'green';
    p.trial.stim.FIXSPOT.size = 0.4;
    p.trial.stim.FIXSPOT.fixWin = 1.5;
    
    
    % Calculating points along line of is eccentricity
    targ_x = p.trial.task.RFpos(1);
    targ_y = p.trial.task.RFpos(2); 

    targ_angle = rad2deg(atan2(targ_y, targ_x));
    angle_arr = [targ_angle, targ_angle + 90, targ_angle + 180, targ_angle + 270];
    radius = sqrt(targ_x^2 + targ_y^2);
    delta = 20;

    p.trial.task.posList = {};
    for q = 1:4
        x = cosd(angle_arr(q)) * radius;
        y = sind(angle_arr(q)) * radius;

        p.trial.task.posList = [p.trial.task.posList [x, y, 1]];
    end

    for i = 1:3
        delta_arr = [delta, delta, delta, delta];
        theta_arr = angle_arr + delta_arr;
        
        delta_up = {};
        for q = 1:4
          x = cosd(theta_arr(q)) * radius;
          y = sind(theta_arr(q)) * radius;

          delta_up = [delta_up [x, y, 1]];
        end

        theta_arr = angle_arr - delta_arr;

        delta_down = {};
        for q = 1:4
          x = cosd(theta_arr(q)) * radius;
          y = sind(theta_arr(q)) * radius;

          delta_down = [delta_down [x, y, 1]];
        end

        p.trial.task.posList = [p.trial.task.posList; delta_up; delta_down];
        
        delta = delta + delta;
    end


    % Loading contrast for cue and distractor rings
    if ~p.trial.task.cStep
        p.trial.stim.ringParameters.cueCon = 'cueGrey';
        p.trial.stim.ringParameters.distCon = 'distGrey';
    else
        p.trial.stim.ringParameters.cueCon = sprintf('down%d', p.trial.task.cStep);
        p.trial.stim.ringParameters.distCon = sprintf('up%d', p.trial.task.cStep);
    end
    

    % Setting amount of time rings are presented before grats come on
    p.trial.task.CueWait = 0.50;
    
    % Assigning lineweight (thickness) to rings
    p.trial.stim.RING.lineWeight = [0.3, 0.3];


    % Creating list of orientations using values collected from user or using default values 
    p.trial.task.oriList = p.trial.task.oriRange(1):15:p.trial.task.oriRange(2); % 15 should be changed to something smaller for true trials
    
    % Creating lists of orientation change magnitudes to apply to blocks
    p.trial.Block.cuedMagList = [2, 4, 8];
    cuedStr = num2str(p.trial.Block.cuedMagList);
    p.trial.Block.cuedMagListStr = strrep(cuedStr, ' ', ',');

    p.trial.Block.uncuedMagList = [0, 0, 2, 32, 90];
    uncuedStr = num2str(p.trial.Block.uncuedMagList);
    p.trial.Block.uncuedMagListStr = strrep(uncuedStr, ' ', ',');
    
    %th = p.trial.task.oriThreshold;
    %p.trial.Block.changeMagList = [th, th + (0.10 * th), th + (0.20 * th), th + (0.40 * th), th + (0.60 * th), th + (0.80 *th)];

    % Setting stimulus parameters
    p.trial.stim.gaborParameters.sFreq = 1.5;
    p.trial.stim.gaborParameters.tFreq = 5;
    p.trial.stim.gaborParameters.contrast = 0.8;

    
    % Creating flat-hazard function from which to pull out time of wait before stim change
    num_range = [1, 100];
    mean = 2;
    bound1 = 1.75;
    bound2 = 2.25;
    
    r = exprnBounded(mean, num_range, bound1, bound2);
    
    function r = exprnBounded(mean, num_range, bound1, bound2)
    
    minE = exp(-bound1 / mean);
    maxE = exp(-bound2 / mean);
    
    randBounded = minE + (maxE-minE).*rand(num_range);
    r = -mean .* log(randBounded);
    
    end

    p.trial.task.flatHazard = r;

    
    % Setting time that must transpire before saccade can be made without being marked as early
    p.trial.task.breakFixCheck = 0.050;
    
    % Setting time window in which response saccade allowed
    p.trial.task.Timing.saccadeStart = 0.020;
    p.trial.task.saccadeTimeout = 0.70;
    
    % Setting time for which target must be fixed on before trial marked correct
    p.trial.task.minTargetFixTime = 0.20; 
    
    % Creating trial increments to scale size of reward based on good performance
    p.trial.reward.IncrementTrial = [50, 150, 300, 400, 500, 600, 650];

    % List of increasing durations of juice flow for reward
    % This list is linked to trial increments for scaling size of reward
    % p.trial.reward.IncrementDur = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
    p.trial.reward.IncrementDur = [0.10, 0.15, 0.175, 0.20, 0.225, 0.25, 0.30];

    % Degree to which current reward decreased for bad performance 
    p.trial.reward.DiscourageProp = 0.7;
    

end

