function ND_FrameUpdate(p)
% collect data (i.e. a hardware module) store it, and apply some processing
% to utilize it for behavioural control.
%
% Taken from pldapsDefaultTrialFunction, modified according to our needs.
%
%
% wolf zinke, Jan. 2017
% Nate Faber, Aug 2017


% ------------------------------------------------------------------------%
%% check keyboard presses
ND_CheckKey(p);   % check for key hits

% Eye calibration key presses
if p.trial.behavior.fixation.enableCalib
    pds.eyecalib.keycheck(p);
end

% ------------------------------------------------------------------------%
%% get analog data
if(~isempty(p.trial.datapixx.adc.channels))
    pds.datapixx.adc.getData(p); % get analogData from Datapixx, including eye position and joystick
end

% ------------------------------------------------------------------------%
%% Get spike data
if p.trial.tdt.use
    pds.tdt.readSpikes(p);
end
% ------------------------------------------------------------------------%
%% check joystick state
% needs to be called after pds.datapixx.adc.getData

if(p.trial.datapixx.useJoystick)
    ND_CheckJoystick(p);
end

% ------------------------------------------------------------------------%
%% % check mouse position
if(p.trial.mouse.use)
  ND_CheckMouse(p);
end

% ------------------------------------------------------------------------%
%% check fixation state
if(p.trial.datapixx.useAsEyepos || p.trial.mouse.useAsEyepos)
    ND_CheckFixation(p);
 end
