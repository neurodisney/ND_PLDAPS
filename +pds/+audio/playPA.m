function p = playPA(p,soundName)
%pds.audio.playPA(p,soundName 
%play the sound associated with the

if(nargin<3)
    repeats = 1;
end

%  Virtual device handle
pahandle = p.trial.sound.(soundName).pahandle;

%  Find out if there is currently a sound playing on that device
status = PsychPortAudio('GetStatus',pahandle);

%  If there is a sound playing then stop it.
if(status.Active~=0)
    PsychPortAudio('Stop',pahandle);
end

PsychPortAudio('Start',pahandle);