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
pds.audio.clearBuffer(p)

%-------------------------------------------------------------------------%
%% Initialize DataPixx
% Write local register cache modifications to Datapixx immediately, 
% then read back Datapixx register snapshot to local cache
% %TODO: do we need this?. Why here and not TrialSetup?
if p.trial.datapixx.use
    Datapixx RegWrRd;
end

%-------------------------------------------------------------------------%
%% Initalize Keyboard %%%
pds.keyboard.clearBuffer(p);

%-------------------------------------------------------------------------%
%% Start of trial timing
% record start of trial in Datapixx, PC & DAQ; each device has a separate clock

% At the beginning of each trial, strobe a unique number to the plexon
% through the Datapixx to identify each trial. Often the Stimulus display
% will be running for many trials before the recording begins so this lets
% the plexon rig sync up its first trial with whatever trial number is on
% for stimulus display.
% SYNC clocks
% TODO move into a pds.plexon.startTrial(p) file. Also just sent the data along the trialStart flax, or a  least after?        
clocktime = fix(clock);
if(p.trial.datapixx.use)
    for(ii = 1:6)
        p.trial.datapixx.unique_number_time(ii,:) = pds.datapixx.strobe(clocktime(ii));
    end

    % TODO move into a pds.plexon.startTrial(p) file? Or is this a generic
    % datapixx thing? not really....
    p.trial.timing.datapixxStartTime  = Datapixx('Gettime');
    p.trial.timing.datapixxTRIALSTART = pds.datapixx.flipBit(p.trial.event.TRIALSTART,p.trial.pldaps.iTrial);  % start of trial (Plexon) WZ: we might need to check this in order to get it working with Tucker Davis.
end

p.trial.unique_number = clocktime;    % trial identifier


%-------------------------------------------------------------------------%
%% Get last Screen FLip prior to trial
% This should be the last step before the main trial loop starts
% because it catches the screen flip that defines trial start

% TODO: WZ - use photo diode rect as marker for trial start as well (needs to be switched off again)

vblTime = Screen('Flip', p.trial.display.ptr, 0);  % this is the last screen flip before trial time

p.trial.trstart = vblTime;
p.trial.stimulus.timeLastFrame = vblTime - p.trial.trstart; % WZ: This has to be the stimulus sub-struct for now because it is hard coded that way in RunTrial.

p.trial.ttime  =        GetSecs - p.trial.trstart;
p.trial.timing.syncTimeDuration = p.trial.ttime;

p.trial.TrialStart = datestr(now,'HH:MM:SS:FFF');  % WZ: added absolute time as string

