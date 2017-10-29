function p = setupAudio(p)
% pds.audio.setupAudio  loads the audio files from dirs.wavfiles, then sets
% up PsychPortAudio and Datapixx to be able to play them

if p.defaultParameters.sound.use && isfield(p.defaultParameters.pldaps.dirs, 'wavfiles')
    
    % Get every filename of the sounds in the wavfiles directory 
    soundDir = p.defaultParameters.pldaps.dirs.wavfiles;
    soundDirFiles = dir(soundDir);
    soundDirFiles = {soundDirFiles.name};
    soundFiles = find(~cellfun(@isempty,strfind(soundDirFiles,'.wav')));
    
    % Setup to write to Datapixx, if enabled
    if p.defaultParameters.sound.useDatapixx
        Datapixx('InitAudio');
        Datapixx('SetAudioVolume', [p.defaultParameters.sound.datapixxVolume, p.defaultParameters.sound.datapixxInternalSpeakerVolume]);
        Datapixx('RegWrRd');
        
        % Set the base buffer location where the sounds will be written
        nextBuf = 16e6;
    end
    
    % Setup to write to PsychPortAudio, if enabled
    if p.defaultParameters.sound.usePsychPortAudio
        InitializePsychSound;
        
        % open a PsychPortAudio master device. Master devices themselves are
        % not directly used to playback or capture sound. Instead one can
        % create (multiple) slave devices that are attached to a master device.
        % Each slave can be controlled independently to playback or record
        % sound through a subset of the channels of the master device. This
        % basically allows to virtualize a soundcard.
        if ~isempty(p.defaultParameters.sound.deviceid)
            devices = PsychPortAudio('GetDevices');
            deviceId = [devices.DeviceIndex] == p.defaultParameters.sound.deviceid;
            p.defaultParameters.sound.master = PsychPortAudio('Open', deviceId, 1+8, 1, devices(deviceId).DefaultSampleRate, 2);
            PsychPortAudio('Start', p.defaultParameters.sound.master, 0, 0, 1);
        else % load with default settings
            p.defaultParameters.sound.master=PsychPortAudio('Open', p.defaultParameters.sound.deviceid, 1+8, 1, [], []);
            PsychPortAudio('Start', p.defaultParameters.sound.master, 0, 0, 1);
        end
        
        % set the volume
        PsychPortAudio('Volume', p.defaultParameters.sound.master, p.defaultParameters.sound.psychPortVolume);
    end
    
    %% Iterate through all the wav files
    for iFile = soundFiles
        filename = soundDirFiles{iFile};
        filepath = fullfile(soundDir, filename);
        
        name = filename(1:end-4);
        
        p.defaultParameters.sound.(name).wavfile = filepath;
        
        % Load the wav file into memory
        [wav, sampleRate] = audioread(filepath);
        wav = wav';
        
        % Store the attributes of the sound
        nSamples = size(wav,2);
        nChannels = size(wav,1);
        p.defaultParameters.sound.(name).sampleRate = sampleRate;
        p.defaultParameters.sound.(name).nSamples = nSamples;
        p.defaultParameters.sound.(name).nChannels = nChannels;
        
        %% Load the sound into device memory for Datapixx
        if p.defaultParameters.sound.useDatapixx
            p.defaultParameters.sound.(name).buf = nextBuf;
            [nextBuf,~,overflow] = Datapixx('WriteAudioBuffer', wav, nextBuf);
            if overflow==1
                disp('Too many sound files provided; failed to load all sounds.')
            end
        end
        
        %% Load the sound into device memory PsychPortAudio
        if p.defaultParameters.sound.usePsychPortAudio
            % If wav file is a mono stream, duplicate into a stereo stream
            if nChannels == 1
                wav = [wav;wav];
            end
            
            % Create a different PsychPortAudio buffer for left, right, and
            % both(stereo) playback
            
            % Left 
            paLeft = PsychPortAudio('OpenSlave', p.defaultParameters.sound.master, 1, 1, [1]);
            PsychPortAudio('FillBuffer',paLeft, wav(1,:));                    
            p.defaultParameters.sound.(name).paLeft = paLeft;
            
            %Right
            paRight = PsychPortAudio('OpenSlave', p.defaultParameters.sound.master, 1, 1, [2]);
            PsychPortAudio('FillBuffer',paRight, wav(2,:));                   
            p.defaultParameters.sound.(name).paRight = paRight;
            
            %Both
            paBoth = PsychPortAudio('OpenSlave', p.defaultParameters.sound.master, 1, 2, [1,2]);
            PsychPortAudio('FillBuffer',paBoth, wav);                    
            p.defaultParameters.sound.(name).paBoth = paBoth;
            
        end
    end
end