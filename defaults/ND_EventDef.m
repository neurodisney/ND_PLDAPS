function p = ND_EventDef(p)
%
% DO NOT CHANGE THESE EVENT CODES WITHOUT EXPLICIT APPROVAL FROM ANITA
% CHANGING THESE EVENT CODES ALTERS ALL ANALYSIS PIPELINES
%
% Defines numeric values for 16 bit codes of trial events
%
% The encodes defined in 'event' will be sent during the course of a trial
% to mark the time when this event happened.
%
% The fields in 'EV' should be used to save the times of these events
% to the pldaps data file.
%
% Structure of Event Codes:
% 1000's dictate initiation of trials and fixation
% 2000's dictate stimulus information and properties
% 3000's dictate live adjustments (pauses, breaks, etc)
% 4000's dictate response behavior and outcomes of trials
% 5000's dictate outcome related code 
% 6100's dictate stimulation (iontophoresis, electrical, drug/pressure)
% 6600's dictate joystick
% 7000's dictate analog and digital outputs
% 8000's dictate reward parameters
% 9000's dictate other types of stimuli (video, auditory, etc)
% 9900's dictate headers
%
% wolf zinke, Feb. 2017
% veronica galvin, May. 2021

disp('****************************************************************')
disp('>>>>  ND:  Defining Event Codes <<<<')
disp('****************************************************************')
disp('');


disp('****************************************************************')
disp('>>>>  ND:  Defining Task Outcomes <<<<')
disp('****************************************************************')
disp('');
% ------------------------------------------------------------------------%
%% initialize event times as NaN
% This should be used to store times when these events happened (to data
% file or if needed for later use in the task program)

p.defaultParameters.EV.TrialStart    = NaN; % Trial start time
p.defaultParameters.EV.TrialEnd      = NaN; % Trial start time
p.defaultParameters.EV.PlanStart     = NaN; % The planned task start time based on ITI
p.defaultParameters.EV.TaskStart     = NaN; % actual task start after animal got ready (i.e. joystick is in released state)
p.defaultParameters.EV.TaskStartTime = NaN; % Holds a DateStr of the time the task starts
p.defaultParameters.EV.TaskEnd       = NaN; % actual task end
p.defaultParameters.EV.NextTrialStart= NaN; % When the next task should start (based on ITI and passed to next trial)
p.defaultParameters.EV.Initiated     = NaN; % animal intiated the task
p.defaultParameters.EV.StimOn        = NaN; % Stimulus Onset
p.defaultParameters.EV.StimOff       = NaN; % Stimulus Offset
p.defaultParameters.EV.StimChange    = NaN; % Stimulus Change
p.defaultParameters.EV.FixOn         = NaN; % Onset of fixation spot
p.defaultParameters.EV.FixOff        = NaN; % Offset of fixation spot
p.defaultParameters.EV.PDOn          = NaN; % Photo diode onset
p.defaultParameters.EV.PDOff         = NaN; % Photo diode offset
p.defaultParameters.EV.GoCue         = NaN; % Onset of Go-signal
p.defaultParameters.EV.InitReward    = NaN; % initial reward given for just fixatin
p.defaultParameters.EV.FirstReward   = NaN; % First reward given in a trial
p.defaultParameters.EV.Reward        = NaN; % time of reward delivery
p.defaultParameters.EV.nextReward    = NaN; % Scheduled time of next reward
p.defaultParameters.EV.StartRT       = NaN; % response time to start trial after active cue
p.defaultParameters.EV.RespRT        = NaN; % reaction time
p.defaultParameters.EV.Response      = NaN; % reaction time
p.defaultParameters.EV.DPX_TaskOn    = NaN; % Synch time with datapixx for task on
p.defaultParameters.EV.DPX_TaskOff   = NaN; % Synch time with datapixx for task off
p.defaultParameters.EV.TDT_TaskOn    = NaN; % Synch time with TDT for task on
p.defaultParameters.EV.TDT_TaskOff   = NaN; % Synch time with TDT for task off
p.defaultParameters.EV.epochEnd      = NaN; % Ending time of the last epoch
p.defaultParameters.EV.epochTimings  = {};  % Ending time of the last epoch
p.defaultParameters.EV.epochCnt      = 0;   % Ending time of the last epoch

% p.defaultParameters.EV.Pause       = NaN;  % WZ: These events should be within trials. Pauses and breaks are between trials. Might cause conflicts...
% p.defaultParameters.EV.Unpause     = NaN;
% p.defaultParameters.EV.Break       = NaN;
% p.defaultParameters.EV.Unbreak     = NaN;

% if joystick is used for behavior
if(p.defaultParameters.behavior.joystick.use)
    p.defaultParameters.EV.JoyRelease = NaN; % time of joystick release
    p.defaultParameters.EV.JoyPress   = NaN; % Press time to start task
end

if(p.defaultParameters.behavior.joystick.use)
    p.defaultParameters.outcome.NoPress       =   1;  % No joystick press occurred to initialize trial
end

% if fixation is used
if(p.defaultParameters.behavior.fixation.use)
    p.defaultParameters.EV.FixEntry   = NaN; % entering fixation window
    p.defaultParameters.EV.FixStart   = NaN; % start of fixation
    p.defaultParameters.EV.WaitFix    = NaN; % wait for fix to be achieved
    p.defaultParameters.EV.FixBreak   = NaN; % fixation break detected
    p.defaultParameters.EV.FixLeave   = NaN; % time when eyes leave fixation window
    p.defaultParameters.EV.Saccade    = NaN; % response saccade detected

    % Fixspot
    p.defaultParameters.EV.FixSpotStart = NaN; % Start of fixation on central fix spot
    p.defaultParameters.EV.FixSpotStop  = NaN; % Stop of fixation on central fix spot

    % Target
    p.defaultParameters.EV.FixTargetStart = NaN; % Start of fixation on target
    p.defaultParameters.EV.FixTargetStop  = NaN; % Stop of fixation on target

    p.defaultParameters.EV.FixStimStart = NaN; % Start of fixation on target
    p.defaultParameters.EV.FixStimStop  = NaN; % Stop of fixation on target
end

% ------------------------------------------------------------------------%
%% Task encodes
% it is the responsibility of the person programming tasks to use these encodes
% in a responsible way to keep as much information about the task as possible.

% task markers
p.defaultParameters.event.TASK_ON       = 1000;   % start of task (should happen after pldaps encodes a trial start)
p.defaultParameters.event.TASK_OFF      = 1001;   % end of task (should happen before pldaps encodes a trial end)
p.defaultParameters.event.TC_CORR       = 4000; % trial complete, correct
p.defaultParameters.event.TC_ERR        = 4010; % trial complete, incorrect
p.defaultParameters.event.NO_TC         = 4011; % trial incomplete
p.defaultParameters.event.PAUSE         = 3000; % Pause the experiment
p.defaultParameters.event.UNPAUSE       = 3001; % Unpause the experiment
p.defaultParameters.event.BREAK         = 3100; % Pause the experiment
p.defaultParameters.event.UNBREAK       = 3101; % Unpause the experiment

% response related
p.defaultParameters.event.RESP_CORR        = 4400; % correct response occurred
p.defaultParameters.event.RESP_EARLY       = 4402; % early response occurred
p.defaultParameters.event.RESP_PREMAT      = 4403; % premature (early) response occurred, after go signal but too early to be true
p.defaultParameters.event.RESP_FALSE       = 4401; % false response occurred
p.defaultParameters.event.RESP_FALSE_EARLY = 4404; % early response towards wrong stimulus
p.defaultParameters.event.RESP_LATE        = 4405; % late response occurred

% fixation related events
p.defaultParameters.event.FIXSPOT_ON    =  1200; % onset of fixation spot
p.defaultParameters.event.FIXSPOT_OFF   =  1201; % offset of fixation spot
p.defaultParameters.event.FIX_IN        = 1210; % gaze enters fixation window
p.defaultParameters.event.FIX_OUT       = 1211; % gaze leaves fixation window
p.defaultParameters.event.FIXATION      = 1220; % gaze has been in the fix window long enought ot be considered a fix
p.defaultParameters.event.FIX_BREAK     = 1221; % gaze has left fix window for long enough to be considered a fix break

% fixation related outcomes
if(p.defaultParameters.behavior.fixation.use)

    p.defaultParameters.outcome.Fixation      =   5120;
    p.defaultParameters.outcome.NoFix         =   5121;
    p.defaultParameters.outcome.FixBreak      =   5123;
    p.defaultParameters.outcome.Jackpot       =   5129;
    p.defaultParameters.outcome.TargetBreak   =   5122;
    p.defaultParameters.outcome.StimBreak     =   5124;
    p.defaultParameters.outcome.PostStimBreak =   5125;
    p.defaultParameters.outcome.NoTargetFix   =   5126;
end

% Other outcome related codes
p.defaultParameters.outcome.Correct           =   5000;  % correct performance, no error occurred
p.defaultParameters.outcome.Abort             =   5001;     % early joystick release prior stimulus onset
p.defaultParameters.outcome.Early             =   5002;  % correct response selection prior to go signal
p.defaultParameters.outcome.False             =   5003;  % wrong response within response window
p.defaultParameters.outcome.EarlyFalse        =   5004;  % wrong response selection prior to go signal
p.defaultParameters.outcome.Late              =   5005;     % response occurred after response window
p.defaultParameters.outcome.Miss              =   5006;  % no response at a reasonable time
p.defaultParameters.outcome.NoStart           =   5007;  % trial not started
p.defaultParameters.outcome.PrematStart       =   5008;  % trial start not too early as response to cue
p.defaultParameters.outcome.TaskStart         =   5009;  % trial not started
p.defaultParameters.outcome.Break             =   5010;  % A break was triggered by the experimenter
p.defaultParameters.outcome.EarlyFalseContra  =   5011;  % Early saccade made to distractor in opposite hemifield as target
p.defaultParameters.outcome.EarlyFalseIpsi    =   5012;  % Early saccade made to distractor in same hemifield as target
p.defaultParameters.outcome.FalseContra       =   5013;  % Timely saccade made to distractor in opposite hemifield as target
p.defaultParameters.outcome.FalseIpsi         =   5014;  % Timely saccade made to distractor in same hemifield as target 


% refinement of fixation break times
% ToDo: WZ - need to check what encodes should/need to be used as events and
%            what should be used as outcome encoded in the trial header
p.defaultParameters.event.FIX_BRK_BSL   = 1231; % fixation break during the pre-stimulus period
p.defaultParameters.event.FIX_BRK_CUE   = 1232; % fixation break while the cue is on
p.defaultParameters.event.FIX_BRK_STIM  = 1233; % fixation break during stimulus presentation
p.defaultParameters.event.FIX_BRK_SPEED = 1234;

% Saccade outcomes
p.defaultParameters.outcome.goodSaccade       = 5051;
p.defaultParameters.outcome.noSaccade         = 5052;  % Saccade was supposed to happen but none did
p.defaultParameters.outcome.earlySaccade      = 5053;
p.defaultParameters.outcome.lateSaccade       = 5054;  % Saccade still occured, but after it was supposed to.
p.defaultParameters.outcome.wrongSaccade      = 5055;  % saccade to wrong target or in wrong direction
p.defaultParameters.outcome.glance            = 5056;  % saccade made to target, but not held for long enough


% joystick related
p.defaultParameters.event.JOY_PRESS     = 6600;    % joystick press detected
p.defaultParameters.event.JOY_RELEASE   = 6601;    % joystick release detected
p.defaultParameters.event.JOY_ON        = 6610;    % joystick elevation above pressing threshold
p.defaultParameters.event.JOY_OFF       = 6611;    % joystick elevation below releasing threshold

% visual stimulus
p.defaultParameters.event.STIM_ON       = 2500;     % stimulus onset
p.defaultParameters.event.STIM_CHNG     = 2502;     % stimulus change (e.g. dimming)
p.defaultParameters.event.STIM_OFF      = 2501;     % stimulus offset

% stimulus movement
p.defaultParameters.event.START_MOVE    = 2610;     % movement onset
p.defaultParameters.event.SPEED_UP      = 2611;     % movement acceleration
p.defaultParameters.event.SPEED_Down    = 2612;     % movement deceleration
p.defaultParameters.event.STOP_MOVE     = 2613;     % movement offset

% task cues
p.defaultParameters.event.CUE_ON        = 1300;     % onset of cue to select task relevant stimulus
p.defaultParameters.event.CUE_OFF       = 1301;     % onset of cue to select task relevant stimulus
p.defaultParameters.event.GOCUE         = 1302;     % cue to give a response

% auditory stimulus
p.defaultParameters.event.SOUND_ON      = 9100;     % stimulus onset

% stimulations (etc. drug delivery)
p.defaultParameters.event.MICROSTIM     = 6100;     % microstimulation pulse onset
p.defaultParameters.event.INJECT        = 6110;     % start of pressure injection
p.defaultParameters.event.IONTO         = 6120;     % start of iontophoretic drug delivery

% Movie related
p.defaultParameters.event.MOVIE_START   = 9000;

% ------------------------------------------------------------------------%
%% Stim Property Blocks
% Sent at the end of the trial to give information about each shown stimulus
% One-to-one correspondence with StimOn signals

p.defaultParameters.event.STIMPROP_BLOCK_ON  = 2000;  % Start of the stimProp Block
p.defaultParameters.event.STIMPROP           = 2010;  % Start of a new stimulus
p.defaultParameters.event.STIMPROP_BLOCK_OFF = 2001;  % End of stim prop block

% Note: 21xx block reserved for stim types
% These are encoded in the actual stim class files, but are put here for easy reference

p.defaultParameters.event.STIM.BaseStim = 2100;
p.defaultParameters.event.STIM.FixSpot  = 2101;
p.defaultParameters.event.STIM.Grating  = 2102;
p.defaultParameters.event.STIM.Ring     = 2103;


%% Integer encoding blocks
% Reserve the 15xxx block for sending integers 0-999
% For encoding whatever use
p.defaultParameters.event.ZERO_INT = 15000;


% ------------------------------------------------------------------------%
%% System encodes
% encoded by running PLDAPS, can be ignored for task development. These
% events have to be defined otherwise PLDAPS will produce errors!
p.defaultParameters.event.TRIALSTART = 1111;         % begin of a trial according to PLDAPS (could differ from task begin)
p.defaultParameters.event.TRIALEND   = 1112;         % end of a trial according to PLDAPS (could differ from task end)

p.defaultParameters.event.PD_FLASH   = 2900;      % onset of photo diode flash
p.defaultParameters.event.PD_ON      = 2990;      % onset of photo diode 
p.defaultParameters.event.PD_OFF     = 2901;      % offset of photo diode 

% feedback
p.defaultParameters.event.REWARD     = 8000;      % reward delivery, irrespective if earned in task or manually given by experimenter
p.defaultParameters.event.AUDIO_REW  = 8800;

% analog output
p.defaultParameters.event.AO_1       = 7011;
p.defaultParameters.event.AO_2       = 7012;
p.defaultParameters.event.AO_3       = 7013;
p.defaultParameters.event.AO_4       = 7014;

% digital output
p.defaultParameters.event.DO_1       = 7021;
p.defaultParameters.event.DO_2       = 7022;
p.defaultParameters.event.DO_3       = 7023;
p.defaultParameters.event.DO_4       = 7024;
p.defaultParameters.event.DO_5       = 7025;
p.defaultParameters.event.DO_6       = 7026;
p.defaultParameters.event.DO_7       = 7027;
p.defaultParameters.event.DO_8       = 7028;

% marker to select start and end of trial header
p.defaultParameters.event.TRIAL_HDR_ON  = 9900;
p.defaultParameters.event.TRIAL_HDR_OFF = 9901;

p.defaultParameters.event.TRIAL_FTR_ON  = 9911;
p.defaultParameters.event.TRIAL_FTR_OFF = 9910;

% in case a value of zero has to be send as event code use this number instead
p.defaultParameters.event.ZERO_CODE = 10987;


%% get a string representation of the outcome
p.defaultParameters.outcome.codenames = fieldnames(p.defaultParameters.outcome);
noc = length(p.defaultParameters.outcome.codenames);
p.defaultParameters.outcome.codes = nan(1,noc);

for(i=1:noc)
    p.defaultParameters.outcome.codes(i) = p.defaultParameters.outcome.(p.defaultParameters.outcome.codenames{i});
end

% pre-define field for the current outcome
p.defaultParameters.outcome.CurrOutcome = NaN;  % just initialize, no start no outcome

% Create a map to store previous outcomes in to get summary information
p.defaultParameters.outcome.allOutcomes = containers.Map;
