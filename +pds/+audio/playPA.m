function p = playPA(p,soundName,audioChannel)
%play a sound that has been created in a PsychPortAudioDevice
% input: p pldaps structure
% soundName: string specifying wavfile to be played
% audioChannel: 'left', 'right', or 'both' specifying which speaker channel
%               defaults to 'both'

if p.trial.sound.use
    
    % Defaults
    if ~exist('audioChannel','var') || isempty(audioChannel)
        audioChannel = 'both';
    end
    
    %  Get the virtual device handle. Three were created one for each of left,
    %  right and both playback
    switch audioChannel
        case 'left'
            pahandle = p.trial.sound.(soundName).paLeft;
            
        case 'right'
            pahandle = p.trial.sound.(soundName).paRight;
            
        case 'both'
            pahandle = p.trial.sound.(soundName).paBoth;
            
        otherwise
            error('playDP: Bad audioChannel')
    end
    
    %  Find out if there is currently a sound playing on that device
    status = PsychPortAudio('GetStatus',pahandle);
    
    %  If there is a sound playing then stop it.
    if(status.Active~=0)
        PsychPortAudio('Stop',pahandle);
    end
    
    PsychPortAudio('Start',pahandle);
end