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
disp('>>>>  Initializen Sessions <<<<')
disp('****************************************************************')
disp('');

% --------------------------------------------------------------------%
%% get task parameters
if isfield(p.defaultParameters, 'task')
    if(isfield(p.trial.task, 'TaskDef'))
        if(~isempty(p.trial.task.TaskDef))
            p = feval(p.trial.task.TaskDef,  p);
        end
    end
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


% % --------------------------------------------------------------------%
% %% define drawing area for joystick representation
% if(p.defaultParameters.pldaps.draw.joystick.use && p.defaultParameters.datapixx.useJoystick)
%
%     % hardcode right now location and size of joystick representation
%     p.defaultParameters.pldaps.draw.joystick.size   = [60 400];        % what area to occupy with joystick representation (pixel)
%     if p.trial.display.useDegreeUnits
%         p.trial.pldaps.draw.joystick.size = ND_pxl2dva(p.trial.pldaps.draw.joystick.size, p);
%     end
%
%     if p.defaultParameters.display.useCustomOrigin
%
%     else
%         p.defaultParameters.pldaps.draw.joystick.pos    = [p.defaultParameters.display.pWidth - ...
%                                                           (p.defaultParameters.display.pWidth/10 - 1.5*p.defaultParameters.pldaps.draw.joystick.size(1)), ...
%                                                           round(p.defaultParameters.display.pHeight/2)]; % where to center joystick representation
%     end
%
%     if p.trial.display.useDegreeUnits
%         p.trial.pldaps.draw.joystick.pos = ND_pxl2dva(p.trial.pldaps.draw.joystick.pos, p);
%     end
%
%     p.defaultParameters.pldaps.draw.joystick.sclfac = p.defaultParameters.pldaps.draw.joystick.size(2) / 2.6; % scaling factor to get joystick signal within the range of the representation area.
%
%     p.defaultParameters.pldaps.draw.joystick.rect = ND_GetRect(p.defaultParameters.pldaps.draw.joystick.pos, ...
%                                                    p.defaultParameters.pldaps.draw.joystick.size);
%
%     p.defaultParameters.pldaps.draw.joystick.levelsz =  round(p.defaultParameters.pldaps.draw.joystick.size .* [1.25, 0.01]);
%
%     % initialize joystick level at zero
%     cjpos = [p.defaultParameters.pldaps.draw.joystick.pos(1), p.defaultParameters.pldaps.draw.joystick.rect(2)];
%     p.defaultParameters.pldaps.draw.joystick.levelrect = ND_GetRect(cjpos, p.defaultParameters.pldaps.draw.joystick.levelsz);
% end

% --------------------------------------------------------------------%
%% define drawing area for joystick representation
if(p.trial.pldaps.draw.joystick.use && p.trial.datapixx.useJoystick)
    p.trial.pldaps.draw.joystick.size   = [60 400];

    % hardcoded location and size of joystick representation
    if p.trial.display.useDegreeUnits
        p.trial.pldaps.draw.joystick.size = ND_pxl2dva(p.trial.pldaps.draw.joystick.size, p);
    end

    % Draw the joystick meter on the right side of the screen
    p.trial.pldaps.draw.joystick.pos    = [p.trial.display.winRect(3) - 3 * p.defaultParameters.pldaps.draw.joystick.size(1), 0];

    p.trial.pldaps.draw.joystick.sclfac = p.trial.pldaps.draw.joystick.size(2) / 2.6; % scaling factor to get joystick signal within the range of the representation area.

    p.trial.pldaps.draw.joystick.rect = ND_GetRect(p.trial.pldaps.draw.joystick.pos, ...
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

%-------------------------------------------------------------------------%
%% eye calibration
if(p.trial.behavior.fixation.useCalibration)    
    p = pds.eyecalib.setup(p);
end

%-------------------------------------------------------------------------%
%% Setup Photodiode stimuli
if(p.trial.pldaps.draw.photodiode.use)
    makePhotodiodeRect(p);
end

%-------------------------------------------------------------------------%
%% Tick Marks
if(p.trial.pldaps.draw.grid.use)
    p = initTicks(p);
end

%-------------------------------------------------------------------------%
%% Audio
if(p.trial.sound.use)
    p = pds.audio.setupAudio(p);
end


%-------------------------------------------------------------------------%
%% REWARD
p = pds.reward.setup(p);

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
%% prepare online plots
if(p.trial.plot.do_online)
    p = feval(p.trial.plot.routine,  p);
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

