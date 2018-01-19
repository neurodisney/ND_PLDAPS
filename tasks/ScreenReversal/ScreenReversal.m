function p = ScreenReversal(p, state)
% Main trial function for fixation calibration.
%
%
%
% wolf zinke, Dec. 2017

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
    % call this after ND_InitSession to be sure that output directory exists!
    p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%s');
    p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Tstart',      'p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart',   '%d');
    p = ND_AddAsciiEntry(p, 'FixRT',       'p.trial.EV.FixStart-p.trial.EV.TaskStart',                     '%d');
    p = ND_AddAsciiEntry(p, 'FirstReward', 'p.trial.task.CurRewDelay',            '%d');
    p = ND_AddAsciiEntry(p, 'RewCnt',      'p.trial.reward.count',                '%d');

    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');

    p = ND_AddAsciiEntry(p, 'FixPeriod',   'p.trial.EV.FixBreak-p.trial.EV.FixStart', '%.5f');
    p = ND_AddAsciiEntry(p, 'FixColor',    'p.trial.stim.FIXSPOT.color',          '%s');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.stim.fix.fixWin',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_X',    'p.trial.stim.fix.pos(1)',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_Y',    'p.trial.stim.fix.pos(2)',             '.%5f');

    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');

    % basic fixation spot parameters
    p.defaultParameters.behavior.fixation.FixGridStp = [4, 4]; % x,y coordinates in a 9pt grid
    p.defaultParameters.behavior.fixation.FixWinStp  = 1;      % change of the size of the fixation window upon key press
    p.defaultParameters.behavior.fixation.FixSPotStp = 0.25;
    p.defaultParameters.stim.FIXSPOT.fixWin          = 4;

    % just initialize here, will be overwritten by conditions
    p.defaultParameters.reward.MinWaitInitial = 0.05;
    p.defaultParameters.reward.MaxWaitInitial = 0.1;

    % p.defaultParameters.task.ContrastList = [0, 2, 4, 8, 16, 32, 64, 100];
    p.defaultParameters.task.MeanBck = p.defaultParameters.display.bgColor(1);  % set background color to mean luminance

    p.defaultParameters.FixTask = 0;

%-------------------------------------------------------------------------%
%% eye calibration
    if(~p.defaultParameters.behavior.fixation.useCalibration)
        p = pds.eyecalib.setup(p);
    end

    p.defaultParameters.task.RandomPos = 0;
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
            DrugCheck(p);
            EyeCheck(p);

        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameDraw
        %% Display stuff on the screen
        % Just call graphic routines, avoid any computations
        TaskDraw(p)

    end  %/ switch state
end  %/  if(nargin == 1) [...] else [...]

% ------------------------------------------------------------------------%
%% Task related functions

% ####################################################################### %
function TaskSetUp(p)
%% main task outline
% Determine everything here that can be specified/calculated before the actual trial start

     % p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix +  p.trial.task.CurRewDelay + p.trial.reward.jackpotTime); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

    ND_SwitchEpoch(p, 'ITI');  % define first task epoch

    p.trial.task.TrialCount    = 0;
    p.trial.task.FlashCount    = 0;
    p.trial.task.DrugCount     = 0;
    p.trial.task.DrugGiven     = 0;
    p.trial.task.LastDrugFlash = 0;
    p.trial.stim.LumeDir       = 0;
    p.trial.task.EyeOnScreen   = 0;

    p.trial.task.NextModulation = p.trial.CurTime + p.trial.task.WaitModulation;
    p.trial.task.T0mod = p.trial.task.NextModulation;
    p.trial.task.CurrCont   = 0;
    p.trial.task.PassedPeak = 0;

% ####################################################################### %
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
    switch p.trial.CurrEpoch

        case p.trial.epoch.ITI
        %% inter-trial interval: wait until sufficient time has passed from the last trial
            if(p.trial.FixTask == 1)
                Task_WaitITI(p);
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot
            % set up current trial
            p.trial.task.TrialCount = p.trial.task.TrialCount + 1;

            p.trial.task.Timing.ITI = ND_GetITI(p.trial.task.Timing.MinITI, ...
                                                p.trial.task.Timing.MaxITI, [], [], 1, 0.10);

            % Reset the reward counter (separate from iReward to allow for manual rewards)
            p.trial.reward.count = 0;

            % Outcome if no fixation occurs at all during the trial
            p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;
            p.trial.task.Good = 0;

            % State for achieving fixation
            p.trial.task.fixFix = 0;

            %% Make the visual stimuli
            % Fixation spot
            p.trial.stim.fix = pds.stim.FixSpot(p);

            % now actually start the trial
            Task_ON(p);
            ND_FixSpot(p, 1);

            p.trial.EV.TaskStart     = p.trial.CurTime;
            p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');

            ND_SwitchEpoch(p,'WaitFix');

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
        %% Fixation target shown, waiting for a sufficiently held gaze

            Task_WaitFixStart(p);

            if(p.trial.CurrEpoch == p.trial.epoch.Fixating)
            % fixation just started, initialize fixation epoch
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
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.Fixating
        %% Animal has reached fixation criteria and now starts receiving rewards for continued fixation

        % Still fixating
        if(p.trial.stim.fix.fixating)
            % While jackpot time has not yet been reached
            if(p.trial.CurTime < p.trial.EV.FixStart + p.trial.reward.jackpotTime)

                % Wait for rewardPeriod to elapse since last reward, then give the next reward
                if(p.trial.reward.GiveSeries==1)
                    cstep = find(p.trial.reward.Step <= p.trial.reward.count, 1, 'last');

                    if(p.trial.CurTime > p.trial.Timer.lastReward + p.trial.reward.Period(cstep))
                        % Give the reward and update the lastReward time
                        pds.reward.give(p, p.trial.reward.Dur);
                        p.trial.Timer.lastReward = p.trial.CurTime;
                        p.trial.reward.count     = p.trial.reward.count + 1;
                    end
                end
            else
                % Give JACKPOT!
                pds.reward.give(p, p.trial.reward.jackpotDur);
                p.trial.Timer.lastReward = p.trial.CurTime;

                % Best outcome
                p.trial.outcome.CurrOutcome = p.trial.outcome.Jackpot;

                % End the task
                ND_SwitchEpoch(p, 'TaskEnd');

                % Play jackpot sound
                pds.audio.playDP(p, 'jackpot','left');
            end

        % Fixation Break, end the trial
        elseif(~p.trial.stim.fix.fixating)
            pds.audio.playDP(p,'breakfix','left');

            ND_SwitchEpoch(p,'TaskEnd');
        end  %  if(p.trial.stim.fix.fixating)

        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling

            % Turn off fixation spot
            ND_FixSpot(p, 0);
            Task_OFF(p);

            % Get the text name of the outcome
            p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

            % Save useful info to an ascii table for plotting
            ND_Trial2Ascii(p, 'save');

            p.trial.EV.PlanStart = p.trial.CurTime + p.trial.task.Timing.ITI;

            ND_SwitchEpoch(p,'ITI');

    end  % switch p.trial.CurrEpoch

% ####################################################################### %
function EyeCheck(p)
%% check if gaze is on screen
        dist = sqrt( p.trial.eyeX^2 + p.trial.eyeY^2 );

        if(dist < p.trial.task.ScreenFixWin && p.trial.task.EyeOnScreen == 0)
        % Eyes start being on screen
            p.trial.task.EyeOnScreen = 1;
            pds.datapixx.strobe(p.trial.event.FIX_IN);

        elseif(dist > p.trial.task.ScreenFixWin && p.trial.task.EyeOnScreen == 1)
        % Eyes left screen area
            p.trial.task.EyeOnScreen = 0;
            pds.datapixx.strobe(p.trial.event.FIX_OUT);
        end

% ####################################################################### %
function DrugCheck(p)
%% check if it is time to trigger adrug stimulation
    if(p.trial.Drug.Give == 1)
        if(p.trial.task.LastDrugFlash > p.trial.Drug.FlashSeriesLength)
            if(p.trial.task.DrugGiven == 0)
                if(p.trial.CurTime > p.trial.task.NextModulation + p.trial.Drug.PeriFlashTime)
                    ND_PulseSeries(p.trial.datapixx.TTL_spritzerChan,      ...
                                   p.trial.datapixx.TTL_spritzerDur,       ...
                                   p.trial.datapixx.TTL_spritzerNpulse,    ...
                                   p.trial.datapixx.TTL_spritzerPulseGap,  ...
                                   p.trial.datapixx.TTL_spritzerNseries,   ...
                                   p.trial.datapixx.TTL_spritzerSeriesGap, ...
                                   p.trial.event.INJECT);

                    p.trial.task.LastDrugFlash = 0;
                    p.trial.task.DrugCount     = p.trial.task.DrugCount + 1;
                    p.trial.task.DrugGiven     = 1;
                end
            end
        else
            p.trial.task.DrugGiven = 0;
        end
    end

% ####################################################################### %
function TaskDraw(p)
%% show epoch dependent stimuli
    % Fill complete screen with current luminance value
    if(p.trial.task.DoFlash == 1)
        if(p.trial.CurTime >= p.trial.task.NextModulation - 0.75*p.trial.display.ifi)

            if(p.trial.stim.LumeDir ~= 0) % stimulus is on
                ccol = [p.trial.task.MeanBck, p.trial.task.MeanBck, p.trial.task.MeanBck];

                ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');
                p.trial.task.NextModulation = p.trial.task.NextModulation + p.trial.task.LOperiod;
                p.trial.stim.LumeDir = 0;

            else % stimulus is off

                % Randomly define if positive or negative contrast
                if(randi([0 1],1) == 1) % brighter screen
                    p.trial.stim.LumeDir =  1;
                else
                    p.trial.stim.LumeDir = -1;
                end

                % get current contrast and strobe value
                p.trial.task.CurrCont = datasample(p.trial.task.ContrastList, 1);

                ccol = ccont/100 * p.trial.task.MeanBck;

                if(ccol > p.trial.task.MeanBck)
                   warning('Current contrast exceeds 0 to 1 range!');
                   ccol = 1;
                end

                ccol = ccol * p.trial.stim.LumeDir;

                pds.datapixx.strobe(15000+(ccont* p.trial.stim.LumeDir)); % encode current contrast
                ccol = cBck + ccol;

                ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');
                p.trial.task.NextModulation = p.trial.task.NextModulation + p.trial.task.HIperiod;
            end

            % keep track of flash numbers
            p.trial.task.FlashCount    = p.trial.task.FlashCount    + 1;
            p.trial.task.LastDrugFlash = p.trial.task.LastDrugFlash + 1;

            p.trial.display.bgColor    = ccol;
            p.trial.pldaps.lastBgColor = ccol;
        end
    else
        % get the current time point in the modulation period
        Cprd = 2*pi * (p.trial.CurTime - p.trial.task.T0mod) / p.trial.task.ModPeriod;

        switch p.trial.task.ModType
            case 'sin'
                ccol = sin(Cprd);

            case 'square'
                ccol = square(Cprd);

            otherwise
                error('Wrong method %s for screen luminance modulation', p.trial.task.ModType);
        end

        % detect transition between Hi/Lo
        if(ccol >= 0 && p.trial.stim.LumeDir ~=  1) % going to Hi
            % keep track of flash numbers
            p.trial.task.FlashCount    = p.trial.task.FlashCount    + 1;
            p.trial.task.LastDrugFlash = p.trial.task.LastDrugFlash + 1;

            p.trial.stim.LumeDir =  1;
            ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');

            if(p.trial.task.RandContSeries == 1)
                p.trial.task.CurrCont = datasample(p.trial.task.ContrastList, 1);
            else
                CtrP = mod(p.trial.task.FlashCount, length(p.trial.task.ContrastList));
                p.trial.task.CurrCont = p.trial.task.CurrCont(CtrP + 1);
            end

            pds.datapixx.strobe(15000 + p.trial.task.CurrCont); % encode current positive contrast

        elseif(ccol <= 0 && p.trial.stim.LumeDir ~= -1) % going to Lo
            p.trial.stim.LumeDir = -1;
            ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');
            p.trial.task.CurrCont = datasample(p.trial.task.ContrastList, 1);

            pds.datapixx.strobe(15000 - p.trial.task.CurrCont); % encode current negative contrast

       end

        p.trial.display.bgColor    = p.trial.task.MeanBck + p.trial.task.CurrCont/100 * ccol * p.trial.task.MeanBck;
        p.trial.pldaps.lastBgColor = p.trial.display.bgColor;

    end  %\ if(p.trial.task.DoFlash == 1)

    % Fill screen
    Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor, p.trial.display.winRect);


% ####################################################################### %
function KeyAction(p)
%% task specific action upon key press
if(~isempty(p.trial.LastKeyPress))

    switch p.trial.LastKeyPress(1)
        case KbName('f') % Turn fixation position on and off
            p.trial.FixTask = ~p.trial.FixTask;

        % reload task definition
        case KbName('BackSpace')

            if(isfield(p.trial.task, 'TaskDef'))
                if(~isempty(p.trial.task.TaskDef))
                    clear(p.trial.task.TaskDef); % make sure content gets updated
                    p = feval(p.trial.task.TaskDef,  p);
                end
                ND_CtrlMsg(p, 'Reloaded task definition file.');
            end
     end
end

% ####################################################################### %
%% additional inline functions
% ####################################################################### %


