function p = DelSacc(p, state)
% Main trial function for initial fixation training.
%
%
%
% wolf zinke, Apr. 2017
% Nate Faber, May 2017

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
    
    p = ND_AddAsciiEntry(p, 'StimPosX',    'p.trial.stim.GRATING.pos(1)',         '%.3f');
    p = ND_AddAsciiEntry(p, 'StimPosY',    'p.trial.stim.GRATING.pos(2)',         '%.3f');
    p = ND_AddAsciiEntry(p, 'tFreq',       'p.trial.stim.GRATING.tFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'sFreq',       'p.trial.stim.GRATING.sFreq',          '%.2f');
    p = ND_AddAsciiEntry(p, 'lContr',      'p.trial.stim.GRATING.lowContrast',    '%.1f');
    p = ND_AddAsciiEntry(p, 'hContr',      'p.trial.stim.GRATING.highContrast',   '%.1f');
    p = ND_AddAsciiEntry(p, 'StimSize',    '2*p.trial.stim.GRATING.radius',       '%.1f');
    
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOn',      'p.trial.EV.StimOn',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOff',     'p.trial.EV.StimOff',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'FixStart',    'p.trial.EV.FixSpotStart',             '%.5f');
    p = ND_AddAsciiEntry(p, 'FixBreak',    'p.trial.EV.FixSpotStop',              '%.5f');
    p = ND_AddAsciiEntry(p, 'StimFix',     'p.trial.EV.FixTargetStart',           '%.5f');
    p = ND_AddAsciiEntry(p, 'StimBreak',   'p.trial.EV.FixTargetStop',            '%.5f');
    p = ND_AddAsciiEntry(p, 'TaskEnd',     'p.trial.EV.TaskEnd',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');
    p = ND_AddAsciiEntry(p, 'GoLatency',   'p.trial.task.centerOffLatency',       '%.5f');
    p = ND_AddAsciiEntry(p, 'StimLatency', 'p.trial.task.stimLatency + p.trial.task.fixLatency',       '%.5f');
    p = ND_AddAsciiEntry(p, 'SRT_FixStart','p.trial.task.SRT_FixStart',           '%.5f');
    p = ND_AddAsciiEntry(p, 'SRT_StimOn',  'p.trial.task.SRT_StimOn',             '%.5f');
    p = ND_AddAsciiEntry(p, 'SRT_Go',      'p.trial.task.SRT_Go',                 '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.behavior.fixation.FixWin',    '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwd',     'p.trial.EV.FirstReward',              '%.5f');
    p = ND_AddAsciiEntry(p, 'Reward',      'p.trial.EV.Reward',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'RewPulses',   'p.trial.reward.nPulse',               '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwdDur',  'p.trial.reward.initialFixRwd * ~isnan(p.trial.EV.FirstReward)', '%.5f');
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


p.trial.CurrEpoch        = p.trial.epoch.ITI;

% Flag to indicate if ITI was too long (set to 0 if ITI epoch is reached before it expires)
p.trial.task.longITI = 1;

% Outcome if no fixation occurs at all during the trial
p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

p.trial.task.Good    = 0;
p.trial.task.fixFix  = 0;
p.trial.task.stimFix  = 0;

%% Generate all the visual stimuli

% Fixation spot
p.trial.stim.fix = pds.stim.FixSpot(p);

% Gratings
% Calculate the location
direction = p.trial.stim.GRATING.direction;
magnitude = p.trial.stim.GRATING.eccentricity;
p.trial.stim.GRATING.pos = magnitude * direction / norm(direction);

% Generate the low contrast stimulus
p.trial.stim.GRATING.contrast = p.trial.stim.GRATING.lowContrast;
p.trial.stim.gratingL = pds.stim.Grating(p);
% and the high contrast stimulus
p.trial.stim.GRATING.contrast = p.trial.stim.GRATING.highContrast;
p.trial.stim.gratingH = pds.stim.Grating(p);

% Assume manual control of the activation of the grating fix windows
p.trial.stim.gratingL.autoFixWin = 0;
p.trial.stim.gratingH.autoFixWin = 0;

% stim starts off
p.trial.task.stimState = 0;   % 0 is off, 1 is low contrast, 2 is high contrast

% ####################################################################### %
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
switch p.trial.CurrEpoch
    
    case p.trial.epoch.ITI
        %% inter-trial interval: wait until sufficient time has passed from the last trial
        if p.trial.CurTime < p.trial.EV.PlanStart
            % All intertrial processing was completed before the ITI expired
            p.trial.task.longITI = 0;
            
        else
            if isnan(p.trial.EV.PlanStart)
                % First trial, or after a break
                p.trial.task.longITI = 0;
            end
            
            % If intertrial processing took too long, display a warning
            if p.trial.task.longITI
                disp('Warning: longer ITI than specified');
            end
            
            switchEpoch(p,'TrialStart');
            
        end
        
        % ----------------------------------------------------------------%  
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
                
                % Reward the monkey if there is initial reward for this trial
                if p.trial.reward.initialFixRwd > 0
                    pds.reward.give(p, p.trial.reward.initialFixRwd);
                    p.trial.EV.FirstReward = p.trial.CurTime;
                end
                
                % Transition to the succesful fixation epoch
                switchEpoch(p,'Fixating')
                
            end
            
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.Fixating
        %% Initial reward has been given (if it is not 0), now stim target will appear
        
        % Still fixating
        if p.trial.stim.fix.fixating
            
            % Wait stim latency before showing reward
            if ~p.trial.task.stimState
                if p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.stimLatency
                    % Turn on stim
                    stim(p,1)
                end
                
                
            else
                
                % Must maintain fixation (inhibit saccade) until central
                % fixation spot disappears
                if p.trial.CurTime > p.trial.EV.StimOn + p.trial.task.centerOffLatency
                    
                    % Saccade has been inhibited long enough. Make the central fix spot disappear
                    fixspot(p,0);
   
                    % Make the stim high contrast
                    stim(p,2)
                    
                    % Change to the saccade epoch
                    switchEpoch(p,'Saccade');
                                        
                end
            
            end
            
            % Fixation Break, end the trial
        elseif ~p.trial.stim.fix.fixating
            pds.audio.playDP(p,'breakfix','left');
            
            if p.trial.task.stimState
                % If the stim is on, need to determine whether it is an early saccade
                % or a stimBreak. Calculated in the BreakFixCheck epoch
                switchEpoch(p,'BreakFixCheck'); 
            else
                p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                switchEpoch(p,'TaskEnd')
            end
            
            % Turn off fixspot and stim
            fixspot(p,0);
            stim(p,0);
          
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.Saccade
        %% Central fixation spot has disappeared. Animal must quickly saccade to stim to get the main reward
        
        if ~p.trial.task.stimFix
            % Animal has not yet saccaded to target
            % Need to check if no saccade has been made or if a wrong saccade has been made

            if p.trial.stim.gratingH.looking
                % Animal has saccaded to stim
                
                % Make sure that saccade was actually a reaction to the go cue,
                % rather than a lucky precocious saccade
                if p.trial.stim.fix.EV.FixBreak < p.trial.EV.FixOff + p.trial.task.minSaccReactTime
                    % Play breakfix sound
                    pds.audio.playDP(p,'breakfix','left');
                    
                    % Turn the stim off and fixation off
                    stim(p,0)
                    fixspot(p,0)
                    
                    % Mark trial early and end task
                    p.trial.outcome.CurrOutcome = p.trial.outcome.Early;
                    switchEpoch(p,'TaskEnd')
                
                
                elseif p.trial.stim.gratingH.fixating
                    % Real reaction to GO cue and has acheived fixation
                    p.trial.task.stimFix = 1;
                end
                

            elseif ~p.trial.stim.fix.fixating
                % Eye has left the central fixation spot. Wait a breifly for eye to arrive
                    if p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + p.trial.task.breakFixCheck
                        % Eye has saccaded somewhere besides the target
                        p.trial.outcome.CurrOutcome = p.trial.outcome.False;

                        % Turn the stim off and fixation off
                        stim(p,0)
                        fixspot(p,0)
                        
                        % Play an incorrect sound
                        pds.audio.playDP(p,'incorrect','left');
                        
                        % End the trial
                        switchEpoch(p,'TaskEnd');
                    
                    end

            elseif p.trial.CurTime > p.trial.EV.FixOff + p.trial.task.saccadeTimeout
                % If no saccade has been made before the time runs out, end the trial

                p.trial.outcome.CurrOutcome = p.trial.outcome.Miss;

                % Turn the stim off and fixation off
                stim(p,0);
                fixspot(p,0);

                % Play an incorrect sound
                pds.audio.playDP(p,'incorrect','left');

                switchEpoch(p,'TaskEnd')              

            end

        else
            % Animal is currently fixating on target
            
            % Wait for animal to hold fixation for the required length of time
            % then give reward and mark trial good
            if p.trial.CurTime > p.trial.stim.gratingH.EV.FixStart + p.trial.task.minTargetFixTime
                p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
                
                if(p.trial.reward.IncrConsecutive == 1)
                    AddPulse = find(p.trial.reward.PulseStep <= p.trial.LastHits+1, 1, 'last');
                    if(~isempty(AddPulse))
                        p.trial.reward.nPulse = p.trial.reward.nPulse + AddPulse;
                    end
                    
                    fprintf('     REWARD!!!  [%d pulse(s) for %d subsequent correct trials]\n\n', ...
                             p.trial.reward.nPulse, p.trial.LastHits+1);
                end

                pds.reward.give(p, p.trial.reward.Dur, p.trial.reward.nPulse);
                pds.audio.playDP(p,'reward','left');
                
                % Record main reward time
                p.trial.EV.Reward = p.trial.CurTime;
                
                % Turn off stim
                stim(p,0)
                
                p.trial.task.Good = 1;
                switchEpoch(p,'TaskEnd');


            elseif ~p.trial.stim.gratingH.fixating
                % If animal's gaze leaves window, end the task and do not give reward
                p.trial.outcome.CurrOutcome = p.trial.outcome.TargetBreak;

                % Turn the stim off
                stim(p,0);
                
                % Play an incorrect sound
                pds.audio.playDP(p,'incorrect','left');

                switchEpoch(p,'TaskEnd');

            end

        end

        
        % ----------------------------------------------------------------%
    case p.trial.epoch.BreakFixCheck
        %% Determine whether stim early saccade or a stimBreak
        % Wait for enough time to elapse after the stimBreak
        delay = p.trial.task.breakFixCheck;
        if p.trial.CurTime > p.trial.stim.fix.EV.FixBreak + delay
            % Get the median eye position in the delay
            frames = ceil(p.trial.display.frate * delay);
            medPos = prctile([p.trial.eyeX_hist(1:frames)', p.trial.eyeY_hist(1:frames)'],50);
            
            % Determine if the medPos is in the fixation window for the stim
            if inFixWin(p.trial.stim.gratingH, medPos);
                p.trial.outcome.CurrOutcome = p.trial.outcome.Early;
            else
                p.trial.outcome.CurrOutcome = p.trial.outcome.StimBreak;
            end
            
            switchEpoch(p,'TaskEnd')
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % Run standard TaskEnd routine
        Task_OFF(p)
        
        % Grab the fixation stopping and starting values from the stim properties
        p.trial.EV.FixSpotStart = p.trial.stim.fix.EV.FixStart;
        p.trial.EV.FixSpotStop  = p.trial.stim.fix.EV.FixBreak;
        p.trial.EV.FixTargetStart = p.trial.stim.gratingH.EV.FixStart;
        p.trial.EV.FixTargetStop  = p.trial.stim.gratingH.EV.FixBreak;
      
        % Flag next trial ITI is done at begining
        p.trial.flagNextTrial = 1;
        
end  % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% Custom draw function for this experiment


% ####################################################################### %
function TaskCleanAndSave(p)
%% Clean up textures, variables, and save useful info to ascii table
Task_Finish(p);

% Destroy the two grating textures generated to save memory
Screen('Close', p.trial.stim.gratingL.texture);
Screen('Close', p.trial.stim.gratingH.texture);

% Get the text name of the outcome
p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

% Calculate the Saccadic Response Time for easy plotting
Calculate_SRT(p);

% Save useful info to an ascii table for plotting
ND_Trial2Ascii(p, 'save');
% ####################################################################### %

% ####################################################################### %
function KeyAction(p)
%% task specific action upon key press
if(~isempty(p.trial.LastKeyPress))
    
    switch p.trial.LastKeyPress(1)
        
        %case KbName('x')  % Space for custom key press routines
            
    end
    
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
% Turn on/off or change the stim
oldVal = p.trial.task.stimState;

% Don't do anything if stim doesn't change
if val == oldVal; return; end

p.trial.task.stimState = val;

% Turn on/off the appropriate generated stimuli
% Only use the fixation window of the high contrast stimulus to avoid problems with overlapping fix windows
switch val
    case 0
        p.trial.stim.gratingL.on = 0;
        p.trial.stim.gratingH.on = 0;
    case 1
        p.trial.stim.gratingL.on = 1;
        p.trial.stim.gratingH.on = 0;
        p.trial.stim.gratingH.fixActive = 1;
    case 2
        p.trial.stim.gratingL.on = 0;
        p.trial.stim.gratingH.on = 1;
        p.trial.stim.gratingH.fixActive = 1;        
    otherwise
        error('bad stim value')
end

% Record the change timing
if val == 0
    % Stim is turning off
    p.trial.EV.StimOff = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.STIM_OFF);    
elseif oldVal == 0
    % Stim is turning on
    p.trial.EV.StimOn = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.STIM_ON);   
else
    % Stim is changing
    p.trial.EV.StimChange = p.trial.CurTime;
    pds.datapixx.strobe(p.trial.event.STIM_CHNG);
end


function Calculate_SRT(p)

switch p.trial.outcome.CurrOutcomeStr
    
    case {'NoStart', 'Break', 'Miss'}
        p.trial.task.SRT_FixStart = NaN;
        p.trial.task.SRT_StimOn   = NaN;
        p.trial.task.SRT_Go       = NaN;
       
    case {'FixBreak'}
        p.trial.task.SRT_FixStart = p.trial.EV.FixSpotStop - p.trial.EV.FixSpotStart;
        p.trial.task.SRT_StimOn   = p.trial.EV.FixSpotStop - (p.trial.EV.FixSpotStart + p.trial.task.fixLatency + p.trial.task.stimLatency);
        p.trial.task.SRT_Go       = p.trial.EV.FixSpotStop - (p.trial.EV.FixSpotStart + p.trial.task.fixLatency + p.trial.task.stimLatency + p.trial.task.centerOffLatency);
    
    case {'StimBreak', 'Early'}
        p.trial.task.SRT_FixStart = p.trial.EV.FixSpotStop - p.trial.EV.FixSpotStart;
        p.trial.task.SRT_StimOn   = p.trial.EV.FixSpotStop - p.trial.EV.StimOn;
        p.trial.task.SRT_Go       = p.trial.EV.FixSpotStop - (p.trial.EV.StimOn + p.trial.task.centerOffLatency);
        
    case {'False','Correct','TargetBreak'}
        p.trial.task.SRT_FixStart = p.trial.EV.FixSpotStop - p.trial.EV.FixSpotStart;
        p.trial.task.SRT_StimOn   = p.trial.EV.FixSpotStop - p.trial.EV.StimOn;
        p.trial.task.SRT_Go       = p.trial.EV.FixSpotStop - p.trial.EV.FixOff;
        
    otherwise
        warning('Calculate_SRT: unrecognized outcome')
        p.trial.task.SRT_FixStart = NaN;
        p.trial.task.SRT_StimOn   = NaN;
        p.trial.task.SRT_Go       = NaN;
        
end
      
