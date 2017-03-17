function p = joy_train(p, state)
% Main trial function for initial joystick training.
%
% The animal needs to learn how to operate a joystick (i.e. lever) in order
% to receive a juice reward.
%
% 1) The trial starts with a change of background color (maybe changed to a
%    appearance of a frame).
% 2) The animal has to press a lever and a large square is shown together
%    with a juice reward (this first reward will be disabled once the main
%    principle is understood).
% 3) If the animal keeps the lever pressed for a minimum hold time and then
%    releases it, the square changes its contrast and another reward will be
%    delivered.
%
%
% TODO: add accoustic feedback
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
    c1.task.Timing.MinHoldTime = 0.2;
    c1.task.Timing.MaxHoldTime = 0.4;

    % condition 2
    c2.Nr = 2;
    c2.task.Timing.MinHoldTime = 0.4;
    c2.task.Timing.MaxHoldTime = 0.6;

    % condition 3
    c3.Nr = 3;
    c3.task.Timing.MinHoldTime = 0.6;
    c3.task.Timing.MaxHoldTime = 0.8;

    % condition 4
    c4.Nr = 4;
    c4.task.Timing.MinHoldTime = 0.8;
    c4.task.Timing.MaxHoldTime = 1.0;

    % condition 5
    c5.Nr = 5;
    c5.task.Timing.MinHoldTime = 1.0;
    c5.task.Timing.MaxHoldTime = 1.2;
    
    % condition 6
    c6.Nr = 6;
    c6.task.Timing.MinHoldTime = 1.2;
    c6.task.Timing.MaxHoldTime = 1.4;
    
    % condition 7
    c7.Nr = 7;
    c7.task.Timing.MinHoldTime = 1.4;
    c7.task.Timing.MaxHoldTime = 1.6;
    
    % condition 8
    c8.Nr = 8;
    c8.task.Timing.MinHoldTime = 1.6;
    c8.task.Timing.MaxHoldTime = 1.8;
    
    % condition 9
    c9.Nr = 9;
    c9.task.Timing.MinHoldTime = 1.8;
    c9.task.Timing.MaxHoldTime = 2.0;

    % create a cell array containing all conditions
    % conditions = {c1, c2, c3, c4, c5};
    %conditions = {c1, c2, c3, c4, c5, c6, c7, c8, c9};
    conditions = {c1, c2, c3, c4, c5, c6};

    p = ND_GetConditionList(p, conditions, maxTrials_per_BlockCond, maxBlocks);

else
% ####################################################################### %
%% Subsequent calls during actual trials
% execute trial specific commands here.

    switch state
% ####################################################################### %
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
            
% ####################################################################### %
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
                        
% ####################################################################### %
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

% ------------------------------------------------------------------------%
function TaskSetUp(p)
%% main task outline
% Determine everything here that can be specified/calculated before the actual trial start
    p.trial.task.Timing.ITI      = ND_GetITI(p.trial.task.Timing.MinITI,      ...
                                             p.trial.task.Timing.MaxITI,      [], [], 1, 0.10);
    p.trial.task.Timing.HoldTime = ND_GetITI(p.trial.task.Timing.MinHoldTime, ...
                                             p.trial.task.Timing.MaxHoldTime, [], [], 1, 0.02);   % Minimum time before response is expected

    p.trial.CurrEpoch = p.trial.epoch.GetReady;
    
% ------------------------------------------------------------------------%
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
    switch p.trial.CurrEpoch
        % ----------------------------------------------------------------%
        case p.trial.epoch.GetReady
        %% before the trial can start joystick needs to be in a released state
            if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
                p.trial.task.Timing.WaitTimer = p.trial.CurTime + p.trial.task.Timing.MinRel;
                p.trial.CurrEpoch = p.trial.epoch.CheckBarRel;
            end

        case p.trial.epoch.CheckBarRel
        %% make sure that the bar is fully release by waiting for a specified time    

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
                    
                   if(p.trial.task.FullTask)
                        % do full task, use other task epochs
                        p.trial.task.Timing.WaitTimer = p.trial.CurTime + p.trial.task.Timing.HoldTime;
                        p.trial.CurrEpoch = p.trial.epoch.WaitGo;

                        if(p.trial.task.Reward.Pull)
                            pds.reward.give(p, p.trial.task.Reward.PullRew);
                        end
                    else
                        % That was the task, reward animal and done                        
                        Task_Correct(p);
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
            if(p.trial.CurTime > p.trial.task.Timing.WaitTimer)
                p.trial.EV.Reward = p.trial.CurTime - p.trial.EV.TaskStart;

                p.trial.reward.Curr = ND_GetRewDur(p); % determine reward amount based on number of previous correct trials

                pds.reward.give(p, p.trial.reward.Curr);

                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitRelease
        %% Wait for joystick release after missed response    FalseStart
            if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
                % use it as optional release reward if not full task is used
                if(p.trial.task.Reward.Pull && ~p.trial.task.FullTask)
                    pds.reward.give(p, p.trial.task.Reward.PullRew);
                end

                Response_JoyRelease(p);
                Response_Late(p);
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling

            if(p.trial.outcome.CurrOutcome == p.trial.outcome.Correct)
                p.trial.task.Timing.WaitTimer = p.trial.CurTime + p.trial.task.Timing.ITI;
                p.trial.CurrEpoch = p.trial.epoch.ITI;
            else
                p.trial.task.Timing.WaitTimer = p.trial.CurTime + p.trial.task.Timing.ITI + p.trial.task.Timing.TimeOut;
                p.trial.CurrEpoch = p.trial.epoch.ITI;
            end
            
            Task_OFF(p);

        % ----------------------------------------------------------------%
        case p.trial.epoch.ITI
        %% inter-trial interval: wait before next trial to start
            if(p.trial.CurTime > p.trial.task.Timing.WaitTimer)
                p.trial.flagNextTrial = 1;
            end
    end  % switch p.trial.CurrEpoch

% ------------------------------------------------------------------------%
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

% ------------------------------------------------------------------------%
function TrialOn(p)
%% show a frame to indicate the trial is active
    Screen('FrameRect', p.trial.display.overlayptr, p.trial.display.clut.TrialStart, ...
                        p.trial.task.FrameRect , p.trial.task.FrameWdth);

% ------------------------------------------------------------------------%
function Target(p, colstate)
%% show the target item with the given color
    Screen('FillOval',  p.trial.display.overlayptr, p.trial.display.clut.(colstate), p.trial.task.TargetRect);

% ------------------------------------------------------------------------%
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
