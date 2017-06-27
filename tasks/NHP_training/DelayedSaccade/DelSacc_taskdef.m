function p = DelSacc_taskdef(p)
% define task parameters for the joystick training task.
% This function will be executed at every trial start, hence it is possible
% to edit it while the experiment is in progress in order to apply online
% modifications of the task.
%
% TODO: - Make sure that changed parameters are kept in the data file, i.e.
%         that there is some log when changes happened
%       - read in only changes in order to allow quicker manipulations via the
%         keyboard without overwriting it every time by calling this routine
%
%
% wolf zinke, Dec. 2016

% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.task.EqualCorrect = 0; % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% ------------------------------------------------------------------------%
%% Main stuff to change
p.trial.task.FixCol = 'black';

p.trial.task.fixLatency       = 0.25; % Time to hold fixation before it counts
p.trial.reward.initialFixRwd  = 0.1; % Small reward for achieving full fixation
p.trial.task.stimLatency      = ND_GetITI(0.2,0.5); % Time from full fixation to stim appearing

p.trial.task.centerOffLatency = ND_GetITI(0.4,1.0); % Time from stim appearing to fixspot disappearing
p.trial.task.saccadeTimeout   = 1;   % Time allowed to make the saccade to the stim before error
p.trial.task.minTargetFixTime = 0.3; % Must fixate on stim for at least this time before it counts

p.trial.reward.Dur            = 1.0; % Reward for completing the task successfully

p.trial.stim.lowContrast      = 0.4; % contrast value when stim.on = 1
p.trial.stim.highContrast     = 1;   % contrast value when stim.on = 2
p.trial.stim.tFreq            = 0;   % drift speed, 0 is stationary

p.trial.behavior.fixation.centralFixWin = 3.5;
p.trial.stim.FixWin           = 5;

%% Reward

% manual reward from experimenter
p.trial.reward.ManDur = 0.1;         % reward duration [s] for reward given by keyboard presses

% ------------------------------------------------------------------------%
%% Task Timings
p.trial.task.Timing.WaitFix = 3;    % Time to get a solid fixation before trial ends unsuccessfully
p.trial.task.Timing.MaxFix = 20;    % Maximum amount of time of fixation
% inter-trial interval
p.trial.task.Timing.MinITI  = 1.5;  % minimum time period [s] between subsequent trials
p.trial.task.Timing.MaxITI  = 3;    % maximum time period [s] between subsequent trials

% penalties
p.trial.task.Timing.TimeOut =  0;   % Time [s] out for incorrect responses

% ------------------------------------------------------------------------%
%% Fixation parameters
p.trial.task.fixrect = ND_GetRect(p.trial.behavior.fixation.fixPos, ...
                                  p.trial.behavior.fixation.FixWin);  % make sure that this will be defined in a variable way in the future

p.trial.behavior.fixation.BreakTime = 0.025;  % minimum time [ms] to identify a fixation break
p.trial.behavior.fixation.entryTime = 0.025;  % minimum time to stay within fixation window to detect initial fixation start

% ------------------------------------------------------------------------%
%% fixation spot parameters
p.trial.behavior.fixation.FixType = 'disc';     % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
p.trial.behavior.fixation.FixCol  = 'fixspot';  % color of fixation spot (as defined in the lookup tables)
p.trial.behavior.fixation.FixSz   = 0.2;        % size of the fixation spot

% ------------------------------------------------------------------------%
%% Stim parameters
% Eccentricity in degrees from origin
p.trial.stim.eccentricity       = 4;     

% Locations of the stimuli (will scale to the proper eccentricity in the task)
% Right now use the 4 diagonal quadrants and the right cardinal.
p.trial.stim.locations          = {[1  , 0], ...
                                   [-1 , 0], ...
                                   [1  , 1], ...
                                   [-1 , 1], ...
                                   [-1 ,-1], ...
                                   [1  ,-1]};
% diameter of the stim
p.trial.stim.radius               = 1;  % WZ: what RF/area are we aiming for? 1-2 dva sshould be good.

% Possbile angles for the stim
p.trial.stim.orientations = [45]; % [0, 45, 90, 135, 180, 225, 270, 315];

p.trial.stim.sFreq = [4]; %[1, 2, 4, 8];   % WZ: range 1-10 cycles/degree

p.trial.stim.grating.res = 300;
% ------------------------------------------------------------------------%
%% Task parameters
% Max distance increase away from stim before considered a wrong saccade
p.trial.behavior.fixation.distInc = 1.5;
% Max angle away from stim before premature saccade is counted instead as a
% fix break.
p.trial.behavior.saccade.earlyAngle = 30;

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 2*(p.trial.task.Timing.WaitFix + p.trial.task.Timing.MaxFix); % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.

