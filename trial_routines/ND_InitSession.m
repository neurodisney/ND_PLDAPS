function p = ND_InitSession(p)
%% Initialize session
% perform default steps to start a session
%
%
% wolf zinke, Jan. 2017

% --------------------------------------------------------------------%
% Define Trial function
% The runTrial function requires trialFunction to be defined, but buried in
% their tutorial they show that this needs to be defined when initializing 
% the trial function (i.e. the experimentSetupFile), otherwise there will be
% an error running runTrial.
if(~isfield(p.defaultParameters.pldaps, 'trialFunction'))
    p.defaultParameters.pldaps.trialFunction = p.trial.session.experimentSetupFile;
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
% defaultBitNames adds .events.NAME to dv
% The MAP server can only take 7 unique bits. 
% TODO: WZ - this refers to handling with the plexon MAP, needs to be
%            adapted for use with Tucker Davis
p = ND_DefaultBitNames(p);

% --------------------------------------------------------------------%
%% pre-allocate frame data
% The frame allocation can only be set once the pldaps is run, otherwise
% p.trial.display.frate will not be available because it is defined in the openscreen call.
p.defaultParameters.pldaps.maxFrames = p.defaultParameters.pldaps.maxTrialLength * p.defaultParameters.display.frate;

% --------------------------------------------------------------------%
%% define drawing area for joystick representation
if(p.defaultParameters.pldaps.draw.joystick.use && p.defaultParameters.datapixx.useJoystick)

    rect = [p.defaultParameters.display.winRect(1) p.defaultParameters.display.winRect(4)-p.defaultParameters.display.ppd ...
    p.defaultParameters.display.winRect(1)+p.defaultParameters.display.ppd p.defaultParameters.display.winRect(4)];

    p.defaultParameters.pldaps.draw.joystick.Orect  = rect; % outter boundary of joystick range
    p.defaultParameters.pldaps.draw.joystick.Irect  = rect; % current threshold boundary (needs to be done in the joystick state function)
     



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



