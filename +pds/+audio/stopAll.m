function stopAll(p)
%pds.audio.stopAll(p)    stops audio output off all sound files on both
%PsychAudio and Datapixx

if p.trial.sound.use && p.trial.sound.usePsychportAudio && isfield(p.trial.sound, 'wavfiles')
    fn=fieldnames(p.trial.sound.wavfiles);
    for iFile = 1:length(fn)
        PsychPortAudio('Stop', p.trial.sound.(fn{iFile}));
    end
end