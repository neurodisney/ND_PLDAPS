function p = ScreenFlash(p, state)
% Main trial function for initial fixation training.
%
%
%
% Nate Faber & wolf zinke, Sep 2017


% ####################################################################### %
%% define the task name that will be used to create a sub-structure in the trial struct

if(~exist('state', 'var'))
    state = [];
end

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
    % call this after ND_InitSession to be sure that output directory exists!
    
    p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%s');
    p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Tstart',      'p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart',   '%d');
    p = ND_AddAsciiEntry(p, 'FixRT',       'p.trial.EV.FixStart-p.trial.EV.TaskStart',                     '%d');
    p = ND_AddAsciiEntry(p, 'FirstReward', 'p.trial.task.CurRewDelay',            '%d');
    p = ND_AddAsciiEntry(p, 'RewCnt',      'p.trial.reward.count',                '%d');

    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');
    
    p = ND_AddAsciiEntry(p, 'FixPeriod',   'p.trial.EV.FixBreak-p.trial.EV.FixStart', '%.5f');
    p = ND_AddAsciiEntry(p, 'FixColor',    'p.trial.stim.FIXSPOT.color',          '%s');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.stim.fix.fixWin',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_X',    'p.trial.stim.fix.pos(1)',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_Y',    'p.trial.stim.fix.pos(2)',             '.%5f');
    
    
    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');

    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.

    p.trial.task.Color_list = Shuffle({'white', 'dRed', 'lRed', 'dGreen', 'orange', 'cyan'});  
    p.trial.task.Color_list = {'white'};
    % --------------------------------------------------------------------%
    %% Enable random positions
    p.trial.task.RandomPos = 0;
    
    p.trial.task.RandomPosRange = [5, 5];  % range of x and y dva for random position
    
    % --------------------------------------------------------------------%
    %% Determine conditions and their sequence
    % define conditions (conditions could be passed to the pldaps call as
    % cell array, or defined here within the main trial function. The
    % control of trials, especially the use of blocks, i.e. the repetition
    % of a defined number of trials per condition, needs to be clarified.


else
    % ####################################################################### %
    %% Call standard routines before executing task related code
    % This carries out standard routines, mainly in respect to hardware interfacing.
    % Be aware that this is done first for each trial state!
    p = ND_GeneralTrialRoutines(p, state);

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
            TaskDraw(p)
            
% ------------------------------------------------------------------------%
% DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
            TaskCleanAndSave(p);
                        
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
                                     
    p.trial.task.CurRewDelay = ND_GetITI(p.trial.reward.MinWaitInitial,  ...
                                         p.trial.reward.MaxWaitInitial,  [], [], 1, 0.001);

    p.trial.CurrEpoch        = p.trial.epoch.ITI;

    % Flag to indicate if ITI was too long (set to 0 if ITI epoch is reached before it expires)
    p.trial.task.longITI = 1;
      
    % Reward
    nRewards = p.trial.reward.nRewards;
    % Reset the reward counter (separate from iReward to allow for manual rewards)
    p.trial.reward.count = 0;
    % Create arrays for direct reference during reward
    p.trial.reward.allDurs = repelem(p.trial.reward.Dur,nRewards);
    p.trial.reward.allPeriods = repelem(p.trial.reward.Period,nRewards);       
    
    % Drug Signal Sent
    p.trial.task.drugSent = 0;
    
    % Outcome if no fixation occurs at all during the trial
    p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;        
    p.trial.task.Good   = 0;
    
    % State for acheiving fixation
    p.trial.task.fixFix = 0;
    
    % if random position is required pick one and move fix spot
    if(p.trial.task.RandomPos == 1)
         Xpos = (rand * 2 * p.trial.task.RandomPosRange(1)) - p.trial.task.RandomPosRange(1);
         Ypos = (rand * 2 * p.trial.task.RandomPosRange(2)) - p.trial.task.RandomPosRange(2);
         p.trial.stim.FIXSPOT.pos = [Xpos, Ypos];
    end
    
    % If the fixspot color is a cell, choose one of the strings from the cell to be the color
    if iscell(p.trial.stim.FIXSPOT.color)
        nColors = length(p.trial.stim.FIXSPOT.color);
        iColor = randi(nColors);
        p.trial.stim.FIXSPOT.color = p.trial.stim.FIXSPOT.color{iColor};
    end
    
    % Send a signal based on the stimulus color
    switch p.trial.stim.FIXSPOT.color
        case 'black'
            pds.datapixx.strobe(15000);
            
        case 'grey1'
            pds.datapixx.strobe(15010);
        
        case 'grey2'
            pds.datapixx.strobe(15020);
        
        case 'grey3'
            pds.datapixx.strobe(15030);
        
        case 'grey4'
            pds.datapixx.strobe(15040);
        
        case 'grey5'
            pds.datapixx.strobe(15050);
        
        case 'grey6'
            pds.datapixx.strobe(15060);
        
        case 'grey7'
            pds.datapixx.strobe(15070);
        
        case 'grey8'
            pds.datapixx.strobe(15080);
        
        case 'grey9'
            pds.datapixx.strobe(15090);
        
        case 'white'
            pds.datapixx.strobe(15100);
        
        otherwise
            pds.datapixx.strobe(15999);
            
    end
        
    
    %% Make the visual stimuli
    % Fixation spot
    p.trial.stim.fix = pds.stim.FixSpot(p);
    
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
            
            switchEpoch(p,'WaitStart');
            
        end
        
        % ----------------------------------------------------------------%  
        case p.trial.epoch.WaitStart
            %% Send the TTL pulse to the arduino to dispense drug
            if p.trial.task.useDrug && ~p.trial.task.drugSent
                ND_PulseSeries(p.trial.datapixx.TTL_spritzerChan,    p.trial.datapixx.TTL_spritzerDur,       ...
                               p.trial.datapixx.TTL_spritzerNpulse,  p.trial.datapixx.TTL_spritzerPulseGap,  ...
                               p.trial.datapixx.TTL_spritzerNseries, p.trial.datapixx.TTL_spritzerSeriesGap, ...
                               p.trial.event.INJECT);
                           
                p.trial.task.drugSent = 1;
            end
            
            if p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.Timing.drugFlashDelay
                switchEpoch(p,'TrialStart');
            end
        % ----------------------------------------------------------------%  
        case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot    
            ND_FixSpot(p,1);
        
            tms = pds.datapixx.strobe(p.trial.event.TASK_ON); 
            p.trial.EV.DPX_TaskOn = tms(1);
            p.trial.EV.TDT_TaskOn = tms(2);

            p.trial.EV.TaskStart = p.trial.CurTime;
            p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
            
            if(p.trial.datapixx.TTL_trialOn)
                pds.datapixx.TTL(p.trial.datapixx.TTL_trialOnChan, 1);
            end
           
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
                    % Turn off fixation spot
                    ND_FixSpot(p,0);
                    
                    % Mark trial NoFix, go directly to TaskEnd, do not start task, do not collect reward
                    p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;
                    switchEpoch(p,'TaskEnd')                   
                end
                
                
            % If gaze is inside fixation window
            elseif p.trial.task.fixFix == 1
                
                % Fixation ceases
                if ~p.trial.stim.fix.fixating
                    % Play breakfix sound
                    pds.audio.playDP(p,'breakfix','left');
                    
                    % Turn the fixation spot off
                    ND_FixSpot(p,0)
                    
                    % Mark trial as breakfix and end the task
                    p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                    switchEpoch(p,'TaskEnd');
                
                % Fixation has been held for long enough && not currently in the middle of breaking fixation
                elseif p.trial.CurTime > p.trial.stim.fix.EV.FixStart + p.trial.task.CurRewDelay
                    
                    % Succesful
                    p.trial.task.Good = 1;
                    p.trial.outcome.CurrOutcome = p.trial.outcome.Fixation;
                    
                    % Reward the monkey
                    p.trial.reward.count = 1;
                    pds.reward.give(p, p.trial.reward.allDurs(1));
                    p.trial.EV.FirstReward   = p.trial.CurTime;
                    p.trial.Timer.lastReward = p.trial.CurTime;
                    
                    % Transition to the succesful fixation epoch
                    switchEpoch(p,'Fixating');

                end
                
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.Fixating
        %% Animal has reached fixation criteria and now starts receiving rewards for continued fixation
            
        % Still fixating    
        if p.trial.stim.fix.fixating
            
            % If the supplied reward schema doesn't cover until jackpot
            % time, just repeat the last reward
            rewardCount = min(p.trial.reward.count , length(p.trial.reward.allDurs));
                
            rewardPeriod = p.trial.reward.allPeriods(rewardCount);
                
                
            % While jackpot time has not yet been reached
            if p.trial.CurTime < p.trial.EV.FirstReward + p.trial.reward.jackpotTime;

                % Wait for rewardPeriod to elapse since last reward, then give the next reward
                if p.trial.CurTime > p.trial.Timer.lastReward + rewardPeriod

                    rewardCount = min(rewardCount + 1 , length(p.trial.reward.allDurs));
                    p.trial.reward.count = p.trial.reward.count + 1;

                    rewardDuration = p.trial.reward.allDurs(rewardCount);                  

                    % Give the reward and update the lastReward time
                    pds.reward.give(p, rewardDuration);
                    p.trial.Timer.lastReward = p.trial.CurTime;

                end

            else
                % Give JACKPOT!
                rewardDuration = p.trial.reward.jackpotDur;
                pds.reward.give(p, rewardDuration);
                p.trial.Timer.lastReward = p.trial.CurTime;

                % Best outcome
                p.trial.outcome.CurrOutcome = p.trial.outcome.Jackpot;

                % Turn off fixation spot
                ND_FixSpot(p,0);
                
                % End the task
                switchEpoch(p,'TaskEnd');

                % Play jackpot sound
                pds.audio.playDP(p,'jackpot','left');
            end
        
        % Fixation Break, end the trial        
        elseif ~p.trial.stim.fix.fixating
            pds.audio.playDP(p,'breakfix','left');
            switchEpoch(p,'TaskEnd');
            ND_FixSpot(p,0);
                                 
        end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % Run standard TaskEnd routine
        Task_OFF(p);
        
        % Flag next trial ITI is done at begining
        p.trial.flagNextTrial = 1;
        
            
    end  % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% show epoch dependent stimuli
% go through the task epochs as defined in TaskDesign and draw the stimulus
% content that needs to be shown during this epoch.

    
% ####################################################################### %
function TaskCleanAndSave(p)
%% Clean up textures, variables, and save useful info to ascii table
Task_Finish(p);

% Get the text name of the outcome
p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

% Save useful info to an ascii table for plotting
ND_Trial2Ascii(p, 'save');
% ####################################################################### %

function KeyAction(p)
%% task specific action upon key press
    if(~isempty(p.trial.LastKeyPress))

        switch p.trial.LastKeyPress(1)
            
            case KbName('p')  % change color ('paint')
                 p.trial.task.Color_list = Shuffle(p.trial.task.Color_list);
                 p.trial.task.FixCol     = p.trial.task.Color_list{mod(p.trial.blocks(p.trial.pldaps.iTrial), ...
                                           length(p.trial.task.Color_list))+1};
                                       
            case KbName('r')  % random position on each trial
                 if(p.trial.task.RandomPos == 0)
                    p.trial.task.RandomPos = 1;
                 else
                    p.trial.task.RandomPos = 0;
                 end
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

        
