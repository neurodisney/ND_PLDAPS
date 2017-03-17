function p = setupPA(p)
% pds.audio.setup(p)    loads audio files at the beginning of an experiment
% sets up the PsychAudio buffer and wav file e.g. used to signal the start of
% a trial for the subject.
%
% (c) jly 2012
%     jk  2015 changed to work with version 4.1 and changed to load all
%              wav files in the wav files directory
%     jly 2016 changed to handle audio slaves - deals with bug on linux
if(isField(p.trial, 'pldaps.dirs.wavfiles'))
    % initialize
    InitializePsychSound;
    
    soundsDir = p.trial.pldaps.dirs.wavfiles;
    
    soundDirFiles=dir(soundsDir);
    soundDirFiles={soundDirFiles.name};
    soundFiles=find(~cellfun(@isempty,strfind(soundDirFiles,'.wav')));
    
    % open a PsychPortAudio master device. Master devices themselves are
    % not directly used to playback or capture sound. Instead one can
    % create (multiple) slave devices that are attached to a master device.
    % Each slave can be controlled independently to playback or record
    % sound through a subset of the channels of the master device. This
    % basically allows to virtualize a soundcard.
    if ~isempty(p.trial.sound.deviceid)
        devices=PsychPortAudio('GetDevices');
        deviceId=[devices.DeviceIndex]==p.trial.sound.deviceid;
        p.trial.sound.master=PsychPortAudio('Open', p.trial.sound.deviceid, 1+8, 1, devices(deviceId).DefaultSampleRate, 2);
        PsychPortAudio('Start', p.trial.sound.master, 0, 0, 1);
    else % load with default settings
        p.trial.sound.master=PsychPortAudio('Open', p.trial.sound.deviceid, 1+8, 1, [], []);
        PsychPortAudio('Start', p.trial.sound.master, 0, 0, 1);
    end
        
    % set the volume of the master to half the system volume
    PsychPortAudio('Volume', p.trial.sound.master, 0.5);
    
    % open slave devices for each audio file
    for iFile=soundFiles
        name= soundDirFiles{iFile};
        p.trial.sound.wavfiles.(name(1:end-4))=fullfile(soundsDir,name);
        
        [y, ~] = audioread(p.trial.sound.wavfiles.(name(1:end-4)));
        wav1 = y';
        nChannels1 = size(wav1, 1);
        p.trial.sound.(name(1:end-4)) = PsychPortAudio('OpenSlave', p.trial.sound.master, 1, nChannels1);
        
        
        PsychPortAudio('FillBuffer',p.trial.sound.(name(1:end-4)), wav1);
    end
else
    p.trial.sound.use=false;
end