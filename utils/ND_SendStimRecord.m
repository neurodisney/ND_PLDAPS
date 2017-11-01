function ND_SendStimRecord(p)
%% Send the record of all the stims that have been shown

stimRecord = p.trial.stim.stimRecord;
nStims = length(stimRecord);

if nStims > 0
    % Start the block
    pds.datapixx.strobe(p.trial.event.STIMPROP_BLOCK_ON);
    
    for iStim=1:nStims
        
        % Indicate new stim info incoming
        pds.datapixx.strobe(p.trial.event.STIMPROP);
        
        % Get the array that holds the stim properties
        stimProps = stimRecord{iStim};
        
        % Send one signal for each property in the stimProps array
        % Convert floats to 16-bit words
        
        
    end
    
    pds.datapixx.strobe(p.trial.event.STIMPROP_BLOCK_ON);
    
end
    