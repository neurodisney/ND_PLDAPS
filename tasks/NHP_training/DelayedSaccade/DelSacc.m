function p = DelSacc(p, state)
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
    % c.task.fixLatency       -  time to hold fixation before it counts
    % c.reward.initialFixRwd  -  Reward for fixating long enough (before stim appears). Set to 0 for harder difficulty
    % c.task.stimLatency      -  Time from initialFixRwd to the stim appearing (if no reward this is ignored).
    % c.reward.stimRwdLatency -  Time from onset of stim to first reward
    
    % c.reward.nRewards       -  array that defines the reward schema with Dur and Period
    % c.reward.Dur            -  array of how long each kind of reward lasts
    % c.reward.Period         -  the period between one reward and the next NEEDS TO BE GREATER THAN Dur
    
    % c.task.centerOffLatency -  Time from stim appearing to when the central fix spot disappears
    % c.reward.jackpotDur     -  the jackpot is given after all other rewards
    % c.task.saccadeTimeout   -  time to make the saccade before stim disappears
    
    % c.stim.lowContrast      -  contrast value when stim.on = 1
    % c.stim.highContrast     -  contrast value when stim.on = 2
    % c.stim.tFreq            -  drift speed, 0 is stationary
    
    
    % condition 1
    c1.Nr = 1;
    c1.task.fixLatency       = 0.75; % Time to hold fixation before it counts
    c1.reward.initialFixRwd  = 0.06;
    c1.task.stimLatency      = 0.35;
    c1.reward.stimRwdLatency = 0.25;
    
    c1.reward.nRewards       = [1    100];
    c1.reward.Dur            = [0.1  0.1];
    c1.reward.Period         = [1    1  ];
    
    c1.task.centerOffLatency = 5;
    c1.reward.jackpotDur     = 0.5;
    c1.task.saccadeTimeout        = 2;
    
    c1.stim.lowContrast      = 0.3;
    c1.stim.highContrast     = 1;
    c1.stim.tFreq            = 1;
    
    c1.nTrials = 100;
    
    
    % Fill a conditions list with n of each kind of condition sequentially
    conditions = cell(1,5000);
    blocks = nan(1,5000);
    totalTrials = 0;
    
    % Iterate through each condition to fill conditions
    conditionsIterator = {c1};
    
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


p.trial.CurrEpoch        = p.trial.epoch.TrialStart;

% Reference distance to check if a wrong saccade is made
p.trial.behavior.fixation.refDist = NaN;

% Outcome if no fixation occurs at all during the trial
p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;

p.trial.task.Good                = 0;
p.trial.behavior.fixation.GotFix = 0;

pds.fixation.move(p);

p.trial.behavior.fixation.FixCol = p.trial.task.Color_list{mod(p.trial.blocks(p.trial.pldaps.iTrial), length(p.trial.task.Color_list))+1};


%% Reward
nRewards = p.trial.reward.nRewards;
% Reset the reward counter (separate from iReward to allow for manual rewards)
p.trial.reward.count = 0;
% Create arrays for direct reference during reward
p.trial.reward.allDurs = repelem(p.trial.reward.Dur,nRewards);
p.trial.reward.allPeriods = repelem(p.trial.reward.Period,nRewards);
% Calculate the jackpot time
p.trial.reward.jackpotTime = sum(p.trial.reward.allPeriods);

% Fixation spot
p.trial.behavior.fixation.fixPos = [0,0];
p.trial.behavior.fixation.FixType = 'disc';
pds.fixation.move(p)

%% Stimulus parameters
% Generate the stimulus
p.trial.stim.grating1 = pds.stim.Grating(p,p.trial.stim.radius);

% Calculate the location of the stim
direction = p.trial.stim.locations{randi(length(p.trial.stim.locations))};
magnitude = p.trial.stim.eccentricity;
p.trial.stim.pos = magnitude * direction / norm(direction);
p.trial.stim.grating1.pos = p.trial.stim.pos;

% Stimulus angle
p.trial.stim.angle = datasample(p.trial.stim.orientations,1);
p.trial.stim.grating1.angle = p.trial.stim.angle;

% Other stim properties
p.trial.stim.grating1.tFreq = p.trial.stim.tFreq;
p.trial.stim.grating1.sFreq = p.trial.stim.sFreq;

% stim starts off
p.trial.stim.on = 0;   % 0 is off, 1 is low contrast, 2 is high contrast
% ####################################################################### %
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
switch p.trial.CurrEpoch
    
    case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot
        p.trial.behavior.fixation.on = 1;
        
        tms = pds.datapixx.strobe(p.trial.event.TASK_ON);
        p.trial.EV.DPX_TaskOn = tms(1);
        p.trial.EV.TDT_TaskOn = tms(2);
        
        p.trial.EV.TaskStart = p.trial.CurTime;
        p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
        
        if(p.trial.datapixx.TTL_trialOn)
            pds.datapixx.TTL_state(p.trial.datapixx.TTL_trialOnChan, 1);
        end

        p.trial.CurrEpoch  = p.trial.epoch.WaitFix;
        p.trial.EV.epochEnd = p.trial.CurTime;
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.WaitFix
        %% Fixation target shown, waiting for a sufficiently held gaze
        
        % Gaze is outside fixation window
        if p.trial.behavior.fixation.GotFix == 0
            
            % Fixation has occured
            if p.trial.FixState.Current == p.trial.FixState.FixIn
                p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak; %Will become FullFixation upon holding long enough
                p.trial.behavior.fixation.GotFix = 1;
                p.trial.Timer.fixStart = p.trial.CurTime;
                
                % Time to fixate has expired
            elseif p.trial.CurTime > p.trial.EV.TaskStart + p.trial.task.Timing.WaitFix
                
                % Long enough fixation did not occur, failed trial
                p.trial.task.Good = 0;
                
                % Go directly to TaskEnd, do not start task, do not collect reward
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                p.trial.EV.epochEnd = p.trial.CurTime;
                p.trial.behavior.fixation.on = 0;
                
            end
            
            
            % If gaze is inside fixation window
        elseif p.trial.behavior.fixation.GotFix == 1
            
            % Fixation ceases
            if p.trial.FixState.Current == p.trial.FixState.FixOut
                
                p.trial.EV.FixBreak = p.trial.CurTime;
                p.trial.behavior.fixation.GotFix = 0;
                
                % Fixation has been held for long enough && not currently in the middle of breaking fixation
            elseif (p.trial.CurTime > p.trial.Timer.fixStart + p.trial.task.fixLatency) && p.trial.FixState.Current == p.trial.FixState.FixIn
                
                p.trial.outcome.CurrOutcome = p.trial.outcome.FullFixation;
                
                % Record when the monkey started fixating
                p.trial.EV.FixStart = p.trial.Timer.fixStart;
                
                % Reward the monkey if there is initial reward for this trial
                if p.trial.reward.initialFixRwd > 0
                    pds.reward.give(p, p.trial.reward.initialFixRwd);
                    p.trial.Timer.lastReward = p.trial.CurTime;
                    
                else
                    % Start showing the stim next frame
                    p.trial.stim.on = 1;
                    p.trial.EV.StimOn = p.trial.CurTime;
                    pds.datapixx.strobe(p.trial.event.STIM_ON);
                end
                
                % Transition to the succesful fixation epoch
                p.trial.CurrEpoch = p.trial.epoch.Fixating;
                p.trial.EV.epochEnd = p.trial.CurTime;
                
            end
            
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.Fixating
        %% Animal has reached fixation criteria and now starts receiving rewards for continued fixation
        
        % Still fixating
        if p.trial.FixState.Current == p.trial.FixState.FixIn
            
            % If stim is off (because an initial reward was given), wait stim latency before showing reward
            if ~p.trial.stim.on
                if p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.stimLatency
                    p.trial.stim.on = 1;
                    pds.datapixx.strobe(p.trial.event.STIM_ON);
                    p.trial.EV.StimOn = p.trial.CurTime;
                    p.trial.Timer.nextReward = p.trial.CurTime + p.trial.reward.stimRwdLatency;
                end
                
                
            else
                
                % Give rewards if fixation is maintained (inhibit saccade to stim)
                if p.trial.CurTime < p.trial.EV.StimOn + p.trial.task.centerOffLatency
                    
                    % If the supplied reward schema doesn't cover the fixspot turns off, just reuse the last one
                    rewardCount = min(p.trial.reward.count , length(p.trial.reward.allDurs));
                    
                    if rewardCount == 0
                        p.trial.Timer.nextReward = p.trial.EV.epochEnd + p.trial.reward.stimRwdLatency;
                    end
                    
                    % Wait for rewardPeriod to elapse since last reward, then give the next reward
                    if p.trial.CurTime > p.trial.Timer.nextReward

                        rewardCount = min(rewardCount + 1 , length(p.trial.reward.allDurs));
                        p.trial.reward.count = p.trial.reward.count + 1;
                        
                        % Get the reward duration
                        rewardDuration = p.trial.reward.allDurs(rewardCount);
                        

                        % Give the reward and update the lastReward time
                        pds.reward.give(p, rewardDuration);
                        p.trial.Timer.lastReward = p.trial.CurTime;
                        
                        % Set a timer for the next reward
                        p.trial.Timer.nextReward = p.trial.CurTime + p.trial.reward.allPeriods(rewardCount);
                    end
                    
                else
                    % Saccade has been inhibited long enough. Make the central fix spot disappear
                    p.trial.behavior.fixation.fixPos = p.trial.stim.pos;
                    p.trial.behavior.fixation.FixType = 'off';
                    pds.fixation.move(p);
                    p.trial.EV.FixOff = p.trial.CurTime;
                    pds.datapixx.strobe(p.trial.event.FIXSPOT_OFF);
                    
                    % Make the stim high contrast
                    p.trial.stim.on = 2;
                    
                    % Change to the saccade epoch
                    p.trial.CurrEpoch = p.trial.epoch.Saccade;
                    p.trial.EV.epochEnd = p.trial.CurTime;
                    
                    % Record the current distance of the eye away from the stim as a reference
                    p.trial.behavior.fixation.refDist = sqrt(sum((p.trial.stim.pos - [p.trial.eyeX p.trial.eyeY]) .^ 2));
                    
                end
            
            end
            
            % Fixation Break, end the trial
        elseif p.trial.FixState.Current == p.trial.FixState.FixOut
            pds.audio.playDP(p,'breakfix','left');
            
            % Turn of fixspot and stim
            p.trial.behavior.fixation.on = 0;
            p.trial.stim.on = 0;
            
            p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
            p.trial.EV.epochEnd = p.trial.CurTime;
            
        end
        
        % ----------------------------------------------------------------%
    case p.trial.epoch.Saccade
        %% Central fixation spot has disappeared. Animal must quickly saccade to stim to get the main reward
        
        if ~p.trial.task.Good
            % Not yet succeeded in task
        
            if p.trial.FixState.Current == p.trial.FixState.FixIn
                % Animal has saccaded to stim, give jackpot and mark trial good
                pds.reward.give(p, p.trial.reward.jackpotDur);
                p.trial.outcome.CurrOutcome = p.trial.outcome.Jackpot;
                p.trial.task.Good = 1;
                p.trial.Timer.taskEnd = p.trial.CurTime + p.trial.reward.jackpotDur + 0.1;
                
                
            else
                % Animal has not yet saccaded to target
                % Need to check if no saccade has been made or if a wrong saccade has been made
                
                % If no saccade has been made before the time runs out, end the trial
                if p.trial.CurTime > p.trial.EV.FixOff + p.trial.task.saccadeTimeout
                    % Turn the stim off and fixation off
                    p.trial.stim.on = 0;
                    p.trial.behavior.fixation.on = 0;
                    
                    % Play an incorrect sound
                    pds.audio.playDP(p,'incorrect','left');
                    
                    p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                    p.trial.EV.epochEnd = p.trial.CurTime;                   
                end
                
                % If the distance from the stim increases, a wrong saccade has been made
                if p.trial.eyeAmp > p.trial.behavior.fixation.refDist + p.trial.behavior.fixation.distInc
                    % Turn the stim off and fixation off
                    p.trial.stim.on = 0;
                    p.trial.behavior.fixation.on = 0;
                    
                    % Play an incorrect sound
                    pds.audio.playDP(p,'incorrect','left');
                    
                    p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                    p.trial.EV.epochEnd = p.trial.CurTime; 
                      
                end

                
            end    
        
        else
            % Correctly saccaded, continue to show stim until jackpot reward ends
            if p.trial.CurTime > p.trial.Timer.taskEnd
                p.trial.stim.on = 0;
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                p.trial.EV.epochEnd = p.trial.CurTime;
                pds.datapixx.strobe(p.trial.event.STIM_OFF);
            end
            
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
        p.trial.EV.epochEnd = p.trial.CurTime;
        
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

if p.trial.behavior.fixation.on
    pds.fixation.draw(p);
end

if p.trial.stim.on == 1
    p.trial.stim.grating1.contrast = p.trial.stim.lowContrast;
    draw(p.trial.stim.grating1,p);
elseif p.trial.stim.on == 2
    p.trial.stim.grating1.contrast = p.trial.stim.highContrast;
    draw(p.trial.stim.grating1,p);
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
                p.trial.task.fixLatency, p.trial.reward.count, p.trial.outcome.CurrOutcome, cOutCome, ...
                p.trial.EV.FixBreak-p.trial.EV.FixStart, p.trial.behavior.fixation.FixCol, p.trial.task.Timing.ITI, ...
                p.trial.behavior.fixation.FixWin, p.trial.behavior.fixation.fixPos(1), p.trial.behavior.fixation.fixPos(2));
            fclose(tblptr);
        end
end

