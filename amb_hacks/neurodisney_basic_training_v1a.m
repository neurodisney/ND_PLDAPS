%% script neurodisney_basic_training_v1a.m
%
% file created: 12.20.16 amb
% last updated: 12.20.16 amb
%
% basic description:
% - 
%
% changelog:
%

%% START parameter declarations

nd.behavior.reward.defaultAmount=0.05; % from ClassDef
nd.behavior.reward.give=1; % check this

nd.conditions=[]; % maybe do this after obj is created

nd.datapixx.adc.bufferAddress=[]; % not sure how to use yet, from ClassDef
nd.datapixx.adc.XEyeposchannel=0;
nd.datapixx.adc.YEyeposchannel=1;
nd.datapixx.adc.PEyediachannel=2; % ND-implemented
nd.datapixx.adc.channels = [0 1 2]; % et x,y,psz
% nd.datapixx.adc.channelGains % do this online?
nd.datapixx.adc.channelMapping='datapixx.adcdata'; % figure out how this works
nd.datapixx.adc.channelModes
nd.datapixx.adc.channelOffsets
nd.datapixx.adc.maxSamples=0; % infinite
nd.datapixx.adc.srate=500; % .5kHz for now
nd.datapixx.adc.numBufferFrames=nd.datapixx.adcsrate*60*10; % hardcode to 10 minutes
nd.datapixx.adc.startDelay=0; % no need to offset

nd.datapixx.enablePropixxCeilingMount=0;
nd.datapixx.enablePropixxRearProjection=1;
nd.datapixx.LogOnsetTimestampLevel=2;
% nd.datapixx.timestamplog=[]; % check this
nd.datapixx.use=1;
nd.datapixx.useAsEyepos=1;
nd.datapixx.useForReward=0; % currently not used

nd.display.bgColor=[1 1 1]./2; % RGB triplet on [0,1]
nd.display.colorclamp=0; % from classdef
nd.display.destinationFactorNew='GL_ONE_MINUS_SRC_ALPHA'; % look ionto
nd.display.displayName='defaultScreenParameters'; % look into
nd.display.heightcm=45; % 45 from ClassDef
nd.display.clut.blackbg=[0 0 0];
nd.display.clut.cursor=[1 0 0];
nd.display.clut.eyepos=[0 1 0];
nd.display.clut.redbg=[1 0 0];
nd.display.clut.window=[]; % find out
nd.display.ctr=[];
nd.display.ifi=[];
nd.display.movie.create=0;
nd.display.movie.frameRate=60;
nd.display.movie.ptr=0;
nd.display.normalizeColor=1; % check what this does
nd.display.overlayptr=1;
nd.display.pHeight=1080; % maybe make this detected and not hard-coded?
nd.display.ptr=0;
nd.display.pWidth=1920; % maybe make this detected and not hard-coded?
nd.display.screenSize=[0 0 nd.display.pWidth nd.display.pHeight].*.75;
nd.display.screenCenterPx= ...
    [nd.display.screenSize(3)-...
    nd.display.screenSize(1), ...
    nd.display.screenSize(4)-...
    nd.display.screenSize(1)]/2;
nd.display.scrnNum=1; % monkey-screen
nd.display.sourceFactorNew='GL_SRC_ALPHA'; % from classdef
nd.display.stereoFlip=[];
nd.display.stereoMode=0;
nd.display.switchOverlayCLUTs=0; % from classDef, mb change
nd.display.useOverlay=1; % from classDef, should keep on
nd.display.viewdist=57; % in cm
nd.display.widthcm=63; %in cm

nd.eyelink.use = false;
nd.eyelink.useAsEyepos = 0;

nd.mouse.use=0;
nd.mouse.useAsEyepos=0;
nd.mouse.useLocalCoordinates=1;% if this is 1, run sets mouse.windowPtr to display.ptr
nd.mouse.windowPtr=nd.display.ptr;

nd.pldaps.dirs.wavfiles=[]; % not currently being used
nd.pldaps.dirs.data='/home/rig1-user/Data/src/amb_code'; % TEMPORARY. FIX LATER

nd.pldaps.draw.cursor.use=0;
nd.pldaps.draw.eyepos.use=1; % this should work
nd.pldaps.draw.framerate.location=[1 1]; % screen loc in dva
nd.pldaps.draw.framerate.nSeconds=2; % how many s to graph data of
nd.pldaps.draw.framerate.show=0; % whether to display their graph
nd.pldaps.draw.framerate.size=[4 2]; % arbitrary atm
nd.pldaps.draw.framerate.use=0; % whether to calc and display txt
nd.pldaps.draw.grid.use=0;
nd.pldaps.draw.photodiode.everyXFrames=10; % rate
nd.pldaps.draw.photodiode.location=1; % [1,4]
nd.pldaps.draw.photodiode.use=0;

nd.pldaps.eyepos.movav=25;

nd.pldaps.pause.preExperiment=0; % if 1, pauses at start of exp to change params, etc
nd.pldaps.pause.type=1; % only 1 is tested (dbg), 2 (pause loop) is also an option

nd.pldaps.save.initialParametersMerged=1; %" save a merged version of all parameters before the first trial?"
nd.pldaps.save.mergedData=1; % " By default pldaps only saves changes to the trial struct in .data. When mergedData is enabled, the complete content of p.trial is saved to p.data. This can cause significantly larger files"
nd.pldaps.save.saveTempFile=0; % dont think we need

nd.pldaps.plexon.use=0;

nd.sound.deviceid=[]; % 	PsychPortAudio deviceid, empty for default
% nd.sound.reward=[] % reward sound = PsychPortAudio('Start', p.trial.sound.reward);
nd.sound.use=1;
nd.sound.useForReward=0; % disable for now

% end parameter declarations

%% START script code