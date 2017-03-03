function p=fix_train_task(p, state)
% main trial function for initial fixation training
%
% created 02/08/2017 AB
% last edited 02/08/2017 AB
% based on 'joy_task.m' WZ
%
% contains the following N=? in-file functions:
% 1. TaskSetUp
% 2. TaskDesign
% 3. TaskDraw
% 4. TrialOn
% 5. Target
% 6. Trial2Ascii

%% define the task name that will be used to create a sub-structure in the
% trial struct

if(~exist('state', 'var'))
    state = [];
end

%% Call standard routines before executing task related code
% This carries out standard routines, mainly in respect to hardware interfacing.
% Be aware that this is done first for each trial state!
p = ND_GeneralTrialRoutines(p, state);

%% Initial call of this function. Use this to define general settings of the experiment/session.
% Here, default parameters of the pldaps class could be adjusted if needed.
% This part corresponds to the experimental setup file and could be a separate
% file. In this case p.defaultParameters.pldaps.trialFunction needs to be defined
% here to refer to the file with the actual trial

if(isempty(state))
    
    %% get task parameters
    
    fix_train_taskdef;  % WZ: could it be removed here and just run in trialSetup?
    
    %% define ascii output file
    % call this after ND_InitSession to be sure that output directory exists!
    Trial2Ascii(p, 'init');
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before
    % executing pds.datapixx.init, hence this is a good place to do so. To
    % avoid conflicts with future changes in the set of default colors, use
    % entries later in the lookup table for the definition of task related colors.
    ND_DefineCol(p, 'TargetDimm', 30, [0.00, 1.00, 0.00]);
    ND_DefineCol(p, 'TargetOn',   31, [1.00, 0.00, 0.00]);
    ND_DefineCol(p, 'FixSpotInit', 32, [1 1 1]); % initial fixspot clr
    ND_DefineCol(p, 'FixSpotAcq', 33, [0.8 1 0.8]); 
    % optional, use flagged is TODO, color fixspot changes to upon
    % acquisition of (stable?) fixation
    
    %% Determine conditions and their sequence
    % define conditions (conditions could be passed to the pldaps call as
    % cell array, or defined here within the main trial function. The
    % control of trials, especially the use of blocks, i.e. the repetition
    % of a defined number of trials per condition, needs to be clarified.
    
    maxTrials_per_BlockCond = 4;
    maxBlocks = 1000;
    
    % condition 1
    c1.Nr = 1;
    c1.task.Timing.MinHoldTime = 0.1;
    c1.task.Timing.MaxHoldTime = 0.2;
    c1.task.Timing.minFixHoldTime = 0.2; % amb 03/03/17 added
    c1.task.Timing.maxFixHoldTime = 0.4; % amb 03/03/17 added
%     % condition 2
%     c2.Nr = 2;
%     
%     % condition 3
%     c3.Nr = 3;
%     
%     % condition 4
%     c4.Nr = 4;
%     
%     % condition 5
%     c5.Nr = 5;
    
    % create a cell array containing all conditions
%     conditions = {c1, c2, c3, c4, c5};
    conditions = {c1};
    p = ND_GetConditionList(p, conditions, maxTrials_per_BlockCond, maxBlocks);
else
    %% Subsequent calls during actual trials
    % execute trial specific commands here.
    switch state
        %% DONE BEFORE MAIN TRIAL LOOP:
        case p.trial.pldaps.trialStates.trialSetup
            TaskSetUp(p);
        case p.trial.pldaps.trialStates.trialPrepare
            p.trial.task.EV.TrialStart = GetSecs;
            %% DONE DURING THE MAIN TRIAL LOOP
        case p.trial.pldaps.trialStates.framePrepareDrawing
            TaskDesign(p);
        case p.trial.pldaps.trialStates.frameDraw
            TaskDraw(p);
            %% DONE AFTER THE MAIN TRIAL LOOP:
        case p.trial.pldaps.trialStates.trialCleanUpandSave
            % ensure all conditions were performed correctly equal often
            p = ND_CheckCondRepeat(p);
            Trial2Ascii(p, 'save');
            if(p.trial.pldaps.iTrial == length(p.conditions))
                p.trial.pldaps.finish = p.trial.pldaps.iTrial;
            end
    end % switch state
end % if(isempty(state))

%% Task related functions

function TaskSetUp(p)
%% main task outline
% Determine everything here that can be specified/calculated before the
% actual trial start
% brute force: read in task parameters every time to allow for online
% modifications.
% TODO: make it robust and let it work with parameter changes via keyboard,
% see e.g. monkeylogic editable concept.
fix_train_taskdef;
% AB to WZ:  this is already done on initialization, do we need it in both
% places?

p.trial.task.Timing.ITI=ND_GetITI(p.trial.task.Timing.MinITI,      ...
    p.trial.task.Timing.MaxITI,      [], [], 1, 0.10);
p.trial.task.Timing.HoldTime=ND_GetITI(p.trial.task.Timing.MinHoldTime, ...
    p.trial.task.Timing.MaxHoldTime, [], [], 1, 0.02);

% AB 03/03/17 -- generate these for fix params
p.trial.task.Timing.FixHoldTime=ND_GetITI(p.trial.task.Timing.MinFixHoldTime, ...
    p.trial.task.Timing.MaxITI,      [], [], 1, 0.02);
% Minimum time before response is expected
p.trial.task.TaskStart   = NaN;
p.trial.CurrEpoch = p.trial.epoch.GetReady;
p.trial.task.Reward.Curr = p.trial.task.Reward.Dur(1);

function TaskDesign(p)%% main task outline
% The different task stages (i.e. 'epochs') are defined here.

switch p.trial.CurrEpoch
    %% before the trial can start joystick needs to be in a released state
    case p.trial.epoch.GetReady
        if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
            % joystick in a released state, let's start the trial
            p.trial.task.EV.TaskStart     = GetSecs;
            p.trial.task.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
            %ND_CtrlMsg(p, 'Trial started');
            
            p.trial.task.Timing.WaitTimer = p.trial.task.EV.TaskStart + p.trial.task.Timing.WaitStart;
            
            p.trial.CurrEpoch = p.trial.epoch.WaitStart;
        end
    %% Wait for joystick press
    case p.trial.epoch.WaitStart
        ctm = GetSecs;
        if(ctm > p.trial.task.Timing.WaitTimer)
            % no trial initiated in the given time window
            %ND_CtrlMsg(p, 'No joystick press');
            p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;
            
            p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
            
        elseif(p.trial.JoyState.Current == p.trial.JoyState.JoyHold)
            
            p.trial.task.EV.StartRT = ctm - p.trial.task.EV.TaskStart;
            
            if(p.trial.task.EV.StartRT <  p.trial.behavior.joystick.minRT)
                % too quick to be a true response
                %ND_CtrlMsg(p, 'premature start');
                p.trial.outcome.CurrOutcome = p.trial.outcome.FalseStart;
                
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                
            else
                % we just got a press in time
                %ND_CtrlMsg(p, 'Joystick press');
                
                p.trial.task.EV.JoyPress      = ctm - p.trial.task.EV.TaskStart;
                p.trial.task.Timing.WaitTimer = ctm + p.trial.task.Timing.HoldTime;
                
                p.trial.CurrEpoch = p.trial.epoch.WaitGo;
                
                if(p.trial.task.Reward.Pull)
                    pds.behavior.reward.give(p, p.trial.task.Reward.PullRew);
                    %ND_CtrlMsg(p, 'Reward');
                end
            end
        end
    %% delay before response is needed
    % this is the epoch while the joystick is held down
    case p.trial.epoch.WaitGo    
        ctm = GetSecs;
        if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest) % early release
            %ND_CtrlMsg(p, 'Early release');
            p.trial.outcome.CurrOutcome = p.trial.outcome.Early;
            p.trial.task.EV.JoyRelease = ctm - p.trial.task.EV.TaskStart;
            
            p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
            
        elseif(ctm > p.trial.task.Timing.WaitTimer)
            %ND_CtrlMsg(p, 'Wait response');
            p.trial.task.EV.GoCue         = ctm - p.trial.task.EV.TaskStart;
            p.trial.task.Timing.WaitTimer = ctm + p.trial.task.Timing.WaitResp;
            
            p.trial.CurrEpoch = p.trial.epoch.WaitResponse;
        end
    %% Wait for joystick release
    case p.trial.epoch.WaitResponse    
        ctm = GetSecs;
        if(ctm > p.trial.task.Timing.WaitTimer)
            %ND_CtrlMsg(p, 'No Response');
            p.trial.outcome.CurrOutcome = p.trial.outcome.Miss;
            
            p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
            
        elseif(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
            
            p.trial.task.EV.RespRT = ctm - p.trial.task.EV.GoCue;
            
            if(p.trial.task.EV.RespRT <  p.trial.behavior.joystick.minRT)
                % premature response - too early to be a true response
                %ND_CtrlMsg(p, 'premature response');
                p.trial.outcome.CurrOutcome = outcome.Early;
                
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                
            else
                % correct response
                %ND_CtrlMsg(p, 'Correct Response');
                p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
                
                p.trial.LastHits = p.trial.LastHits + 1;
                p.trial.NHits    = p.trial.NHits    + 1;
                
                p.trial.task.EV.JoyRelease    = ctm - p.trial.task.EV.TaskStart;
                p.trial.task.Timing.WaitTimer = ctm + p.trial.task.Reward.Lag;
                
                p.trial.CurrEpoch = p.trial.epoch.WaitReward;
            end
        end
    %% Wait for for reward
    % add error condition for new press
    case p.trial.epoch.WaitReward
        ctm = GetSecs;
        if(ctm > p.trial.task.Timing.WaitTimer)
            p.trial.task.EV.Reward = ctm - p.trial.task.EV.TaskStart;
            % TODO: add function to select current reward amount based on time or
            %       number of consecutive correct trials preceding the current one.
            
            p.trial.task.Reward.Curr = ND_GetRewDur(p); % determine reward amount based on number of previous correct trials
            
            pds.behavior.reward.give(p, p.trial.task.Reward.Curr);
            ND_CtrlMsg(p, ['Reward: ', num2str(p.trial.task.Reward.Curr), ' seconds']);
            
            p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
        end
    %% Wait for joystick release after missed response    FalseStart
    case p.trial.epoch.WaitRelease
        
        if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
            p.trial.task.EV.JoyRelease = GetSecs;
            %ND_CtrlMsg(p, 'Late Release');
            
            p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        if(p.trial.outcome.CurrOutcome == p.trial.outcome.Correct)
            p.trial.task.Timing.WaitTimer = GetSecs + p.trial.task.Timing.ITI;
            %ND_CtrlMsg(p, ['Correct: next trial in ', num2str(p.trial.task.Timing.ITI, '%.4f'), 'seconds.']);
            
            p.trial.CurrEpoch = p.trial.epoch.ITI;
            
        else
            p.trial.task.Timing.WaitTimer = GetSecs + p.trial.task.Timing.ITI + p.trial.task.Timing.TimeOut;
            %ND_CtrlMsg(p, ['Error: next trial in ', num2str(p.trial.task.Timing.ITI, '%.4f'), 'seconds.']);
            
            p.trial.CurrEpoch = p.trial.epoch.ITI;
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.ITI
        %% inter-trial interval: wait before next trial to start
        if(GetSecs > p.trial.task.Timing.WaitTimer)
            p.trial.flagNextTrial = 1;
        end
end % switch p.trial.CurrEpoch
