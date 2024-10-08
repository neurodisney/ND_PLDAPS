 function SS = ND_RigDefaults(rig)
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
% Nate Faber, 2017

% If no rig is specified, use rig1
if(~exist('rig','var') || isempty(rig))
    [~, rigname] = system('hostname');
    rig = str2num(regexp(rigname,'\d+','match','once'));
end

SS.defaultParameters.session.rig = rig;

switch rig
    case 1
        display(sprintf('\n\n Loading settings for rig 1... \n\n'));
    case 2
        display(sprintf('\n\n Loading settings for rig 2... \n\n'));
    otherwise
        display(sprintf('\n\n No rig identified, loading settings for rig1... \n\n'));
end

% ------------------------------------------------------------------------%
%% DataPixx settings: VPixx device control (Datapixx, ProPixx, VIEWPixx)
SS.datapixx.use                                 = 1;      % enable control of VPixx devices

SS.datapixx.enablePropixxCeilingMount           = 0;      % ProPixx: enableCeilingMount   (flip image vertically)
SS.datapixx.enablePropixxRearProjection         = 1;      % ProPixx: enableRearProjection (flip image horizontally)    !!!

SS.datapixx.propixxIntensity                    = 3;      % Projector brightness (0 = 100%, 1 = 50%, 2 = 25%, 3 = 12.5%, 4 = 6.25%). [] to not change.

% GetPreciseTime: Set internal parameters for PsychDatapixx('GetPreciseTime').
% This is highly recommend to speed up inter trial interval. see pldapsSyncTests, PsychDatapixx('GetPreciseTime?')
% WZ: Also for more clarification check the PsychDataPixx function in Psychtoolbox-3/Psychtoolbox/PsychHardware/DatapixxToolbox/DatapixxBasic
% Currently values are set as specified as default in pds.datapixx.init,
% leaving all fields empty should result in the same parameters.
SS.datapixx.GetPreciseTime.maxDuration          = 0.015;  % maximum duration in seconds to wait for a good estimate
SS.datapixx.GetPreciseTime.optMinwinThreshold   = 1.2e-4; % Minimum Threshold that defines a good estimate to end before maxDuration
SS.datapixx.GetPreciseTime.syncmode             = 2;      % syncmode: accepted values are 1,2,3

SS.datapixx.LogOnsetTimestampLevel              = 2;

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
switch rig
    case 1
        SS.display.viewdist                     = 57.0; % screen distance to the observer
        SS.display.heightcm                     = 30.0; % height of the visible screen in cm
        SS.display.widthcm                      = 53.5; % width  of the visible screen in cm
        SS.display.bgColor                      = [0.37, 0.37, 0.37];  % datapixx background color. This is the base color datapix uses a screen color and has to be monochrome. It can be changed during trial.
    case 2
        SS.display.viewdist                     = 57.0;   
        SS.display.heightcm                     = 30.0;     
        SS.display.widthcm                      = 53.5;  
        SS.display.bgColor                      = [0.37, 0.37, 0.37]; % datapixx background color: target 20 cd/m^2
    otherwise
        SS.display.viewdist                     = 57.0;   
        SS.display.heightcm                     = 30.0;    
        SS.display.widthcm                      = 53.5;   
end

SS.display.breakColor                           = 'black';  % screen color during breaks
SS.display.scrnNum                              = 1;      % screen number for full screen display, 1 is monkey-screen,0 is experimenter screen
SS.display.viewdist                             = 57.0;    % screen distance to the observer
SS.display.heightcm                             = 30.0;     % height of the visible screen in cm
SS.display.widthcm                              = 53.5;     % width  of the visible screen in cm
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
SS.display.coordMatrix                          = eye(3);% Identity matrix, will be transformed  to allow for easy pix -> screen transformations

% ------------------------------------------------------------------------%
%% EyeLink settings: Eyelink specific parameters
SS.eyelink.use                                  = 0;     % if 1 use the eyelink module

% ------------------------------------------------------------------------%
%% Tucker-Davis Technologies: TDT specific parameters for receiving electrophysiological data
SS.tdt.use                                      = 0;     % Collect UDP packets from the RZ5

% Use the IP address specific to the rig
switch rig
    case 1
        SS.tdt.ip                               = '129.59.230.10';
%     case 2
%         SS.tdt.ip                               = 'NO_IP_YET';
    otherwise
        SS.tdt.ip                               = '129.59.230.10';
end

SS.tdt.channels                                 = 32; % Number of ephys channels to analyze in incoming data
SS.tdt.sortCodes                                = 4;  % Number of units classified per channel. [1, 2, or 4]
SS.tdt.bitsPerSort                              = 4;  % Bits used to encode number of spikes for each unit. [1, 2, 4, or 8]

% ------------------------------------------------------------------------%
%% Mouse settings: configure how mouse data should be handled
SS.mouse.use                                    = 0;     % collect and store mouse positions
SS.mouse.useAsEyepos                            = 0;     % toggle use of mouse to set eyeX and eyeY

% Some vestigal parameters from PLDAPS class defaults
SS.mouse.useLocalCoordinates                    = 0;
SS.mouse.initialCoordinates                     = [];
% ------------------------------------------------------------------------%
%% Sound: control sound playback
SS.sound.use                                    = 0;     % toggle use of sound   !!!
SS.sound.deviceid                               = [];    % PsychPortAudio deviceID, empty for default
SS.sound.useForReward                           = 1;     % toggle playing a sound for reward   !!!

% Datapixx sound and PsychPortAudio can both be used simultaneously to
% maximize audio channels (Need to get datapixx working first)
SS.sound.useDatapixx                            = 1;
SS.sound.datapixxVolume                         = 1.0;
SS.sound.datapixxInternalSpeakerVolume          = 0;

SS.sound.usePsychPortAudio                      = 0;
SS.sound.psychPortVolume                        = 0.9;

% ------------------------------------------------------------------------%
%% PLDAPS settings: pldaps core parameters
SS.pldaps.finish                                = inf;   % Number of trials to run. Can be changed dynamically
SS.pldaps.maxPriority                           = 1;     % Switch to PTB to maxpriority during the trial? See MaxPriority('?')
SS.pldaps.maxTrialLength                        = 25;    % Maximum duration of a trial in seconds. Used to allocate memory.
SS.pldaps.nosave                                = 0;     % disables saving of data when true. see .pldaps.save for more control
%SS.pldapt default parameters for a rig in the Disney lab.
%s.save_nostart                          = 0;     % do not save pds files if the trial was not started
SS.pldaps.pass                                  = 0;     % indicator of behavior (i.e. fixations) should always be assumed to be good.
SS.pldaps.quit                                  = 0;     % control experiment during a trial.
SS.pldaps.trialMasterFunction         = 'ND_runTrial';   % function to be called to run a single Trial.
SS.pldaps.useFileGUI                            = 0;     % use a GUI to specify the output file. (WZ TODO: I think could be removed. File names generated automatically.)
SS.pldaps.experimentAfterTrialsFunction         = [];    % a function to be called after each trial.
SS.pldaps.MovAv                                 = 25;    % if > 1 it defines a time window to calculate a moving average of the eye position (.eyeX and .eyeY) over this many samples (TODO: Maybe use a time period instead of number of sample. Right now there is a clear inconsistency when using the mouse).

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
SS.pldaps.draw.framerate.nSeconds               = 5;          % number of seconds to show the history for
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
SS.pldaps.pause                                 = 0;     % pause the experiment after the current trial
% save: control how pldaps saves data
SS.pldaps.save.initialParametersMerged          = 1;     % save merged initial parameters

% ####################################################################### %
%% Below follow definitions used in the Disney Lab
% This is currently work in progress and we need to find an efficient set
% of definitions that will work most reliable across several tasks.

% ------------------------------------------------------------------------%
%% Debugging
SS.pldaps.GetTrialStateTimes = 0;  % create a 2D matrix (trialstate, frame) with timings. This might impair performance therefore disabled per default
SS.pldaps.GetScreenFlipTimes = 0;  % get each screen refresh time, i.e. wait for synch for each screen update
SS.pldaps.ptbVerbosity       = 3;  % See here https://github.com/Psychtoolbox-3/Psychtoolbox-3/wiki/FAQ:-Control-Verbosity-and-Debugging

% ------------------------------------------------------------------------%
%% Reward settings
SS.datapixx.useForReward      = 0;     % WZ TODO: What else could be needed for reward? Maybe we should get rid of this option...
SS.reward.defaultAmount       = 0.125;  % Default amount of reward.=0; [in seconds]
SS.reward.Lag                 = 0.15;  % Delay between response and reward onset
SS.datapixx.adc.RewardChannel = 3;     % Default ADC output channel

% ------------------------------------------------------------------------%
%% Condition/Block design
SS.Block.maxBlocks      = -1;  % max number of blocks to complete; if negative blocks continue until experimenter stops, otherwise task stops after completion of all blocks
SS.Block.maxBlockTrials =  4;  % max number of trials per condition in a block (for unbalanced numbers use an array with the same length as number of condition and specify desired trial number per condition)
SS.Block.EqualCorrect   =  0;  % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions
SS.Block.GenBlock       =  1;  % Flag to indicate that a block with a new condition list needs to be generated
c1.Nr = 1;
SS.Block.Conditions     = {c1}; % as default only one condition
SS.Block.BlockList      = [];

% ------------------------------------------------------------------------%
%% Eye tracking
SS.datapixx.useAsEyepos        = 0;

% Default ADC channels to use (set up later in ND_InitSession)
SS.datapixx.adc.XEyeposChannel = 0;
SS.datapixx.adc.YEyeposChannel = 1;
SS.datapixx.adc.PupilChannel   = 2;

% Saccade parameters
SS.behavior.fixation.use       =  0;       % does this task require control of eye position

SS.behavior.fixation.on        =  0;       % If not required, fixation states will be ignored
SS.behavior.fixation.Sample    = 25;       % how many data points to use for determining fixation state.
SS.behavior.fixation.entryTime = 0.025;    % minimum time [s] before fixation is registered when gaze enters fixation window
SS.behavior.fixation.BreakTime = 0.05;     % minimum time [s] to identify a fixation break
SS.behavior.fixation.GotFix    = 0;        % state indicating if currently fixation is acquired

SS.behavior.fixation.MinFixStart = 0.1;    % minimum time gaze has to be in fixation window to start trial, if GiveInitial == 1 after this period a reward is given

% Calibration of eye position
SS.behavior.fixation.useCalibration  = 1;         % load mat file for eye calibration
SS.behavior.fixation.enableCalib     = 0;         % allow changing the current eye calibration parameters
SS.eyeCalib.name                     = 'Default';        % Name of the calibration used. For back referencing in the data later
SS.eyeCalib.file                     = 'nofile';   % THe file that stores the calibration information
SS.eyeCalib.offsetTweak              = [0, 0];    % Additive tweak to the offset parameter  
SS.eyeCalib.gainTweak                = [0, 0];    % Additive tweak to the gain parameter
SS.behavior.fixation.calibTweakMode  = 'off';     % Parameter currently being tweaked
SS.behavior.fixation.offsetTweakSize = 0.1;       % How much to tweak offset by in dva
SS.behavior.fixation.gainTweakSize   = 0.03;       % How much to tweak gain by
SS.eyeCalib.rawEye    = [];
SS.eyeCalib.fixPos    = [];
SS.eyeCalib.medRawEye = [];
SS.eyeCalib.medFixPos = [];
SS.behavior.fixation.calibSamples    = 200;    % analog eyesamples in the the datapixx to determine the position of an eye calibration point
SS.behavior.fixation.NSmpls          = 50;     % how many datapixx samples of the eye position to be used to calculate the median

SS.behavior.fixation.FixGridStp      = [2, 2]; % x,y coordinates in a 9pt grid
SS.behavior.fixation.FixSPotStp      = 0.1;    % change of the size of the fixation window upon key press
SS.behavior.fixation.GridPos         = 5;      % cntral fixation position (for pure offset correction)

SS.behavior.fixation.FixWinStp       = 0.25;   % change of the size of the fixation window upon key press

SS.behavior.fixation.NumSmplCtr      = 10;     % number of recent samples to use to determine current (median) eye position (has to be smaller than SS.pldaps.draw.eyepos.history)

% rig specific eye calibration parameter
switch rig
    case 1
        % defaults before Screen Resize 6/22/20
        SS.eyeCalib.defaultGain      = [-14.8258 -13.2805];  % default gain, used if no calibration points are entered
        SS.eyeCalib.defaultOffset    = [-0.9830, -1.7773];    % default offset, used if no calibration points are entered
     
    case 2
        % defaults before Screen Resize 
        SS.eyeCalib.defaultGain      = [-14.8258 -13.2805];  % default gain, used if no calibration points are entered
        SS.eyeCalib.defaultOffset    = [-0.9830, -1.7773];  % default offset, used if no calibration points are entered
        
    otherwise
        % defaults before Screen Resize 
        SS.eyeCalib.defaultGain      = [-14.8258 -13.2805];  % default gain, used if no calibration points are entered
        SS.eyeCalib.defaultOffset    = [-0.9830, -1.7773];    % default offset, used if no calibration points are entered
end

% Define fixation states
SS.FixState.Current     = NaN;
SS.FixState.FixOut      =    0;  % Gaze out of fixation window
SS.FixState.startingFix = 0.25;  % Gaze has momentarily entered fixation window
SS.FixState.FixIn       =    1;  % Gaze robustly within fixation window
SS.FixState.breakingFix = 0.75;  % Gaze has momentarily left fixation window

% ------------------------------------------------------------------------%
%% Stimuli
SS.stim.allStims       = {}; % Cell array to store references of all the stims created
SS.stim.record.arrays  = {}; % Cell array to store arrays of properties each time a stimuli comes on.
SS.stim.record.structs = {}; % Cell array to store the properties of stims as they come on (but in struct form).

% Default position for stimuli to be generated
SS.stim.pos = [0,0];

% fixation window
SS.stim.fixWin                       =  2.5;  % diameter of fixation window in dva
SS.pldaps.draw.eyepos.history        = 60;  % show eye position of the previous n frames in addition to current one
SS.pldaps.draw.eyepos.sz             = 8;   % size in pixels of the eye pos indicator
SS.pldaps.draw.eyepos.fixwinwdth_pxl = 2;   % frame width of the fixation window in pixels

% Fixation spot stimuli
SS.stim.FIXSPOT.pos          = [0,0];
SS.stim.FIXSPOT.fixWin       =  2.0;        % diameter of fixation window in dva
SS.stim.FIXSPOT.type         = 'disc';    % shape of fixation target, options implemented atm are 'disc' and 'rect', or 'off'
SS.stim.FIXSPOT.color        = 'fixspot'; % color of fixation spot (as defined in the lookup tables)
SS.stim.FIXSPOT.size         = 0.2;       % size of the fixation spot
SS.behavior.fixation.fix.pos = [0,0];     % Somethings may rely on this, will be overwritten upon creation of first FixSpot

% Sine Wave Grating stimlui
SS.stim.GRATING.sFreq    = 3; % Spatial frequency, cycles/deg
SS.stim.GRATING.tFreq    = 0; % Temporal frequency, drift speed. 0 is no drift
SS.stim.GRATING.angle    = 0; % Rotation
SS.stim.GRATING.contrast = 1;
SS.stim.GRATING.res      = 1000; % Half the size of the texture matrix
SS.stim.GRATING.radius   = 1;
SS.stim.GRATING.contrastMethod = 'balanced';
SS.stim.GRATING.pos      = [0, 0];
SS.stim.GRATING.fixWin   =  4;  
SS.stim.GRATING.alpha    = 1; % Fully opaque
SS.stim.GRATING.hemifield = NaN;
% SS.stim.GRATING.srcRadius  = 500; % Big source to allow for more resolution

SS.stim.DRIFTGABOR.fixWin       = 2;
SS.stim.DRIFTGABOR.size         = [5, 5]; %this controls stim texture size, not size of stim shown
SS.stim.DRIFTGABOR.frequency    = 3;
SS.stim.DRIFTGABOR.angle        = 45;
SS.stim.DRIFTGABOR.phase        = 0;
SS.stim.DRIFTGABOR.sigma        = 0.4; %this wraps stim texture with Gaussian envelope, controlling on-screen stim size
SS.stim.DRIFTGABOR.contrast     = 1;
SS.stim.DRIFTGABOR.alpha        = 1;
SS.stim.DRIFTGABOR.pos          = [0, 0];

% Ring (i.e. location cue)
SS.stim.RING.pos       = [0,0];
SS.stim.RING.size      = 2;
SS.stim.RING.linewidth = 0.1;
SS.stim.RING.color     = 'fixspot'; 
SS.stim.RING.fixWin    = 2;
SS.stim.RING.alpha     = 1; % Fully opaque

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
SS.datapixx.adc.TTLamp       =  3;  % amplitude of TTL pulses via adc

SS.datapixx.TTLdur           = [];  % depending on the DAQ sampling rate it might be necessary to ensure a minimum duration of the TTL pulse
SS.datapixx.EVdur            = [];  % depending on the DAQ sampling rate it might be necessary to ensure a minimum duration of the strobe signal

SS.datapixx.TTL_trialOn      = 1;   % if 1 set a digital output high while trial is active
SS.datapixx.TTL_trialOnChan  = 1;   % DIO channel used for trial state TTL

% ------------------------------------------------------------------------%
%% TTL pulse series for pico spritzer
SS.datapixx.TTL_spritzerChan      = 5;    % DIO channel
SS.datapixx.TTL_spritzerDur       = 0.01; % duration of TTL pulse
SS.datapixx.TTL_spritzerNpulse    = 1;    % number of pulses in a series
SS.datapixx.TTL_spritzerPulseGap  = 0.01; % gap between subsequent pulses

SS.datapixx.TTL_spritzerNseries   = 1;    % number of pulse series
SS.datapixx.TTL_spritzerSeriesGap    = 30;   % gap between subsequent series

% ------------------------------------------------------------------%

%% Stimulation/Drug Injection
SS.Drug.DoStim     = 0;       % activate module to control drug application
SS.Drug.StimTrial  = 0;       % Is the current trial a drug trial
SS.Drug.StimTrial  = 0;       % Is the current trial a drug trial
SS.Drug.StimDesign = 'block'; % What design (block, random, condition)
SS.Drug.StimTime   = 0;       % application time relative to task start
SS.Drug.LastStim   = NaN;     % when was the last drug applicatio
SS.Drug.StimBlock  = 'trial'; % how to define a block, based on 'trial' or based on 'time'

% ------------------------------------------------------------------------%
%% Control screen flips
SS.pldaps.draw.ScreenEvent     = [];      % no event awaiting, otherwise use event code to be sent to TDT
SS.pldaps.draw.ScreenEventName = {};      % keep track of times in pldaps data file

% ------------------------------------------------------------------------%
%% Keyboard assignments
% assign keys to specific functions here and utilize these in the
% ND_CheckKey function to trigger defined actions.
KbName('UnifyKeyNames');

SS.key.reward    = KbName('space');  % trigger reward
SS.key.quit      = KbName('ESCAPE'); % end experiment
SS.key.pause     = KbName('p');      % pause the experiment
SS.key.break     = KbName('b');      % give a break
SS.key.CtrJoy    = KbName('j');      % set current joystick position as zero

% controll fix win
SS.key.FixInc    = KbName('=+');     % increase size of fixation window
SS.key.FixDec    = KbName('-_');     % decrease size of fixation window

% trigger pico spritzer injection
SS.key.spritz    = KbName('tab');    % Send a TTL pulse over the analog channel connected to the pico spritzer

% block controll
SS.key.BlockAdvance      = KbName('a'); % advance to next block
SS.key.BlockEqualCorrect = KbName('s'); % switch between accepting only correct trials or all trials

% eye calibration
SS.key.viewEyeCalib      = KbName('insert'); % View the current calibration points on screen
SS.key.CalibrateEyeOffset= KbName('Home'); % toggle between off, xTweak and yTweak for offset
SS.key.CalibrateEyeGain  = KbName('End'); % toggle between off, xTweak and yTweak for gain
SS.key.CalibrateEyeUp    = KbName('PageUp'); %increase or move offset/gain up
SS.key.CalibrateEyeDown  = KbName('PageDown'); %decrease oe move offset/gain down

% Keys for freeing the keyboard, allowing for use in other programs while the task is going
SS.pldaps.keyboardFree   = 0; % Start with PLDAPS interpretting key strokes.
SS.key.freeKeyboard      = KbName('k');   % Enable standard keyboard input
SS.key.stopFreeKeyboard  = KbName('end'); % If the keyboard is enabled, go back to standard break mode with this key

% ------------------------------------------------------------------------%
%% initialize field for editable variables
SS.editable   = {};

% ------------------------------------------------------------------------%
%% Online plots
% allow specification of a matlab routine for online data analysis
SS.plot.do_online =  0;  % run online data analysis between two subsequent trials
SS.plot.routine   = [];  % matlab function to be called for online analysis (TODO: make a default routine for the most rudimentary analysis)
SS.plot.fig       = [];  % figure handle for online plot (leave empty)
