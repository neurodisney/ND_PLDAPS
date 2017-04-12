function p = ND_TrialPrepare(p)
% get everything ready for starting the main trial loop.
% in part taken from trialPrepare in the PLDAPS pldapsDefaultTrialFunction
%
%
% wolf zinke, Dec. 2016


%-------------------------------------------------------------------------%
%% setup PsychPortAudio %%%
% use the PsychPortAudio pipeline to give auditory feedback because it
% has less timing issues than Beeper.m -- Beeper freezes flips as long as
% it is producing sound whereas PsychPortAudio loads a wav file into the
% buffer and can call it instantly without wasting much compute time.

% Going to use datapixx for the sound, so disabling this
% pds.audio.clearBuffer(p)

%-------------------------------------------------------------------------%
%% Initialize DataPixx
% Write local register cache modifications to Datapixx immediately,
% then read back Datapixx register snapshot to local cache
% %TODO: do we need this?. Why here and not TrialSetup?
Datapixx RegWrRd;


%-------------------------------------------------------------------------%
%% Initialize Keyboard %%%
pds.keyboard.clearBuffer(p);

%-------------------------------------------------------------------------%
%% Start of trial timing
% record start of trial in Datapixx, PC & DAQ; each device has a separate clock

p.trial.timing.datapixxStartTime  = Datapixx('Gettime');
p.trial.timing.datapixxTRIALSTART = pds.tdt.strobe(p.trial.event.TRIALSTART);  % start of trial

%-------------------------------------------------------------------------%
%% Get last Screen Flip prior to trial
% This should be the last step before the main trial loop starts
% because it catches the screen flip that defines trial start

% TODO: WZ - use photo diode rect as marker for trial start as well (needs to be switched off again)

% ensure background color is correct
Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor);
p.trial.pldaps.lastBgColor = p.trial.display.bgColor;

% this is the last screen flip before trial time
vblTime = Screen('Flip', p.trial.display.ptr, 0);

p.trial.trstart = vblTime;
p.trial.stimulus.timeLastFrame = vblTime - p.trial.trstart; % WZ: This has to be the stimulus sub-struct for now because it is hard coded that way in RunTrial.

p.trial.ttime  =        GetSecs - p.trial.trstart;
p.trial.timing.syncTimeDuration = p.trial.ttime;

p.trial.TrialStart = datestr(now,'HH:MM:SS:FFF');  % WZ: added absolute time as string

p.trial.EV.TrialStart = p.trial.trstart; % WZ: added for convenience/consistency


