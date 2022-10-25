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
            
            if iProp == 1
                pds.datapixx.strobe(property);
           
            elseif iProp == 2
                signalx = typecast(cast(round(property * 100), 'int16'), 'uint16');
                pds.datapixx.strobe(signalx);
               
            elseif iProp == 3
                signaly = typecast(cast(round(property * 100), 'int16'), 'uint16');
                pds.datapixx.strobe(signaly);
               
            elseif iProp == 4
                signalr = typecast(cast(round(property * 100), 'int16'), 'uint16');
                radius = 18000 + signalr;
                pds.datapixx.strobe(radius);
               
            elseif iProp == 5
                signalo = typecast(cast(round(property), 'int16'), 'uint16');
                orientation = 15000 + signalo;
                pds.datapixx.strobe(orientation);
               
            elseif iProp == 6
                signalc = typecast(cast(round(property * 100), 'int16'), 'uint16');
                contrast = 3000 + signalc;
                pds.datapixx.strobe(contrast);
               
            elseif iProp == 7
                signals = typecast(cast(round(property * 100), 'int16'), 'uint16');
                sFreq = 19000 + signals;
                pds.datapixx.strobe(sFreq);
               
            elseif iProp == 8
                signalt = typecast(cast(round(property * 100), 'int16'), 'uint16');
                tFreq = 20000 + signalt;
                pds.datapixx.strobe(tFreq);
                
            end
                
        end
        
    end
    
    pds.datapixx.strobe(p.trial.event.STIMPROP_BLOCK_OFF);
    
end