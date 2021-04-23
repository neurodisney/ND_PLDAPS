function ND_SendStimRecord(p)
%% Send the record of all the stims that have been shown

stimRecord = p.trial.stim.record.arrays;
nStims = length(stimRecord);

if nStims > 0
    % Start the block
    pds.datapixx.strobe(p.trial.event.STIMPROP_BLOCK_ON);
    
    for iStim = 1:nStims
        
        % Indicate new stim info incoming
        pds.datapixx.strobe(p.trial.event.STIMPROP);
        
        % Get the array that holds the stim properties
        stimProps = stimRecord{iStim};
        nProps = length(stimProps);
        
        % Send one signal for each property in the stimProps array
        % Convert floats to 16-bit words
        for iProp = 1:nProps
            property = stimProps(iProp);
            
            % The first property is a class code for the type of stim
            % Just transmit it directly
            if iProp == 1
                pds.datapixx.strobe(property);
            
            elseif property == 0
                % If the property is 0, transmit a special signal (since signals are interspersed with 0 strobes, it is lost
                % otherwise)
                pds.datapixx.strobe(p.trial.event.ZERO_CODE);
                
            else
                
                % Otherwise, save 2 decimal points of precision (must divide by 100 later)
                signal = typecast(cast(round(property * 100), 'int16'), 'uint16'); 
                pds.datapixx.strobe(signal);
            end
                
        end
        
    end
    
    pds.datapixx.strobe(p.trial.event.STIMPROP_BLOCK_OFF);
    
end
    