%% script neurodisney_joystick_trial2trial_parms_v1a.m
%
% file created: 12.20.16 amb
% last updated: 12.20.16 amb
%
% basic description:
% - this m file lists and declares a stripped-down set of variables
%    that may need to changed on a trial-to-trial basis by the experimenter
%    to advance a subject's training stage
% - the training script will run this script at during a pre/inter-trial
%    prep period and use the parameter values here for the upcoming trial
% - comment out a given parameter to not overwrite it and have the last
%    used value persevere 
% changelog:

%% START parameter declaration

nd.behavior.reward.defaultAmount=0.05; % from ClassDef
nd.behavior.reward.give=1; % check this

nd.datapixx.adc.channelGains
nd.datapixx.adc.channelMapping='datapixx.adcdata'; % figure out how this works
nd.datapixx.adc.channelModes
nd.datapixx.adc.channelOffsets

nd.display.bgColor=[1 1 1]./2; % RGB triplet on [0,1]

nd.display.clut.blackbg=[0 0 0];
nd.display.clut.cursor=[1 0 0];
nd.display.clut.eyepos=[0 1 0];
nd.display.clut.redbg=[1 0 0];
nd.display.clut.window=[]; % find out
nd.display.normalizeColor=1;
nd.display.overlayptr=1;
nd.display.switchOverlayCLUTs=0; % from classDef, mb change
nd.display.useOverlay=1; % from classDef, should keep on
nd.display.viewdist=57; % in cm
nd.display.widthcm=63; %in cm
nd.display.heightcm=45; % 45 from ClassDef
nd.display.pHeight=1080; % maybe make this detected and not hard-coded?
nd.display.pWidth=1920; % maybe make this detected and not hard-coded?
nd.display.screenSize=[0 0 nd.display.pWidth nd.display.pHeight];
nd.display.screenCenterPx= ...
    [nd.display.screenSize(3)-...
    nd.display.screenSize(1), ...
    nd.display.screenSize(4)-...
    nd.display.screenSize(1)]/2;

nd.eyelink.use=0;

nd.pldaps.draw.eyepos.use=1; % this should work
nd.pldaps.draw.framerate.location=[1 1]; % screen loc in dva
nd.pldaps.draw.framerate.nSeconds=2; % how many s to graph data of
nd.pldaps.draw.framerate.show=0; % whether to display their graph
nd.pldaps.draw.framerate.size=[4 2]; % arbitrary atm
nd.pldaps.draw.framerate.use=0; % whether to calc and display txt
nd.pldaps.draw.photodiode.everyXFrames=10; % rate
nd.pldaps.draw.photodiode.location=1; % [1,4]
nd.pldaps.draw.photodiode.use=0;

nd.pldaps.eyepos.movav=25; 

nd.pldaps.pause.type=1; % only 1 is tested, not sure if this is changed

nd.sound.deviceid=[];

nd.sound.use=1;
nd.sound.useForReward=0; % disable for now

% END parameter declaration
%% START neurodisney task-specific params
% should we rename this parameter subsection from fixTrain to something
% more general? let me know!

% stimulus shape,color parameters
nd.fixTrain.stimContrastPolarity=-1; % 1 or -1
nd.fixTrain.stimContrastNorm=0.1; % 0 to 1, prop. contrast
nd.fixTrain.bgColorRGB=[1 1 1]./2;%.*127; % should be 0-1!
nd.display.bgColor=nd.fixTrain.bgColorRGB;%./255;
nd.fixTrain.stimColorRGB=nd.fixTrain.bgColorRGB ...
    +.5.*(nd.fixTrain.stimContrastPolarity ...
    .* nd.fixTrain.stimContrastNorm);
nd.fixTrain.rewardColorRGB=[1 1/10 1/2];%[255 25 127];  WZ: [255 25 127] / 255;
nd.fixTrain.punishColorRGB=[1/2 1/4 1/8];%[128 64 32];
% lots of assumptions above, need to tidy it up
nd.fixTrain.stimType='circle';

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
nd.fixTrain.winCenterXYPx=nd.fixTrain.stimCenterXYPx; % this means the 
% stimulus center:fixation window center are yoked. making these
% dissociable allows us the flexibility to easily implement tasks such as
% an anti-saccade paradigm

% bounds -- this assumes the stimulus is cetnered
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
% END neurodisney task-specific params

% temporal parameters
nd.fixTrain.acquireTS=2;% 2;
nd.fixTrain.holdTS=2;%.25;
nd.fixTrain.slopTS=.05; % amount of time fixation is allowed to
%leave window; not yet implemented
nd.fixTrain.preStimTS=1;
nd.fixTrain.failTS=5;
nd.fixTrain.goodTS=5;

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

% new