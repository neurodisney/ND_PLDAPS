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
% wolf zinke, Jan 2017
% Nate Faber, May 2017

%% get eye position data
if(p.trial.mouse.useAsEyepos)
    
    % Get the last mouse position
    iSample  = p.trial.mouse.samples;
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
    
elseif p.trial.datapixx.useAsEyepos
    sIdx = (p.trial.datapixx.adc.dataSampleCount - p.trial.behavior.fixation.Sample + 1) : p.trial.datapixx.adc.dataSampleCount;  % determine the position of the sample. If this causes problems with negative values in the first trial, make sure to use only positive indices.
    
    % calculate a moving average of the eye position for display reasons
    p.trial.eyeX   = p.trial.eyeCalib.gain(1) * (prctile(p.trial.AI.Eye.X(sIdx), 50) - p.trial.eyeCalib.offset(1));
    p.trial.eyeY   = p.trial.eyeCalib.gain(2) * (prctile(p.trial.AI.Eye.Y(sIdx), 50) - p.trial.eyeCalib.offset(2));

else
    % If neither option is enabled just fix the eyepos at 0,0
    p.trial.eyeX = 0;
    p.trial.eyeY = 0;
end

%% update eye position history (per frame)
if(p.trial.pldaps.draw.eyepos.use)
    p.trial.eyeXY_draw = [p.trial.eyeX, p.trial.eyeY];
    
    p.trial.eyeX_hist = [p.trial.eyeXY_draw(1), p.trial.eyeX_hist(1:end-1)];
    p.trial.eyeY_hist = [p.trial.eyeXY_draw(2), p.trial.eyeY_hist(1:end-1)];
end

%% Update the fixation state of all the stimuli on the screen
for i = 1:length(p.trial.stim.allStims)
    stim = p.trial.stim.allStims{i};
    checkFix(stim,p);
end

