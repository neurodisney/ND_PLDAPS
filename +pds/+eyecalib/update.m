function p = update(p)
% pds.eyecalib.update(p) update current eye calibration with current
% information about eye positions
%
% Nate Faber, april 2017

% This function calculates the offset and gain to best match the raw eye signal
% with the fixation points recorded

% The first point in the calibration series will be used to determine the
% offset, MUST do the first calibration point in the center
centerEye = p.trial.Calib.rawEye(1,:);
centerFix = p.trial.Calib.fixPos(1,:);

if centerFix ~= [0 0]
    warn('First calibration point must be in the center, clearing calibration points')
    p.trial.Calib.rawEye = [];
    p.trial.Calib.fixPos = [];
    return
end

p.trial.fixation.Offset = centerEye;

% Only calculate gain if more than one calibration point has been collected
nCalib = size(p.trial.Calib.rawEye,1);
if nCalib > 1
    
    % Transform the eye and fixation postions relative to this center
    relativeEye = bsxfun(@minus,p.trial.Calib.rawEye(2:end,:), centerEye);
    relativeFix = bsxfun(@minus,p.trial.Calib.fixPos(2:end,:), centerFix);
    
    % When calculating x and y gains, only use points where the fixation
    % position was not at 0
    xIndices = find(relativeFix(:,1));
    yIndices = find(relativeFix(:,2));
    
    % Get the exact gain for each point and average them together to get experimental gain.
    xGain = nanmean( relativeFix(xIndices,1) ./ relativeEye(xIndices,1) );
    yGain = nanmean( relativeFix(yIndices,2) ./ relativeEye(yIndices,2) );
    
    % Update the p struct (only if the new gain is not nan)
    oldGain = p.trial.behavior.fixation.FixGain;
    if isnan(xGain)
        xGain = oldGain(1);
    end
    if isnan(yGain)
        yGain = oldGain(2);
    end
    
    p.trial.behavior.fixation.FixGain = [xGain, yGain];
    
    if(any((p.trial.behavior.fixation.FixGain == oldGain) == 0))
        fprintf('/n >>> Fixation gain changed to [%.4f, %.4f] (was before [%.4f, %.4f]\n', ...
            p.trial.behavior.fixation.FixGain, oldGain);
    end

else
    fprintf('\n >>> Fixation offset set to [%.4f, %.4f]\n', centerEye)
end