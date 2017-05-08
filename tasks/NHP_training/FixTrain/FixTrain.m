function p = FixTrain(p, state)
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
    % call this after ND_InitSession to be sure that output directory exists!
    Trial2Ascii(p, 'init');

    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.

    p.trial.task.Color_list = Shuffle({'white', 'red', 'green', 'blue', 'orange', 'yellow', 'cyan', 'magenta'});  
    
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

    
    % reward series for continous fixation
    % c.task.Reward.MinWaitInitial -  minimum latency to reward after fixation
    % c.task.Reward.MaxWaitInitial -  maximum latency to reward after fixation
    % c.task.Reward.nRewards       -  array of how many of each kind of reward
    % c.task.Reward.Dur            -  array of how long each kind of reward lasts
    % c.task.Reward.Period         -  the period between one reward and the next NEEDS TO BE GREATER THAN Dur
    % c.task.Reward.jackpotDur     -  the jackpot is given after all other rewards
    p.trial.task.Reward.WaitNext = [0.75, 0.5, 0.25];  % wait period until next reward
    p.trial.task.Reward.Dur      = 0.1;               % reward duration [s], user vector to specify values used for incremental reward scheme
    p.trial.task.Reward.Step     = [0, 4, 6];          % define the number of subsequent rewards after that the next delay period should be used.

    % condition 1
    c1.Nr = 1;
    c1.task.Reward.MinWaitInitial = 0.13;        % min wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c1.task.Reward.MaxWaitInitial = 0.17;        % max wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c1.task.Reward.InitialRew     = 0.1;         % duration for initial reward pulse
    c1.task.Reward.Dur            = 0.1;         % reward duration [s], user vector to specify values used for incremental reward scheme
    c1.task.Reward.Step           = 0;           % define the number of subsequent rewards after that the next delay period should be used.
    c1.task.Reward.WaitNext       = 0.75;         % wait period until next reward
    
    c1.nTrials = 100;
    
    
    % condition 2
    c2.Nr = 2;
    c2.task.Reward.MinWaitInitial = 0.23;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c2.task.Reward.MaxWaitInitial = 0.27; % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c2.task.Reward.InitialRew     = 0.1;  % duration for initial reward pulse
    c2.task.Reward.Dur            = 0.1;         % reward duration [s], user vector to specify values used for incremental reward scheme
    c2.task.Reward.Step           = 0;           % define the number of subsequent rewards after that the next delay period should be used.
    c2.task.Reward.WaitNext       = 0.75;         % wait period until next reward
    c2.nTrials = 100;
    
    
    % condition 3
    c3.Nr = 3;
    c3.task.Reward.MinWaitInitial = 0.48; % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c3.task.Reward.MaxWaitInitial = 0.52;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c3.task.Reward.InitialRew     = 0.15;  % duration for initial reward pulse
    c3.task.Reward.Dur            = 0.15;         % reward duration [s], user vector to specify values used for incremental reward scheme
    c3.task.Reward.Step           = 0;           % define the number of subsequent rewards after that the next delay period should be used.
    c3.task.Reward.WaitNext       = 0.50;         % wait period until next reward
    c3.nTrials = 300;
    
    % condition 4
    c4.Nr = 4;
    c4.task.Reward.MinWaitInitial = 0.73;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c4.task.Reward.MaxWaitInitial = 0.77;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c4.task.Reward.InitialRew     = 0.2;  % duration for initial reward pulse
    c4.task.Reward.Dur            = 0.2;         % reward duration [s], user vector to specify values used for incremental reward scheme
    c4.task.Reward.Step           = 0;           % define the number of subsequent rewards after that the next delay period should be used.
    c4.task.Reward.WaitNext       = 0.25;         % wait period until next reward
    c4.nTrials = 300;
    
    % condition 4
    c5.Nr = 5;
    c5.task.Reward.MinWaitInitial = 0.98;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c5.task.Reward.MaxWaitInitial = 1.02;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    c5.task.Reward.InitialRew     = 0.25;  % duration for initial reward pulse
    c5.task.Reward.Dur            = 0.25;         % reward duration [s], user vector to specify values used for incremental reward scheme
    c5.task.Reward.Step           = 0;           % define the number of subsequent rewards after that the next delay period should be used.
    c5.task.Reward.WaitNext       = 0.1;         % wait period until next reward
    c5.nTrials = 1000;
    
    
    % Fill a conditions list with n of each kind of condition sequentially
    conditions = cell(1,5000);
    blocks = nan(1,5000);
    totalTrials = 0;
    
    % Iterate through each condition to fill conditions
    conditionsIterator = {c2,c3,c4,c5};
    
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
            Trial2Ascii(p, 'save');
                        
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
    
    % Outcome if no fixation occurs at all during the trial
    p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;
        
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
    
    p.trial.behavior.fixation.FixCol = p.trial.task.Color_list{mod(p.trial.blocks(p.trial.pldaps.iTrial), length(p.trial.task.Color_list))+1};
    
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
            p.trial.Timer.trialStart = p.trial.CurTime;
            p.trial.CurrEpoch  = p.trial.epoch.WaitFix;
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
            %% Fixation target shown, waiting for a sufficiently held gaze
            
            % If gaze is outside fixation window
            if p.trial.behavior.fixation.GotFix == 0
               
                % Fixation has occured
                if p.trial.FixState.Current == p.trial.FixState.FixIn
                    p.trial.outcome.CurrOutcome = p.trial.outcome.BriefFixation;
                    p.trial.behavior.fixation.GotFix = 1;
                    p.trial.Timer.fixStart = p.trial.CurTime;
                
                % Time to fixate has expired
                elseif p.trial.CurTime > p.trial.Timer.trialStart + p.trial.Timing.WaitFix
                    
                    % Long enough fixation did not occur, failed trial
                    p.trial.task.Good = 0;
                    
                    % Go directly to TaskEnd, do not start task, do not collect reward
                    p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                    
                end
                
                
            % If gaze is inside fixation window
            elseif p.trial.behavior.fixation.GotFix == 1
                
                % Fixation ceases
                if p.trial.FixState.Current == p.trial.FixState.FixOut
                    p.trial.behavior.GotFix = 0;
                
                % Fixation has been held for long enough && not currently in the middle of breaking fixation
                elseif (p.trial.CurTime > p.trial.fixStart + p.trial.task.CurRewDelay) && p.trial.FixState.Current == p.trial.FixState.FixIn
                    
                    % Succesful
                    p.trial.task.Good = 1;
                    p.trial.outcome.CurrOutcome = p.trial.outcome.FullFixation;
                    
                    % Record when the monkey started fixating
                    p.trial.EV.FixStart = p.trial.Timer.fixStart;
                    
                    % Reward the monkey
                    pds.reward.give(p, p.trial.task.Reward.InitialRew);
                    p.trial.task.Reward.cnt = p.trial.task.Reward.cnt + 1;
                    
                    % Transition to the succesful fixation epoch
                    p.trial.epoch.CurrEpoch = p.trial.epoch.Fixating;

                end
                
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
        
        pds.fixation.move(p);
    end

% ####################################################################### %
%% additional inline functions that
% ####################################################################### %

% ####################################################################### %
function Trial2Ascii(p, act)
%% Save trial progress in an ASCII table
% 'init' creates the file with a header defining all columns
% 'save' adds a line with the information for the current trial
%
% make sure that number of header names is the same as the number of entries
% to write, also that the position matches.

    switch act
        case 'init'
            tblptr = fopen(p.trial.session.asciitbl , 'w');

            fprintf(tblptr, ['Date  Time  Secs  Subject  Experiment  Tcnt  Cond  Tstart  FixRT  ',...
                             'FirstReward  RewCnt  Result  Outcome  FixPeriod  FixColor  ITI FixWin  fixPos_X  fixPos_Y \n']);
            fclose(tblptr);

        case 'save'
            if(p.trial.pldaps.quit == 0 && p.trial.outcome.CurrOutcome ~= p.trial.outcome.NoStart && p.trial.outcome.CurrOutcome ~= p.trial.outcome.NoFix)  % we might loose the last trial when pressing esc.
                                
                trltm = p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart;

                cOutCome = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

                tblptr = fopen(p.trial.session.asciitbl, 'a');

                fprintf(tblptr, '%s  %s  %.4f  %s  %s  %d  %d  %.5f  %.5f  %.5f  %d  %d  %s  %.5f  %s  %.5f  %.2f  %.2f  %.2f \n' , ...
                                datestr(p.trial.session.initTime,'yyyy_mm_dd'), p.trial.EV.TaskStartTime, ...
                                p.trial.EV.DPX_TaskOn, p.trial.session.subject, p.trial.session.experimentSetupFile, ...
                                p.trial.pldaps.iTrial, p.trial.Nr, trltm, p.trial.EV.FixStart-p.trial.EV.TaskStart,  ...
                                p.trial.task.CurRewDelay, p.trial.task.Reward.cnt, p.trial.outcome.CurrOutcome, cOutCome, ...
                                p.trial.EV.FixBreak-p.trial.EV.FixStart, p.trial.behavior.fixation.FixCol, p.trial.task.Timing.ITI, ...
                                p.trial.behavior.fixation.FixWin, p.trial.behavior.fixation.fixPos(1), p.trial.behavior.fixation.fixPos(2));
               fclose(tblptr);
            end
    end
        
