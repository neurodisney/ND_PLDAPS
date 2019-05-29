function p = RFmap_taskdef(p)
% define task parameters for a passive viewing task to obtain tuning functions (e.g. CRF).
% This function will be executed at every trial start, hence it is possible
% to edit it while the experiment is in progress in order to apply online
% modifications of the task.
%
%
% wolf zinke, 2018

% ------------------------------------------------------------------------%
%% Reward
% manual reward from experimenter
p.trial.reward.GiveInitial   = 0; % If set to 1 reward animal when starting to fixate
p.trial.reward.InitialRew    = 0.025; % duration of the initial reward

p.trial.reward.GiveSeries    = 1; % If set to 1 give a continous series of rewards until end of fixation period
p.trial.reward.Dur           = 0.04; % reward duration for pulse in reward series while keeping fixation
p.trial.reward.Step          = [0, 4, 8, 10, 12];     % define the number of subsequent rewards after that the next delay period should be used.
p.trial.reward.Period        = [1 0.75 0.50 0.25]; % the period between one reward and the next NEEDS TO BE GREATER THAN Dur
p.trial.task.CurRewDelay     = 0.65;  % time to first reward

p.trial.reward.ManDur        = 0.05; % reward duration [s] for reward given by keyboard presses

p.trial.reward.jackpotDur    = 0.1;  % final reward after keeping fixation for the complete time
p.trial.reward.jackpotnPulse = 3;

% ------------------------------------------------------------------------%
%% Timing
p.trial.task.Timing.WaitFix = 4;    % Time to wait for fixation before NoStart

% Main trial timings
p.trial.task.fixLatency     = 0.15;  % Time to hold fixation before mapping begins

% inter-trial interval
p.trial.task.Timing.MinITI  = 1.0;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 2.5;  % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% Drug Timings
p.trial.Drug.Give       = 0;     % Should drug be given during the experiment?
p.trial.Drug.Start      = -150;  % relative to first stimulus onset. Make sure thatthis time does not exced the minimum p.trial.stim.PreStim defined below.
p.trial.Drug.Intervall  =  200;  % time period before next drung injection is triggered. Set to NaN if only one pulse is needed.
p.trial.Drug.Count      = 0;
p.trial.Drug.NextInject = NaN;

% ------------------------------------------------------------------------%
%% Paradigm
% Defined at the beginning of a session, changes within the if-block will be ignored while running the experiment
if(~isfield(p.trial, 'pldaps') || p.trial.pldaps.iTrial <= 1)
   
    % ------------------------------------------------------------------------%
    %% Grating stimuli parameters

    % !!! MAKE SURE TO ADJUST LOCATION TO MATCH RF CENTER !!!
    % if this line gets uncommented it will over-ride what was specified when calling start_NeuroCRF!!!
    % p.trial.stim.GRATING.pos = [-2, -3];  % ToDo: define as input argument for start_NeuroCRF and pop-up menu if not specified!

    switch p.defaultParameters.stim.RFmeth  % this needs to be defaultParameters because trial is not yet fully initialized
        case 'coarse'
            p.trial.stim.ori      = [0, 90];   % orient of grating
            p.trial.stim.radius   = 0.5;       % size of grating 
            p.trial.stim.contrast = 1;         % intensity contrast
            p.trial.stim.sFreq    = 1.5;       % spatial frequency 
            p.trial.stim.tFreq    = 0;         % temporal frequency (0 means static grating) 
            p.trial.stim.grdStp   = 0.25;      % spacing of grating centers 

            p.trial.stim.extent   = [8, 8];    % [X; Y] span in dva of the area sampled for RF mapping
            
        case 'fine'
            p.trial.stim.ori      = [0:7] * 22.5; % orient of grating
            p.trial.stim.radius   = 0.5;          % size of grating 
            p.trial.stim.contrast = 1;            % intensity contrast
            p.trial.stim.sFreq    = 1.5;          % spatial frequency 
            p.trial.stim.tFreq    = 0;            % temporal frequency (0 means static grating) 
            p.trial.stim.grdStp   = 0.1;          % spacing of grating centers 

            p.trial.stim.extent   = [2, 2];       % [X; Y] span in dva of the area sampled for RF mapping
    end
    
    % calculate the range of possible x/y locations
    p.trial.stim.xRange = [-1, 1] * (p.trial.stim.extent(1)/2) + p.defaultParameters.stim.LocCtr(1);  % this needs to be defaultParameters because trial is not yet fully initialized
    p.trial.stim.yRange = [-1, 1] * (p.trial.stim.extent(2)/2) + p.defaultParameters.stim.LocCtr(2);  % this needs to be defaultParameters because trial is not yet fully initialized
    
    % ------------------------------------------------------------------------%
    %% Drug Condition/Block design
    p.trial.task.OnlyCorrect  = 1; % If set to one a trial is only considered completed when done correctly
    
    % define grid coordinates
    p.trial.stim.Xpos = p.trial.stim.xRange(1) : p.trial.stim.grdStp : p.trial.stim.xRange(2); 
    p.trial.stim.Ypos = p.trial.stim.yRange(1) : p.trial.stim.grdStp : p.trial.stim.yRange(2); 
    
    % bin the coordinates on a more coarse scale for stimulus balancing purposes
    Nbin = ceil(p.trial.stim.extent / p.trial.stim.radius);
    p.trial.stim.Xbin = discretize(p.trial.stim.Xpos, linspace(p.trial.stim.xRange(1), p.trial.stim.xRange(2), Nbin(1) + 1));
    p.trial.stim.Ybin = discretize(p.trial.stim.Ypos, linspace(p.trial.stim.yRange(1), p.trial.stim.yRange(2), Nbin(2) + 1));
    
    % get binned locations
    p.trial.stim.PosBins   = combvec(unique(p.trial.stim.Xbin), unique(p.trial.stim.Ybin))';
    p.trial.stim.PosBinID  = 1:size(p.trial.stim.PosBins,1); % define unique identifier for each position in the grid
    
    p.trial.stim.PosBinCnt = zeros(size(p.trial.stim.PosBinID));  % keep control of shown locations
    
    % get unique stimulus parameter combinations   
    p.trial.task.StimCondPars = combvec(p.trial.stim.PosBinID, p.trial.stim.ori,   p.trial.stim.radius, ...
                                        p.trial.stim.contrast, p.trial.stim.sFreq, p.trial.stim.tFreq)';
    
    p.trial.task.NumStimCond  = size(p.trial.task.StimCondPars, 1); % Number of unique unique combination of stimulus parameters

    % a stimulus condition will be defined as unique combination of all grating parameters
    p.trial.stim.Nstim           = 32;  % Number of stimuli presented within a trial given that fixation is kept. Might be worth to define this number based on p.trial.task.NumStimCond below.
    p.trial.task.NumStimRepeats  = 4;  % how often to show a stimulus condition in a block.
    p.trial.task.NumBlockPeriods = 1;  % a block period consists of two blocks, one with drug and the other one without drug
    p.trial.task.DrugBlock       = 0;  % if 1, the session starts with a drug block (odd numbered blocks are with drug), if zero even numbered blocks are with drug.

    AllStim = p.trial.task.NumStimCond * p.trial.task.NumStimRepeats; % complete number of stimuli to be shown within a block

    % just fill up the number of stimuli to be shown to match the desired set of trials
    if(mod(AllStim, p.trial.stim.Nstim) ~= 0)
        AllStim = AllStim + p.trial.stim.Nstim-mod(Nstim, p.trial.stim.Nstim);
    end
    Ntrials = AllStim/p.trial.stim.Nstim;
    
    % generate blocks
    p.trial.task.BlockNum  = [];
    p.trial.task.BlockCond = [];
       
    for(b=1:2*p.trial.task.NumBlockPeriods)
        StimSeq = ND_RandSample(1:p.trial.task.NumStimCond, AllStim, 0); % create a randomized sequence of stimulus conditions (no repeats)

        % translate the spatial binning into finer samples coordinates
        
        p.trial.task.BlockNum  = [p.trial.task.BlockNum ; repmat(b, Ntrials, 1)];
        
        p.trial.task.BlockCond = [p.trial.task.BlockCond; reshape(StimSeq, [p.trial.stim.Nstim, Ntrials])'];
    end
    
    p.trial.pldaps.finish = length(p.trial.task.BlockNum); % Stop condition
    
end  % if(p.trial.pldaps.iTrial <= 1)

% ------------------------------------------------------------------------%
%% visual stimulus timing
% define trial time based on the number of stimuli shown
p.trial.stim.OnTime    = 0.1;  % How long each stimulus is presented
p.trial.stim.OffTime   = 0.1;  % Gaps between succesive stimuli
p.trial.stim.PreStim   = ND_GetITI(0.35, 0.65, [], [], 1, 0.05);  % Time before first stimulus is shown
p.trial.stim.ProstStim = 0.25;  % Time to continue maintaining fixation after last stimulus is shown

% total fixation time is now defined based on number of presentation and times
p.trial.task.Timing.jackpotTime = p.trial.stim.Nstim    * p.trial.stim.OnTime    +  ...
                                 (p.trial.stim.Nstim-1) * p.trial.stim.OffTime   +  ...
                                  p.trial.stim.PreStim  + p.trial.stim.ProstStim;

% ------------------------------------------------------------------------%
%% Drug delivery parameters
% TTL pulse series for pico spritzer
p.trial.datapixx.TTL_spritzerChan      = 5;    % DIO channel
p.trial.datapixx.TTL_spritzerDur       = 0.01; % duration of TTL pulse
p.trial.datapixx.TTL_spritzerNpulse    = 1;    % number of pulses in a series
p.trial.datapixx.TTL_spritzerPulseGap  = 0.01; % gap between subsequent pulses

p.trial.datapixx.TTL_spritzerNseries   = 1;    % number of pulse series
p.trial.datapixx.TTL_spritzerSeriesGap = 30 ;  % gap between subsequent series

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.stim.FIXSPOT.pos   = [0,0];
p.trial.stim.FIXSPOT.type  = 'rect';   % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.stim.FIXSPOT.color = 'white';  % color of fixation spot (as defined in the lookup tables)
p.trial.stim.FIXSPOT.size  = 0.15;     % size of the fixation spot

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.behavior.fixation.BreakTime = 0.050;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.150;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% Task parameters
p.trial.task.breakFixCheck = 0.2; % Time after a stimbreak where if task is marked early or stim break is calculated

% ------------------------------------------------------------------------%
%% Eye Signal Sampling
p.trial.behavior.fixation.Sample    = 75;

% ------------------------------------------------------------------------%
%% Break color
p.trial.display.breakColor = 'black';
% ------------------------------------------------------------------------%
