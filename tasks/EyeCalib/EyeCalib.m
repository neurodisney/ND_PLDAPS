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
    
    % Colors used for calibration points
    bgColor = p.trial.display.bgColor; % For making things invisible on the monkey screen;
    ND_DefineCol(p, 'Calib_LG', 70, [0.69, 1.00, 0.69], bgColor); % Light Green
    ND_DefineCol(p, 'Calib_G',  71, [0.00, 1.00, 0.00], bgColor); % Green
    ND_DefineCol(p, 'Calib_DG', 72, [0.00, 0.69, 0.00], bgColor); % Dark Green
    ND_DefineCol(p, 'Calib_LR', 73, [1.00, 0.69, 0.69], bgColor); % Light Red
    ND_DefineCol(p, 'Calib_R',  74, [1.00, 0.00, 0.00], bgColor); % Red
    ND_DefineCol(p, 'Calib_DR', 75, [0.69, 0.00, 0.00], bgColor); % Dark Red
    ND_DefineCol(p, 'Calib_Y',  76, [1.00, 1.00, 0.00], bgColor); % Yellow
    
    % Always use light blue for fixation spot during calibration
    ND_DefineCol(p, 'Fix_LB',  77, [0.69, 0.69, 1.00]);
    
    p.trial.behavior.fixation.FixCol = 'Fix_LB';
    
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
    c1.task.Reward.MinWaitInitial = 0.15; % min wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c1.task.Reward.MaxWaitInitial = 0.15;  % max wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c1.task.Reward.InitialRew     = 0.2;  % duration for initial reward pulse
    
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
                pds.eyecalib.keycheck(p);
                pds.fixation.keycheck(p);
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
                                     
    p.trial.task.CurRewDelay = ND_GetITI(p.trial.task.Reward.MinWaitInitial,  ...
                                         p.trial.task.Reward.MaxWaitInitial,  [], [], 1, 0.001);

    p.trial.CurrEpoch        = p.trial.epoch.TrialStart;
        
    p.trial.task.Reward.Curr = p.trial.task.Reward.InitialRew; % determine reward amount based on number of previous correct trials
        
    p.trial.task.Good                = 1;  % assume no error untill error occurs
    p.trial.task.Reward.cnt          = 0;  % counter for received rewardsw
    p.trial.behavior.fixation.GotFix = 0;
    
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
        
            p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.WaitFix;
            p.trial.CurrEpoch  = p.trial.epoch.WaitFix;
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
        %% Fixation target shown, wait until gaze gets in there
        
            if(p.trial.FixState.Current == p.trial.FixState.FixIn || p.trial.behavior.fixation.GotFix == 1)
            % got fixation
                if(p.trial.behavior.fixation.GotFix == 0) % starts to fixate
                    p.trial.behavior.fixation.GotFix = 1;
                    p.trial.Timer.FixBreak = p.trial.CurTime + p.trial.behavior.fixation.entryTime; % start timer to check if it is robust fixation
                    
                elseif(p.trial.FixState.Current == p.trial.FixState.FixOut)
                    p.trial.behavior.fixation.GotFix = 0;
                    
                elseif(p.trial.CurTime > p.trial.Timer.FixBreak) % long enough within FixWin
                    pds.datapixx.strobe(p.trial.event.FIXATION);

                    p.trial.EV.FixStart = p.trial.CurTime - p.trial.behavior.fixation.entryTime;
                    
                    p.trial.Timer.Wait  = p.trial.CurTime + p.trial.task.Timing.MaxFix;
                    p.trial.CurrEpoch   = p.trial.epoch.Fixating;
                    
                    p.trial.outcome.CurrOutcome = p.trial.outcome.FIXATION; % at least fixation was achieved
                    
                    p.trial.Timer.Reward = p.trial.CurTime + p.trial.task.CurRewDelay; % timer for initial reward
                end
                
            elseif(p.trial.CurTime  > p.trial.Timer.Wait)
            % trial offering ended    
                p.trial.task.Good = 0;
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;  % Go directly to TaskEnd, do not start task, do not collect reward
                p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.Fixating
        %% Animal maintains fixation 
        
            % check current fixation
            if(p.trial.FixState.Current == p.trial.FixState.FixOut || p.trial.behavior.fixation.GotFix == 0) % fixation break          
                
                if(p.trial.behavior.fixation.GotFix == 1)
                % first time break detected    
                    p.trial.behavior.fixation.GotFix = 0;
                    p.trial.Timer.FixBreak = p.trial.CurTime + p.trial.behavior.fixation.BreakTime;
                    
                elseif(p.trial.FixState.Current == p.trial.FixState.FixIn)
                % gaze returned in time to not be a fixation break
                    p.trial.behavior.fixation.GotFix = 1;

                elseif(p.trial.CurTime > p.trial.Timer.FixBreak)
                % out too long, it's a break    
                    pds.datapixx.strobe(p.trial.event.FIX_BREAK);
                    
                    p.trial.EV.FixBreak = p.trial.CurTime - p.trial.behavior.fixation.BreakTime;
                    p.trial.CurrEpoch   = p.trial.epoch.TaskEnd; % Go directly to TaskEnd, do not continue task, do not collect reward
                    
                    if(p.trial.outcome.CurrOutcome ~= p.trial.outcome.Correct)
                        p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak; % only consider break before first reward
                    end
                    
                    p.trial.task.Good = 0;
                end
            end
            
            % fixation time expired    
            if(p.trial.CurTime  > p.trial.Timer.Wait)
                pds.reward.give(p,  p.trial.task.Reward.JackPot);  % long term fixation, deserves something big
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                        
            % reward if it is about time
            elseif(p.trial.task.Good == 1 && p.trial.behavior.fixation.GotFix == 1 && ...
                p.trial.CurTime > p.trial.Timer.Reward)
                
                pds.reward.give(p, p.trial.task.Reward.Curr);
                p.trial.task.Reward.cnt = p.trial.task.Reward.cnt + 1;
                
                rs = find(~(p.trial.task.Reward.Step >= p.trial.task.Reward.cnt), 1, 'last');

                p.trial.Timer.Reward = p.trial.CurTime + p.trial.task.Reward.Dur + p.trial.task.Reward.WaitNext(rs);
                                
                p.trial.task.Reward.Curr = p.trial.task.Reward.Dur;
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
            
            if(p.trial.task.Reward.cnt > 0)
                p.trial.outcome.CurrOutcome = p.trial.outcome.Correct; % received a reward, hence correct
            end

            % determine ITI
            if(p.trial.outcome.CurrOutcome ~= p.trial.outcome.Correct)
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
        case {p.trial.epoch.TrialStart, p.trial.epoch.WaitFix, p.trial.epoch.Fixating}
        %% delay before response is needed
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