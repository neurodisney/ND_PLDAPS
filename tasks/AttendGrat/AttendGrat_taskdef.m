% John Amodeo, May 2023


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

    % Set ratio of cued to uncued trials
    p.trial.task.cuedRatio = [1, 1, 1];


    % Setting RF properties
    RFpos = [-3, 2];
    p.trial.task.RFpos = RFpos;

    RFori = 70;
    p.trial.task.RFori = RFori;
    p.trial.task.targOriList = [RFori - 20, RFori, RFori + 20];
    p.trial.task.disOriList = [RFori - 40, RFori + 40];

    RFsize = 1.25; 
    p.trial.stim.RING.radius = RFsize + 0.5;
    p.trial.stim.DRIFTGABOR.radius = RFsize;

    
    % Setting stimulus parameters
    p.trial.stim.gaborParameters.sFreq = 1.5;
    p.trial.stim.gaborParameters.tFreq = 5;
    p.trial.stim.gaborParameters.contrast = 0.80;
    p.trial.stim.DRIFTGABOR.size = [5, 5];

    % Creating lists of orientation change magnitudes to apply to blocks
    p.trial.Block.cuedMagList = [64, 32, 32, 0, 8, 16, 16, 32, 32, 32, 64, 64];
    p.trial.Block.uncuedMagList = [64, 32, 32, 0, 8, 16, 16, 32, 32, 32, 64, 64];

    % Calculating points along line of is eccentricity
    targ_x = p.trial.task.RFpos(1);
    targ_y = p.trial.task.RFpos(2);

    targ_angle = rad2deg(atan2(targ_y, targ_x));
    angle_arr = [targ_angle, targ_angle + 90, targ_angle + 180, targ_angle + 270];
    radius = sqrt(targ_x^2 + targ_y^2);

    % Angle (degrees) between line connecting origin (0, 0) and
    % preceeding point and line connecting origin and succeeding point.
    angular_offset = 8;
    p.trial.task.stimOffset = angular_offset;

    p.trial.task.posList = {};
    for q = 1:4
        x = cosd(angle_arr(q)) * radius;
        y = sind(angle_arr(q)) * radius;
        p.trial.task.posList = [p.trial.task.posList [x, y, 1]];
    end

    for i = 1:2
        offsets_up = {};
        offsets_down = {};

        for q = 1:4
            % Upward
            theta_up = angle_arr(q) + i * angular_offset;
            x_up = cosd(theta_up) * radius;
            y_up = sind(theta_up) * radius;
            offsets_up = [offsets_up [x_up, y_up, 1]];

            % Downward
            theta_down = angle_arr(q) - i * angular_offset;
            x_down = cosd(theta_down) * radius;
            y_down = sind(theta_down) * radius;
            offsets_down = [offsets_down [x_down, y_down, 1]];
        end

        p.trial.task.posList = [p.trial.task.posList; offsets_up; offsets_down];

    end


    % Loading contrast for cue and distractor rings
    p.trial.task.cStep = 5;
    p.trial.stim.ringParameters.cueCon = sprintf('down%d', p.trial.task.cStep);
    p.trial.stim.ringParameters.distCon = sprintf('up%d', p.trial.task.cStep);
    

    % Setting amount of time rings are presented before grats come on
    p.trial.task.CueWait = 1.5;
    
    % Assigning lineweight (thickness) to rings
    p.trial.stim.RING.lineWeight = [0.3, 0.3];

    % Setting properties for fixation point
    p.trial.stim.FIXSPOT.type = 'rect';    
    p.trial.stim.FIXSPOT.color = 'green';
    p.trial.stim.FIXSPOT.size = 0.25;
    p.trial.stim.FIXSPOT.fixWin = 1.75;

    
    % Creating flat-hazard function from which to pull out time of wait before stim change
    num_range = [1, 100];
    mean = 2;
    bound1 = 1.5;
    bound2 = 3;
    
    r = exprnBounded(mean, num_range, bound1, bound2);
    
    function r = exprnBounded(mean, num_range, bound1, bound2)
    
    minE = exp(-bound1 / mean);
    maxE = exp(-bound2 / mean);
    
    randBounded = minE + (maxE-minE).*rand(num_range);
    r = -mean .* log(randBounded);
    
    end

    p.trial.task.flatHazard = r;

    
    % Setting time that must transpire before saccade can be made without
    % being marked as fix break
    p.trial.task.breakFixCheck = 0.050;
    
    % Setting time window in which response saccade allowed
    p.trial.task.Timing.saccadeStart = 0.100;
    p.trial.task.saccadeTimeout = 0.400;
    
    % Setting time for which target must be fixed on before trial marked correct
    p.trial.task.minTargetFixTime = 0.20; 
    
    % Creating trial increments to scale size of reward based on good performance
    p.trial.reward.IncrementTrial = 10:10:1000;
    
    % List of increasing durations of juice flow for reward
    p.trial.reward.IncrementDur = 0.15:0.001:(0.15 + 0.001*(length(p.trial.reward.IncrementTrial) - 1));

end

