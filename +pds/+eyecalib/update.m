function p = update(p)
% pds.eyecalib.update(p) update current eye calibration with current
% information about eye positions
%
% Nate Faber, april 2017
%
% This function calculates the offset and gain to best match the raw eye signal
% with the fixation points recorded

rawEye = p.trial.Calib.rawEye;
fixPos = p.trial.Calib.fixPos;

%% Calculate Offset
% Any calibration points taken at 0,0 (the center of the screen), will be
% averaged together to determine the offset.

% Find the indices where the fixPos is 0,0
centerIndices = find(~any(fixPos'));

% If offset can't be established return without changing gain.
if isempty(centerIndices)
    warning('Central calibration point must be taken')
    return
end

% Average the eye signals taken at the center to get the Offset
centerEye =  mean(rawEye(centerIndices,:), 1);
centerFix = [0,0];

oldOffset = p.trial.behavior.fixation.Offset;
newOffset = centerEye;
p.trial.behavior.fixation.Offset = newOffset;


%% Calculate Gain
% Transform the eye and fixation postions relative to this center
relativeEye = bsxfun(@minus,p.trial.Calib.rawEye(2:end,:), centerEye);
relativeFix = bsxfun(@minus,p.trial.Calib.fixPos(2:end,:), centerFix);

% When calculating x and y gains, only use points where the fixation
% position was not at 0
xIndices = find(relativeFix(:,1));
yIndices = find(relativeFix(:,2));

% Get the exact gain for each point and average them together to get experimental gain.
xGain = nanmean( relativeFix(xIndices,1) ./ relativeEye(xIndices,1) , 1);
yGain = nanmean( relativeFix(yIndices,2) ./ relativeEye(yIndices,2) , 1);

% Update the p struct (only if the new gain is not nan)
oldGain = p.trial.behavior.fixation.FixGain;
if isnan(xGain)
    xGain = oldGain(1);
end
if isnan(yGain)
    yGain = oldGain(2);
end

newGain = [xGain, yGain];
p.trial.behavior.fixation.FixGain = newGain;

%% Display info
disp('Current Calibration:')

% Offset
if all(oldOffset == newOffset)
    % Nothing changed, just display the offset
    fprintf('Offset = [%.4f, %.4f]\n',newOffset);
else
    % Offset changed, display the change
    fprintf('Offset = [%.4f, %.4f] <- [%.4f, %.4f]\n', newOffset, oldOffset);
end

% Gain
if all(oldGain == newGain)
    % Nothing changed, just display the gain
    fprintf('Gain   = [%.4f, %.4f]\n\n',newGain);
else
    % Offset changed, display the change
    fprintf('Gain   = [%.4f, %.4f] <- [%.4f, %.4f]\n\n', newGain, oldGain);
end

% Calibration Table
fprintf('Calibration Table\n');
disp([rawEye fixPos]);
