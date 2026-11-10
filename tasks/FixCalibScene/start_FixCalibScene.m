function p = start_FixCalibScene(subjname, rig)
% Start a FixCalibScene session: InitFixTrain-style eye calibration
% (same calibration keys, same calibration file and folder) where each
% successful fixation hold is followed by an image (as in ViewScene).
%
% Built from start_InitFixTrain.m and start_ViewScene.m, Nov 2026.

% ------------------------------------------------------------------------%
%% Set default variables
if(~exist('subjname','var') || isempty(subjname))
    subjname = 'tst';
end

if(~exist('rig','var') || isempty(rig))
    [~, rigname] = system('hostname');
    rig = str2num(rigname);
end

%-------------------------------------------------------------------------%
%% load default settings into a struct
SS = ND_RigDefaults(rig);

%% ################## Edit within the following block ################## %%

%% Display: colour images + experimenter overlay (same as start_ViewScene)
SS.display.useC48      = 0;
SS.display.useOverlay  = 3;
SS.display.expScrnNum  = 0;              % <-- screen of the experimenter task monitor
SS.display.expWinRect  = [0 0 960 540];  % <-- where the experimenter view sits on that screen

%% Define task related functions
exp_fun = 'FixCalibScene';

SS.pldaps.trialFunction = exp_fun;
SS.task.TaskDef         = 'FixCalibScene_taskdef';   % task parameters (re-read every trial)

% ------------------------------------------------------------------------%
%% define variables that need to passed to next trial
SS.editable = {'task.RandomPos', 'task.Color_list', 'stim.FIXSPOT.pos'};

% ------------------------------------------------------------------------%
%% Enable required components (as in start_InitFixTrain)
SS.sound.use                  = 1;
SS.sound.useDatapixx          = 1;
SS.behavior.fixation.use      = 1; % eye position is behavioral relevant
SS.behavior.joystick.use      = 0;
SS.plot.do_online             = 0;
SS.pldaps.nosave              = 0;
SS.pldaps.draw.joystick.use   = 0;
SS.pldaps.draw.eyepos.use     = 1; % draw eye position on experimenter view
SS.pldaps.draw.photodiode.use = 0;
SS.datapixx.useForReward      = 1;

SS.pldaps.draw.grid.use       = 1;

SS.datapixx.useAsEyepos       = 1;
SS.datapixx.useJoystick       = 0;
SS.datapixx.TTL_trialOn       = 0;

% calibration functionality - identical to InitFixTrain, so calibration
% files are created and saved by the same routines into the same folder
SS.behavior.fixation.useCalibration = 1;
SS.behavior.fixation.enableCalib    = 1;

SS.pldaps.GetTrialStateTimes  = 0;

SS.datapixx.adc.srate = 1000;

%% ################## Edit within the preceding block ################### %%

% ------------------------------------------------------------------------%
%% create the pldaps class and run
p = pldaps(subjname, SS, exp_fun);
p.run;

% ------------------------------------------------------------------------%
%% Ensure DataPixx is closed
if(Datapixx('IsReady'))
    Datapixx('Close');
end
