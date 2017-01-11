% amb_pldaps_paraminit.m
% based on: scratch-written from pldaps/README.MD
% created: ??/??/?? AMB
% last edited: 10/24/16 AMB
%
% update log: 10/24/16 AMB
% - replacing  settingsStruct with 'nd' (for neurodisney)
%
% load settingsStruct
% just spell out the settingsStruct, for ease of changing, rather than
% loading
%
% this is the highest level script to run for a pldaps training session
% a parameter structure is defined ('nd' by convention)
%



%% begin settingsStruct declaration -- rather than load file
nd.datapixx.use=1;

nd.display.scrnNum=1; % 1 is monkey-screen,0 is experimenter screen
nd.display.screenSize=[0 0 1920 1080];%.*.75; % [xtop yleft xbot yright] coordinates 
nd.display.screenCenterPx= ...
    [nd.display.screenSize(3)-...
    nd.display.screenSize(1), ...
    nd.display.screenSize(4)-...
    nd.display.screenSize(1)]/2;
% with 0,0 being top-left of screen. bigger x = lower on display
% current screenres = [1920 1080]
nd.display.normalizeColor=1;

nd.eyelink.use=0; % maybe abstract eye tracking in general from
% which proprietary system is used
nd.pldaps.draw.eyepos.use=1; % displays eyepos
nd.mouse.useAsEyePos=0; % once ET from SMI fixed (the code i 
% wrote), can set this 0

nd.sound.use=0;

nd.pldaps.pause.preExperiment=0; % not sure on this

nd.pldaps.draw.grid.use=0;

%% end settingsStruct declaration

%% begin NeuroDisney custom settingsStruct -- not yet implemented
% figure out of any of this is needed; at leat AI channel -> xy pos mapping
% is already instantiated in default pldaps 
nd.AIeyetracker.use=1;
nd.AIeyetracker.draw=1; % this is implemented
nd.AIeyetracker.chanX=1;
nd.AIeyetracker.chanY=2;
nd.AIeyetracker.chanPD=3;
nd.AIeyetracker.XYtype='pupil'; % can be gaze, pupil, pupil-CR
% chan 4 currently unused

%% end NeuroDisney custom settingsStruct 


%% begin NeuroDisney .fixTrain 

% stimulus parameters
nd.fixTrain.stimContrastPolarity=-1; % 1 or -1
nd.fixTrain.stimContrastNorm=0.1; % 0 to 1, prop. contrast
nd.fixTrain.bgColorRGB=[1 1 1]./2;%.*127; % should be 0-1!
% now overwrite the shitty basic one
nd.display.bgColor=nd.fixTrain.bgColorRGB;%./255;
nd.fixTrain.stimColorRGB=nd.fixTrain.bgColorRGB ...
    +.5.*(nd.fixTrain.stimContrastPolarity ...
    .* nd.fixTrain.stimContrastNorm);
nd.fixTrain.rewardColorRGB=[1 1/10 1/2];%[255 25 127];
nd.fixTrain.punishColorRGB=[1/2 1/4 1/8];%[128 64 32];
% lots of assumptions above, need to tidy it up
nd.fixTrain.stimType='circle';

% stimTypes to implement: 
% 'square': filled rectangle
% 'circle':
% 'line':
% 'gabor':
% 'imgfile':


% fixation window parameters
nd.fixTrain.winDraw=1;

% spatial parameters
% size
nd.fixTrain.stimSizeXYPx=[100 100]; % not independent currently
% will implement non-1 aspect ratio later
nd.fixTrain.winSizeXYGain=1.25;
nd.fixTrain.winSizeXYPx=nd.fixTrain.stimSizeXYPx ...
    .* nd.fixTrain.winSizeXYGain;

% location
nd.fixTrain.stimCenterXYPx=[0 0];
nd.fixTrain.winCenterXYPx=nd.fixTrain.stimCenterXYPx;

% bounds
nd.fixTrain.winEdgeMinX=...
    nd.display.screenCenterPx(1)-...
    nd.fixTrain.stimSizeXYPx(1)/2 ...
    ;
nd.fixTrain.winEdgeMaxX=...
    nd.display.screenCenterPx(1)+...
    nd.fixTrain.stimSizeXYPx(1)/2 ...
    ;

nd.fixTrain.winEdgeMinY=...
    nd.display.screenCenterPx(2)-...
    nd.fixTrain.stimSizeXYPx(2)/2 ...
    ;
nd.fixTrain.winEdgeMaxY=...
    nd.display.screenCenterPx(2)+...
    nd.fixTrain.stimSizeXYPx(2)/2 ...
    ;

% temporal parameters
nd.fixTrain.acquireTS=2;% 2;
nd.fixTrain.holdTS=2;%.25;
nd.fixTrain.slopTS=.05; % amount of time fixation is allowed to
%leave window; not yet implemented
nd.fixTrain.preStimTS=1;
nd.fixTrain.failTS=5;
nd.fixTrain.goodTS=5;

% trial progress/outcome properties
nd.fixTrain.epoch=0;
% 0 = start of trial
% 1 = preStimEpoch
% 2 = stimOn
% 3 = stimAcqTimeOut
% 4 = fixOn
% 5 = fixBroken
% 6 = fixCompleted
% 7 = rewardState % combined w 6 for now
% 8 = itiCompleted % dont need, with 6-7
% 9 = itiAborted % dont need, really, with 3
nd.fixTrain.preStimTOn=NaN;
nd.fixTrain.acquireTOn=NaN;
nd.fixTrain.fixTOn=NaN;
nd.fixTrain.failTOn=NaN;
nd.fixTrain.goodTOn=NaN;
nd.fixTrain.currT=NaN;
%% end NeuroDisney FixTrain

%% map ND-novel onto PLDAPS
nd.stimulus.eyeW=nd.fixTrain.stimSizeXYPx(1);
%


p=pldaps(@plainAMBHack1,'test',nd);

p.defaultParameters.datapixx.adc.channels                        = [0, 1, 2, 4, 5];
%p.defaultParameters.datapixx.adc.channelMapping                  = {'datapixx.adcdata'};   % Specify where to store the collected data.
p.defaultParameters.datapixx.adc.channelMapping                  = {'eye.X', 'eye.Y', 'eye.PD', 'joystick.X', 'joystick.Y'};   % Specify where to store the collected data.
p.defaultParameters.datapixx.useForReward                        = 1; 
p.defaultParameters.datapixx.useAsEyepos                         = 1;   

% p.defaultParameters.datapixx.adc
p.defaultParameters.pldaps.draw.framerate.use=1; % this enables my text display
p.defaultParameters.pldaps.draw.framerate.show=0; % this is for the weird
% build-in graph
% p.defaultParameters.datapixx.use=1;
% p.defaultParameters.datapixx.adc.XEyeposChannel=0;
% p.defaultParameters.datapixx.adc.YEyeposChannel=1;
% p.defaultParameters.datapixx.adc.srate=500;
p.defaultParameters.pldaps.dirs.data='/home/rig1-user/Data/src/amb_code';
% p.defaultParameters.session.experimentFile='plainAMBHack1';


% p.defaultParameters.eyelink.use=1;
% p.defaultParameters.eyelink.useAsEyepos=1;
%p.defaultParameters.mouse.useAsEyePos=0; % step 1, should be defau %
%redundant, defined before p is createdpl

% p.defaultParameters.pldaps.draw.eyepos.use=0; % implement later % defined
% before p is created
% is 1 by default
% p.defaultParameters.pldaps.draw.cursor=1; % literally nothing!
%Datapixx('Reset')
Datapixx('Close')
% pause(2); disp('pausing 2s for dpx reset')
Datapixx('Open'); % Opens communication with PROPixx Controller
Datapixx('StopAllSchedules'); % Stops any I/O schedules that were running before
Datapixx('EnableAdcFreeRunning'); % Start up free-running sampling of voltages at ADCs

p.run
Datapixx('Close')
sca
disp('masterscript has finished running')

% ans = 
% 
%       bufferAddress: []
%        channelGains: 1
%      channelMapping: 'datapixx.adc.data'
%        channelModes: 0
%      channelOffsets: 0
%            channels: []
%          maxSamples: 0
%     numBufferFrames: 600000
%               srate: 1000
%          startDelay: 0
%      XEyeposChannel: []
%      YEyeposChannel: []
