function p = get_joy(p, state)
% Main trial function for initial joystick training.
%
%
%
% wolf zinke, Dec. 2016

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
% file. In this case p.defaultParameters.pldaps.trialFunction needs to be defined
% here to refer to the file with the actual trial
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
    ND_DefineCol(p, 'TargetOn',   30, [1.00, 1.00, 1.00]);
    ND_DefineCol(p, 'TargetDimm', 31, [0.5, 0.5, 0.5]);

    % ND_DefineCol(p, 'TargetDimm', 30, [0.00, 1.00, 0.00]);
    % ND_DefineCol(p, 'TargetOn',   31, [1.00, 0.00, 0.00]);

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
    c1.task.Timing.MinHoldTime = 2.5;
    c1.task.Timing.MaxHoldTime = 3;
    
    % condition 2
    c2.Nr = 2;
    c2.task.Timing.MinHoldTime = 3;
    c2.task.Timing.MaxHoldTime = 3.5;
    
    % condition 3
    c3.Nr = 3;
    c3.task.Timing.MinHoldTime = 3.5;
    c3.task.Timing.MaxHoldTime = 4;
    
    % condition 4
    c4.Nr = 4;
    c4.task.Timing.MinHoldTime = 4;
    c4.task.Timing.MaxHoldTime = 4.5;
    
    % condition 5
    c5.Nr = 5;
    c5.task.Timing.MinHoldTime = 4.5;
    c5.task.Timing.MaxHoldTime = 5;

    % create a cell array containing all conditions
    % conditions = {c1, c2, c3, c4, c5};
    conditions = {c1, c2, c3, c4, c5};
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
    p.trial.task.Timing.ITI      = ND_GetITI(p.trial.task.Timing.MinITI,      ...
                                             p.trial.task.Timing.MaxITI,      [], [], 1, 0.10);
    p.trial.task.Timing.HoldTime = ND_GetITI(p.trial.task.Timing.MinHoldTime, ...
                                             p.trial.task.Timing.MaxHoldTime, [], [], 1, 0.02);   % Minimum time before response is expected

    p.trial.CurrEpoch = p.trial.epoch.GetReady;

    p.trial.task.Reward.Timer = 0; % set zero to start with a reward upon press

% ####################################################################### %
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
    switch p.trial.CurrEpoch
        % ----------------------------------------------------------------%
        case p.trial.epoch.GetReady
        %% before the trial can start joystick needs to be in a released state
            if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
                p.trial.task.Timing.WaitTimer = GetSecs + p.trial.task.Timing.MinRel;
                p.trial.CurrEpoch = p.trial.epoch.CheckBarRel;
            end

        case p.trial.epoch.CheckBarRel

            if(p.trial.JoyState.Current == p.trial.JoyState.JoyHold)
                % pressed again to quickly
                Task_NotReady(p);  % Go directly to TaskEnd, do not start task, do not collect reward

            elseif(p.trial.CurTime > p.trial.task.Timing.WaitTimer)
            % joystick in a properly released state, let's start the trial
                Task_Ready(p);               
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitStart
        %% Wait for joystick press
            if(p.trial.CurTime > p.trial.task.Timing.WaitTimer)
            % no trial initiated in the given time window
                Task_NoStart(p);   % Go directly to TaskEnd, do not start task, do not collect reward

            elseif(p.trial.JoyState.Current == p.trial.JoyState.JoyHold)
                
                Task_InitPress(p);
                
                if(p.trial.EV.StartRT <  p.trial.task.Timing.minRT)
                % too quick to be a true response
                    Task_PrematStart(p);

                else
                % we just got a press in time
                    Task_ON(p);

                    p.trial.task.Timing.WaitTimer = p.trial.CurTime + p.trial.task.Timing.HoldTime;
                    p.trial.CurrEpoch = p.trial.epoch.WaitGo;
                        
                    if(p.trial.task.Reward.Pull)
                        pds.reward.give(p, p.trial.task.Reward.PullRew);
                    end
                end
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitGo
        %% delay before response is needed
            if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest) % early release
                Response_JoyRelease(p);
                Response_Early(p);  % Go directly to TaskEnd, do not continue task, do not collect reward

            elseif(p.trial.CurTime > p.trial.task.Timing.WaitTimer)
                Task_GoCue(p);

            elseif(p.trial.task.Reward.RewTrain)
                % shoot of a train of rewards
                if(p.trial.CurTime > p.trial.task.Reward.Timer)
                    cr_gap = ND_GetITI(p.trial.task.Reward.RewGapMin, ...
                                       p.trial.task.Reward.RewGapMax,[],[],[], 0.01);
                    p.trial.task.Reward.Timer = p.trial.CurTime + p.trial.task.Reward.TrainRew  + cr_gap;
                                                               
                    pds.reward.give(p, p.trial.task.Reward.TrainRew);
                end
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitResponse
        %% Wait for joystick release
            if(p.trial.CurTime > p.trial.task.Timing.WaitTimer)
                Response_Miss(p);  % Go directly to TaskEnd, do not continue task, do not collect reward

            elseif(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
                Response_JoyRelease(p);
                
                if(p.trial.EV.RespRT <  p.trial.task.Timing.minRT)
                % premature response - too early to be a true response
                     Response_Early(p); % Go directly to TaskEnd, do not continue task, do not collect reward
                else
                % correct response
                    Task_Correct(p);
                end
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitReward
        %% Wait for for reward
        % add error condition for new press
            if(p.trial.JoyState.Current > p.trial.task.Timing.WaitTimer)
                p.trial.task.Reward.Curr = ND_GetRewDur(p); % determine reward amount based on number of previous correct trials
                Task_Reward(p);
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitRelease
        %% Wait for joystick release after missed response
            if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
                Response_JoyRelease(p);
                Response_Late(p);
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        % set timer for intertrial interval
            Task_OFF(p);
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.ITI
        %% inter-trial interval: wait before next trial to start
            if(GetSecs > p.trial.task.Timing.WaitTimer)
                p.trial.flagNextTrial = 1;
            end
    end   % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% show epoch dependent stimuli
% go through the task epochs as defined in TaskDesign and draw the stimulus
% content that needs to be shown during this epoch.
    switch p.trial.CurrEpoch
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitStart
        %% Wait for joystick press
            TrialOn(p);

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitGo
        %% delay before response is needed
            TrialOn(p);
            Target(p, 'TargetOn');

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitResponse
        %% Wait for joystick release
            TrialOn(p);
            Target(p, 'TargetDimm');

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitReward
        %% Wait for for reward
            TrialOn(p);
            Target(p, 'TargetDimm');
    end

% ####################################################################### %
%% additional inline functions that
% ####################################################################### %

% ####################################################################### %
function TrialOn(p)
%% show a frame to indicate the trial is active
    Screen('FrameRect', p.trial.display.overlayptr, p.trial.display.clut.TrialStart, ...
                        p.trial.task.FrameRect , p.trial.task.FrameWdth);

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

            fprintf(tblptr, ['Date  Time  Secs  Subject  Experiment  Tcnt  Cond  Tstart  JPress  GoCue  JRelease  Reward  RewDur  ',...
                             'Result  Outcome  StartRT  RT  ChangeTime \n']);
            fclose(tblptr);

        case 'save'
            if(p.trial.pldaps.quit == 0 && p.trial.outcome.CurrOutcome ~= p.trial.outcome.NoStart && ...
               p.trial.outcome.CurrOutcome ~= p.trial.outcome.PrematStart)  % we might loose the last trial when pressing esc.
                
                if(p.trial.outcome.CurrOutcome == p.trial.outcome.Correct || ...
                   p.trial.outcome.CurrOutcome == p.trial.outcome.Early)
                    RT = p.trial.EV.JoyRelease - p.trial.task.Timing.HoldTime;
                else
                    RT = NaN;
                end
                
                trltm = p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart;

                cOutCome = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

                tblptr = fopen(p.trial.session.asciitbl, 'a');

                fprintf(tblptr, '%s  %s  %.4f  %s  %s  %d  %d  %.5f %.5f  %.5f  %.5f  %.5f  %.5f  %d  %s  %.5f  %.5f  %.5f\n' , ...
                                datestr(p.trial.session.initTime,'yyyy_mm_dd'), p.trial.EV.TaskStartTime, ...
                                p.trial.EV.TaskStart, p.trial.session.subject, ...
                                p.trial.session.experimentSetupFile, p.trial.pldaps.iTrial, p.trial.Nr, ...
                                trltm, p.trial.EV.JoyPress, ...
                                p.trial.EV.GoCue, p.trial.EV.JoyRelease, p.trial.EV.Reward, ...
                                p.trial.task.Reward.Curr, p.trial.outcome.CurrOutcome, cOutCome, ...
                                p.trial.EV.StartRT, RT, p.trial.task.Timing.HoldTime);
               fclose(tblptr);
            end
    end
