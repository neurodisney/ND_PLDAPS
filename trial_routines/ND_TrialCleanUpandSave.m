function p = ND_TrialCleanUpandSave(p)
% Finish up the trial.
% in part taken from cleanUpandSave in the PLDAPS pldapsDefaultTrialFunction
%
% TODO: watch PLDAPS future development for changes in hardware cleanUpandSave 
%       methods that will include part of this functionality. Avoid duplication!
%
% wolf zinke, Dec. 2016

% might be moved to pds.datapixx.cleanUpandSave
[p.trial.timing.flipTimes(:,p.trial.iFrame)] = deal(Screen('Flip', p.trial.display.ptr));

%-------------------------------------------------------------------------%
%% Ensure correct background color and determine trial end and duration
Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor);
p.trial.pldaps.lastBgColor = p.trial.display.bgColor;

vblTime = Screen('Flip', p.trial.display.ptr,0);

p.trial.trialend                = vblTime;
p.trial.trialduration           = vblTime - p.trial.trstart;

p.trial.timing.datapixxTrialEnd = PsychDataPixx('GetPreciseTime');

%-------------------------------------------------------------------------%
%% end DataPixx ( since we use it no if querry needed
if(p.trial.datapixx.use)
    p.trial.datapixx.datapixxstoptime = Datapixx('GetTime'); % WZ: Does this need to be called first or could it be combined with the following if block?
end

pds.datapixx.adc.cleanUpandSave(p);

% WZ: Is this just plexon related?
if(p.trial.datapixx.use)
    p.trial.timing.datapixxTRIALEND = pds.datapixx.flipBit(p.trial.event.TRIALEND,p.trial.pldaps.iTrial);  % start of trial (Plexon)
end

%-------------------------------------------------------------------------%
%% End Photo Diode
if(p.trial.pldaps.draw.photodiode.use)
    p.trial.timing.photodiodeTimes(:, p.trial.pldaps.draw.photodiode.dataEnd:end) = [];
end

%-------------------------------------------------------------------------%
%% End Keyboard
KbQueueStop();
KbQueueFlush();

p.trial.keyboard.samplesTimes(       :, p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.samplesFrames(      :, p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.pressedSamples(     :, p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.firstPressSamples(  :, p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.firstReleaseSamples(:, p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.lastPressSamples(   :, p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.lastReleaseSamples( :, p.trial.keyboard.samples+1:end) = [];

%-------------------------------------------------------------------------%
%% end mouse
if(p.trial.mouse.use)
    p.trial.mouse.cursorSamples(     :, p.trial.mouse.samples+1:end) = [];
    p.trial.mouse.buttonPressSamples(:, p.trial.mouse.samples+1:end) = [];
    p.trial.mouse.samplesTimes(      :, p.trial.mouse.samples+1:end) = [];
end

%-------------------------------------------------------------------------%
%% Trial information
p.trial.trialnumber   = p.trial.pldaps.iTrial;

% system timing
p.trial.timing.flipTimes             = p.trial.timing.flipTimes(:, 1:p.trial.iFrame);  % WZ: Why here again? Was defined at the function start...
p.trial.timing.frameStateChangeTimes = p.trial.timing.frameStateChangeTimes(:, 1:p.trial.iFrame - 1);

%-------------------------------------------------------------------------%
%%  clean up data
% TODO: remove entries in the trial struct that need not to be written but
% might occupy a lot of disk space.

%-------------------------------------------------------------------------%
%%  reward system
% TODO: Is this needed?
pds.behavior.reward.cleanUpandSave(p);
