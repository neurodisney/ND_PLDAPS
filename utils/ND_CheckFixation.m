function p = ND_CheckFixation(p)
% Read in the eye position signal and check how much it deviates from a
% defined position.
%
% Currently, it is hard coded to calculate the median for a defined number
% of recent samples in order to determine a more robust eye position.
%
%
% TODO: Define sample based on a time period not number of samples.
%
% wolf zinke, Jan. 2017
% Nate Faber, May 2017

%% get eye position data
if(p.trial.mouse.useAsEyepos)
    
    % Get the last mouse position
    iSample = p.trial.mouse.samples;
    mousePos = p.trial.mouse.cursorSamples(:,iSample); 
    
    % If manual calibration has been collected, use it. Otherwise, just use the actual mouse position
    if any(p.trial.eyeCalib.offset ~= p.trial.eyeCalib.defaultOffset)
     
        offset = p.trial.eyeCalib.offset;
        
        gain = p.trial.eyeCalib.gain;
        % If gain hasn't been changed for a particular axis, just use a gain of 1
        gain(gain == p.trial.eyeCalib.defaultGain) = 1;
        
        p.trial.eyeX = gain(1) * (mousePos(1) - offset(1));
        p.trial.eyeY = gain(2) * (mousePos(2) - offset(2));
        
    else
        % If no calibration has been specified, just use the actualy position of the mouse
        p.trial.eyeX = mousePos(1);
        p.trial.eyeY = mousePos(2);
        
    end
    
else
    sIdx = (p.trial.datapixx.adc.dataSampleCount - p.trial.behavior.fixation.Sample + 1) : p.trial.datapixx.adc.dataSampleCount;  % determine the position of the sample. If this causes problems with negative values in the first trial, make sure to use only positive indices.

    % calculate a moving average of the eye position for display reasons
    p.trial.eyeX   = p.trial.eyeCalib.gain(1) * (prctile(p.trial.AI.Eye.X(sIdx), 50) - p.trial.eyeCalib.offset(1));
    p.trial.eyeY   = p.trial.eyeCalib.gain(2) * (prctile(p.trial.AI.Eye.Y(sIdx), 50) - p.trial.eyeCalib.offset(2));
end

p.trial.eyeAmp = sqrt((p.trial.behavior.fixation.fixPos(1) - p.trial.eyeX)^2 + ...
    (p.trial.behavior.fixation.fixPos(2) - p.trial.eyeY)^2 );

%% update eye position history (per frame)
if(p.trial.pldaps.draw.eyepos.use)
    p.trial.eyeXY_draw = [p.trial.eyeX, p.trial.eyeY];
    
    p.trial.eyeX_hist = [p.trial.eyeXY_draw(1), p.trial.eyeX_hist(1:end-1)];
    p.trial.eyeY_hist = [p.trial.eyeXY_draw(2), p.trial.eyeY_hist(1:end-1)];
end

%% if relevant for task determine fixation state
if p.trial.behavior.fixation.use && p.trial.behavior.fixation.on

    switch p.trial.FixState.Current
        case p.trial.FixState.FixOut
            %% currently not fixating
            
            % Eye enters the fixation window
            if(p.trial.eyeAmp <= p.trial.behavior.fixation.FixWin/2 )
                pds.datapixx.strobe(p.trial.event.FIX_IN);
                p.trial.FixState.Current = p.trial.FixState.startingFix;
                p.trial.EV.FixEntry = p.trial.CurTime;
            end
        
        case p.trial.FixState.startingFix
            %% gaze has momentarily entered fixation window
            
            % Gaze leaves again
            if p.trial.eyeAmp > p.trial.behavior.fixation.FixWin/2
                pds.datapixx.strobe(p.trial.event.FIX_OUT);
                p.trial.FixState.Current = p.trial.FixState.FixOut;
                
            % Gaze is robustly within the fixation window
            elseif p.trial.CurTime >= p.trial.EV.FixEntry + p.trial.behavior.fixation.entryTime
                pds.datapixx.strobe(p.trial.event.FIXATION);
                p.trial.FixState.Current = p.trial.FixState.FixIn;
                p.trial.EV.FixStart = p.trial.EV.FixEntry;
            end
            
        case p.trial.FixState.FixIn
            %% gaze within fixation window

            % Eye leaves the fixation window
            if(p.trial.eyeAmp > p.trial.behavior.fixation.FixWin/2)
                pds.datapixx.strobe(p.trial.event.FIX_OUT);
                
                % Set state to fixbreak to ascertain if this is just jitter (time out of fixation window is very short)
                p.trial.FixState.Current = p.trial.FixState.breakingFix;
                p.trial.EV.FixLeave = p.trial.CurTime;
            end
        
        case p.trial.FixState.breakingFix
            %% gaze has momentarily left fixation window    
            
            % Eye has re-entered fixation window
            if p.trial.eyeAmp <= p.trial.behavior.fixation.FixWin/2
                pds.datapixx.strobe(p.trial.event.FIX_IN);
                p.trial.FixState.Current = p.trial.FixState.FixIn;
            
            % Eye has not re-entered fix window in time
            elseif p.trial.CurTime > p.trial.EV.FixLeave + p.trial.behavior.fixation.BreakTime
                pds.datapixx.strobe(p.trial.event.FIX_BREAK);
                p.trial.FixState.Current = p.trial.FixState.FixOut;
                p.trial.EV.FixBreak = p.trial.EV.FixLeave;
            end
       
        otherwise
            %% Initially nan, just get the current state
            if(isnan(p.trial.FixState.Current))
                if(p.trial.eyeAmp > p.trial.behavior.fixation.FixWin/2)
                    p.trial.FixState.Current = p.trial.FixState.FixOut;

                elseif(p.trial.eyeAmp <= p.trial.behavior.fixation.FixWin/2)
                    p.trial.FixState.Current = p.trial.FixState.FixIn;
                    p.trial.EV.FixStart = p.trial.CurTime;

                else
                    p.trial.FixState.Current = NaN;
                end
            else
                error('Unknown fixation state!');
            end
    end  % switch p.FixState.Current
end  % if(p.trial.behavior.fixation.use)

