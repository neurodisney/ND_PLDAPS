function p = ND_InitSession(p)
%% Initialize session
% perform default steps to start a session
%
% This initialization happens after openscreen was called, hence display
% information is available and all information here should be added to
% p.trial and not p.defaultParameters anymore.
%
% wolf zinke, Jan. 2017

disp('****************************************************************')
disp('>>>>  Initializing Sessions <<<<')
disp('****************************************************************')
disp('');

% --------------------------------------------------------------------%
%% get task parameters
if(isField(p.defaultParameters, 'task'))
    if(isfield(p.defaultParameters.task, 'TaskDef'))
        if(~isempty(p.defaultParameters.task.TaskDef))
            p = feval(p.defaultParameters.task.TaskDef,  p);
        end
    end
end

% --------------------------------------------------------------------%
%% Generate Block/Condition series
if(~isfield(p,'conditions') || isempty(p.conditions))  % check first if the condition list was created in the task setup file
    p.trial.Block.GenBlock = 1;
    p = ND_GenCndLst(p);
else
    p.trial.Block.GenBlock = 0;
end

% --------------------------------------------------------------------%
%% pre-allocate frame data
% The frame allocation can only be set once the pldaps is run, otherwise
% p.defaultParameters.display.frate will not be available because it is defined in the openscreen call.
% WZ TODO: get rid of this pre-allocation that makes it necessary to specify a (arbitrary) trial length!
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;

% --------------------------------------------------------------------%
%% set variables that contain summary information across trials
% TODO: WZ: right now not working correctly. Needs to be updated between trials
%           in ND_runTrial when lock is removed from defaultParameters
p.trial.LastHits         = 0;   % how many correct trials since last error
p.trial.NHits            = 0;   % how many correct trials in total
p.trial.NError           = 0;   % how incorrect trials (excluding not started trials)
p.trial.NCompleted       = 0;   % number of started trials
p.trial.cPerf            = 0;   % current hit rate
p.trial.SmryStr          = ' '; % text message with trial/session summary

% --------------------------------------------------------------------%
%% define drawing area for joystick representation
if(p.trial.pldaps.draw.joystick.use && p.trial.datapixx.useJoystick)
    p.trial.pldaps.draw.joystick.size   = [60 400];

    % hardcoded location and size of joystick representation
    if p.trial.display.useDegreeUnits
        p.trial.pldaps.draw.joystick.size = ND_pxl2dva(p.trial.pldaps.draw.joystick.size, p);
    end

    % Draw the joystick meter on the right side of the screen
    p.trial.pldaps.draw.joystick.pos     = [p.trial.display.winRect(3) - 3 * p.defaultParameters.pldaps.draw.joystick.size(1), 0];

    p.trial.pldaps.draw.joystick.sclfac  = p.trial.pldaps.draw.joystick.size(2) / 2.6; % scaling factor to get joystick signal within the range of the representation area.

    p.trial.pldaps.draw.joystick.rect    = ND_GetRect(p.trial.pldaps.draw.joystick.pos, ...
                                                               p.trial.pldaps.draw.joystick.size);

    p.trial.pldaps.draw.joystick.levelsz =  p.trial.pldaps.draw.joystick.size .* [1.25, 0.01];

    % initialize joystick level at zero
    cjpos = [p.trial.pldaps.draw.joystick.pos(1), p.trial.pldaps.draw.joystick.rect(2)];
    p.trial.pldaps.draw.joystick.levelrect = ND_GetRect(cjpos, p.trial.pldaps.draw.joystick.levelsz);
end

%-------------------------------------------------------------------------%
%% prepare fixation control display
if(p.trial.pldaps.draw.eyepos.use)
    p.trial.pldaps.draw.eyepos.fixwinwdth = ND_pxl2dva(p.trial.pldaps.draw.eyepos.fixwinwdth_pxl, p);
end

if(p.trial.behavior.fixation.use)
    p = pds.fixation.setup(p);
end

%-------------------------------------------------------------------------%
%% eye calibration
if(p.trial.behavior.fixation.useCalibration)    
    p = pds.eyecalib.setup(p);
end

%-------------------------------------------------------------------------%
%% reference dva grid
if(p.trial.pldaps.draw.grid.use)
    % set up grid
    Xrng = floor(min(abs(p.trial.display.winRect([1,3]))));
    Yrng = floor(min(abs(p.trial.display.winRect([2,4]))));
    
    p.trial.pldaps.draw.grid.tick_line_matrix = nan(2, 4*(Xrng+Yrng+1));
    
    % x lines
    cnt = 1;
    for(i=-Xrng:Xrng)
        p.trial.pldaps.draw.grid.tick_line_matrix(:,[cnt, cnt+1]) = [i, i; p.trial.display.winRect([2,4])];
        cnt = cnt + 2;
    end
        
    for(i=-Yrng:Yrng)
        p.trial.pldaps.draw.grid.tick_line_matrix(:,[cnt, cnt+1]) = [p.trial.display.winRect([1,3]); i, i];
        cnt = cnt + 2;
    end
end

%-------------------------------------------------------------------------%
%% Audio
if(p.trial.sound.use)
    p = pds.audio.setupAudio(p);
end

%-------------------------------------------------------------------------%
%% Setup Photodiode stimuli
if(p.trial.pldaps.draw.photodiode.use)    
    szstep = p.trial.pldaps.draw.photodiode.size / 2; % move PD away from edge
    
    switch p.trial.pldaps.draw.photodiode.location
        case 1 % upper left corner
            PDpos = [p.trial.display.winRect(1) + szstep, p.trial.display.winRect(4) - szstep];
        case 2
            PDpos = [p.trial.display.winRect(3) - szstep, p.trial.display.winRect(4) - szstep];
        case 3
            PDpos = [p.trial.display.winRect(1) + szstep, p.trial.display.winRect(2) + szstep];
        case 4
            PDpos = [p.trial.display.winRect(3) - szstep, p.trial.display.winRect(2) + szstep];
    end
        
    p.trial.pldaps.draw.photodiode.rect = ND_GetRect(PDpos, p.trial.pldaps.draw.photodiode.size);
end

%-------------------------------------------------------------------------%
%% Initialize Datapixx including dual CLUTS and timestamp logging
p = pds.datapixx.init(p);

%-------------------------------------------------------------------------%
%% Initialize keyboard
pds.keyboard.setup(p);

%-------------------------------------------------------------------------%
%% Initialize mouse
if(p.trial.mouse.useLocalCoordinates)
    p.trial.mouse.windowPtr = p.trial.display.ptr;
end

if(~isempty(p.trial.mouse.initialCoordinates))
    SetMouse(p.trial.mouse.initialCoordinates(1), ...
             p.trial.mouse.initialCoordinates(2), p.trial.mouse.windowPtr)
end

% --------------------------------------------------------------------%
%% Set text size for screen display
Screen('TextSize', p.trial.display.overlayptr , 36);

% --------------------------------------------------------------------%
%% Define session start time
% PsychDataPixx('GetPreciseTime') is very slow. However, in order to keep
% various timings in sync it seems to be recommended to call this more
% often, hence it might be good to use it whenever timing is not a big
% issue, i.e. start and end of trials, whereas within the trial GetSecs
% should be much faster. PsychDataPixx('GetPreciseTime') and GetSecs seem
% to output the time with a comparable reference.

p.trial.timing.datapixxSessionStart = PsychDataPixx('GetPreciseTime');  % WZ: inserted this entry for follow up timings
% this call happens before datapixx gets initialized in pldaps.run!

