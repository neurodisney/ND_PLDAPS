function stopAll(p)
%pds.audio.stopAll(p)    stops audio output off all sound files on both
%PsychAudio and Datapixx

if p.trial.sound.use
    
    %% Stop Datapixx Audio
    if p.trial.sound.useDatapixxAudio
        Datapixx('StopAudioSchedule')
    end
    
    %% Stop PsychPortAudio
    % Iterate through all the subfields of p.trial.sound
    if p.trial.sound.usePsychPortAudio
        fields = fieldnames(p.trial.sound);
        for soundName=fields'
            
            soundStruct = p.trial.sound.(soundName{1});
            
            % Test if field is actually a sound by testing if it has the
            % pahandle field. Otherwise it is variable or setting, like
            % .datapixxVolume
            if isfield(soundStruct,'paBoth')
                % Stop the sounds playing on the three pa channels (left, right, and both)
                PsychPortAudio('Stop',soundStruct.paLeft)
                PsychPortAudio('Stop',soundStruct.paRight)
                PsychPortAudio('Stop',soundStruct.paBoth)
            end
        end
    end
end