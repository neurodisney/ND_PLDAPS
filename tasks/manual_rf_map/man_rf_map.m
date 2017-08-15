function p = man_rf_map(p, state)
% The main trial function for creating a movable grating stimulus for manual RF mapping
%
%       Left/Right Arrows - change orientation
%       Up/Down Arrows - change spatial frequency
%       Enter - Mark stim position and properties
%       Backspace - Remove last mark
%       z - Clear all marks
%
% Nate Faber, Aug 2017

% ####################################################################### %
%% define the task name that will be used to create a sub-structure in the trial struct

if(~exist('state', 'var'))
    state = [];
end

% ####################################################################### %
%% Call standard routines before executing task related code
% This carries out standard routines, mainly in respect to hardware interfacing.
% Be aware that this is done first for each trial state!
p = ND_GeneralTrialRoutines(p, state);

% ####################################################################### %
%% Initial call of this function. Use this to define general settings of the experiment/session.
% Here, default parameters of the pldaps class could be adjusted if needed.
% This part corresponds to the experimental setup file and could be a separate
% file. In this case p.defaultParameters.pldaps.trialFunction needs to be
% defined here to refer to the file with the actual trial.
% At this stage, p.trial is not yet defined. All assignments need
% to go to p.defaultparameters
if(isempty(state))
    
    % --------------------------------------------------------------------%
    %% define ascii output file
    p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'Good',        'p.trial.task.Good',                   '%d');
    
    p = ND_AddAsciiEntry(p, 'tFreq',       'p.trial.stim.GRATING.tFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'sFreq',       'p.trial.stim.GRATING.sFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'contrast',    'p.trial.stim.GRATING.contrast',       '%.1f');
    p = ND_AddAsciiEntry(p, 'StimSize',    '2*p.trial.stim.GRATING.radius',       '%.1f');
    
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'FixStart',    'p.trial.EV.FixSpotStart',             '%.5f');
    p = ND_AddAsciiEntry(p, 'FixBreak',    'p.trial.EV.FixSpotStop',              '%.5f');
    p = ND_AddAsciiEntry(p, 'TaskEnd',     'p.trial.EV.TaskEnd',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.behavior.fixation.FixWin',    '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwd',     'p.trial.EV.FirstReward',              '%.5f');
    p = ND_AddAsciiEntry(p, 'Reward',      'p.trial.EV.Reward',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'RewPulses',   'p.trial.reward.nPulse',               '%.5f');
    p = ND_AddAsciiEntry(p, 'RewardDur',   'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)',           '%.5f');
    p = ND_AddAsciiEntry(p, 'TotalRwd',    'sum(p.trial.reward.timeReward(:,2))', '%.5f');
    
    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');
    
    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.
    
    
    % --------------------------------------------------------------------%
    %% Determine conditions and their sequence
    % define conditions (conditions could be passed to the pldaps call as
    % cell array, or defined here within the main trial function. The
    % control of trials, especially the use of blocks, i.e. the repetition
    % of a defined number of trials per condition, needs to be clarified.
        
    % condition 1
    c1.Nr = 1;    
    c1.nTrials = 20000;
    
    
    % Fill a conditions list with n of each kind of condition sequentially
    conditions = cell(1,5000);
    blocks = nan(1,5000);
    totalTrials = 0;
    
    % Iterate through each condition to fill conditions
    conditionsIterator = {c1};
    
    for iCond = 1:size(conditionsIterator,2)
        cond = conditionsIterator(iCond);
        nTrials = cond{1}.nTrials;
        conditions(1, totalTrials+1:totalTrials+nTrials) = repmat(cond,1,nTrials);
        blocks(1, totalTrials+1:totalTrials+nTrials) = repmat(iCond,1,nTrials);
        totalTrials = totalTrials + nTrials;
    end
    
    % Truncate the conditions cell array to it's actualy size
    conditions = conditions(1:totalTrials);
    blocks = blocks(1:totalTrials);
    
    p.conditions = conditions;
    p.trial.blocks = blocks;
    
    p.defaultParameters.pldaps.finish = totalTrials;
    
    p.trial.stim.marks = {}
    
    % Stim starts disabled
    p.trial.task.stimEnabled = 0;
    
    % Set up initial stim to use
    p.trial.stim.iAngle = 1;
    p.trial.stim.iSFreq = 1;
   
    
else
    % ####################################################################### %
    %% Subsequent calls during actual trials
    % execute trial specific commands here.
    
    switch state
        % ------------------------------------------------------------------------%
        % DONE BEFORE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialSetup
            %% trial set-up
            % prepare everything for the trial, including allocation of stimuli
            % and all other more time demanding stuff.
            TaskSetUp(p);
            
            % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialPrepare
            %% trial preparation
            % just prior to actual trial start, use it for time sensitive preparations;
            p.trial.EV.TrialStart = p.trial.CurTime;
            
            % ------------------------------------------------------------------------%
            % DONE DURING THE MAIN TRIAL LOOP:
            % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.framePrepareDrawing
            %% Get ready to display
            % prepare the stimuli that should be shown, do some required calculations
            if(~isempty(p.trial.LastKeyPress))
                KeyAction(p);
            end
            MouseAction(p);
            TaskDesign(p);
            % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameDraw
            %% Display stuff on the screen
            % Just call graphic routines, avoid any computations
            TaskDraw(p);
            
            % ------------------------------------------------------------------------%
            % DONE AFTER THE MAIN TRIAL LOOP:
            % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
            TaskCleanAndSave(p);
            %% trial end
            
            
    end  %/ switch state
end  %/  if(nargin == 1) [...] else [...]

% ------------------------------------------------------------------------%
%% Task related functions

% ####################################################################### %
function TaskSetUp(p)
%% main task outline
% Determine everything here that can be specified/calculated before the actual trial start
p.trial.task.Timing.ITI  = ND_GetITI(p.trial.task.Timing.MinITI,  ...
    p.trial.task.Timing.MaxITI,  [], [], 1, 0.10);


p.trial.CurrEpoch        = p.trial.epoch.TrialStart;


% Outcome if no fixation occurs at all during the trial
p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

p.trial.task.Good    = 0;
p.trial.task.fixFix  = 0;
p.trial.task.stimState = 0;

%% Switch modes or reset RF data based on flags
if p.trial.RF.flag_fine
    switch_to_fine(p);
end

if p.trial.RF.flag_new
    new_neuron(p);
end

%% Generate all the visual stimuli

% Fixation spot
p.trial.stim.fix = pds.stim.FixSpot(p);

% Gratings
% Generate all the possible gratings 
p.trial.stim.gratings = {};
for angle = p.trial.stim.angle
    p.trial.stim.GRATING.angle = angle;
    
    for sFreq = p.trial.stim.sFreq
        p.trial.stim.GRATING.sFreq = sFreq;
        
        % Generate the stimulus
        p.trial.stim.gratings{end+1} = pds.stim.Grating(p);
        
    end
    
end

%% Set up reward
nRewards = p.trial.reward.nRewards;
% Reset the reward counter (separate from iReward to allow for manual rewards)
p.trial.reward.count = 0;
% Create arrays for direct reference during reward
p.trial.reward.allDurs = repelem(p.trial.reward.Dur,nRewards);
p.trial.reward.allPeriods = repelem(p.trial.reward.Period,nRewards);


% ####################################################################### %
function TaskDesign(p)
%% main task outline

% The different task stages (i.e. 'epochs') are defined here.
switch p.trial.CurrEpoch
    
    case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot       
        tms = pds.datapixx.strobe(p.trial.event.TASK_ON);
        p.trial.EV.DPX_TaskOn = tms(1);
        p.trial.EV.TDT_TaskOn = tms(2);
        
        p.trial.EV.TaskStart = p.trial.CurTime;
        p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
        
        if(p.trial.datapixx.TTL_trialOn)
            pds.datapixx.TTL(p.trial.datapixx.TTL_trialOnChan, 1);
        end
        
        fixspot(p,1);
        
        switchEpoch(p,'WaitFix');
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.WaitFix
        %% Fixation target shown, waiting for a sufficiently held gaze
        
        % Gaze is outside fixation window
        if p.trial.task.fixFix == 0
            
            % Fixation has occured
            if p.trial.stim.fix.fixating
                p.trial.task.fixFix = 1;
                
                % Time to fixate has expired
            elseif p.trial.CurTime > p.trial.EV.TaskStart + p.trial.task.Timing.WaitFix
                
                % Long enough fixation did not occur, failed trial
                p.trial.task.Good = 0;
                p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;
                
                % Go directly to TaskEnd, do not start task, do not collect reward
                fixspot(p,0);
                switchEpoch(p,'TaskEnd');
                
            end
            
            
            % If gaze is inside fixation window
        elseif p.trial.task.fixFix == 1
            
            % Fixation ceases
            if ~p.trial.stim.fix.fixating
                
                p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                % Turn off the spot and end the trial
                fixspot(p,0);
                switchEpoch(p,'TaskEnd');
                
                % Fixation has been held for long enough
            elseif (p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.fixLatency)
                
                % Turn the first stim on
                stim(p,1)
                
                % Transition to the succesful fixation epoch
                switchEpoch(p,'Fixating')
                
            end
            
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.Fixating
        %% Initial reward has been given (if it is not 0), now stim target will appear
        
        % Still fixating
        if p.trial.stim.fix.fixating
                
            % While jackpot time has not yet been reached
            if p.trial.CurTime < p.trial.EV.epochEnd + p.trial.reward.jackpotTime;

                % If the supplied reward schema doesn't cover until jackpot
                % time, just repeat the last reward
                rewardCount = max(min(p.trial.reward.count , length(p.trial.reward.allDurs)),1);                
                rewardPeriod = p.trial.reward.allPeriods(rewardCount);
                
                if p.trial.reward.count == 0
                    nextRewardTime = p.trial.EV.epochEnd + rewardPeriod;
                else
                    nextRewardTime = p.trial.Timer.lastReward + rewardPeriod;
                end
                
                % Wait for rewardPeriod to elapse since last reward, then give the next reward
                if p.trial.CurTime > nextRewardTime

                    rewardCount = min(rewardCount + 1 , length(p.trial.reward.allDurs));
                    p.trial.reward.count = p.trial.reward.count + 1;

                    rewardDuration = p.trial.reward.allDurs(rewardCount);                  

                    % Give the reward and update the lastReward time
                    pds.reward.give(p, rewardDuration);
                    p.trial.Timer.lastReward = p.trial.CurTime;

                end

            else
                % Monkey has fixated long enough to get the jackpot
                p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
                
                % Give JACKPOT!
                rewardDuration = p.trial.reward.jackpotDur;
                pds.reward.give(p, rewardDuration);
                p.trial.Timer.lastReward = p.trial.CurTime;
                
                % Play sound
                pds.audio.playDP(p,'jackpot','left');
                
                % Record main reward time
                p.trial.EV.Reward = p.trial.CurTime;
                
                % Turn off fixspot and stim
                fixspot(p,0);
                stim(p,0);
                
                p.trial.task.Good = 1;
                switchEpoch(p,'TaskEnd');
                
            end
                
           
        elseif ~p.trial.stim.fix.fixating
            % Fixation Break, end the trial
            pds.audio.playDP(p,'breakfix','left');
            
            p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
            switchEpoch(p,'TaskEnd')
            
            % Turn off fixspot and stim
            fixspot(p,0);
            stim(p,0);
          
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % Run standard TaskEnd routine
        Task_OFF(p);
        
        % Grab the fixation stopping and starting values from the stim properties
        p.trial.EV.FixSpotStart = p.trial.stim.fix.EV.FixStart;
        p.trial.EV.FixSpotStop  = p.trial.stim.fix.EV.FixBreak;
      
        switchEpoch(p,'ITI');
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.ITI
        %% inter-trial interval: wait before next trial to start
        Task_WaitITI(p);
        
end  % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% Custom draw function for this experiment
ptr = p.trial.display.overlayptr;

%% Draw the marks
for iMark = 1:length(p.trial.task.marks)
    mark = p.trial.task.marks{iMark};
    pos = mark.pos;
    sz = 8;
    color = p.trial.display.clut.magentabg;
    Screen('Drawdots',  ptr, pos', sz, color, [0 0], 0);
end

%% Draw the a dot when the stimulus is not visible to where it will appear (mouse position)

% Only draw if stimulus is not visible
if ~(p.trial.task.stimState && p.trial.task.stimEnabled)
    
    if p.trial.task.stimEnabled;
        % If the stimulus is enabled but not visible, show a green dot
        color = p.trial.display.clut.greenbg;
    else
        % If the stimulus is disabled, show a red dot
        color = p.trial.display.clut.redbg;
    end
    
    pos = p.trial.stim.pos;
    sz = 6;
    
    Screen('Drawdots',  ptr, pos', sz, color, [0 0], 0);
end



% ####################################################################### %
function TaskCleanAndSave(p)
%% Clean up textures, variables, and save useful info to ascii table
Task_Finish(p);

% Destroy the two grating textures generated to save memory
for grating = p.trial.stim.gratings
    Screen('Close', grating{1}.texture);
end

% Get the text name of the outcome
p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

% Save useful info to an ascii table for plotting
ND_Trial2Ascii(p, 'save');

% ####################################################################### %
function KeyAction(p)
%% task specific action upon key press
if(~isempty(p.trial.LastKeyPress))
    
    switch p.trial.LastKeyPress(1)
            
        case KbName('''"') % Apostrophe Key, turn on and off the stimulus
            p.trial.task.stimEnabled = ~p.trial.task.stimEnabled;
            updateStim(p)
            
        case 37 % Enter Key, mark the current stimulus position and properties
            % Allow manual spiking to be triggered if TDT is not used
            
        case KbName('Backspace')
            % Remove last mark made
            p.trial.stim.marks = p.trial.stim.marks(1:end-1);
            
        case KbName('z')
            % Clear all marks
            p.trial.stim.marks = {};
            
        case KbName('LeftArrow')
            % Rotate orientation counter clockwise
            nAngles = length(p.trial.stim.angle);
            p.trial.stim.iAngle = mod(p.trial.stim.iAngle, nAngles) + 1;
            % Refresh the stim
            updateStim(p)
            
        case KbName('RightArrow')
            % Rotate orientation clockwise
            nAngles = length(p.trial.stim.angle);
            p.trial.stim.iAngle = mod(p.trial.stim.iAngle - 2, nAngles) + 1;            
            % Refresh the stim
            updateStim(p)
            
        case KbName('UpArrow')
            % Increase Spatial Frequency
            nFreqs = length(p.trial.stim.sFreq);
            p.trial.stim.iSFreq = mod(p.trial.stim.iSFreq, nFreqs) + 1;
            % Refresh the stim
            updateStim(p)
            
        case KbName('DownArrow')
            % Decrease Spatial Frequency
            nFreqs = length(p.trial.stim.sFreq);
            p.trial.stim.iSFreq = mod(p.trial.stim.iSFreq -2, nFreqs) + 1;
            % Refresh the stim
            updateStim(p)
            
            
    end
    
end

function MouseAction(p)
%% Proccess mouse events
if p.trial.mouse.use
    % Load in variables from p
    iSample = p.trial.mouse.samples;

    mousePos = p.trial.mouse.cursorSamples(:,iSample)';
    xPos = mousePos(1);
    yPos = mousePos(2);
    
    % Set the stim pos to match up with the mouse
    p.trial.stim.pos = [xPos, yPos];
    
    % Move the active stim
    stimNum = selectStim(p);
    grating = p.trial.stim.gratings{stimNum};
    grating.pos = [xPos, yPos];
end

% ####################################################################### %

%% additional inline functions
% ####################################################################### %
function switchEpoch(p,epochName)
p.trial.CurrEpoch = p.trial.epoch.(epochName);
p.trial.EV.epochEnd = p.trial.CurTime;



function fixspot(p,bool)
if bool && ~p.trial.stim.fix.on
    p.trial.stim.fix.on = 1;
    p.trial.EV.FixOn = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.FIXSPOT_ON);
elseif ~bool && p.trial.stim.fix.on
    p.trial.stim.fix.on = 0;
    p.trial.EV.FixOff = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.FIXSPOT_OFF);
end


function stim(p,val)
oldval = p.trial.task.stimState;

% Don't do anything if stim is signalled to turn off and is already off
% Signalled to turn on and already on,
% Or signalled to change and is off.
if val ~= oldval
    p.trial.task.stimState = val;
    updateStim(p)
end

function updateStim(p)

% Turn on/off the appropriate generated stimuli
% Only use the fixation window of the high contrast stimulus to avoid problems with overlapping fix windows
if p.trial.task.stimEnabled && p.trial.task.stimState
    %% Turn on the appropriate stimulus, or update its properties
    % Select the proper stim
    stimNum = selectStim(p);
    
    for iGrating = 1:length(p.trial.stim.gratings)
        grating = p.trial.stim.gratings{iGrating};
        
        if iGrating == stimNum
            % Turn on the stimulus if it is off
            if ~grating.on
                grating.on = 1;
                
                % Record the timings
                p.trial.EV.StimOn = p.trial.CurTime;
                
                % Strobe which stimulus was turned on
                pds.datapixx.strobe(p.trial.event.STIM_ON);
                pds.datapixx.strobe(stimNum);
                
            end
        
        else
            % All other stimuli should be turned off
            if grating.on
                % Turn the grating off
                grating.on = 0;
                
                % Strobe that this particular stimulus turned off
                pds.datapixx.strobe(p.trial.event.STIM_OFF);
                pds.datapixx.strobe(iGrating);
            end
        end
        
    end
    
else
    %% Turn off all stimuli
    for iGrating = 1:length(p.trial.stim.gratings)
        grating = p.trial.stim.gratings{iGrating};
        if grating.on
            % Turn the grating off
            grating.on = 0;
            
            % Strobe that this particular stimulus turned off
            pds.datapixx.strobe(p.trial.event.STIM_OFF);
            pds.datapixx.strobe(iGrating);
        end
        
    end
    p.trial.EV.StimOff = p.trial.CurTime;
    
end

function iStim = selectStim(p)
% Figures out the right stim number
iAngle = p.trial.stim.iAngle;

iSFreq = p.trial.stim.iSFreq;
nSFreq = length(p.trial.stim.sFreq);

iStim = (iAngle - 1) * nSFreq + iSFreq;

iStim = (iAngle - 1) * nAngle + iSFreq;

