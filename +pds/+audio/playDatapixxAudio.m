function p=playDatapixxAudio(p,soundName)

%play a sound that has been buffered in the datapixx audiobuffer
%input: p pldaps structure
% soundName: string specifying wavfile to be played

if p.trial.sound.use
    
    buf=p.trial.sound.(soundName).buf;
    freq=p.trial.sound.(soundName).freq;
    nSamples=p.trial.sound.(soundName).nSamples;
    nChannels=p.trial.sound.(soundName).nChannels;
    
    if nChannels==1
        lrMode=0;
    else
        lrMode=3;
    end
    
    %set up audio schedule
    Datapixx('SetAudioSchedule', 0, freq, nSamples, lrMode, buf, []);
    
    %start playback (will stop on its own)
    Datapixx('StartAudioSchedule');
    Datapixx('RegWrRd');
end
