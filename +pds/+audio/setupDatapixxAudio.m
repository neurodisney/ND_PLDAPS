function p=setupDatapixxAudio(p)

%instead of using psychportaudio, this setup uses the datapixx to generate
%audio output

if p.trial.sound.use && isField(p.trial, 'pldaps.dirs.wavfiles')

    Datapixx('InitAudio');
    Datapixx('SetAudioVolume', p.trial.sound.volume);   
    Datapixx('RegWrRd');
    
    soundsDir = p.trial.pldaps.dirs.wavfiles;
    
    soundDirFiles=dir(soundsDir);
    soundDirFiles={soundDirFiles.name};
    soundFiles=find(~cellfun(@isempty,strfind(soundDirFiles,'.wav')));
   
    nextBuf=16e6;
    for iFile=soundFiles
       name= soundDirFiles{iFile};
       p.trial.sound.wavfiles.(name(1:end-4))=fullfile(soundsDir,name);
       p.trial.sound.(name(1:end-4)).buf=nextBuf;
    
       [wav1, freq] = audioread(p.trial.sound.wavfiles.(name(1:end-4)));
       wav1 = wav1';
       
       p.trial.sound.(name(1:end-4)).freq=freq;
       p.trial.sound.(name(1:end-4)).nSamples=size(wav1,2);
       p.trial.sound.(name(1:end-4)).nChannels=size(wav1,1);
       
       
       
       [nextBuf,underflow,overflow]=Datapixx('WriteAudioBuffer', wav1, nextBuf);
       if overflow==1
           disp('Too many sound files provided; failed to load all sounds.')
       end
    end
end