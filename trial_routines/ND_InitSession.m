function p = ND_InitSession(p)
%% Initialize session
% perform default steps to start a session
%
%
% wolf zinke, Jan. 2017

% --------------------------------------------------------------------%
%% set output directory
p.defaultParameters.pldaps.dirs.data = fullfile(p.defaultParameters.pldaps.dirs.data, ...
                                                p.defaultParameters.session.subject, ...
                                                p.defaultParameters.session.experimentSetupFile, datestr(now,'yyyy_mm_dd'));

% --------------------------------------------------------------------%
%% Define Trial function
% The runTrial function requires trialFunction to be defined, but buried in
% their tutorial they show that this needs to be defined when initializing 
% the trial function (i.e. the experimentSetupFile), otherwise there will be
% an error running runTrial.
if(~isfield(p.defaultParameters.pldaps, 'trialFunction'))
    p.defaultParameters.pldaps.trialFunction = p.trial.session.experimentSetupFile;
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
%% ensure that the data directory exists 
% TODO: use the entry from the trial struct
if(~exist(fullfile(p.trial.pldaps.dirs.data,'TEMP'),'dir'))
    mkdir(fullfile(p.trial.pldaps.dirs.data,'TEMP'));
end

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
% Setup default color lookup tables for huklab experiments. You can modify
% these later as long as it's done before pdsDatapixxInit
p = ND_DefaultColors(p);

% Bits
% define standard event codes for trial events (16 bit)
p = ND_EventDef(p);

% --------------------------------------------------------------------%
%% pre-allocate frame data
% The frame allocation can only be set once the pldaps is run, otherwise
% p.trial.display.frate will not be available because it is defined in the openscreen call.
p.defaultParameters.pldaps.maxFrames = p.defaultParameters.pldaps.maxTrialLength * p.defaultParameters.display.frate;

% --------------------------------------------------------------------%
%% define drawing area for joystick representation
if(p.defaultParameters.pldaps.draw.joystick.use && p.defaultParameters.datapixx.useJoystick)

    % hardcode right now location and size of joystick representation   
    p.trial.pldaps.draw.joystick.size   = [60 400];        % what area to occupy with joystick representation (pixel)
    p.trial.pldaps.draw.joystick.pos    = [p.trial.display.pWidth - ...
                                          (p.trial.display.pWidth/10 - 1.5*p.trial.pldaps.draw.joystick.size(1)), ...
                                           round(p.trial.display.pHeight/2)]; % where to center joystick representation
                                       
    p.trial.pldaps.draw.joystick.sclfac = p.trial.pldaps.draw.joystick.size(2) / 2.6; % scaling factor to get joystick signal within the range of the representation area.
    
    p.trial.pldaps.draw.joystick.rect = ND_GetRect(p.trial.pldaps.draw.joystick.pos, ...
                                                   p.trial.pldaps.draw.joystick.size);
                                               
    p.trial.pldaps.draw.joystick.levelsz =  round(p.trial.pldaps.draw.joystick.size .* [1.25, 0.01]);    
    
    % initialize joystick level at zero
    cjpos = [p.trial.pldaps.draw.joystick.pos(1), p.trial.pldaps.draw.joystick.rect(2)];
    p.trial.pldaps.draw.joystick.levelrect = ND_GetRect(cjpos, p.trial.pldaps.draw.joystick.levelsz);
    
end

% --------------------------------------------------------------------%
%% set variables that contain summary information across trials
p.trial.LastHits         = 0;      % how many correct trials since last error
p.trial.NHits            = 0;      % how many correct trials in total



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


% --------------------------------------------------------------------%
%% helper functions

function p = CheckChannelExists(p, channm, chk)
   
    if(isempty(p.defaultParameters.datapixx.adc.(channm)) || isnan(p.defaultParameters.datapixx.adc.(channm)) )
        if(chk == 1)
            error([channm , ' has no value assigned!']);
        end
    else
        if(~any(p.defaultParameters.datapixx.adc.channels == p.defaultParameters.datapixx.adc.(channm)))
            p.defaultParameters.datapixx.adc.channels = ... 
                sort([p.defaultParameters.datapixx.adc.channels, p.defaultParameters.datapixx.adc.(channm)]);
        end        
    end



