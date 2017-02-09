function SS = ND_RigDefaults(SS)
% This file summarizes gives an overview of parameters that could be set for
% the pldaps class and provides the default settings for an actual rig that
% is used for experiments.
%
% This function takes a struct with default rig settings as input (optional)
% and sets values for most existing fields. The output struct could then be
% used as input for the pldaps function. There, it will override the
% default parameters and use the ones here defined instead. the resulting
% struct could also be saved as default setting struct for the current rig.
%
% Relevant parameters are indicated by '!!!'.
%
%
% wolf zinke, Oct. 2016


% ------------------------------------------------------------------------%
%% behavior settings: behavioral control parameters
SS.behavior.reward.defaultAmount                = 0.05;   % Default amount of reward.=0; [in seconds]

% ------------------------------------------------------------------------%
%% datapixx settings: VPixx device control (Datapixx, ProPixx, VIEWPixx)
SS.datapixx.use                                 = 1;      % enable control of VPixx devices

SS.datapixx.enablePropixxCeilingMount           = 0;      % ProPixx: enableCeilingMount   (flip image vertically)
SS.datapixx.enablePropixxRearProjection         = 1;      % ProPixx: enableRearProjection (flip image horizontally)    !!!

SS.datapixx.useAsEyepos                         = 1;      % use Datapixx adc inputs as eye position                    !!!
SS.datapixx.useForReward                        = 1;      % use Datapixx to set for a given duration. WZ: Default channel used is chan 3, needs hard coding in pldaps code to change                 !!!

SS.datapixx.LogOnsetTimestampLevel              = 2;      % Get and Store a the time each frame arrived at the VPixx device.

% GetPreciseTime: Set internal parameters for PsychDatapixx('GetPreciseTime').
% This is highly recommend to speed up inter trial interval. see pldapsSyncTests, PsychDatapixx('GetPreciseTime?')
% WZ: Also for more clarification check the PsychDataPixx function in Psychtoolbox-3/Psychtoolbox/PsychHardware/DatapixxToolbox/DatapixxBasic
% Currently values are set as specified as default in pds.datapixx.init,
% leaving all fields empty should result in the same parameters.
SS.datapixx.GetPreciseTime.maxDuration          = 0.015;  % maximum duration in seconds to wait for a good estimate
SS.datapixx.GetPreciseTime.optMinwinThreshold   = 1.2e-4; % Minimum Threshold that defines a good estimate to end before maxDuration
SS.datapixx.GetPreciseTime.syncmode             = 2;      % syncmode: accepted values are 1,2,3

% adc: Continuously collect and store adc data from Datapixx.
SS.datapixx.adc.bufferAddress                   = [];     % typically left empty.
SS.datapixx.adc.channelGains                    = 1;      % Apply a gain to collected data.
SS.datapixx.adc.channelModes                    = 0;      % Defines the referencing of the channel.
SS.datapixx.adc.channelOffsets                  = 0;      % Apply an offset to collected data.
SS.datapixx.adc.maxSamples                      = 0;      % maximum number of samples to collect
SS.datapixx.adc.numBufferFrames                 = 600000; % maximum number of samples to store in datapixx memory.
SS.datapixx.adc.srate                           = 1000;   % samples rate in Hz
SS.datapixx.adc.startDelay                      = 0;      % delay until beginning of recording.
SS.datapixx.adc.channels                        = [0, 1, 2, 3, 4, 5]; % List of channels to collect data from. Channel 3 is as default reserved for reward.               !!!
SS.datapixx.adc.channelMapping = {'AI.Eye.X', 'AI.Eye.Y', 'AI.Eye.PDx', 'AI.Eye.PDy', 'AI.Joy.X', 'AI.Joy.Y'}; % Specify where to store the collected data. WZ: Seems that the names need to start with 'datapixx.' to ensure that the fields are created (apparently only in the datapixx substructure).

SS.datapixx.adc.XEyeposChannel                  = 0;      % if datapixx.useAsEyepos=true, use this channel set eyeX    !!!
SS.datapixx.adc.YEyeposChannel                  = 1;      % if datapixx.useAsEyepos=true, use this channel set eyeY    !!!

% ------------------------------------------------------------------------%
%% display settings: pecify options for the screen.
SS.display.bgColor                              = [0.25, 0.25, 0.25];  % datapixx background color. This is the base color datapix uses a screen color and has to be monochrome. It can be changed during trial.
SS.display.scrnNum                              = 1;      % screen number for full screen display, 1 is monkey-screen,0 is experimenter screen
SS.display.viewdist                             = 57;     % screen distance to the observer                            !!!
SS.display.heightcm                             = 29.5;   % height of the visible screen in cm                         !!!
SS.display.widthcm                              = 52.0;   % width  of the visible screen in cm                         !!!
SS.display.screenSize                           = [];     % size of the window to create pixels in, leave empty for full screen

SS.display.useOverlay                           = 1;      % create an overlay pointer
SS.display.colorclamp                           = 1;      % clamp colors to [0-1] range. Typically not necessary
SS.display.normalizeColor                       = 1;      % use colors in [0-1] normalized color range on PTB screen. Often implied by other setting anyway
SS.display.switchOverlayCLUTs                   = false;  % switch overlay colors between experimenter and subject view

SS.display.colorclamp                           = 0;      % clamp colors to [0-1] range. Typically not necessary
SS.display.forceLinearGamma                     = false;  % force a linear gamma table at the end of screen initiation.
SS.display.stereoFlip                           = [];     % check before use if supported
SS.display.stereoMode                           = 0;      % check before use if supported
SS.display.sourceFactorNew      = 'GL_SRC_ALPHA';         % Blending mode used for psychtoolblox screen BlendFunction (http://docs.psychtoolbox.org/BlendFunction)
SS.display.destinationFactorNew = 'GL_ONE_MINUS_SRC_ALPHA';  % Blending mode used for psychtoolblox screen BlendFunction (http://docs.psychtoolbox.org/BlendFunction)
SS.display.displayName          = 'defaultScreenParameters'; % a name for your screen

% movie: optinal create of videos, typically used during replay
SS.display.movie.create                         = false; % toggle movie creation
SS.display.movie.dir                            = [];    % directory to store the movie.
SS.display.movie.file                           = [];    % file name. Leave empty to use same file base as PDS file
SS.display.movie.frameRate                      = [];    % frame rate of the movie.
SS.display.movie.height                         = [];    % height of the movie.
SS.display.movie.width                          = [];    % width of the movie.
SS.display.movie.options  = ':CodecType=x264enc :EncodingQuality=1.0'; % encoding parameters

% ------------------------------------------------------------------------%
%% eyelink settings: Eyelink specific parameters
SS.eyelink.use                                  = 0;     % if 1 use the eyelink module

% SS.eyelink.buffereventlength                    = 30;    % don't change.
% SS.eyelink.buffersamplelength                   = 31;    % don't change.
% SS.eyelink.calibration_matrix                   = [];    % calibration matrix when using raw (uncalibrated) Data
% SS.eyelink.collectQueue                         = 1;     % collect and store each sample recorded during trials
% SS.eyelink.custom_calibration                   = 0;     % don't use.
% SS.eyelink.custom_calibrationScale              = 0.25;  % don't use.
% SS.eyelink.saveEDF                              = 0;     % toggle downloading of the EDF file directly after the experiment.
% SS.eyelink.useAsEyepos                          = 1;     % toggle use of eyelink to set eyeX and eyeY
% SS.eyelink.useRawData                           = 0;     % toggle use of raw (uncalibrated) Data.

% ------------------------------------------------------------------------%
%% mouse settings: configure how mouse data should be handled
SS.mouse.use                                    = 0;     % collect and store mouse positions
SS.mouse.useAsEyepos                            = 0;     % toggle use of mouse to set eyeX and eyeY

% ------------------------------------------------------------------------%
%% sound: contol sound playback
SS.sound.use                                    = 0;     % toggle use of sound   !!!
SS.sound.deviceid                               = [];    % PsychPortAudio deviceID, empty for default
SS.sound.useForReward                           = 1;     % toggle playing a sound for reward   !!!

% ------------------------------------------------------------------------%
%% plexon settings: interact with plexon MAP or Omniplex
% spikeserver: configure our plexon spike server.
SS.plexon.spikeserver.use	                    = 0;     % toggle use of our plexon spike server

% ------------------------------------------------------------------------%
%% pldaps settings: pldaps core parameters
SS.pldaps.finish                                = inf;   % Number of trials to run. Can be changed dynamically
SS.pldaps.goodtrial                             = 0;     % indicator whether the trial was good. Not used by pldaps itself
SS.pldaps.iTrial                                = 1;     % trial number. cannot be changed by the user
SS.pldaps.maxPriority                           = 1;     % Switch to PTB to maxpriority during the trial? See MaxPriority('?')
SS.pldaps.maxTrialLength                        = 25;    % Maximum duration of a trial in seconds. Used to allocate memory.
SS.pldaps.nosave                                = 0;     % disables saving of data when true. see .pldaps.save for more control
SS.pldaps.pass                                  = 0;     % indicator of behavior (i.e. fixations) should always be assumed to be good.
SS.pldaps.quit                                  = 0;     % control experiment during a trial.
SS.pldaps.trialMasterFunction            = 'runTrial';   % function to be called to run a single Trial.
% SS.pldaps.trialFunction                       = [];    % function to be called to run a single Trial.
SS.pldaps.useFileGUI                            = 0;     % use a GUI to specify the output file.
SS.pldaps.experimentAfterTrialsFunction         = [];    % a function to be called after each trial.
SS.pldaps.eyeposMovAv                           = 25;    % if > 1 it defines a time window to calculate a moving average of the eye position (.eyeX and .eyeY) over this many samples (TODO: Maybe use a time period instead of number of sample. Right now there is a clear inconsistency when using the mouse).
SS.pldaps.useModularStateFunctions              = 0;     % use modular state functions, see pldaps.runModularTrial, pldaps.getModules, pldaps.runStateforModules

% dirs: configure pldaps' built-in drawing options
SS.pldaps.dirs.data                             = '~/Data/ExpData';   % data directory.
SS.pldaps.dirs.wavfiles                         = '/usr/local/PLDAPS/beepsounds';  % directory for sound files

% cursor: control drawing of the mouse cursor
SS.pldaps.draw.cursor.use                       = 0;     % enable drawing of the mouse cursor.

% eyepos: control drawing of the eye position
SS.pldaps.draw.eyepos.use                       = 1;     % enable drawing of the eye position.

% frame rate: control drawing of a frame rate history to see frame drops.
SS.pldaps.draw.framerate.location               = [-30, -10]; % location (XY) of the plot in degrees of visual angle.
SS.pldaps.draw.framerate.nSecond                = 5;          % number of seconds to show the history for
SS.pldaps.draw.framerate.show                   = 0;          % draw the frame rate. need use to be enabled as well
SS.pldaps.draw.framerate.size                   = [10, 5];    % size (XY) of the plot in degrees of visual angle.
SS.pldaps.draw.framerate.use                    = 1;          % set to true to collect data needed to show frame rate.

% grid: control drawing of a grid
SS.pldaps.draw.grid.use                         = 0;     % enable drawing of the grid

% photo diode: control drawing of a flashing photo diode square.
SS.pldaps.draw.photodiode.use                   = 1;     % enable drawing the photo diode square
SS.pldaps.draw.photodiode.everyXFrames          = 10;    % will be shown every nth frame
SS.pldaps.draw.photodiode.location              = 1;     % location of the square as an index: 1-4 for the different corners of the screen

% pause: control pausing behavior of pldaps
SS.pldaps.pause.preExperiment                   = 0;     % pause before experiment starts: 0=don't; 1 = debugger; 2 = pause loop
SS.pldaps.pause.type                            = 1;     % Only type 1 is currently tested.

% save: control how pldaps saves data
SS.pldaps.save.initialParametersMerged          = 1;     % save merged initial parameters
SS.pldaps.save.mergedData                       = 1;     % Save merged data. By default pldaps only saves changes to the trial struct in .data. When mergedData is enabled, the complete content of p.trial is saved to p.data. This can cause significantly larger files
SS.pldaps.save.trialTempfiles                   = 1;     % save temp files with the data from each trial?
SS.pldaps.save.v73                              = 0;     % save as matlab version v73?

% ------------------------------------------------------------------------%
%% Screen/Display parameters
% dot sizes for drawing (Taken from pdsDefaultTrialStructure)
% corresponding colors are defined in ND_DefaultColors.
SS.stimulus.eyeW      = 8;    % eye indicator width in pixels
SS.stimulus.fixdotW   = 8;    % width of the fixation dot
SS.stimulus.targdotW  = 8;    % width of the target dot
SS.stimulus.cursorW   = 8;    % cursor width in pixels


% ####################################################################### %
%% Below follow definitions used in the Disney Lab
% This is currently work in progress and we need to find an efficient set
% of definitions that work most reliable across several tasks.

% ------------------------------------------------------------------------%
%% Analog input channels
% specify channel assignments and the use of joystick input
SS.datapixx.adc.EyeRange = [-10, 10]; % range of analog signal, use this for initia mapping of eye position. 
SS.datapixx.adc.PupilChannel = 2;  % if datapixx.useAsEyepos=true, use this channel to determine pupil diameter  !!!

SS.datapixx.useJoystick      = 1;  % acquire data about joystick state                                           !!!

SS.datapixx.adc.XJoyChannel  = 4;  % if datapixx.useJoystick=true, use this channel to determine x               !!!
SS.datapixx.adc.YJoyChannel  = 5;  % if datapixx.useJoystick=true, use this channel to determine x               !!!

% ------------------------------------------------------------------------%
%% Keyboard assignments
% assign keys to specific functions here and utilize these in the
% ND_CheckKeyMouse function to trigger defined actions.

SS.key.reward = 'space';    % trigger reward
SS.key.pause  = 'p';
SS.key.quit   = 'ESCAPE';
SS.key.debug  = 'd';

% ------------------------------------------------------------------------%
%% Define task epoch flags
% TODO: Get a set of required task epochs with a clear naming convention
SS.epoch.GetReady       =   0;  % Wait to initialize task
SS.epoch.WaitStart      =   1;  % Wait for a joystick press to indicate readiness to work on a trial
SS.epoch.WaitResponse   =   2;  % Wait for joystick release
SS.epoch.WaitPress      =   3;  % Target not acquired yet, wait for fixation
SS.epoch.WaitRelease    =   4;  % Target not acquired yet, wait for fixation
SS.epoch.WaitFix        =   5;  % Target not acquired yet, wait for fixation
SS.epoch.WaitTarget     =   6;  % wait for target onset
SS.epoch.WaitGo         =   7;  % delay period before response is required
SS.epoch.WaitReward     =   8;  % delay before reward delivery
SS.epoch.TaskEnd        =   9;  % trial completed
SS.epoch.ITI            =  10;  % inter-trial interval: wait before next trial to start
SS.epoch.AbortError     =  -1;  % Error occurred, finish trial (maybe add time out)

% ------------------------------------------------------------------------%
%% joystick parameters
SS.behavior.joystick.use       =  1;         % does this task require control of joystick state
SS.behavior.joystick.Zero      = [2.6, 2.6]; % joystick signal at resting state (released)
SS.behavior.joystick.Sample    = 20;         % how many data points to use for determining joystick state.
SS.behavior.joystick.PullThr   = 1.5;        % threshold to detect a joystick press
SS.behavior.joystick.RelThr    = 1.0;        % threshold to detect a joystick release
% SS.behavior.joystick.ActTime   =  20;        % minimum time [ms] required to be considered as joystick action

SS.pldaps.draw.joystick.use    = 1;          % draw joystick states on control screen

% ------------------------------------------------------------------------%
%% Define joystick states
SS.JoyState.Current     = NaN;
SS.JoyState.JoyHold     =   1;  % joystick pressed
SS.JoyState.JoyRest     =   0;  % joystick released

% ------------------------------------------------------------------------%
%% Saccade parameters
SS.behavior.fixation.use       =  1;      % does this task require control of eye position
SS.behavior.fixation.BreakTime = 25;      % minimum time [ms] to identify a fixation break
SS.behavior.fixation.FixWin    =  4;      % diameter of fixation window in dva
SS.behavior.fixation.FixPos    = [0 ,0];  % center position of fixation window
SS.behavior.joystick.Sample    = 20;      % how many data points to use for determining fixation state.

% ------------------------------------------------------------------------%
%% Define fixation states
SS.FixState.Current     = NaN;
SS.FixState.GazeIn      =   1;  % Gaze at target
SS.FixState.GazeOut     =   0;  % Gaze left fixation window

% ------------------------------------------------------------------------%
%% Define task outcomes
SS.outcome.CurrOutcome  = NaN;  % just initialize, no start no outcome

SS.outcome.Correct      =   0;  % correct performance, no error occurred
SS.outcome.NoPress      =   1;  % No joystick press occurred to initialize trial
SS.outcome.Abort        =   2;  % early joystick release prior stimulus onset
SS.outcome.Early        =   3;  % release prior to response window
SS.outcome.False        =   4;  % wrong response within response window
SS.outcome.Late         =   5;  % response occurred after response window
SS.outcome.Miss         =   6;  % no response at a reasonable time
SS.outcome.FalseStart   =   7;  % no response at a reasonable time

% get a string representation of the outcome
SS.outcome.codenames = fieldnames(SS.outcome);
noc = length(SS.outcome.codenames);
SS.outcome.codes = nan(1,noc);
for(i=1:noc)
    SS.outcome.codes(i) = SS.outcome.(SS.outcome.codenames{i});
end
