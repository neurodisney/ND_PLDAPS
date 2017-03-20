function p = setupAudio(p)
% pds.audio.setupAudio  loads the audio files from dirs.wavfiles, then sets
% up PsychportAudio and Datapixx to be able to play them

if p.trial.sound.use && isField(p.trial, 'pldaps.dirs.wavfiles')
    
    % Get every filename of the sounds in the wavfiles directory 
    soundDir = p.trial.pldaps.dirs.wavfiles;
    soundDirFiles = dir(soundDir);
    soundDirFiles = {soundDirFiles.name};
    soundFiles = find(~cellfun(@isempty,strfind(soundDirFiles,'.wav')));
    
    % Setup to write to Datapixx, if enabled
    if p.trial.sound.useDatapixx
        Datapixx('InitAudio');
        Datapixx('SetAudioVolume', p.trial.sound.datapixxVolume);
        Datapixx('RegWrRd');
        
        % Set the base buffer location where the sounds will be written
        nextBuf = 16e6;
    end
    
    % Setup to write to PsychportAudio, if enabled
    if p.trial.sound.usePsychportAudio
        InitializePsychSound;
        
        % open a PsychPortAudio master device. Master devices themselves are
        % not directly used to playback or capture sound. Instead one can
        % create (multiple) slave devices that are attached to a master device.
        % Each slave can be controlled independently to playback or record
        % sound through a subset of the channels of the master device. This
        % basically allows to virtualize a soundcard.
        if ~isempty(p.trial.sound.deviceid)
            devices = PsychPortAudio('GetDevices');
            deviceId = [devices.DeviceIndex] == p.trial.sound.deviceid;
            p.trial.sound.master = PsychPortAudio('Open', deviceId, 1+8, 1, devices(deviceId).DefaultSampleRate, 2);
            PsychPortAudio('Start', p.trial.sound.master, 0, 0, 1);
        else % load with default settings
            p.trial.sound.master=PsychPortAudio('Open', p.trial.sound.deviceid, 1+8, 1, [], []);
            PsychPortAudio('Start', p.trial.sound.master, 0, 0, 1);
        end
        
        % set the volume
        PsychPortAudio('Volume', p.trial.sound.master, p.trial.sound.psychportVolume);
    end
    
    %% Iterate through all the wav files
    for iFile = soundFiles
        filename = soundDirFiles{iFile};
        filepath = fullfile(soundDir, filename);
        
        name = filename(1:end-4);
        
        p.trial.sound.(name).wavfile = filepath;
        
        % Load the wav file into memory
        [wav, sampleRate] = audioread(filepath);
        wav = wav';
        
        % Store the attributes of the sound
        nSamples = size(wav,2);
        nChannels = size(wave,1);
        p.trial.sound.(name).sampleRate = sampleRate;
        p.trial.sound.(name).nSamples = nSamples;
        p.trial.sound.(name).nChannels = nChannels;
        
        % Load the sound into device memory for Datapixx
        if p.trial.sound.useDatapixx
            p.trial.sound.(name).buf = nextBuf;
            [nextBuf,~,overflow] = Datapixx('WriteAudioBuffer', wav, nextBuf);
            if overflow==1
                disp('Too many sound files provided; failed to load all sounds.')
            end
        end
        
        % Load the sound into device memory PsychportAudio
        if p.trial.sound.usePsychportAudio
            pahandle = PsychPortAudio('OpenSlave', p.trial.sound.master, 1, nChannels);
            PsychPortAudio('FillBuffer',pahandle, wav)
            
            p.trial.sound.(name).pahandle = pahandle;
        end
    end
end