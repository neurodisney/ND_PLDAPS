function SS = ND_RigDefaults(SS)
% set default parameters for a rig in the Disney lab.
%
% This file summarizes gives an overview of parameters that could be set for
% the pldaps class and provides the default settings for an actual rig that
% is used for experiments. It will override the class parameters defined by
% the function @pldaps/pldapsClassDefaultParameters.m
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
%% DataPixx settings: VPixx device control (Datapixx, ProPixx, VIEWPixx)
SS.datapixx.use                                 = 1;      % enable control of VPixx devices

SS.datapixx.enablePropixxCeilingMount           = 0;      % ProPixx: enableCeilingMount   (flip image vertically)
SS.datapixx.enablePropixxRearProjection         = 1;      % ProPixx: enableRearProjection (flip image horizontally)    !!!

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
SS.datapixx.adc.channels                        = [];     % Start empty, will be populated in ND_InitSession
SS.datapixx.adc.channelMapping                  = {};     % Specify where to store the collected data. WZ: Seems that the names need to start with 'datapixx.' to ensure that the fields are created (apparently only in the datapixx substructure).

% ------------------------------------------------------------------------%
%% Display settings: specify options for the screen.
SS.display.bgColor                              = [0.25, 0.25, 0.25];  % datapixx background color. This is the base color datapix uses a screen color and has to be monochrome. It can be changed during trial.
SS.display.scrnNum                              = 1;      % screen number for full screen display, 1 is monkey-screen,0 is experimenter screen
SS.display.viewdist                             = 114;    % screen distance to the observer
SS.display.heightcm                             = 40;     % height of the visible screen in cm
SS.display.widthcm                              = 71;     % width  of the visible screen in cm
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

% movie: optional create of videos, typically used during replay
SS.display.movie.create                         = false; % toggle movie creation
SS.display.movie.dir                            = [];    % directory to store the movie.
SS.display.movie.file                           = [];    % file name. Leave empty to use same file base as PDS file
SS.display.movie.frameRate                      = [];    % frame rate of the movie.
SS.display.movie.height                         = [];    % height of the movie.
SS.display.movie.width                          = [];    % width of the movie.
SS.display.movie.options  = ':CodecType=x264enc :EncodingQuality=1.0'; % encoding parameters

% Use the coordinate frame transformations
SS.display.useCustomOrigin                      = 1;     % 0 is off (use PTB standard origin in corner), 1 uses central origin, [x,y] uses custom pixel location as origin
SS.display.useDegreeUnits                       = 1;     % 0 uses pixels, 1 uses uniform scaling to degrees priortizing accuracy near the center of the screen

% ------------------------------------------------------------------------%
%% EyeLink settings: Eyelink specific parameters
SS.eyelink.use                                  = 0;     % if 1 use the eyelink module

% ------------------------------------------------------------------------%
%% Mouse settings: configure how mouse data should be handled
SS.mouse.use                                    = 0;     % collect and store mouse positions
SS.mouse.useAsEyepos                            = 0;     % toggle use of mouse to set eyeX and eyeY

% ------------------------------------------------------------------------%
%% Sound: control sound playback
SS.sound.use                                    = 0;     % toggle use of sound   !!!
SS.sound.deviceid                               = [];    % PsychPortAudio deviceID, empty for default
SS.sound.useForReward                           = 1;     % toggle playing a sound for reward   !!!

% Datapixx sound and PsychPortAudio can both be used simultaneously to
% maximize audio channels (Need to get datapixx working first)
SS.sound.useDatapixx                            = 1;
SS.sound.datapixxVolume                         = 0.9;
SS.sound.datapixxInternalSpeakerVolume          = 0;

SS.sound.usePsychPortAudio                      = 1;
SS.sound.psychPortVolume                        = 0.9;

% ------------------------------------------------------------------------%
%% PLDAPS settings: pldaps core parameters
SS.pldaps.finish                                = inf;   % Number of trials to run. Can be changed dynamically
SS.pldaps.maxPriority                           = 1;     % Switch to PTB to maxpriority during the trial? See MaxPriority('?')
SS.pldaps.maxTrialLength                        = 25;    % Maximum duration of a trial in seconds. Used to allocate memory.
SS.pldaps.nosave                                = 0;     % disables saving of data when true. see .pldaps.save for more control
SS.pldaps.pass                                  = 0;     % indicator of behavior (i.e. fixations) should always be assumed to be good.
SS.pldaps.quit                                  = 0;     % control experiment during a trial.
SS.pldaps.trialMasterFunction         = 'ND_runTrial';   % function to be called to run a single Trial.
SS.pldaps.useFileGUI                            = 0;     % use a GUI to specify the output file. (WZ TODO: I think could be removed. File names generated automatically.)
SS.pldaps.experimentAfterTrialsFunction         = [];    % a function to be called after each trial.
SS.pldaps.eyeposMovAv                           = 25;    % if > 1 it defines a time window to calculate a moving average of the eye position (.eyeX and .eyeY) over this many samples (TODO: Maybe use a time period instead of number of sample. Right now there is a clear inconsistency when using the mouse).

% dirs: configure pldaps' built-in drawing options
if(exist('/DATA/ExpData', 'dir'))
    SS.pldaps.dirs.data = '/DATA/ExpData';   % data directory.
else
    SS.pldaps.dirs.data = '~/Data/ExpData';   % data directory.
end
SS.pldaps.dirs.wavfiles                         = './beepsounds';  % directory for sound files

% cursor: control drawing of the mouse cursor
SS.pldaps.draw.cursor.use                       = 0;     % enable drawing of the mouse cursor. (WZ TODO: Will we ever use it? Maybe get rid of it.)
SS.pldaps.draw.cursor.sz                        = 8;     % cursor width in pixels

% eyepos: control drawing of the eye position
SS.pldaps.draw.eyepos.use                       = 0;     % enable drawing of the eye position.

% frame rate: control drawing of a frame rate history to see frame drops.
SS.pldaps.draw.framerate.location               = [-30, -10]; % location (XY) of the plot in degrees of visual angle.
SS.pldaps.draw.framerate.nSecond                = 5;          % number of seconds to show the history for
SS.pldaps.draw.framerate.show                   = 0;          % draw the frame rate. need use to be enabled as well
SS.pldaps.draw.framerate.size                   = [10, 5];    % size (XY) of the plot in degrees of visual angle.
SS.pldaps.draw.framerate.use                    = 1;          % set to true to collect data needed to show frame rate.

% grid: control drawing of a grid
SS.pldaps.draw.grid.use                         = 0;     % enable drawing of the grid

% photo diode: control drawing of a flashing photo diode square.
SS.pldaps.draw.photodiode.use                   = 0;     % enable drawing the photo diode square
SS.pldaps.draw.photodiode.XFrames               = 4;     % for how many frames should the PD signal be shown
SS.pldaps.draw.photodiode.location              = 3;     % location of the square as an index: 1-4 for the different corners of the screen
SS.pldaps.draw.photodiode.size                  = 1.5;   % next screen shows update of PD signal state
SS.pldaps.draw.photodiode.state                 = 0;     % is PD signal on?
SS.pldaps.draw.photodiode.cnt                   = 0;     % counter for PD signals

% pause: control pausing behavior of pldaps
SS.pldaps.pause.preExperiment                   = 0;     % pause before experiment starts: 0=don't; 1 = debugger; 2 = pause loop
SS.pldaps.pause.type                            = 1;     % Only type 1 is currently tested.

% save: control how pldaps saves data
SS.pldaps.save.initialParametersMerged          = 1;     % save merged initial parameters
SS.pldaps.save.mergedData                       = 1;     % Save merged data. By default pldaps only saves changes to the trial struct in .data. When mergedData is enabled, the complete content of p.trial is saved to p.data. This can cause significantly larger files
SS.pldaps.save.trialTempfiles                   = 1;     % save temp files with the data from each trial?

% ####################################################################### %
%% Below follow definitions used in the Disney Lab
% This is currently work in progress and we need to find an efficient set
% of definitions that will work most reliable across several tasks.

% ------------------------------------------------------------------------%
%% Debugging
SS.pldaps.GetTrialStateTimes = 0;  % create a 2D matrix (trialstate, frame) with timings. This might impair performance therefore disabled per default
SS.pldaps.GetScreenFlipTimes = 0;  % get each screen refresh time, i.e. wait for synch for each screen update

% ------------------------------------------------------------------------%
%% Reward settings
SS.datapixx.useForReward      = 0;     % WZ TODO: What else could be needed for reward? Maybe we should get rid of this option...
SS.reward.defaultAmount       = 0.05;  % Default amount of reward.=0; [in seconds]
SS.reward.Lag                 = 0.15;  % Delay between response and reward onset
SS.datapixx.adc.RewardChannel = 3;     % Default ADC output channel

% ------------------------------------------------------------------------%
%% Eye tracking
SS.datapixx.useAsEyepos        = 0;

% Default ADC channels to use (set up later in ND_InitSession)
SS.datapixx.adc.XEyeposChannel = 0;
SS.datapixx.adc.YEyeposChannel = 1;
SS.datapixx.adc.PupilChannel   = 2;

% Saccade parameters
SS.behavior.fixation.use       =  0;       % does this task require control of eye position

SS.behavior.fixation.required  =  0;       % If not required, fixation states will be ignored
SS.behavior.fixation.Sample    = 25;       % how many data points to use for determining fixation state.
SS.behavior.fixation.BreakTime = 0.05;     % minimum time [ms] to identify a fixation break
SS.behavior.fixation.GotFix    = 0;        % state indicating if currently fixation is acquired

% fixation target parameters
SS.behavior.fixation.FixPos    = [0, 0];    % center position of fixation window [dva]
SS.behavior.fixation.FixType   = 'disc';    % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
SS.behavior.fixation.FixCol    = 'fixspot'; % color of fixation spot (as defined in the lookup tables)
SS.behavior.fixation.FixSz     = 0.25;      % size of the fixation spot

% Calibration of eye position
SS.behavior.fixation.useCalibration  = 0;    % load mat file for eye calibration
SS.behavior.fixation.enableCalib     = 1;    % allow changing the current eye calibration parameters
SS.behavior.fixation.CalibMat        = [];
SS.Calib.rawEye    = [];
SS.Calib.fixPos    = [];
SS.Calib.medRawEye = [];
SS.Calib.medFixPos = [];
SS.behavior.fixation.CalibMethod     = 'gain'; % method used for calibration, currently only gain adjustment
SS.behavior.fixation.NSmpls          = 50;     % how many datapixx samples of the eye position to be used to calculate the median

SS.behavior.fixation.FixGridStp      = [2, 2]; % x,y coordinates in a 9pt grid
SS.behavior.fixation.GridPos         = 5;

SS.behavior.fixation.FixWinStp       = 0.25;    % change of the size of the fixation window upon key press
SS.behavior.fixation.FixGain         = [-5, -5];  % additional fine scale adjustment of the eye position signal to scale it to dva
SS.behavior.fixation.Offset          = [0, 0];  % offset to get current position signal to FixPos
SS.behavior.fixation.PrevOffset      = [0, 0];  % keep track of previous offset to change back from the one

SS.behavior.fixation.NumSmplCtr      = 10;      % number of recent samples to use to determine current (median) eye position ( has to be small than SS.pldaps.draw.eyepos.history)

% fixation window
SS.behavior.fixation.FixWin          =  4;  % diameter of fixation window in dva
SS.pldaps.draw.eyepos.history        = 60;  % show eye position of the previous n frames in addition to current one
SS.pldaps.draw.eyepos.sz             = 8;   % size in pixels of the eye pos indicator
SS.pldaps.draw.eyepos.fixwinwdth_pxl = 2;   % frame width of the fixation window in pixels

% Define fixation states
SS.FixState.Current  = NaN;
SS.FixState.FixIn    =   1;  % Gaze within fixation window
SS.FixState.FixOut   =   0;  % Gaze out of fixation window
SS.FixState.FixBreak =  -1;  % Gaze out of fixation window

% ------------------------------------------------------------------------%
%% Joystick
SS.datapixx.useJoystick      = 0;

% Default ADC channels to use (set up later in ND_InitSession)
SS.datapixx.adc.XJoyChannel  = 3;
SS.datapixx.adc.YJoyChannel  = 4;

SS.behavior.joystick.use     =  0;         % does this task require control of joystick state
SS.behavior.joystick.Zero    = [2.6, 2.6]; % joystick signal at resting state (released)
SS.behavior.joystick.Sample  = 20;         % how many data points to use for determining joystick state.
SS.behavior.joystick.PullThr = 1.5;        % threshold to detect a joystick press
SS.behavior.joystick.RelThr  = 1.0;        % threshold to detect a joystick release

SS.pldaps.draw.joystick.use  = 1;          % draw joystick states on control screen

% Define joystick states
SS.JoyState.Current     = NaN;
SS.JoyState.JoyHold     =   1;  % joystick pressed
SS.JoyState.JoyRest     =   0;  % joystick released

% ------------------------------------------------------------------------%
%% Analog/digital input/output channels
SS.datapixx.adc.TTLamp      =  3;  % amplitude of TTL pulses via adc

SS.datapixx.TTLdur          = [];  % depending on the DAQ sampling rate it might be necessary to ensure a minimum duration of the TTL pulse
SS.datapixx.EVdur           = [];  % depending on the DAQ sampling rate it might be necessary to ensure a minimum duration of the strobe signal

SS.datapixx.TTL_trialOn     = 1;   % if 1 set a digital output high while trial is active
SS.datapixx.TTL_trialOnChan = 1;   % DIO channel used for trial state TTL

% ------------------------------------------------------------------------%
%% Control screen flips
SS.pldaps.draw.ScreenEvent     = 0;       % no event awaiting, otherwise use event code to be sent to TDT
SS.pldaps.draw.ScreenEventName = 'NULL';  % keep track of times in pldaps data file

% ------------------------------------------------------------------------%
%% Keyboard assignments
% assign keys to specific functions here and utilize these in the
% ND_CheckKey function to trigger defined actions.
KbName('UnifyKeyNames');
SS.key.reward  = KbName('space');    % trigger reward
SS.key.quit    = KbName('ESCAPE');   % end experiment

SS.key.FixReq  = KbName('f');  % disable/enable fixation control
SS.key.CtrJoy  = KbName('j');  % set current joystick position as zero

SS.key.FixInc  = KbName('=+'); % increase size of fixation window
SS.key.FixDec  = KbName('-_'); % decrease size of fixation window

% ------------------------------------------------------------------------%
%% initialize field for editable variables
SS.editable   = {};

% ------------------------------------------------------------------------%
%% Online plots
% allow specification of a matlab routine for online data analysis
SS.plot.do_online =  0;  % run online data analysis between two subsequent trials
SS.plot.routine   = [];  % matlab function to be called for online analysis (TODO: make a default routine for the most rudimentary analysis)
SS.plot.fig       = [];  % figure handle for online plot (leave empty)



