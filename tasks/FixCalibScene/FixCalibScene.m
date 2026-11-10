function p = FixCalibScene(p, state)
% Eye calibration task with image presentation.
%
% Each trial: fixation spot -> animal holds fixation for an adjustable
% time (reward pulses as in InitFixTrain; calibration points can be added
% with the usual calibration keys) -> fixation spot off, image on for
% exactly IMAGE.duration -> trial ends Correct.
% Breaking fixation before the image ends the trial (FixBreak, no image).
% Gaze during the image does not matter.
%
% Calibration is handled by the same shared routines as InitFixTrain
% (pds.eyecalib.*), so calibration files are named and saved the same way,
% in the same folder.
%
% Built from InitFixTrain.m (wolf zinke, Nate Faber) and ViewScene.m
% (John Amodeo), Nov 2026.

if(~exist('state', 'var'))
    state = [];
end

% ####################################################################### %
%% Initial call: session set-up
if(isempty(state))

    % --------------------------------------------------------------------%
    %% ascii output file
    p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%s');
    p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Tstart',      'p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart', '%d');
    p = ND_AddAsciiEntry(p, 'FixRT',       'p.trial.EV.FixStart-p.trial.EV.FixOn', '%d');
    p = ND_AddAsciiEntry(p, 'RewCnt',      'p.trial.reward.count',                '%d');

    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');

    p = ND_AddAsciiEntry(p, 'FixDur',      'p.trial.task.CurFixDur',              '%.3f');
    p = ND_AddAsciiEntry(p, 'FixPeriod',   'p.trial.EV.FixBreak-p.trial.EV.FixStart', '%.5f');
    p = ND_AddAsciiEntry(p, 'FixColor',    'p.trial.stim.FIXSPOT.color',          '%s');
    p = ND_AddAsciiEntry(p, 'intITI',      'p.trial.task.Timing.ITI',             '%.5f');

    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.stim.fix.fixWin',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_X',    'p.trial.stim.fix.pos(1)',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_Y',    'p.trial.stim.fix.pos(2)',             '%.5f');

    p = ND_AddAsciiEntry(p, 'Scene',       'p.trial.stim.sceneName',              '%s');
    p = ND_AddAsciiEntry(p, 'SceneDur',    'p.trial.stim.scene.duration',         '%.3f');
    p = ND_AddAsciiEntry(p, 'StimOn',      'p.trial.EV.StimOn',                   '%.5f');
    p = ND_AddAsciiEntry(p, 'StimOff',     'p.trial.EV.StimOff',                  '%.5f');
    p = ND_AddAsciiEntry(p, 'sizeGain',    'p.trial.stim.IMAGE.sizeGain',         '%.3f');
    p = ND_AddAsciiEntry(p, 'ImageSizeX',  'p.trial.stim.scene.dispSize(1)',      '%.3f');
    p = ND_AddAsciiEntry(p, 'ImageSizeY',  'p.trial.stim.scene.dispSize(2)',      '%.3f');

    ND_Trial2Ascii(p, 'init');

    % basic fixation spot parameters (as in InitFixTrain)
    p.defaultParameters.behavior.fixation.FixGridStp = [4, 4];
    p.defaultParameters.behavior.fixation.FixWinStp  = 1;
    p.defaultParameters.behavior.fixation.FixSPotStp = 0.25;   % arrow-key step for the fix spot [dva]

    % starting fixation window size [dva]; set once per session so
    % keyboard changes carry over from trial to trial
    p.defaultParameters.stim.FIXSPOT.fixWin = 4;

    %---------------------------------------------------------------------%
    %% eye calibration (as in InitFixTrain)
    if(~p.defaultParameters.behavior.fixation.useCalibration)
        p = pds.eyecalib.setup(p);
    end

    p.defaultParameters.task.RandomPos = 0;

else
% ####################################################################### %
%% Trial states
    p = ND_GeneralTrialRoutines(p, state);

    switch state
        case p.trial.pldaps.trialStates.trialSetup
            TaskSetUp(p);

        case p.trial.pldaps.trialStates.trialPrepare
            p.trial.EV.TrialStart = p.trial.CurTime;

        case p.trial.pldaps.trialStates.framePrepareDrawing
            if(~isempty(p.trial.LastKeyPress))
                KeyAction(p);
            end
            TaskDesign(p);

        case p.trial.pldaps.trialStates.trialCleanUpandSave
            TaskCleanAndSave(p);
    end
end

% ####################################################################### %
function TaskSetUp(p)
%% everything that can be prepared before the trial starts
    p.trial.task.Timing.ITI = ND_GetITI(p.trial.task.Timing.MinITI, ...
                                        p.trial.task.Timing.MaxITI, [], [], 1, 0.10);

    % fixation time required before the image appears on this trial
    p.trial.task.CurFixDur = p.trial.task.Timing.MinFixDur + ...
        rand * (p.trial.task.Timing.MaxFixDur - p.trial.task.Timing.MinFixDur);

    p.trial.reward.count        = 0;
    p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;
    p.trial.task.Good           = 0;
    p.trial.task.fixFix         = 0;
    p.trial.task.stimState      = 0;
    p.trial.task.sceneShown     = 0;
    p.trial.task.calibWasOn     = [];

    % random fixation spot position if enabled ('r' key)
    if(p.trial.task.RandomPos == 1)
         Xpos = (rand * 2 * p.trial.task.RandomPosRange(1)) - p.trial.task.RandomPosRange(1);
         Ypos = (rand * 2 * p.trial.task.RandomPosRange(2)) - p.trial.task.RandomPosRange(2);
         p.trial.stim.FIXSPOT.pos = [Xpos, Ypos];
    end

    p.trial.stim.FIXSPOT.color = p.trial.task.Color_list{mod(p.trial.Block.BlockList(p.trial.pldaps.iTrial), ...
                                                         length(p.trial.task.Color_list))+1};

    % fixation spot
    p.trial.stim.fix = pds.stim.FixSpot(p);

    % image: next one from a shuffled queue, so every image is shown once
    % before any repeats (same as ViewScene)
    if isempty(p.trial.Block.imageset)
        p.trial.Block.imageset = randperm(length(p.trial.task.stim.sceneNames));
    end
    val   = p.trial.Block.imageset(1);
    scene = p.trial.task.stim.sceneNames(val);
    p.trial.task.stim.val  = val;
    p.trial.stim.sceneName = scene{1};

    if strcmp(p.trial.task.stim.sceneType, 'image')
        p.trial.stim.IMAGE.imagePath = fullfile(p.trial.task.stim.sceneDir, scene{1});
        p.trial.stim.scene = pds.stim.Image(p);
    elseif strcmp(p.trial.task.stim.sceneType, 'video')
        p.trial.stim.VIDEO.moviePath = fullfile(p.trial.task.stim.sceneDir, scene{1});
        p.trial.stim.scene = pds.stim.Video(p);
    end
    p.trial.stim.scene.on        = 0;   % hidden until the fixation hold is done
    p.trial.stim.scene.fixActive = 0;

    % used to pre-allocate memory; must cover the longest possible trial
    p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix + p.trial.task.Timing.MaxFixDur + ...
                                       p.trial.stim.scene.duration + p.trial.task.durOffset + 1);

    ND_SwitchEpoch(p, 'ITI');

% ####################################################################### %
function TaskDesign(p)
%% task epochs
    switch p.trial.CurrEpoch

        case p.trial.epoch.ITI
            Task_WaitITI(p);

        % ----------------------------------------------------------------%
        case p.trial.epoch.TrialStart
        %% fixation spot on
            Task_ON(p);
            ND_FixSpot(p, 1);

            p.trial.EV.TaskStart     = p.trial.CurTime;
            p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');

            ND_SwitchEpoch(p, 'WaitFix');

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
        %% waiting for a sufficiently held gaze (NoStart / NoFix handled here)
            Task_WaitFixStart(p);

            if(p.trial.CurrEpoch == p.trial.epoch.Fixating)
                p.trial.outcome.CurrOutcome = p.trial.outcome.Fixation;

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
        %% fixation hold: reward pulses, calibration points can be added
            if(p.trial.stim.fix.fixating)

                if(p.trial.CurTime < p.trial.EV.FixStart + p.trial.task.CurFixDur)
                    % still in the hold period: reward series as in InitFixTrain
                    if(p.trial.reward.GiveSeries == 1)
                        cstep = find(p.trial.reward.Step <= p.trial.reward.count, 1, 'last');
                        if(p.trial.CurTime > p.trial.Timer.lastReward + p.trial.reward.Period(cstep))
                            pds.reward.give(p, p.trial.reward.Dur);
                            p.trial.Timer.lastReward = p.trial.CurTime;
                            p.trial.reward.count     = p.trial.reward.count + 1;
                        end
                    end
                else
                    % hold completed: jackpot, fixation spot off, image on
                    if(p.trial.reward.jackpotDur > 0)
                        pds.reward.give(p, p.trial.reward.jackpotDur);
                        p.trial.Timer.lastReward = p.trial.CurTime;
                        pds.audio.playDP(p, 'jackpot', 'left');
                    end
                    ND_FixSpot(p, 0);
                    showScene(p, 1);
                    ND_SwitchEpoch(p, 'WaitResponse');
                end

            else
                % fixation broken before the image: end trial, no image
                p.trial.outcome.CurrOutcome = p.trial.outcome.FixBreak;
                p.trial.task.Good = 0;
                pds.audio.playDP(p, 'breakfix', 'left');
                ND_FixSpot(p, 0);
                ND_SwitchEpoch(p, 'TaskEnd');
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitResponse
        %% image on for exactly scene.duration from its actual onset
        % (EV.StimOn is set by ND_FrameFlip at the flip that shows the image);
        % gaze does not matter here, every trial that gets here is Correct
            dur = p.trial.stim.scene.duration + p.trial.task.durOffset;
            if ~isnan(p.trial.EV.StimOn) && p.trial.CurTime >= p.trial.EV.StimOn + dur
                showScene(p, 0);
                if(p.trial.reward.SceneRew > 0)
                    pds.reward.give(p, p.trial.reward.SceneRew);
                    p.trial.EV.Reward = p.trial.CurTime;
                end
                p.trial.outcome.CurrOutcome = p.trial.outcome.Correct;
                p.trial.task.Good = 1;
                ND_SwitchEpoch(p, 'TaskEnd');
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
            Task_OFF(p);
            p.trial.flagNextTrial = 1;
    end

% ####################################################################### %
function showScene(p, display_val)
%% turn the image on (1) or off (0)
    if(display_val ~= p.trial.task.stimState)
        p.trial.task.stimState = display_val;
        switch display_val
            case 0
                p.trial.stim.scene.on        = 0;
                p.trial.stim.scene.fixActive = 0;
                ND_AddScreenEvent(p, p.trial.event.STIM_OFF, 'StimOff');
                restoreCalib(p);

            case 1
                p.trial.stim.scene.on        = 1;
                p.trial.stim.scene.fixActive = 1;   % window drawn for the experimenter only
                p.trial.task.sceneShown      = 1;
                ND_AddScreenEvent(p, p.trial.event.STIM_ON, 'StimOn');

                % no calibration points while the fixation spot is off
                if(p.trial.task.blockCalibDuringScene)
                    p.trial.task.calibWasOn = p.trial.behavior.fixation.enableCalib;
                    p.trial.behavior.fixation.enableCalib = 0;
                end
        end
    end

% ####################################################################### %
function restoreCalib(p)
%% switch calibration back to what it was before the image
    if(~isempty(p.trial.task.calibWasOn))
        p.trial.behavior.fixation.enableCalib = p.trial.task.calibWasOn;
        p.trial.task.calibWasOn = [];
    end

% ####################################################################### %
function TaskCleanAndSave(p)
%% end of trial
    restoreCalib(p);   % in case the trial ended while the image was on
    Task_Finish(p);

    p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

    % take the image off the queue only if it was actually shown
    if p.trial.task.sceneShown
        p.trial.Block.imageset(1) = [];
    end

    ND_Trial2Ascii(p, 'save');

% ####################################################################### %
function KeyAction(p)
%% task specific keys (as in InitFixTrain)
    switch p.trial.LastKeyPress(1)

        case KbName('r')  % toggle random fixation position on each trial
            p.trial.task.RandomPos = ~p.trial.task.RandomPos;

        case KbName('f')  % fixation spot on/off
            p.trial.stim.fix.on = ~p.trial.stim.fix.on;

        % move fixation spot to calibration grid positions (number keys 1-9)
        case p.trial.key.GridKeyCell
            gpos = find(p.trial.key.GridKey == p.trial.LastKeyPress(1));
            p.trial.behavior.fixation.GridPos = gpos;
            p.trial.stim.FIXSPOT.pos = p.trial.eyeCalib.Grid_XY(gpos, :);
            p.trial.stim.fix.pos     = p.trial.stim.FIXSPOT.pos;

        % move fixation spot in steps
        case KbName('RightArrow')
            p.trial.stim.FIXSPOT.pos = p.trial.stim.FIXSPOT.pos + [p.trial.behavior.fixation.FixSPotStp, 0];
            p.trial.stim.fix.pos     = p.trial.stim.FIXSPOT.pos;

        case KbName('LeftArrow')
            p.trial.stim.FIXSPOT.pos = p.trial.stim.FIXSPOT.pos - [p.trial.behavior.fixation.FixSPotStp, 0];
            p.trial.stim.fix.pos     = p.trial.stim.FIXSPOT.pos;

        case KbName('UpArrow')
            p.trial.stim.FIXSPOT.pos = p.trial.stim.FIXSPOT.pos + [0, p.trial.behavior.fixation.FixSPotStp];
            p.trial.stim.fix.pos     = p.trial.stim.FIXSPOT.pos;

        case KbName('DownArrow')
            p.trial.stim.FIXSPOT.pos = p.trial.stim.FIXSPOT.pos - [0, p.trial.behavior.fixation.FixSPotStp];
            p.trial.stim.fix.pos     = p.trial.stim.FIXSPOT.pos;
    end
