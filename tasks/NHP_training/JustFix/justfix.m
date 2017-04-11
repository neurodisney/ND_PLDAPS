function p = justfix(p, state)
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
    %% define ascii output file
    % call this after ND_InitSession to be sure that output directory exists!
    Trial2Ascii(p, 'init');

    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.
    ND_DefineCol(p, 'Fix_W',  30, [0.80, 0.80, 0.80]);
    ND_DefineCol(p, 'Fix_R',  31, [0.80, 0.00, 0.00]);
    ND_DefineCol(p, 'Fix_G',  32, [0.00, 0.80, 0.00]);
    ND_DefineCol(p, 'Fix_B',  33, [0.00, 0.00, 0.80]);

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
    p.trial.task.Reward.MinWaitInitial  = 0.05; % min wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.MaxWaitInitial  = 0.1;  % max wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.InitialRew      = 0.1;  % duration for initial reward pulse
    
    % condition 2
    c1.Nr = 2;
    p.trial.task.Reward.MinWaitInitial  = 0.1;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.MaxWaitInitial  = 0.25; % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.InitialRew      = 0.2;  % duration for initial reward pulse

    % condition 3
    c1.Nr = 3;
    p.trial.task.Reward.MinWaitInitial  = 0.25; % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.MaxWaitInitial  = 0.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.InitialRew      = 0.4;  % duration for initial reward pulse

    % condition 4
    c1.Nr = 4;
    p.trial.task.Reward.MinWaitInitial  = 0.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.MaxWaitInitial  = 1.0;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.InitialRew      = 0.6;  % duration for initial reward pulse

    % condition 5
    c1.Nr = 5;
    p.trial.task.Reward.MinWaitInitial  = 1.0;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.MaxWaitInitial  = 1.5;  % wait period for initial reward after arriving in FixWin (in s, how long to hold for first reward)
    p.trial.task.Reward.InitialRew      = 0.8;  % duration for initial reward pulse
    
    
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
            KeyAction(p);
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
                                         p.trial.task.Reward.MaxWaitInitial,  [], [], 1, 0.10);

    p.trial.CurrEpoch = p.trial.epoch.TrialStart;
        
    p.trial.task.Reward.Curr = p.trial.task.Reward.InitialRew; % determine reward amount based on number of previous correct trials
        
    p.trial.task.Good = 1;
    p.trial.task.Reward.cnt = 0;  % counter for received rewardsw
    
    p.trial.task.FixCol = 'Fix_W';
    
    
% ####################################################################### %
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
    switch p.trial.CurrEpoch

        case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot    
            tms = pds.tdt.strobe(p.trial.event.TASK_ON); 
            p.trial.EV.DPX_TaskOn = tms(1);
            p.trial.EV.TDT_TaskOn = tms(2);

            p.trial.EV.TaskStart = p.trial.CurTime;

            if(p.trial.datapixx.TTL_trialOn)
                pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan, 1);
            end
        
            p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.WaitFix;
            p.trial.CurrEpoch  = p.trial.epoch.WaitFix;
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
        %% Fixation target shown, wait until gaze gets in there
        
            if(p.trial.FixState.Current == p.trial.FixState.FixIn)
            % got fixation
                if(p.trial.behavior.fixation.GotFix == 0) % starts to fixate
                    p.trial.behavior.fixation.GotFix = 1;
                    p.trial.Timer.FixBreak = p.trial.CurTime + p.trial.behavior.fixation.EnsureFix;
                    
                elseif(p.trial.FixState.Current == p.trial.FixState.FixOut)
                    p.trial.behavior.fixation.GotFix = 0;
                    
                elseif(p.trial.CurTime > p.trial.Timer.FixBreak) % long enough within FixWin
                    pds.tdt.strobe(p.trial.event.FIXATION);

                    p.trial.EV.FixStart = p.trial.CurTime - p.trial.behavior.fixation.EnsureFix;
                    
                    p.trial.Timer.Wait  = p.trial.CurTime + p.trial.task.Timing.MaxFix;
                    p.trial.CurrEpoch   = p.trial.epoch.Fixating;
                    p.trial.outcome.CurrOutcome = p.trial.outcome.FIXATION;
                    
                    p.trial.Timer.Reward = p.trial.CurTime + p.trial.task.CurRewDelay; 
                end
                
            elseif(p.trial.CurTime  > p.trial.Timer.Wait)
            % trial offering ended    
                Task_NoStart(p);   % Go directly to TaskEnd, do not start task, do not collect reward
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.Fixating
        %% Animal keeps fixation and is pressing joystick
        
            % check current fixation
            if(p.trial.FixState.Current == p.trial.FixState.FixOut) % fixation break          
                
                if(p.trial.behavior.fixation.GotFix == 1)
                % first time break detected    
                    p.trial.behavior.fixation.GotFix = 0;
                    p.trial.Timer.FixBreak = p.trial.CurTime + p.trial.behavior.fixation.BreakTime;
                    
                elseif(p.trial.FixState.Current == p.trial.FixState.FixIn)
                % gaze returned in time to be not a fixation break
                    p.trial.behavior.fixation.GotFix = 1;

                elseif(p.trial.CurTime > p.trial.Timer.FixBreak)
                % out too long, it's a break    
                    pds.tdt.strobe(p.trial.event.FIX_BREAK);
                    
                    p.trial.EV.FixBreak = p.trial.CurTime - p.trial.behavior.fixation.BreakTime;
                    p.trial.CurrEpoch   = p.trial.epoch.TaskEnd; % Go directly to TaskEnd, do not continue task, do not collect reward
                    
                    if(p.trial.outcome.CurrOutcome ~= p.trial.outcome.Correct)
                        p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak; % only consider break before first reward
                    end
                    
                    p.trial.task.Good = 0;
                end
            end
            
            % reward if it is about time
            if(p.trial.task.Good == 0 && p.trial.behavior.fixation.GotFix == 1 && ...
               p.trial.CurTime > p.trial.Timer.Reward)
                
                pds.reward.give(p, p.trial.task.Reward.Curr);
                p.trial.task.Reward.cnt = p.trial.task.Reward.cnt + 1;
                
                p.trial.outcome.CurrOutcome = p.trial.outcome.Correct; % received a reward, hence correct
                
                rs = find(~(p.trial.task.Reward.Step >= p.trial.task.Reward.cnt), 1, 'last');

                p.trial.Timer.Reward = p.trial.CurTime + p.trial.task.Reward.WaitNext(rs);
                
                p.trial.task.Reward.Curr = p.trial.task.Reward.Dur;
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        % set timer for intertrial interval            
            tms = pds.tdt.strobe(p.trial.event.TASK_OFF); 
            p.trial.EV.DPX_TaskOff = tms(1);
            p.trial.EV.TDT_TaskOff = tms(2);

            p.trial.EV.TaskEnd = p.trial.CurTime;

            if(p.trial.datapixx.TTL_trialOn)
                pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan, 0);
            end

            % determine ITI
            if(p.trial.outcome.CurrOutcome == p.trial.outcome.Correct)
                p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.ITI;
            else
                p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.ITI + p.trial.task.Timing.TimeOut;
            end
            
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

    switch p.trial.CurrEpoch

        % ----------------------------------------------------------------%
        case {p.trial.epoch.TrialStart, p.trial.epoch.WaitFix, p.trial.epoch.Fixating}
        %% delay before response is needed
            Target(p, p.trial.task.FixCol);

    end
% ####################################################################### %
function KeyAction(p)
%% task specific action upon key press
    if(~isempty(p.trial.LastKeyPress))

        grdX = p.trial.behavior.fixation.FixGridStp(1);
        grdY = p.trial.behavior.fixation.FixGridStp(2);

        switch p.trial.LastKeyPress

            % grid positions
            case KbName('1')
            p.trial.behavior.fixation.FixPos = [-grdX, -grdY];
            MoveFix(p);
            
            case KbName('2')
            p.trial.behavior.fixation.FixPos = [    0, -grdY];
            MoveFix(p);
            
            case KbName('3')
            p.trial.behavior.fixation.FixPos = [ grdX, -grdY];
            MoveFix(p);
            
            case KbName('4')
            p.trial.behavior.fixation.FixPos = [-grdX,     0];
            MoveFix(p);
            
            case KbName('5')
            p.trial.behavior.fixation.FixPos = [    0,     0];
            MoveFix(p);
            
            case KbName('6')
            p.trial.behavior.fixation.FixPos = [ grdX,    0];
            MoveFix(p);
            
            case KbName('7')
            p.trial.behavior.fixation.FixPos = [-grdX,  grdY];
            MoveFix(p);
            
            case KbName('8')
            p.trial.behavior.fixation.FixPos = [    0,  grdY];
            MoveFix(p);
            
            case KbName('9')
            p.trial.behavior.fixation.FixPos = [ grdX,  grdY];
            MoveFix(p);
            
            % steps
            case KbName('RightArrow')
            p.trial.behavior.fixation.FixPos(1) = p.trial.behavior.fixation.FixPos(1) + ...
                                                  p.trial.behavior.fixation.FixWinStp;   
            MoveFix(p);
            
            case KbName('LeftArrow')
            p.trial.behavior.fixation.FixPos(1) = p.trial.behavior.fixation.FixPos(1) - ...
                                                  p.trial.behavior.fixation.FixWinStp;
            MoveFix(p);
            
            case KbName('UpArrow')
            p.trial.behavior.fixation.FixPos(2) = p.trial.behavior.fixation.FixPos(2) + ...
                                                  p.trial.behavior.fixation.FixWinStp;
            MoveFix(p);
            
            case KbName('DownArrow')
            p.trial.behavior.fixation.FixPos(2) = p.trial.behavior.fixation.FixPos(2) - ...
                                                  p.trial.behavior.fixation.FixWinStp;
            MoveFix(p);
            
            case KbName('g')
                
                fprintf('\n#####################\n  >>  Fix Pos: %d, %d \n Eye Sig: %d, 5d \n#####################\n', ...
                        p.trial.behavior.fixation.FixPos, p.trial.behavior.fixation.FixScale);
        end
    end


% ####################################################################### %
function MoveFix(p)
%% displace fixation window and fixation target
p.trial.task.fixrect       = ND_GetRect(p.trial.behavior.fixation.FixPos, ...
                                        p.trial.behavior.fixation.FixWin);  
% target item
p.trial.task.TargetPos = p.trial.behavior.fixation.FixPos;    % Stimulus diameter in dva25seconds

% get dva values into psychtoolbox pixel values/coordinates
p.trial.task.TargetPos  = p.trial.behavior.fixation.FixPos;
p.trial.task.TargetRect = ND_GetRect(p.trial.task.TargetPos, p.trial.task.TargetSz);


% ####################################################################### %
%% additional inline functions that
% ####################################################################### %

% ####################################################################### %
function Target(p, colstate)
%% show the target item with the given color
    Screen('FillOval',  p.trial.display.overlayptr, p.trial.display.clut.(colstate), p.trial.task.TargetRect);

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

            fprintf(tblptr, ['Date  Time  Secs  Subject  Experiment  Tcnt  Cond  Tstart  ',...
                             'FirstReward  RewCnt  Result  Outcome  FixPeriod  FixColor\n']);
            fclose(tblptr);

        case 'save'
            if(p.trial.pldaps.quit == 0 && p.trial.outcome.CurrOutcome ~= p.trial.outcome.NoStart)  % we might loose the last trial when pressing esc.
                                
                trltm = p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart;

                cOutCome = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

                tblptr = fopen(p.trial.session.asciitbl, 'a');

                fprintf(tblptr, '%s  %s  %.4f  %s  %s  %d  %d  %.5f  %.5f  %d  %d  %s  %.5f  %s\n' , ...
                                datestr(p.trial.session.initTime,'yyyy_mm_dd'), p.trial.EV.TaskStartTime, ...
                                p.trial.EV.TaskStart, p.trial.session.subject,  p.trial.session.experimentSetupFile, ...
                                p.trial.pldaps.iTrial, p.trial.Nr, trltm,  ...
                                p.trial.task.CurRewDelay, p.trial.task.Reward.cnt, p.trial.outcome.CurrOutcome, cOutCome, ...
                                p.trial.EV.FixBreak-p.EV.EV.FixStart, p.trial.task.FixCol);
               fclose(tblptr);
            end
    end
