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


    % Setting RF properties
    RfPos = [6, -8];
    p.trial.task.RfPos = RfPos;

    RfOri = 270;
    p.trial.task.RfOri = RfOri;
    p.trial.task.RfOriCurve = [RfOri - 40, RfOri - 20, RfOri, RfOri + 20, RfOri + 20];

    RfRadius = 1.5; 
    p.trial.task.RfSize = RfRadius;
    p.trial.stim.DRIFTGABOR.radius = RfRadius;

    % Setting ring properties
    ringPos = RfPos;
    p.trial.task.ringPos = ringPos;

    ringRadius = RfRadius + 0.5;
    p.trial.task.ringSize = ringRadius;
    p.trial.stim.RING.radius = ringRadius;

    cueRingDelta = 10;
    p.trial.task.cueRingDelta = cueRingDelta;
    p.trial.stim.ringParameters.cueCon = sprintf('down%d', cueRingDelta);

    baseRingDelta = 1;
    p.trial.task.baseRingDelta = baseRingDelta;
    p.trial.stim.ringParameters.distCon = sprintf('up%d', baseRingDelta);

    p.trial.task.ringFlash = 0.200;
    p.trial.stim.ringParameters.cue2Con =  sprintf('down%d', 6);

    % Setting gabor properties
    p.trial.stim.gaborParameters.sFreq = 1.5;
    p.trial.stim.gaborParameters.tFreq = 5;
    p.trial.stim.gaborParameters.contrast = 0.80;
    p.trial.stim.DRIFTGABOR.size = [5, 5];

    % Calculating points along line of is eccentricity
    targ_x = RfPos(1);
    targ_y = RfPos(2);

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

    % Setting amount of time rings are presented before grats come on
    p.trial.task.CueWait = 1.25;
    
    % Assigning lineweight (thickness) to rings
    p.trial.stim.RING.lineWeight = [0.3, 0.3];

    % Setting properties for fixation point
    p.trial.stim.FIXSPOT.type = 'rect';    
    p.trial.stim.FIXSPOT.color = 'green';
    p.trial.stim.FIXSPOT.size = 0.25;
    p.trial.stim.FIXSPOT.fixWin = 1.75;

    
    % Creating flat-hazard function from which to pull out time of wait before stim change
    num_range = [1, 5];
    mean = 1.5;
    bound1 = 1.25;
    bound2 = 3.25;
    
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
    p.trial.task.breakFixCheck = 0.010;
    
    % Setting time window in which response saccade allowed
    p.trial.task.Timing.saccadeStart = 0.100;
    p.trial.task.saccadeTimeout = 0.400;
    
    % Setting time for which target must be fixed on before trial marked correct
    p.trial.task.minTargetFixTime = 0.20; 
    
    % Creating trial increments to scale size of reward based on good performance
    p.trial.reward.IncrementTrial = 40:40:2000;
    p.trial.reward.penalty = 0.005;
    
    % List of increasing durations of juice flow for reward
    p.trial.reward.IncrementDur = 0.15:0.001:(0.15 + 0.001*(length(p.trial.reward.IncrementTrial) - 1));

    % Setting rig equipment distances (inches)
    p.trial.task.VPixx2ScreenDis = 60;
    p.trial.task.Screen2MonkeyDis = 25;
    p.trial.task.EyeCam2MonkeyDis = 18;
    
end

