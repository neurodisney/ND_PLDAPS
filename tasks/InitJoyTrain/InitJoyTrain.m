function p = InitJoyTrain(p, state)
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
% TODO: add accoustic feedback
%
% wolf zinke, Dec. 2016

% 7/25/2025 - Updating all scripts within InitJoyTrain folder for an adapted 
% joystick training timeline. Keeping older comments and notes and attempting 
% to just build on top for multiple condition interoperability.

% New structure (currently):
% 1) Trial start with joystick(JS) dot at center of screen. Animal needs to touch joystick
% to gain juice reward.
% 2) Animal has to push JS dot outside a radial distance from the center point. Radius
% starts small, and increases as the animal gains more successes. 
% 3) Animal has to hold dot position outside the set radius for a minimum time interval.
% 4) Directionality is introduced. Background stimulus is introduced that indicates a particular
% side of the screen the animal needs to send the JS dot to. First this is just bidirectional, 
% either left or side hemifield, then quadrant-level, then particular ROI (target circle on screen), 
% etc. 

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

    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.
    %ND_DefineCol(p, 'TargetOn',   30, [1.00, 1.00, 1.00]);
    %ND_DefineCol(p, 'TargetDimm', 31, [0.5, 0.5, 0.5]);

    % ND_DefineCol(p, 'TargetDimm', 30, [0.00, 1.00, 0.00]);
    % ND_DefineCol(p, 'TargetOn',   31, [1.00, 0.00, 0.00]);

    % --------------------------------------------------------------------%


else
% ####################################################################### %
%% Call standard routines before executing task related code
% This carries out standard routines, mainly in respect to hardware interfacing.
% Be aware that this is done first for each trial state!
    p = ND_GeneralTrialRoutines(p, state);
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
            
            %TaskDraw(p) % 7/31/2025 - MJH - Appears deprecated according to new task structure.
                        
% ####################################################################### %
% DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
            
            Task_Finish(p);
                        
            Trial2Ascii(p, 'save');
                        CheckBar
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
    
    p.trial.reward.count = 0; % set initial reward 8/1/2025 - MJH - Matching to InitFixTrain.
    
    %p.trial.reward.Curr = ND_GetRewDur(p); % 8/6/25 - MJH - reward dur handled in "_taskdef" now. %determine reward amount based on number of previous correct trials
    
    ND_SwitchEpoch(p, 'GetReady');  % define first task epoch % 8/1/25 - MJH - copied from FixTrain, but GetReady seems to be the epoch to kick things off for joystick.
    %ND_SwitchEpoch(p, 'GoMichael') % Debug idea John came up with lol see how it switches.
% ------------------------------------------------------------------------%
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
    switch p.trial.CurrEpoch
        % ----------------------------------------------------------------%
        case p.trial.epoch.GetReady
        %% before the trial can start joystick needs to be in a released state
            if(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
                p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.MinRel;
                %p.trial.CurrEpoch = p.trial.epoch.CheckBarRel; % MJH - not how the new task structure works
                ND_SwitchEpoch(p,'CheckBarRel') % MJH updated
            end
            
            
            
        %case p.trial.epoch.GoMichael
        %    disp('you rock');

        case p.trial.epoch.CheckBarRel
        %% make sure that the bar is fully release by waiting for a specified time    
            if(p.trial.JoyState.Current == p.trial.JoyState.JoyHold)
            % pressed again to quickly
                Task_NotReady(p);  % Go directly to TaskEnd, do not start task, do not collect reward
            elseif(p.trial.CurTime > p.trial.Timer.Wait)
            % joystick in a properly released state, let's start the trial
                Task_Ready(p); 
                %p.trial.CurrEpoch = p.defaultParameters.epoch.WaitStart; % 8/1/2025 - MJH - Added here since it doesn't seem like things switch? not sure...
                ND_SwitchEpoch(p,'WaitStart'); % MJH - another version of the above...still not sure.
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitStart
        %% Wait for joystick press
            %ND_SwitchEpoch(p,'WaitPress'); %MJH - Added but trying to figure out. Waitpress and WaitStart appear redundant. In either case, begin waiting for press...
            if(p.trial.CurTime > p.trial.Timer.Wait)
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
                        p.trial.Timer.Wait = p.trial.CurTime + p.trial.task.Timing.HoldTime;
                        %p.trial.CurrEpoch = p.trial.epoch.WaitGo; 8/4/2025 - MJH - Deprecated per new task structure
                        ND_SwitchEpoch(p,'WaitGo')%Trying to emulate the above w/ the new function. 
                        if(p.trial.reward.Pull)
                            pds.reward.give(p, p.trial.reward.PullRew);
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
            elseif(p.trial.CurTime > p.trial.Timer.Wait)
                Task_GoCue(p);
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitResponse
        %% Wait for joystick release
            if(p.trial.CurTime > p.trial.Timer.Wait)
                Response_Miss(p);  % Go directly to TaskEnd, do not continue task, do not collect reward
            elseif(p.trial.JoyState.Current == p.trial.JoyState.JoyRest)
                Response_JoyRelease(p);
                p.trial.EV.RespRT = p.trial.EV.JoyRelease - p.trial.EV.GoCue;
                
                if(p.trial.EV.RespRT <  p.trial.task.Timing.minRT)
                % premature response - too early to be a true response
                     Response_Early(p); % Go directly to TaskEnd, do not continue task, do not collect reward
                else
                % correct response
                    %Task_Correct(p); % 8/6/25 - MJH - Task_Correct appears not used now. It included an epoch switch to "WaitReward" which itself called to a "Task_Reward" function. New "Task_CorrectReward" seems to just invoke pds.reward.give directly. Reward dur is also specified in the "_taskdef" script and is used by the new Task_CorrectReward.
                    Task_CorrectReward(p)
                end
            end

        % ----------------------------------------------------------------%
        
        %case p.trial.epoch.WaitReward  %8/6/2025 - MJH - This epoch may not be needed now.
        %% Wait for for reward
        % add error condition for new press
            %Task_Reward(p);

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitRelease
        %% Wait for joystick release after missed response    FalseStart
            Task_WaitRelease(p);

        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        % set timer for intertrial interval
            Task_OFF(p);

        % ----------------------------------------------------------------%
        case p.trial.epoch.ITI
        %% inter-trial interval: wait before next trial to start
            Task_WaitITI(p);
            
    end  % switch p.trial.CurrEpoch

% ------------------------------------------------------------------------%
% function TaskDraw(p)
%% show epoch dependent stimuli

% 7/31/2025 - MJH - these appear to be deprecated according to the new task structure. 

% go through the task epochs as defined in TaskDesign and draw the stimulus
% content that needs to be shown during this epoch.
%     switch p.trial.CurrEpoch
%         % ----------------------------------------------------------------%
%         case p.trial.epoch.WaitStart
%         %% Wait for joystick press
%             TrialOn(p);
% 
%         % ----------------------------------------------------------------%
%         case p.trial.epoch.WaitGo
%         %% delay before response is needed
%             TrialOn(p);
%             Target(p, 'TargetOn');
% 
%         % ----------------------------------------------------------------%
%         case p.trial.epoch.WaitResponse
%         %% Wait for joystick release
%             TrialOn(p);
%             Target(p, 'TargetDimm');
% 
%         % ----------------------------------------------------------------%
%         case p.trial.epoch.WaitReward
%         %% Wait for for reward
%             TrialOn(p);
%             Target(p, 'TargetDimm');
%     end



% ####################################################################### %
%% additional inline functions that
% 7/31/2025 - MJH - The two functions below here appears to be deprecated per the new task structure.
% ------------------------------------------------------------------------%
% function TrialOn(p)
% %% show a frame to indicate the trial is active
%     Screen('FrameRect', p.trial.display.overlayptr, p.trial.display.clut.TrialStart, ...
%                         p.trial.task.FrameRect , p.trial.task.FrameWdth);
% 
% % ------------------------------------------------------------------------%
% function Target(p, colstate)
% %% show the target item with the given color
%     Screen('FillOval',  p.trial.display.overlayptr, p.trial.display.clut.(colstate), p.trial.task.TargetRect);
%%
% ------------------------------------------------------------------------%
% function Trial2Ascii(p, act)
% %% Save trial progress in an ASCII table
% % 'init' creates the file with a header defining all columns
% % 'save' adds a line with the information for the current trial
% %
% % make sure that number of header names is the same as the number of entries
% % to write, also that the position matches.
% 
%     switch act
%         case 'init'
%             tblptr = fopen(p.trial.session.asciitbl , 'w');
% 
%             fprintf(tblptr, ['Date  Time  Secs  Subject  Experiment  Tcnt  Cond  Tstart  JPress  GoCue  JRelease  Reward  RewDur  ',...
%                              'Result  Outcome  StartRT  RT  ChangeTime \n']);
%             fclose(tblptr);
% 
%         case 'save'
%             if(p.trial.pldaps.quit == 0 && p.trial.outcome.CurrOutcome ~= p.trial.outcome.NoStart && ...
%                p.trial.outcome.CurrOutcome ~= p.trial.outcome.PrematStart)  % we might loose the last trial when pressing esc.
%                 
%                 if(p.trial.outcome.CurrOutcome == p.trial.outcome.Correct || ...
%                    p.trial.outcome.CurrOutcome == p.trial.outcome.Early)
%                     RT = p.trial.EV.JoyRelease - p.trial.task.Timing.HoldTime;
%                 else
%                     RT = NaN;
%                 end
%                 
%                 trltm = p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart;
% 
%                 cOutCome = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};
% 
%                 tblptr = fopen(p.trial.session.asciitbl, 'a');
% 
%                 fprintf(tblptr, '%s  %s  %.4f  %s  %s  %d  %d  %.5f %.5f  %.5f  %.5f  %.5f  %.5f  %d  %s  %.5f  %.5f  %.5f\n' , ...
%                                 datestr(p.trial.session.initTime,'yyyy_mm_dd'), p.trial.EV.TaskStartTime, ...
%                                 p.trial.EV.TaskStart, p.trial.session.subject, ...
%                                 p.trial.session.experimentSetupFile, p.trial.pldaps.iTrial, p.trial.Nr, ...
%                                 trltm, p.trial.EV.JoyPress, ...
%                                 p.trial.EV.GoCue, p.trial.EV.JoyRelease, p.trial.EV.Reward, ...
%                                 p.trial.reward.Curr, p.trial.outcome.CurrOutcome, cOutCome, ...
%                                 p.trial.EV.StartRT, RT, p.trial.task.Timing.HoldTime);
%                fclose(tblptr);
%             end
%     end
