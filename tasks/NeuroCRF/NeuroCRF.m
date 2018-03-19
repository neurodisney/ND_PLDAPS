function p = NeuroCRF(p, state)
% Calculating receptive fields using reverse correlation of stimuli with spike data
% 
%
%
% Nate Faber, July/August 2017
% modified by wolf zinke, Mar 2018

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
    p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'Good',        'p.trial.task.Good',                   '%d');
        
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOn',   'p.trial.EV.FixOn',                    '%.5f');
    p = ND_AddAsciiEntry(p, 'FixSpotOff',  'p.trial.EV.FixOff',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'FixStart',    'p.trial.EV.FixSpotStart',             '%.5f');
    p = ND_AddAsciiEntry(p, 'FixBreak',    'p.trial.EV.FixSpotStop',              '%.5f');
    p = ND_AddAsciiEntry(p, 'FixPeriod',   'p.trial.task.FixPeriod',              '%.5f');
    p = ND_AddAsciiEntry(p, 'TaskEnd',     'p.trial.EV.TaskEnd',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.behavior.fixation.FixWin',    '%.5f');
    p = ND_AddAsciiEntry(p, 'InitRwd',     'p.trial.EV.FirstReward',              '%.5f');
    p = ND_AddAsciiEntry(p, 'Reward',      'p.trial.EV.Reward',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'RewardDur',   'p.trial.reward.Dur * ~isnan(p.trial.EV.Reward)',           '%.5f');
    p = ND_AddAsciiEntry(p, 'TotalRwd',    'sum(p.trial.reward.timeReward(:,2))', '%.5f');
    
    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');
    
    % --------------------------------------------------------------------%
    %% Create stimulus log file
    % initialize a simple ascii file that logs the information of the gratings shown for the RF mapping
    
    p.trial.stimtbl.file = fullfile(p.defaultParameters.session.dir, ...
                                   [p.defaultParameters.session.filestem,'_Stimuli.csv']);
    
    StimLstPtr = fopen(p.trial.stimtbl.file, 'w');
    fprintf(StimLstPtr, 'Trial,  GratingNr,  Onset,  TrialTime,  Xpos,  Ypos,  Radius,  Ori,  SpatFreq,  TempFreq,  Contrast\n');
    fclose(StimLstPtr);
    
    % --------------------------------------------------------------------%
    %% Set fixed grating parameters
    p.trial.stim.GRATING.res    = 300;
    p.trial.stim.GRATING.fixWin = 0;

    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.
    
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
            % TaskDraw(p);
            
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
    p.trial.task.Timing.ITI = ND_GetITI(p.trial.task.Timing.MinITI,  ...
                                        p.trial.task.Timing.MaxITI,  ...
                                        [], [], 1, 0.10);

    p.trial.CurrEpoch       = p.trial.epoch.ITI;

     p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix +  ...
                                        p.trial.task.CurRewDelay    + ...
                                        p.trial.task.Timing.jackpotTime); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

    % Outcome if no fixation occurs at all during the trial
    p.trial.outcome.CurrOutcome = p.trial.outcome.NoStart;

    p.trial.task.Good      = 0;
    p.trial.task.fixFix    = 0;
    p.trial.task.stimState = 0;

    p.trial.task.FixPeriod = NaN;

    % Reset the reward counter (separate from iReward to allow for manual rewards)
    p.trial.reward.count = 0;
    
    %% Generate visual stimuli

    % Fixation spot
    p.trial.stim.fix = pds.stim.FixSpot(p);

    % Gratings
    p.trial.stim.gratings = {};
    p.trial.stim.count    =  0;
    
    % how many gratings to allocate
    p.trial.stim.Nstim = ceil((1.5 * p.trial.task.Timing.jackpotTime) / (p.trial.stim.Period));      
    
    % create lists with parameters for each grating
    Ori_lst = ND_RandSample(p.trial.stim.ori,      p.trial.stim.Nstim);
    Rad_lst = ND_RandSample(p.trial.stim.radius,   p.trial.stim.Nstim);
    SFr_lst = ND_RandSample(p.trial.stim.sFreq,    p.trial.stim.Nstim);
    tFr_lst = ND_RandSample(p.trial.stim.tFreq,    p.trial.stim.Nstim);
    Ctr_lst = ND_RandSample(p.trial.stim.contrast, p.trial.stim.Nstim);
    
    for(s = 1:p.trial.stim.Nstim)
        p.trial.stim.GRATING.ori      = Ori_lst(s);
        p.trial.stim.GRATING.radius   = Rad_lst(s);
        p.trial.stim.GRATING.sFreq    = SFr_lst(s);
        p.trial.stim.GRATING.tFreq    = tFr_lst(s);
        p.trial.stim.GRATING.contrast = Ctr_lst(s);
        
        p.trial.stim.gratings{s} = pds.stim.Grating(p);
    end
 
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
            ND_FixSpot(p, 1);

            p.trial.EV.TaskStart = p.trial.CurTime;
            p.trial.EV.TaskStartTime = datestr(now, 'HH:MM:SS:FFF');
            
            ND_FixSpot(p, 1);
            
            ND_SwitchEpoch(p,'WaitFix');

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
            %% Fixation target shown, waiting for a sufficiently held gaze
            Task_WaitFixStart(p);
            
            if(p.trial.CurrEpoch == p.trial.epoch.Fixating)
                stim(p,1)                
                
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
                
            elseif(p.trial.CurrEpoch == p.trial.epoch.TaskEnd)
                p.trial.task.FixPeriod = p.trial.CurTime - p.trial.EV.FixStart;
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.Fixating
        %% Animal has reached fixation criteria and now starts receiving rewards for continued fixation

            % Still fixating
            if p.trial.stim.fix.fixating

                % While jackpot time has not yet been reached
                if(p.trial.CurTime < p.trial.stim.fix.EV.FixStart + p.trial.task.Timing.jackpotTime)

                    % ----------------------------------------------------------------%
                    % Wait for rewardPeriod to elapse since last reward, then give the next reward
                    if(p.trial.reward.GiveSeries == 1)
                        cstep = find(p.trial.reward.Step <= p.trial.reward.count, 1, 'last');

                        if(p.trial.CurTime > p.trial.Timer.lastReward + p.trial.reward.Period(cstep))                        
                        % Give the reward and update the lastReward time
                            pds.reward.give(p, p.trial.reward.Dur);
                            p.trial.Timer.lastReward = p.trial.CurTime;
                            p.trial.reward.count     = p.trial.reward.count + 1;
                        end
                    end

                    % ----------------------------------------------------------------%
                    if(p.trial.task.stimState)
                        % Keep stim on for stimOn Time
                        if(p.trial.CurTime > p.trial.EV.StimOn + p.trial.stim.OnTime - 0.75*p.trial.display.ifi/2)
                            stim(p, 0); % Turn stim off
                        end

                    elseif(~p.trial.task.stimState)
                        % Wait the stim off period before displaying the next stimuli
                        if(p.trial.CurTime > p.trial.EV.StimOff + p.trial.stim.OffTime - 0.75*p.trial.display.ifi)
                            if(p.trial.CurTime < p.trial.stim.fix.EV.FixStart    + ...
                                                 p.trial.task.Timing.jackpotTime - ...
                                                 p.trial.stim.OnTime)
                                stim(p, 1); % Turn stim on
                            end
                        end
                    end

                % ----------------------------------------------------------------%
                else
                    % Give JACKPOT!
                    pds.audio.playDP(p,'jackpot','left');
                    pds.reward.give(p, p.trial.reward.jackpotDur, p.trial.reward.jackpotnPulse);
                    p.trial.Timer.lastReward = p.trial.CurTime;

                    % Best outcome
                    p.trial.outcome.CurrOutcome = p.trial.outcome.Jackpot;

                    p.trial.task.FixPeriod = p.trial.CurTime - p.trial.EV.FixStart;

                    % Record main reward time
                    p.trial.EV.Reward = p.trial.CurTime;

                    % Turn off fixspot and stim
                    ND_FixSpot(p, 0);

                    ND_SwitchEpoch(p,'TaskEnd');
                end

            elseif ~p.trial.stim.fix.fixating
                % Fixation Break, end the trial
                p.trial.task.FixPeriod = p.trial.CurTime - p.trial.EV.FixStart;
                pds.audio.playDP(p,'breakfix','left');
                ND_SwitchEpoch(p,'TaskEnd')
                % Turn off fixspot and stim
                ND_FixSpot(p,0);
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
            %% finish trial and error handling
            stim(p, 0);   % Turn off stim

            % Run standard TaskEnd routine
            Task_OFF(p);

            % Grab the fixation stopping and starting values from the stim properties
            p.trial.EV.FixSpotStart = p.trial.stim.fix.EV.FixStart;
            p.trial.EV.FixSpotStop  = p.trial.stim.fix.EV.FixBreak;

            % Flag next trial ITI is done at begining
            p.trial.flagNextTrial = 1;

    end  % switch p.trial.CurrEpoch

% ####################################################################### %
% function TaskDraw(p)
%% Custom draw function for this experiment

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
%     if(~isempty(p.trial.LastKeyPress))
%         switch p.trial.LastKeyPress(1)
%         end
%     end

% ####################################################################### %
%% additional inline functions
% ####################################################################### %

function stim(p, val)
% Turn on/off or change the stim
    % Don't do anything if stim doesn't change
    if(val ~= p.trial.task.stimState)

        p.trial.task.stimState = val;

        % Turn on/off the appropriate generated stimuli
        % Only use the fixation window of the high contrast stimulus to avoid problems with overlapping fix windows
        switch val
            case 0
                % Turn off all stimuli (as a precaution)
                % for(g = 1:length(p.trial.stim.gratings))
                %     p.trial.stim.gratings{g}.on = 0;
                % end
                
                StimCnt = p.trial.stim.count;
                
                if(StimCnt > 0)
                    % turn off last shown grating
                    p.trial.stim.gratings{StimCnt}.on = 0;
                    ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');
                    
                    % log grating info, do it here when turning off to keep track of onset times
                    StimLstPtr = fopen(p.trial.stimtbl.file, 'a');

                    %                  Trial GratingNr  Onset  TrialTime  Xpos   Ypos  Radius  Ori  SpatFreq  TempFreq  Contrast
                    fprintf(StimLstPtr, '%d,  %d,       %.5f,  %.4f,      %.4f,  %.4f,  %.4f,  %.4f,  %.4f,   %.4f,     %.6f\n', ...
                           p.trial.pldaps.iTrial, StimCnt, p.trial.EV.StimOn, ...
                           p.trial.EV.StimOn - p.trial.stim.fix.EV.FixStart,  ...
                           p.trial.stim.locations(StimCnt, 1), p.trial.stim.locations(StimCnt, 2),       ...
                           p.trial.stim.gratings{ StimCnt}.radius, p.trial.stim.gratings{StimCnt}.angle, ...
                           p.trial.stim.gratings{ StimCnt}.sFreq, p.trial.stim.gratings{StimCnt}.tFreq,  ...
                           p.trial.stim.gratings{ StimCnt}.contrast);
                    
                    fclose(StimLstPtr);
                end
            case 1
                % Select the current stimulus
                p.trial.stim.count = p.trial.stim.count + 1;
                
                % Make the stimulus visible
                p.trial.stim.gratings{p.trial.stim.count}.on = 1;
                ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');

            otherwise
                error('bad stim value')
        end
    end


