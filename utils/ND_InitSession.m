function p = ND_InitSession(p)
%% Initialise session
% perform default steps to start a session
%
%
% wolf zinke, Jan. 2017

% --------------------------------------------------------------------%
% Define Trial function
% The runTrial function requires trialFunction to be
% defined, but burried in their tutorial they show that this needs to be
% defined when initialising the trial function (i.e. the experimentSetupFile),
% otherwise there will be an error running runTrial.
if(~isfield(p.defaultParameters.pldaps, 'trialFunction'))
    p.defaultParameters.pldaps.trialFunction = p.trial.session.experimentSetupFile;
end

% --------------------------------------------------------------------%
% initialize the random number generator (verify how this affects pldaps)
rng('shuffle', 'twister');

% --------------------------------------------------------------------%
%% ensure that the data directory exists (TODO: use the entry from the trial struct)
if(~exist(fullfile(p.trial.pldaps.dirs.data,'TEMP'),'dir'))
    mkdir(fullfile(p.trial.pldaps.dirs.data,'TEMP'));
end

% --------------------------------------------------------------------%
% The frame allocation can only be set once the pldaps is run,
% otherwise p.trial.display.frate will not be available because it is
% defined in the openscreen call.
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;

% --------------------------------------------------------------------%
% Define session start time    
% PsychDataPixx('GetPreciseTime') is very slow. However, in order to keep
% various timings in synch it seems to be recommended to call this more
% often, hence it might be good to use it whenever timing is not a big
% issue, i.e. start and end of trials, whereas within the trial GetSecs
% should be much faster. PsychDataPixx('GetPreciseTime') and GetSecs seem
% to output the time with a comparable reference.

% potential ad hoc hack? :
% global dpx
% dpx.syncmode=2; %1,2,3
% dpx.maxDuration=0.02;
% dpx.optMinwinThreshold=6.5e-5;

p.trial.timing.datapixxSessionStart = PsychDataPixx('GetPreciseTime');  % WZ: inserted this entry for follow up timings
% WZ, 17/01/02: Why does this take now so long? Any hardware issues? My tests before showed a time ~1/2s before...

% this call happens before datapix gets initialized in pldaps.run!
