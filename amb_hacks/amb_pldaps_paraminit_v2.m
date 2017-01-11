% amb_pldaps_paraminit.m
% created xx/xx/16 AMB
% based on demo from pldaps/README.md
% last edited 11/28/16 AMB
% changelog:
%
% previous notes:
% load settingsStruct
% just spell out the settingsStruct, for ease of changing, rather than
% loading
%Screen('Preference', 'ConserveVRAM', 64); Screen('Preference', 'SkipSyncTests', 1);

%% behavior
nd.behavior.reward.defaultAmount=0.05; % from ClassDef
nd.behavior.reward.give=1; % check this
% nd.behavior.reward.iReward internally used
% nd.behavior.reward.timeReward internally used
% end behavior param def

nd.conditions=[]; % maybe do this after obj is created

%% datapixx
nd.datapixx.adc.bufferAddress=[]; % not sure how to use yet, from ClassDef
nd.datapixx.adc.XEyeposchannel=0;
nd.datapixx.adc.YEyeposchannel=1;
nd.datapixx.adc.PEyediachannel=2;
nd.datapixx.adc.channels = [0 1 2]; % et x,y,psz
% nd.datapixx.adc.channelGains
nd.datapixx.adc.channelMapping='datapixx.adcdata'; % figure out how this works
% nd.datapixx.adc.channelModes
% nd.datapixx.adc.channelOffsets
nd.datapixx.adc.maxSamples=0; % infinite
nd.datapixx.adc.srate=500; % .5kHz for now
nd.datapixx.adcsrate=1000; % we added this
nd.datapixx.adc.numBufferFrames=nd.datapixx.adcsrate*60*10; % hardcode to 10 minutes
nd.datapixx.adc.startDelay=0; % no need to offset

nd.datapixx.enablePropixxCeilingMount=0;
nd.datapixx.enablePropixxRearProjection=1;
nd.datapixx.LogOnsetTimestampLevel=2;
nd.datapixx.timestamplog=[]; % check this
nd.datapixx.use=1;
nd.datapixx.useAsEyepos=1;
nd.datapixx.useForReward=0; % currently not used
% end datapixx params

%% display

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
nd.display.frate=60; % we added this
nd.display.movie.create=0;
nd.display.movie.frameRate=60;
nd.display.movie.ptr=0;
nd.display.normalizeColor=1;
nd.display.overlayptr=1;
nd.display.pHeight=1080; % maybe make this detected and not hard-coded?
nd.display.ptr=0;
nd.display.pWidth=1920; % maybe make this detected and not hard-coded?
nd.display.screenSize=[0 0 nd.display.pWidth nd.display.pHeight];
% nd.display.screenCenterPx=[nd.display.pWidth nd.display.pHeight]./2;
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
% end display param defs

%% eyelink -- should all be deprecated/unused, but putting here for completion for now
% nd.	eyelink.	buffereventlength = 30;
% nd.	eyelink.	buffersamplelength = 31;
% nd.	eyelink.	calibration_matrix = [ ];
% nd.	eyelink.	collectQueue = true;
% nd.	eyelink.	custom_calibration = false;
% nd.	eyelink.	custom_calibrationScale = 0.2500;
% nd.	eyelink.	saveEDF = false;
nd.	eyelink.	use = false;
nd.	eyelink.	useAsEyepos = 0;
% nd.	eyelink.	useRawData = false;
% end eyelink paramdef

%% keyboard -- codes defined by /PLDAPS/+pds/+keyboard/setup.m
% keyboard.codes.dKey
% keyboard.codes.mKey
% keyboard.codes.pKey
% keyboard.codes.qKey
% keyboard.codes.xKey
% -- the below dont need to be init'd
% keyboard.firstPressedSamples
% keyboard.firstPressQ
% keyboard.firstReleaseSamples
% keyboard.lastPressSamples
% keyboard.lastReleaseSamples
% keyboard.nCodes % defined by setup as above
% keyboard.pressedQ
% keyboard.pressedSamples
% keyboard.samples
% keyboard.samplesFrames
% keyboard.samplesTimes
% end keyboard paramdef

%% mouse params start
% mouse.buttonPressSamples % set by pldapsDefaultTrialFunction
% mouse.cursorSamples % " " 
% mouse.initalCoordinates % not in documentation
% mouse.samples
% mouse.samplesTimes
nd.mouse.use=0;
nd.mouse.useAsEyepos=0;
nd.mouse.useLocalCoordinates=1;% if this is 1, run sets mouse.windowPtr to display.ptr
nd.mouse.windowPtr=nd.display.ptr;
% end mouse paramdef

%% pds params start
% these are just functions, dont think I need. Fill in later for completion
% end pds paramdef

%% pldaps paramdef start
%% pldaps.dirs paramdef start
nd.pldaps.dirs.wavfiles=[]; % not currently being used
nd.pldaps.dirs.data='/home/rig1-user/Data/src/amb_code'; % TEMPORARY. FIX LATER
% pldaps.dirs paramdef end
%% pldaps.draw paramdef start
nd.pldaps.draw.cursor.use=0;
nd.pldaps.draw.eyepos.use=1; % this should work
nd.pldaps.draw.framerate.location=[1 1]; % screen loc in dva
%pldaps.draw.framerate.nFrames % internally calculated
nd.pldaps.draw.framerate.nSeconds=2; % how many s to graph data of
% pldaps.draw.framerate.sf.xlims% internally calculated
% pldaps.draw.framerate.sf.ylims% internally calculated
nd.pldaps.draw.framerate.show=0; % whether to display their graph
nd.pldaps.draw.framerate.size=[4 2]; % arbitrary atm
nd.pldaps.draw.framerate.use=0; % whether to calc and display txt
% pldaps.draw.grid.tick_line_matrix % internally defined
nd.pldaps.draw.grid.use=0;
%nd.pldaps.draw.photodiode.dataEnd % internal usage
nd.pldaps.draw.photodiode.everyXFrames=10; % rate
nd.pldaps.draw.photodiode.location=1; % [1,4]
%nd.pldaps.draw.photodiode.rect % internal usage
nd.pldaps.draw.photodiode.use=0;
% end pldaps.draw paramdef
%% pldaps.eyepos mparamdef start
nd.pldaps.eyepos.movav=25; % number of samples to include in movav
% nd.pldaps.eyepos.XSamplesCountSubs % internally used
% nd.pldaps.eyepos.XSamplesFieldSubs % internally used
% nd.pldaps.eyepos.YSamplesFieldSubs % internally used
% end pldaps.eyepos
%% pldaps.puase paramdef start
%nd.pldaps.pause %interally used
nd.pldaps.pause.preExperiment=0; % if 1, pauses at start of exp to change params, etc
nd.pldaps.pause.type=1; % only 1 is tested
% end pldaps.pause paramdef
%% pldaps.save paramdef start
nd.pldaps.save.initialParametersMerged=1; %" save a merged version of all parameters before the first trial?"
nd.pldaps.save.mergedData=1; % " By default pldaps only saves changes to the trial struct in .data. When mergedData is enabled, the complete content of p.trial is saved to p.data. This can cause significantly larger files"
nd.pldaps.save.saveTempFile=0; % dont think we need
% end pldaps.save paramdef
%% pldaps.trialStates paramdef start
% all internally defined/used, no need for now
% end pldaps.trialStates paramdef
%% pldaps.plexon paramdef start
nd.pldaps.plexon.use=0; % we are using TDT
% end pldaps paramdef
%% session paramdef start
% all internally used
% end session paramdef
%% sound paramdef start
nd.sound.deviceid=[]; % 	PsychPortAudio deviceid, empty for default
% nd.sound.flagBuzzer=[]; % not sure, set to 0 during replay
%nd.sound.master=[]; % internal. =PsychPortAudio('Open'
%nd.sound.reward=[] % reward sound = PsychPortAudio('Start', p.trial.sound.reward);
% need to check formatting on above!
nd.sound.use=1;
nd.sound.useForReward=0; % disable for now
%nd.sound.wavefiles % set by pds.audio.setup; vestigial/duplicate from wavdir
% end sound paramdef
%% stimulus paramdef start
% end stimulus paramdef




% old params below



%% begin settingsStruct declaration -- rather than load file
% nd.datapixx.use=0; declared elsewhere

%n d.display.scrnNum=1; % 1 is monkey-screen,0 is experimenter screen
% nd.display.screenSize=[0 0 1920 1080];%.*.75; % [xtop yleft xbot yright] coordinates
nd.display.screenCenterPx= ...
    [nd.display.screenSize(3)-...
    nd.display.screenSize(1), ...
    nd.display.screenSize(4)-...
    nd.display.screenSize(1)]/2;
% with 0,0 being top-left of screen. bigger x = lower on display
% current screenres = [1920 1080]
% nd.display.normalizeColor=1;

nd.eyelink.use=0; % maybe abstract eye tracking in general from
% which proprietary system is used
% nd.pldaps.draw.eyepos.use=1; % displays eyepos, moved up
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


p=pldaps(@plainAMBHack2,'test',nd);

%% pldaps object instance is now created
% below, inserting a block of code from plain.m
%{
% all of this is from the nargin==1 block of plain.m
% moved up front for transparency
p = defaultColors(p);
p = defaultBitNames(p);
%p.defaultParameters.good = 1; % lol rly huklab? see what this does
p.defaultParameters.pldaps.trialFunction='plainAMBHack2';
%         p.trial.pldaps.maxTrialLength = 5; % max trial dur in S
p.trial.pldaps.maxTrialLength = 20;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
% how does this not crash???
c.Nr=1; %one condition;
p.conditions=repmat({c},1,10); % the 10 is the # of trials of this condition
clear c;
p.defaultParameters.pldaps.finish = length(p.conditions);
%}
%%



% p.defaultParameters.datapixx.adc
p.defaultParameters.pldaps.draw.framerap = defaultColors(p);
p = defaultBitNames(p);
p.defaultParameters.pldaps.draw.framerate.use=1; % this enables my text display
p.defaultParameters.pldaps.draw.framerate.show=0; % this is for the weird
% build-in graph
% p.defaultParameters.datapixx.use=1;
% p.defaultParameters.nd.datapixx.adcXEyeposChannel=0;
% p.defaultParameters.nd.datapixx.adcYEyeposChannel=1;
% p.defaultParameters.nd.datapixx.adcsrate=500;
p.defaultParameters.pldaps.dirs.data='/home/rig1-user/Data/src/amb_code';
% p.defaultParameters.session.experimentFile='plainAMBHack1';


% p.defaultParameters.eyelink.use=1;
% p.defaultParameters.eyelink.useAsEyepos=1;
%p.defaultParameters.mouse.useAsEyePos=0; % step 1, should be defau
% moved up to proper section, which case is it??"? Pos or pos

% p.defaultParameters.pldaps.draw.eyepos.use=0; % implement later, moved
% up

% is 1 by default
% p.defaultParameters.pldaps.draw.cursor=1; % literally nothing!
%Datapixx('Reset')
% Datapixx('Close')
% pause(2); disp('pausing 2s for dpx reset')
% Datapixx('Open'); % Opens communication with PROPixx Controller
% Datapixx('StopAllSchedules'); % Stops any I/O schedules that were running before
% Datapixx('EnableAdcFreeRunning'); % Start up free-running sampling of voltages at ADCs

p.run
% Datapixx('Close')
sca
disp('masterscript has finished running')

% ans =
%
%       bufferAddress: []
%        channelGains: 1
%      channelMapping: 'nd.datapixx.adcdata'
%        channelModes: 0
%      channelOffsets: 0
%            channels: []
%          maxSamples: 0
%     numBufferFrames: 600000
%               srate: 1000
%          startDelay: 0
%      XEyeposChannel: []
%      YEyeposChannel: []

