function p = ND_InitSession(p)
%% Initialize session
% perform default steps to start a session
%
%
% wolf zinke, Jan. 2017

disp('****************************************************************')
disp('>>>>  Initializen Sessions <<<<')
disp('****************************************************************')
disp('');

% --------------------------------------------------------------------%
%% set output directory  (moved to PLDAPS/@pldaps/run.m)
% WZ: define output directory
p.defaultParameters.pldaps.dirs.data = fullfile(p.defaultParameters.pldaps.dirs.data, ...
                                        p.defaultParameters.session.subject, ...
                                        p.defaultParameters.session.experimentSetupFile, datestr(now,'yyyy_mm_dd'));
                                    
% ensure that the data directory exists
if(~exist(fullfile(p.defaultParameters.pldaps.dirs.data,'TEMP'),'dir'))
    mkdir(fullfile(p.defaultParameters.pldaps.dirs.data,'TEMP'));
end

p.defaultParameters.session.dir      =  p.defaultParameters.pldaps.dirs.data;
p.defaultParameters.session.filestem = [p.defaultParameters.session.dir, ...
                                        p.defaultParameters.session.subject, '_', ...
                                        datestr(p.defaultParameters.session.initTime, 'yyyymmdd'), '_', ...
                                        p.defaultParameters.session.experimentSetupFile, '_',  ...
                                        datestr(p.defaultParameters.session.initTime, 'HHMM')];
p.defaultParameters.session.file     = [p.defaultParameters.session.filestem, '.pds'];

p.defaultParameters.session.asciitbl = [p.trial.session.filestem,'.dat'];

% --------------------------------------------------------------------%
%% Define Trial function
% The runTrial function requires trialFunction to be defined, but buried in
% their tutorial they show that this needs to be defined when initializing
% the trial function (i.e. the experimentSetupFile), otherwise there will be
% an error running runTrial.
if(~isfield(p.defaultParameters.pldaps, 'trialFunction'))
    p.defaultParameters.pldaps.trialFunction = p.defaultParameters.session.experimentSetupFile;
end

% --------------------------------------------------------------------%
%% After Trial function
% Define function that is executed after trial completion when the lock of defaultParameters is released
% This function allows to pass variable content between trials. Otherwise,
% the variables that are changed within a trial will not be updated and
% reset to the initial value for the subsequent trial.
if(~isfield(p.defaultParameters.pldaps, 'experimentAfterTrialsFunction') || ...
    isempty(p.defaultParameters.pldaps.experimentAfterTrialsFunction) )
    p.defaultParameters.pldaps.experimentAfterTrialsFunction = 'ND_AfterTrial';  % a function to be called after each trial.
end

% --------------------------------------------------------------------%
%% initialize the random number generator
% verify how this affects pldaps
rng('shuffle', 'twister');

% --------------------------------------------------------------------%
%% ensure channel mapping
% test if the channels needed are specified
if (p.defaultParameters.datapixx.useAsEyepos == 1)
    p = CheckChannelExists(p, 'XEyeposChannel', 1);
    p = CheckChannelExists(p, 'YEyeposChannel', 1);
    p = CheckChannelExists(p, 'PupilChannel',   0);
end

if (p.defaultParameters.datapixx.useJoystick == 1)
    p = CheckChannelExists(p, 'XJoyChannel', 1);
    p = CheckChannelExists(p, 'YJoyChannel', 1);
end

% --------------------------------------------------------------------%
%% Set some defaults

% trial states
p = ND_TrialStates(p);

% colors
% Setup default color lookup tables for huklab experiments. You can modify
% these later as long as it's done before pdsDatapixxInit
p = ND_DefaultColors(p);

% bits
% define standard event codes for trial events (16 bit)
p = ND_EventDef(p);

% outcomes
% define possible task outcomes
p = ND_Outcomes(p);

% task epochs
p = ND_TaskEpochs(p);

% --------------------------------------------------------------------%
%% pre-allocate frame data
% The frame allocation can only be set once the pldaps is run, otherwise
% p.defaultParameters.display.frate will not be available because it is defined in the openscreen call.
p.defaultParameters.pldaps.maxFrames = p.defaultParameters.pldaps.maxTrialLength * p.defaultParameters.display.frate;

% --------------------------------------------------------------------%
%% define drawing area for joystick representation
if(p.defaultParameters.pldaps.draw.joystick.use && p.defaultParameters.datapixx.useJoystick)

    % hardcode right now location and size of joystick representation
    p.defaultParameters.pldaps.draw.joystick.size   = [60 400];        % what area to occupy with joystick representation (pixel)
    p.defaultParameters.pldaps.draw.joystick.pos    = [p.defaultParameters.display.pWidth - ...
                                          (p.defaultParameters.display.pWidth/10 - 1.5*p.defaultParameters.pldaps.draw.joystick.size(1)), ...
                                           round(p.defaultParameters.display.pHeight/2)]; % where to center joystick representation

    p.defaultParameters.pldaps.draw.joystick.sclfac = p.defaultParameters.pldaps.draw.joystick.size(2) / 2.6; % scaling factor to get joystick signal within the range of the representation area.

    p.defaultParameters.pldaps.draw.joystick.rect = ND_GetRect(p.defaultParameters.pldaps.draw.joystick.pos, ...
                                                   p.defaultParameters.pldaps.draw.joystick.size);

    p.defaultParameters.pldaps.draw.joystick.levelsz =  round(p.defaultParameters.pldaps.draw.joystick.size .* [1.25, 0.01]);

    % initialize joystick level at zero
    cjpos = [p.defaultParameters.pldaps.draw.joystick.pos(1), p.defaultParameters.pldaps.draw.joystick.rect(2)];
    p.defaultParameters.pldaps.draw.joystick.levelrect = ND_GetRect(cjpos, p.defaultParameters.pldaps.draw.joystick.levelsz);
end

% --------------------------------------------------------------------%
%% set variables that contain summary information across trials
% TODO: WZ: right now not working correctly. Needs to be updated between trials
%           in ND_runTrial when lock is removed from defaultParameters
p.defaultParameters.LastHits         = 0;   % how many correct trials since last error
p.defaultParameters.NHits            = 0;   % how many correct trials in total
p.defaultParameters.NError           = 0;   % how incorrect trials (excluding not started trials)
p.defaultParameters.NCompleted       = 0;   % number of started trials
p.defaultParameters.cPerf            = 0;   % current hit rate
p.defaultParameters.SmryStr          = ' '; % text message with trial/session summary

% --------------------------------------------------------------------%
%% sanity checks

% there is no point of drawing eye position if it is not recorded
if(~p.defaultParameters.mouse.useAsEyepos && ~p.defaultParameters.datapixx.useAsEyepos && ~p.defaultParameters.eyelink.use)
    p.defaultParameters.pldaps.draw.eyepos.use = 0;
end

% don't enable online plots if no function is specified
if(~exist(p.defaultParameters.plot.routine,'file'))
    warning('Plotting routine for online analysis not found, disabled plotting!');
    p.defaultParameters.plot.do_online  =  0;  
elseif(~isfield(p.defaultParameters.plot, 'fig'))
    p.defaultParameters.plot.fig = [];
end

% check that each task epoch has a unique number
if(isField(p.defaultParameters, 'epoch'))
    disp('>>>>  Checking p.defaultParameters.epoch for consistency <<<<')
    CheckUniqueNumbers(p.defaultParameters.epoch);
end

% check that event codes are unique
if(isField(p.defaultParameters, 'event'))
    disp('>>>>  Checking p.defaultParameters.event for consistency <<<<')
    CheckUniqueNumbers(p.defaultParameters.event);
end

% check that task outcome codes are unique
if(isField(p.defaultParameters, 'outcome'))
    disp('>>>>  Checking p.defaultParameters.outcome for consistency <<<<')
    CheckUniqueNumbers(p.defaultParameters.outcome);
end

% --------------------------------------------------------------------%
%% Define session start time
% PsychDataPixx('GetPreciseTime') is very slow. However, in order to keep
% various timings in sync it seems to be recommended to call this more
% often, hence it might be good to use it whenever timing is not a big
% issue, i.e. start and end of trials, whereas within the trial GetSecs
% should be much faster. PsychDataPixx('GetPreciseTime') and GetSecs seem
% to output the time with a comparable reference.

p.defaultParameters.timing.datapixxSessionStart = PsychDataPixx('GetPreciseTime');  % WZ: inserted this entry for follow up timings
% this call happens before datapixx gets initialized in pldaps.run!

% --------------------------------------------------------------------%
%% Set text size for screen display
Screen('TextSize', p.defaultParameters.display.overlayptr , 36);

% --------------------------------------------------------------------%
%% helper functions
function p = CheckChannelExists(p, channm, chk)
% ensure that adc channels do exist
    if(isempty(p.defaultParameters.datapixx.adc.(channm)) || isnan(p.defaultParameters.datapixx.adc.(channm)) )
        if(chk == 1)
            error([channm, ' has no value assigned!']);
        end
    else
        if(~any(p.defaultParameters.datapixx.adc.channels == p.defaultParameters.datapixx.adc.(channm)))
            p.defaultParameters.datapixx.adc.channels = ...
                sort([p.defaultParameters.datapixx.adc.channels, p.defaultParameters.datapixx.adc.(channm)]);
        end
    end

% --------------------------------------------------------------------%
function CheckUniqueNumbers(s)
% make sure that all fields in a struct have unique numbers assigned
    fldnms = fieldnames(s);

    epnum = nan(1,length(fldnms));

    for(i=1:length(fldnms))
        if(~iscell(s.(fldnms{i})) && isnumeric(s.(fldnms{i})) && length(s.(fldnms{i})) == 1)
            if(any(epnum == s.(fldnms{i})))
                error(['Duplicate number assignment found for field :',fldnms{i}, '!']);
            end
            epnum(i) =  s.(fldnms{i});
        end
    end
