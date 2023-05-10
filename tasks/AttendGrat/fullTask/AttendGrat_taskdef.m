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
    p.trial.Block.maxBlockTrials = 3;


    % Setting properties for fixation point
    p.trial.stim.FIXSPOT.type = 'rect';    
    p.trial.stim.FIXSPOT.color = 'green';
    p.trial.stim.FIXSPOT.size = 0.4;
    p.trial.stim.FIXSPOT.fixWin = 2.1;
    
    % Storing position of mapped receptive field collected from user or assigning default values
    if isempty(p.trial.task.RFpos)
        p.trial.task.RFpos = [4,4];
    end
    
    targ_x = p.trial.task.RFpos(1);
    targ_y = p.trial.task.RFpos(2);

    posList = {[-1*targ_x, targ_y, 0], [targ_x, targ_y, 1], [-1*targ_x, -1*targ_y, 0], [targ_x, -1*targ_y, 1]};
    p.trial.task.posList = posList(randperm(length(posList)));

    % Calculating points along line of is eccentricity
    angle = rad2deg(atan2(targ_y, targ_x));
    radius = sqrt(targ_x^2 + targ_y^2);
    delta = 5;
    
    angle_arr = [angle];
    for b = 1:3
        theta = angle - delta;
        angle_arr = [angle_arr theta];
    
        theta = angle + delta;
        angle_arr = [angle_arr theta];

        delta = delta + delta;
    end

    p.trial.task.targPosList = {};
    for c = 1:7
        x = cosd(angle_arr(c)) * radius;
        y = sind(angle_arr(c)) * radius;

        x_diff = sqrt(targ_x^2 - x^2);
        y_diff = sqrt(targ_y^2 - y^2);

        if x < targ_x
            if y > targ_y
                p.trial.task.targPosList = [p.trial.task.targPosList; {[x, y, 1], [-1*(sqrt(targ_x^2 - x_diff^2)), -1*(sqrt(targ_y^2 + y_diff^2)), 0], [sqrt(targ_x^2 + x_diff^2), -1*(sqrt(targ_y^2 - y_diff^2)), 1], [-1*(sqrt(targ_x^2 + x_diff^2)), sqrt(targ_y^2 - y_diff^2), 0]}];
            elseif y < targ_y
                p.trial.task.targPosList = [p.trial.task.targPosList; {[sqrt(targ_x^2 + x_diff^2), -1*(sqrt(targ_y^2 - y_diff^2)), 1], [-1*(sqrt(targ_x^2 - x_diff^2)), -1*(sqrt(targ_y^2 + y_diff^2)), 0], [x, y, 1], [-1*(sqrt(targ_x^2 + x_diff^2)), sqrt(targ_y^2 - y_diff^2), 0]}];
            end

        elseif x > targ_x
            if y > targ_y
                p.trial.task.targPosList = [p.trial.task.targPosList; {[-1*(sqrt(targ_x^2 + x_diff^2)), sqrt(targ_y^2 - y_diff^2), 0], [x, y, 1], [-1*(sqrt(targ_x^2 - x_diff^2)), -1*(sqrt(targ_y^2 + y_diff^2)), 0], [sqrt(targ_x^2 - x_diff^2), -1*(sqrt(targ_y^2 - y_diff^2)), 1]}];
            elseif y < targ_y
                p.trial.task.targPosList = [p.trial.task.targPosList; {[x, y, 1], [-1*(sqrt(targ_x^2 - x_diff^2)), sqrt(targ_y^2 + y_diff^2), 0], [sqrt(targ_x^2 - x_diff^2), -1*(sqrt(targ_y^2 + y_diff^2)), 1], [-1*(sqrt(targ_x^2 + x_diff^2)), -1*(sqrt(targ_y^2 - y_diff^2)), 0]}];
            end

        end

    end 


    % Storing contrast for cue and distractor rings collected from user or assigning default values
    if isempty(p.trial.task.contrast)
        p.trial.task.contrast = 0.65;
    end
    

    % Selecting trial type: cued (1) or uncued (0)
    p.trial.task.cued = 1; 

    % Setting amount of time rings are presented before grats come on
    p.trial.task.CueWait = 0.50;
    
    % Assigning lineweight (thickness) to rings
    p.trial.stim.RING.lineWeight = [0.3, 0.3];
    
    % Assigning radius to rings
    p.trial.stim.RING.radius = 1.5;

    % Turning flashing on (1) or off (0) for stimuli
    p.trial.stim.RING.flashing = 0;
    p.trial.stim.GRATING.flashing = 0;


    % Creating list of orientations using values collected from user or using default values
    if isempty(p.trial.task.oriRange)
        p.trial.task.oriRange = [176,0];
    end   
    
    p.trial.task.oriList = p.trial.task.oriRange(2):15:p.trial.task.oriRange(1); % 15 should be changed to something smaller for true trials
    
    % Creating list of orientation change magnitudes to apply to blocks
    p.trial.Block.changeMagList = [1, 2, 2, 8, 8, 16, 16, 24, 24, 32, 32];
    
    %th = p.trial.task.oriThreshold;
    %p.trial.Block.changeMagList = [th, th + (0.10 * th), th + (0.20 * th), th + (0.40 * th), th + (0.60 * th), th + (0.80 *th)];

    p.trial.stim.gratingParameters.sFreq = 2;

    
    % Creating flat-hazard function from which to pull out time of wait before stim change
    num_range = [1, 100];
    mean = 2;
    bound1 = 1.25;
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
    p.trial.task.Timing.saccadeStart = 0.03;
    p.trial.task.saccadeTimeout = 0.70;
    
    % Setting time for which target must be fixed on before trial marked correct
    p.trial.task.minTargetFixTime = 0.40; 
    
    % Creating trial increments to scale size of reward based on good performance
    p.trial.reward.IncrementTrial = [50, 150, 300, 400, 500, 600, 650];

    % List of increasing durations of juice flow for reward
    % This list is linked to trial increments for scaling size of reward
    % p.trial.reward.IncrementDur = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
    p.trial.reward.IncrementDur = [0.10, 0.15, 0.175, 0.20, 0.225, 0.25, 0.30];

    % Degree to which current reward decreased for bad performance 
    p.trial.reward.DiscourageProp = 0.7;
    

end

