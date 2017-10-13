function p = ND_PrepSession(p)
%% Initialize session
% perform default preparation prior to start a session
%
% define dependent parameter checks and check for consistency; this needs
% to be called before openscreen!
%
%
% wolf zinke, Mar. 2017

disp('****************************************************************')
disp('>>>>  Preparing Sessions <<<<')
disp('****************************************************************')
disp('');

p.defaultParameters.DateStr = datestr(p.defaultParameters.session.initTime,'yyyy_mm_dd');

% --------------------------------------------------------------------%
%% set output directories and file names
p.defaultParameters.session.dir          =  fullfile(p.defaultParameters.pldaps.dirs.data, ...
                                                     p.defaultParameters.session.subject, p.defaultParameters.DateStr, ...
                                                     p.defaultParameters.session.experimentSetupFile);
% Eye calibration directory
p.defaultParameters.session.eyeCalibDir  =  fullfile(p.defaultParameters.pldaps.dirs.data, ...
                                                     p.defaultParameters.session.subject, p.defaultParameters.DateStr, ...
                                                     'EyeCalib');
% ensure that the data directory exists
p.defaultParameters.session.tmpdir   = fullfile(p.defaultParameters.session.dir,'TEMP');

if(~exist(p.defaultParameters.session.tmpdir,'dir'))
    mkdir(p.defaultParameters.session.tmpdir);
end

p.defaultParameters.session.filestem = [p.defaultParameters.session.subject, '_', ...
                                        datestr(p.defaultParameters.session.initTime, 'yyyymmdd'), '_', ...
                                        p.defaultParameters.session.experimentSetupFile, '_',  ...
                                        datestr(p.defaultParameters.session.initTime, 'HHMM')];

p.defaultParameters.session.trialdir = fullfile(p.defaultParameters.session.dir, p.defaultParameters.session.filestem);

if(~exist(p.defaultParameters.session.trialdir,'dir'))
    mkdir(p.defaultParameters.session.trialdir);
end

p.defaultParameters.session.file     = [p.defaultParameters.session.dir, filesep, p.defaultParameters.session.filestem, '.pds'];

p.defaultParameters.asciitbl.session.file = [p.defaultParameters.session.dir, filesep, p.defaultParameters.session.filestem,'.dat'];
%--------------------------------------------------------------------%
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
% if(~isfield(p.defaultParameters.pldaps, 'experimentAfterTrialsFunction') || ...
%     isempty(p.defaultParameters.pldaps.experimentAfterTrialsFunction) )
%     p.defaultParameters.pldaps.experimentAfterTrialsFunction = 'ND_AfterTrial';  % a function to be called after each trial.
% end

% --------------------------------------------------------------------%
%% initialize the random number generator
% verify how this affects pldaps
rng('shuffle', 'twister');

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
%% sanity checks

% there is no point of drawing eye position if it is not recorded
if(~p.defaultParameters.behavior.fixation.use)
    p.defaultParameters.pldaps.draw.eyepos.use = 0;
end

% Take enough samples
if(p.defaultParameters.behavior.fixation.use)
    if( p.defaultParameters.behavior.fixation.NumSmplCtr > p.defaultParameters.pldaps.draw.eyepos.history)
        p.defaultParameters.behavior.fixation.NumSmplCtr = p.defaultParameters.pldaps.draw.eyepos.history;
    end
end

% if joystick is needed make sure datapixx provides the signal
if(p.defaultParameters.behavior.joystick.use && ~p.defaultParameters.datapixx.useJoystick)
    p.defaultParameters.datapixx.useJoystick = 1;
end

% don't enable online plots if no function is specified
if(p.defaultParameters.plot.do_online && ~exist(p.defaultParameters.plot.routine,'file'))
    warning('Plotting routine for online analysis not found, disabled plotting!');
    p.defaultParameters.plot.do_online  =  0;
elseif(p.defaultParameters.plot.do_online && ~isfield(p.defaultParameters.plot, 'fig'))
    p.defaultParameters.plot.fig = [];
end

% check that each task epoch has a unique number
if(isfield(p.defaultParameters, 'epoch'))
    disp('>>>>  Checking p.defaultParameters.epoch for consistency <<<<')
    CheckUniqueNumbers(p.defaultParameters.epoch);
end

% check that event codes are unique
if(isfield(p.defaultParameters, 'event'))
    disp('>>>>  Checking p.defaultParameters.event for consistency <<<<')
    CheckUniqueNumbers(p.defaultParameters.event);
end

% check that task outcome codes are unique
if(isfield(p.defaultParameters, 'outcome'))
    disp('>>>>  Checking p.defaultParameters.outcome for consistency <<<<')
    CheckUniqueNumbers(p.defaultParameters.outcome);
end

% --------------------------------------------------------------------%
%% Map the ADC channels

% Ensure that the channels vector and channelMapping cell array are initialized
if(~isfield(p.defaultParameters.datapixx.adc, 'channels'))
    p.defaultParameters.datapixx.adc.channels = [];
end

if(~isfield(p.defaultParameters.datapixx.adc, 'channelMapping'))
    p.defaultParameters.datapixx.adc.channelMapping = {};
end

% add channels to collect eye data
if(p.defaultParameters.datapixx.useAsEyepos == 1)
    if(isfield(p.defaultParameters.datapixx.adc, 'XEyeposChannel') && ~isempty(p.defaultParameters.datapixx.adc.XEyeposChannel))
        p.defaultParameters.datapixx.adc.channels(end+1) = p.defaultParameters.datapixx.adc.XEyeposChannel;
        p.defaultParameters.datapixx.adc.channelMapping{end+1} = 'AI.Eye.X';
    end

    if(isfield(p.defaultParameters.datapixx.adc, 'YEyeposChannel') && ~isempty(p.defaultParameters.datapixx.adc.YEyeposChannel))
        p.defaultParameters.datapixx.adc.channels(end+1) = p.defaultParameters.datapixx.adc.YEyeposChannel;
        p.defaultParameters.datapixx.adc.channelMapping{end+1} = 'AI.Eye.Y';
    end

    if(isfield(p.defaultParameters.datapixx.adc, 'PupilChannel') && ~isempty(p.defaultParameters.datapixx.adc.PupilChannel))
        p.defaultParameters.datapixx.adc.channels(end+1) = p.defaultParameters.datapixx.adc.PupilChannel;
        p.defaultParameters.datapixx.adc.channelMapping{end+1} = 'AI.Eye.PD';
    end
end

% add channels to collect joystick data
if(p.defaultParameters.datapixx.useJoystick == 1)

    if(isfield(p.defaultParameters.datapixx.adc, 'XJoyChannel') && ~isempty(p.defaultParameters.datapixx.adc.XJoyChannel))
        p.defaultParameters.datapixx.adc.channels(end+1) = p.defaultParameters.datapixx.adc.XJoyChannel;
        p.defaultParameters.datapixx.adc.channelMapping{end+1} = 'AI.Joy.X';
    end

    if(isfield(p.defaultParameters.datapixx.adc, 'YJoyChannel') && ~isempty(p.defaultParameters.datapixx.adc.YJoyChannel))
        p.defaultParameters.datapixx.adc.channels(end+1) = p.defaultParameters.datapixx.adc.YJoyChannel;
        p.defaultParameters.datapixx.adc.channelMapping{end+1} = 'AI.Joy.Y';
    end
end

%-------------------------------------------------------------------------%
%% initialize conditions and blocks as empty here
% This is a quck&dirty ad hoc fix to not touch the pldaps call where conditions are defined.
% We define conditions in the experimental setup file (that will be called after executing the
% current function) or if nothing is defined use our default definition.
p.conditions       = {};
SS.Block.BlockList = [];

%-------------------------------------------------------------------------%
%% create p.trial as copy of the default parameters
p.trial = p.defaultParameters;

% --------------------------------------------------------------------%
%% helper functions

% function p = CheckChannelExists(p, channm, chk)
% % ensure that adc channels do exist
%     if(isempty(p.defaultParameters.datapixx.adc.(channm)) || isnan(p.defaultParameters.datapixx.adc.(channm)) )
%         if(chk == 1)
%             error([channm, ' has no value assigned!']);
%         end
%     else
%         if(~any(p.defaultParameters.datapixx.adc.channels == p.defaultParameters.datapixx.adc.(channm)))
%             p.defaultParameters.datapixx.adc.channels = ...
%                 sort([p.defaultParameters.datapixx.adc.channels, p.defaultParameters.datapixx.adc.(channm)]);
%         end
%     end

% --------------------------------------------------------------------%
function CheckUniqueNumbers(s)
% make sure that all fields in a struct have unique numbers assigned
    fldnms = fieldnames(s);

    epnum = nan(1,length(fldnms));

    for(i=1:length(fldnms))
        if(~iscell(s.(fldnms{i})) && isnumeric(s.(fldnms{i})) && length(s.(fldnms{i})) == 1)
            if(any(epnum == s.(fldnms{i})))
                error('Duplicate number assignment (%d) found for field %s!\n',s.(fldnms{i}), fldnms{i});
            end
            epnum(i) =  s.(fldnms{i});
        end
    end
