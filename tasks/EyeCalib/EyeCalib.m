function p = EyeCalib(p, state)
% Main trial function for initial fixation training.
%
%
%
% wolf zinke, Apr. 2017

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
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.  
    
    p.trial.behavior.fixation.FixCol = 'lBlue';
    
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

    maxTrials_per_BlockCond = 4;
    maxBlocks = 1000;

    % condition 1
    c1.Nr = 1;
    c1.reward.MinWaitInitial = 0.15;
    c1.reward.MaxWaitInitial = 0.15;
    c1.reward.Dur            = 0.05;
    c1.reward.Period         = 0.2;
    
    conditions = {c1};

    p = ND_GetConditionList(p, conditions, maxTrials_per_BlockCond, maxBlocks);

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
            TaskDraw(p)
            
% ------------------------------------------------------------------------%
% DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
            Task_Finish(p);                      
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

    p.trial.CurrEpoch        = p.trial.epoch.TrialStart;
        
    p.trial.task.Good                = 1;  % assume no error untill error occurs
    p.trial.reward.count          = 0;  % counter for received rewardsw
    p.trial.behavior.fixation.GotFix = 0;
    p.trial.behavior.fixation.on       = 0;  % Whether or not to display the fixation spot
    
    % if random position is required pick one and move fix spot
    if(p.trial.task.RandomPos == 1)
        p.trial.behavior.fixation.fixPos = p.trial.eyeCalib.Grid_XY(randi(size(p.trial.eyeCalib.Grid_XY,1)), :);
        
         Xpos = (rand * 2 * p.trial.task.RandomPosRange(1)) - p.trial.task.RandomPosRange(1);
         Ypos = (rand * 2 * p.trial.task.RandomPosRange(2)) - p.trial.task.RandomPosRange(2);
         p.trial.behavior.fixation.fixPos = [Xpos, Ypos];
    end
    pds.fixation.move(p);
    
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
                pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan, 1);
            end
 
            p.trial.Timer.trialStart = p.trial.CurTime;
            p.trial.CurrEpoch  = p.trial.epoch.WaitExperimenter;
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitExperimenter
            %% No fixation spot is shown, wait for experimenter to press 'f' to turn on spot
            if p.trial.behavior.fixation.on
                p.trial.CurrEpoch = p.trial.epoch.WaitFix;
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
            %% Fixation target shown, waiting for a sufficiently held gaze
            
            % 'f' key is pressed, turn off fixation spot and return to earlier epoch.
            if ~p.trial.behavior.fixation.on
                p.trial.behavior.fixation.GotFix = 0;
                p.trial.CurrEpoch = p.trial.epoch.WaitExperimenter;
                return;
            end
            
            % Gaze is outside fixation window
            if p.trial.behavior.fixation.GotFix == 0
               
                % Fixation has occured
                if p.trial.FixState.Current == p.trial.FixState.FixIn
                    p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak; %Will become FullFixation upon holding long enough
                    p.trial.behavior.fixation.GotFix = 1;
                    p.trial.Timer.fixStart = p.trial.CurTime;
                end
                
                
            % If gaze is inside fixation window
            elseif p.trial.behavior.fixation.GotFix == 1
                
                % Fixation ceases
                if p.trial.FixState.Current == p.trial.FixState.FixOut
                    p.trial.EV.FixBreak = p.trial.CurTime;
                    p.trial.behavior.fixation.GotFix = 0;
                
                % Fixation has been held for long enough && not currently in the middle of breaking fixation
                elseif (p.trial.CurTime > p.trial.Timer.fixStart + p.trial.task.CurRewDelay) && p.trial.FixState.Current == p.trial.FixState.FixIn
                    
                    % Succesful
                    p.trial.task.Good = 1;
                    p.trial.outcome.CurrOutcome = p.trial.outcome.FullFixation;
                    
                    % Record when the monkey started fixating
                    p.trial.EV.FixStart = p.trial.Timer.fixStart;
                    
                    % Reward the monkey
                    p.trial.reward.count = p.trial.reward.count + 1;
                    pds.reward.give(p, p.trial.reward.Dur);
                    p.trial.Timer.lastReward = p.trial.CurTime;
                    
                    % Transition to the succesful fixation epoch
                    p.trial.CurrEpoch = p.trial.epoch.Fixating;

                end
                
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.Fixating
        %% Animal has reached fixation criteria and now starts receiving rewards for continued fixation
        
        % 'f' key is pressed, turn off fixation spot and return to earlier epoch.
            if ~p.trial.behavior.fixation.on
                p.trial.behavior.fixation.GotFix = 0;
                p.trial.CurrEpoch = p.trial.epoch.WaitExperimenter;
                return;
            end
        
        % Still fixating    
        if p.trial.FixState.Current == p.trial.FixState.FixIn
                
                rewardCount = p.trial.reward.count;
                rewardPeriod = p.trial.reward.Period;
                
                % Wait for rewardPeriod to elapse since last reward, then give the next reward
                if p.trial.CurTime > p.trial.Timer.lastReward + rewardPeriod
                    
                    rewardCount = rewardCount + 1;
                    p.trial.reward.count = rewardCount;
                    
                    % Get the reward duration
                    rewardDuration = p.trial.reward.Dur;                  
                    
                    % Give the reward and update the lastReward time
                    pds.reward.give(p, rewardDuration);
                    p.trial.Timer.lastReward = p.trial.CurTime;
                    
                end
        
        % Fixation Break, go back to waitFix    
        elseif p.trial.FixState.Current == p.trial.FixState.FixOut
            % TODO: Possibly play breakfix sound
            p.trial.behavior.fixation.GotFix = 0;
            p.trial.CurrEpoch = p.trial.epoch.WaitFix;
                                 
        end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % set timer for intertrial interval            
            tms = pds.datapixx.strobe(p.trial.event.TASK_OFF); 
            p.trial.EV.DPX_TaskOff = tms(1);
            p.trial.EV.TDT_TaskOff = tms(2);

            p.trial.EV.TaskEnd = p.trial.CurTime;

            if(p.trial.datapixx.TTL_trialOn)
                pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan, 0);
            end

            % determine ITI
            switch p.trial.outcome.CurrOutcome
                
                case {p.trial.outcome.NoFix, p.trial.outcome.FixBreak}
                    % Timeout if no fixation
                    p.trial.task.Timing.ITI = p.trial.task.Timing.ITI + p.trial.task.Timing.TimeOut;
            end
            
            p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.ITI;
            
            p.trial.Timer.ITI  = p.trial.Timer.Wait;
            p.trial.CurrEpoch  = p.trial.epoch.ITI;
        
        % ----------------------------------------------------------------%
        case p.trial.epoch.ITI
        %% inter-trial interval: wait before next trial to start
            Task_WaitITI(p);
            
    end  % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% show epoch dependent stimuli
% go through the task epochs as defined in TaskDesign and draw the stimulus
% content that needs to be shown during this epoch.

%% TODO: draw predicted eye pos for calibration grid, draw indicator for random posiiton vs. fix, indicate current position

    if p.trial.behavior.fixation.enableCalib
        pds.eyecalib.draw(p)
    end
    
    
    switch p.trial.CurrEpoch
        % ----------------------------------------------------------------%
        case {p.trial.epoch.WaitFix, p.trial.epoch.Fixating}
            pds.fixation.draw(p);

    end
    
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
        end
        
        pds.fixation.move(p);
    end