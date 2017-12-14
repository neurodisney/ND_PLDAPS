function p = FixCalib(p, state)
% Main trial function for fixation calibration.
%
%
%
% wolf zinke, Dec. 2017

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
    p = ND_AddAsciiEntry(p, 'FixRT',       'p.trial.EV.FixStart-p.trial.EV.FixOn',                     '%d');
    p = ND_AddAsciiEntry(p, 'FirstReward', 'p.trial.task.CurRewDelay',            '%d');
    p = ND_AddAsciiEntry(p, 'RewCnt',      'p.trial.reward.count',                '%d');

    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');
    
    p = ND_AddAsciiEntry(p, 'FixPeriod',   'p.trial.EV.FixBreak-p.trial.EV.FixStart', '%.5f');
    p = ND_AddAsciiEntry(p, 'FixColor',    'p.trial.stim.FIXSPOT.color',          '%s');
    p = ND_AddAsciiEntry(p, 'intITI',      'p.trial.task.Timing.ITI',             '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.stim.fix.fixWin',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_X',    'p.trial.stim.fix.pos(1)',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_Y',    'p.trial.stim.fix.pos(2)',             '.%5f');
       
    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');
    
    % basic fixation spot parameters
    p.defaultParameters.behavior.fixation.FixGridStp = [4, 4]; % x,y coordinates in a 9pt grid
    p.defaultParameters.behavior.fixation.FixWinStp  = 1;      % change of the size of the fixation window upon key press
    p.defaultParameters.behavior.fixation.FixSPotStp = 0.25;
    p.defaultParameters.stim.FIXSPOT.fixWin          = 4;         
    
    % just initialize here, will be overwritten by conditions
    p.defaultParameters.reward.MinWaitInitial  = 0.05;
    p.defaultParameters.reward.MaxWaitInitial  = 0.1; 
    
%-------------------------------------------------------------------------%
%% eye calibration
    if(~p.defaultParameters.behavior.fixation.useCalibration)    
        p = pds.eyecalib.setup(p);
    end

    p.defaultParameters.task.RandomPos = 0;
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
        %   TaskDraw(p)
            
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
    p.trial.task.Timing.ITI  = ND_GetITI(p.trial.task.Timing.MinITI, ...
                                         p.trial.task.Timing.MaxITI, [], [], 1, 0.10);
                                     
     p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix +  p.trial.task.CurRewDelay + p.trial.reward.jackpotTime); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

    % Reset the reward counter (separate from iReward to allow for manual rewards)
    p.trial.reward.count = 0;
    
    % Outcome if no fixation occurs at all during the trial
    p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;        
    p.trial.task.Good   = 0;
    
    % State for achieving fixation
    p.trial.task.fixFix = 0;
    
    % if random position is required pick one and move fix spot
    if(p.trial.task.RandomPos == 1)
         Xpos = (rand * 2 * p.trial.task.RandomPosRange(1)) - p.trial.task.RandomPosRange(1);
         Ypos = (rand * 2 * p.trial.task.RandomPosRange(2)) - p.trial.task.RandomPosRange(2);
         p.trial.stim.FIXSPOT.pos = [Xpos, Ypos];
    end
       
    %% Make the visual stimuli
    % Fixation spot
    p.trial.stim.fix = pds.stim.FixSpot(p);
    
    ND_SwitchEpoch(p, 'ITI');  % define first task epoch
    
% ####################################################################### %
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
    switch p.trial.CurrEpoch
        
        case p.trial.epoch.ITI
        %% inter-trial interval: wait until sufficient time has passed from the last trial
            Task_WaitITI(p);
        
        % ----------------------------------------------------------------%  
        case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot    
        
            Task_ON(p);
            ND_FixSpot(p,1);

            p.trial.EV.TaskStart     = p.trial.CurTime;
            p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
            
            ND_SwitchEpoch(p,'WaitFix');
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
        %% Fixation target shown, waiting for a sufficiently held gaze
            
            Task_WaitFixStart(p);
            
            if(p.trial.CurrEpoch == p.trial.epoch.Fixating)
            % fixation just started, initialize fixation epoch
                p.trial.task.Good = 1;
                p.trial.outcome.CurrOutcome = p.trial.outcome.Fixation;           

                % initial rewardfor fixation start
                if(p.trial.reward.GiveInitial == 1)
                    pds.reward.give(p, p.trial.reward.InitialRew);
                    p.trial.EV.FirstReward   = p.trial.CurTime;
                    p.trial.Timer.lastReward = p.trial.CurTime;
                else
                    p.trial.Timer.lastReward = p.trial.stim.fix.EV.FixStart;
                end
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.Fixating
        %% Animal has reached fixation criteria and now starts receiving rewards for continued fixation
            
        % Still fixating    
        if(p.trial.stim.fix.fixating)
            % While jackpot time has not yet been reached
            if(p.trial.CurTime < p.trial.EV.FixStart + p.trial.reward.jackpotTime)

                % Wait for rewardPeriod to elapse since last reward, then give the next reward
                if(p.trial.reward.GiveSeries==1)
                    cstep = find(p.trial.reward.Step <= p.trial.reward.count, 1, 'last');

                    if(p.trial.CurTime > p.trial.Timer.lastReward + p.trial.reward.Period(cstep))                        
                        % Give the reward and update the lastReward time
                        pds.reward.give(p, p.trial.reward.Dur);
                        p.trial.Timer.lastReward = p.trial.CurTime;
                        p.trial.reward.count     = p.trial.reward.count + 1;
                    end
                end
            else
                % Give JACKPOT!
                pds.reward.give(p, p.trial.reward.jackpotDur);
                p.trial.Timer.lastReward = p.trial.CurTime;

                % Best outcome
                p.trial.outcome.CurrOutcome = p.trial.outcome.Jackpot;

                % Turn off fixation spot
                ND_FixSpot(p,0);
                
                % End the task
                ND_SwitchEpoch(p,'TaskEnd');

                % Play jackpot sound
                pds.audio.playDP(p,'jackpot','left');
            end
        
        % Fixation Break, end the trial        
        elseif(~p.trial.stim.fix.fixating)
            pds.audio.playDP(p,'breakfix','left');
            ND_SwitchEpoch(p,'TaskEnd');
            ND_FixSpot(p,0);
        end  %  if(p.trial.stim.fix.fixating)
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % Run standard TaskEnd routine
        Task_OFF(p);
        
        % Flag next trial ITI is done at begining
        p.trial.flagNextTrial = 1;
        
    end  % switch p.trial.CurrEpoch

% ####################################################################### %
%function TaskDraw(p)
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
        
        case KbName('r')  % random position on each trial
            if(p.trial.task.RandomPos == 0)
                p.trial.task.RandomPos = 1;
            else
                p.trial.task.RandomPos = 0;
            end
            
        case KbName('f') % Turn fixation position on and off
            p.trial.stim.fix.on = ~p.trial.stim.fix.on;
            
        % move target to grid positions
        case p.trial.key.GridKeyCell
            gpos = find(p.trial.key.GridKey == p.trial.LastKeyPress(1));
            p.trial.behavior.fixation.GridPos = gpos;
            
            p.trial.stim.FIXSPOT.pos = p.trial.eyeCalib.Grid_XY(gpos, :);
            p.trial.stim.fix.pos = p.trial.stim.FIXSPOT.pos;
            
        % move target by steps
        case KbName('RightArrow')
            p.trial.stim.FIXSPOT.pos = p.trial.stim.FIXSPOT.pos + [p.trial.behavior.fixation.ND_FixSpotStp, 0];
            p.trial.stim.fix.pos     = p.trial.stim.FIXSPOT.pos;
            
        case KbName('LeftArrow')
            p.trial.stim.FIXSPOT.pos = p.trial.stim.FIXSPOT.pos - [p.trial.behavior.fixation.ND_FixSpotStp, 0];
            p.trial.stim.fix.pos     = p.trial.stim.FIXSPOT.pos;
            
        case KbName('UpArrow')
            p.trial.stim.FIXSPOT.pos = p.trial.stim.FIXSPOT.pos + [0, p.trial.behavior.fixation.ND_FixSpotStp];
            p.trial.stim.fix.pos     = p.trial.stim.FIXSPOT.pos;
            
        case KbName('DownArrow')
            p.trial.stim.FIXSPOT.pos = p.trial.stim.FIXSPOT.pos - [0, p.trial.behavior.fixation.ND_FixSpotStp];
            p.trial.stim.fix.pos     = p.trial.stim.FIXSPOT.pos;
    end
end
    
% ####################################################################### %
%% additional inline functions
% ####################################################################### %

        
