function p = playDP(p, soundName, audioChannel)
% play a sound that has been buffered in the datapixx audiobuffer
% input: p pldaps structure
% soundName: string specifying wavfile to be played
% audioChannel: 'left', 'right', or 'both' specifying which speaker channel
%               defaults to 'both'

if(p.trial.sound.use)
    % Default audioChannels
    if ~exist('audioChannel','var') || isempty(audioChannel)
        audioChannel = 'both';
    end
    
    % Get the sound attributes
    buf       = p.trial.sound.(soundName).buf;
    freq      = p.trial.sound.(soundName).sampleRate;
    nSamples  = p.trial.sound.(soundName).nSamples;
    nChannels = p.trial.sound.(soundName).nChannels;
    
    switch audioChannel        
        case 'left'
            lrMode = 1;
            
        case 'right'
            lrMode = 2;
            
        case 'both'    
            if nChannels==1
                lrMode=0; %MONO
            else
                lrMode=3; %STEREO
            end
            
        otherwise
            error('playDP: Bad audioChannel')
    end
    
    %set up audio schedule
    Datapixx('SetAudioSchedule', 0, freq, nSamples, lrMode, buf, []);
    Datapixx('RegWrRd');
    
    %start playback (will stop on its own)
    Datapixx('StartAudioSchedule');
    Datapixx('RegWrRd');
end
