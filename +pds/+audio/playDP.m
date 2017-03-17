function p=playDP(p,soundName)

%play a sound that has been buffered in the datapixx audiobuffer
%input: p pldaps structure
% soundName: string specifying wavfile to be played

if p.trial.sound.use
    
    buf=p.trial.sound.datapixx.(soundName).buf;
    freq=p.trial.sound.datapixx.(soundName).freq;
    nSamples=p.trial.sound.datapixx.(soundName).nSamples;
    nChannels=p.trial.sound.datapixx.(soundName).nChannels;
    
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
