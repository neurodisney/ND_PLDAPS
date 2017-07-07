function p = update(p)
% pds.eyecalib.update(p) update current eye calibration with current
% information about eye positions
%
% Nate Faber, april 2017
%
% This function calculates the offset and gain to best match the raw eye signal
% with the fixation points recorded

rawEye = p.trial.eyeCalib.rawEye;
fixPos = p.trial.eyeCalib.fixPos;

offsetTweak = p.trial.eyeCalib.offsetTweak;
gainTweak   = p.trial.eyeCalib.gainTweak;

%% Median of rawEye point cloud for each unique fixPos
% For the calibration points collected at each individual fixPos on the
% screen, calculate the median, and then use these medians in the future
% calibration calculations. This allows multiple points to be collected
% rapidly and used in a robust manner.

% Find all the fixPos positions that exist in the calibration array
medFixPos = unique(fixPos, 'rows');
nFixPos = size(medFixPos,1);

% Preallocate the array to store the medians of the rawEye point clouds
medRawEye = zeros(nFixPos,2);

% Iterate over all the fix positions
for iFixPos = 1:nFixPos
    thisFixPos = medFixPos(iFixPos,:);
    
    % Get the indices of the calibration table that correspond to this
    % fixPos
    calibIndices = find(ismember(fixPos,thisFixPos,'rows'));
    
    % Calculate the spatial median of the rawEye signals at this fixPos
    medianX = prctile(rawEye(calibIndices,1), 50);
    medianY = prctile(rawEye(calibIndices,2), 50);
    
    medRawEye(iFixPos,:) = [medianX medianY];
end

% Store the median values in p for drawing later
p.trial.eyeCalib.medFixPos = medFixPos;
p.trial.eyeCalib.medRawEye = medRawEye;

%% Calculate Offset
% Any calibration points taken at 0,0 (the center of the screen), will be
% averaged together to determine the offset.

% Find the index of the median values where the fixPos is 0,0
centerIndex = find(ismember(medFixPos,[0 0],'rows'));

% If offset can't be established return without changing gain.
if isempty(centerIndex)
    warning('Central calibration point must be taken')
    return
end

% Set the offset to the median rawEye signal taken at [0 0]
centerEye = medRawEye(centerIndex,:);
centerFix = [0,0];

oldOffset = p.trial.eyeCalib.offset;
newOffset = centerEye - offsetTweak;
p.trial.eyeCalib.offset = newOffset;


%% Calculate Gain
% Transform the eye and fixation postions relative to this center
relativeEye = bsxfun(@minus,rawEye, centerEye);
relativeFix = bsxfun(@minus,fixPos, centerFix);

% When calculating x and y gains, only use points where the fixation
% position was not at 0
xIndices = find(relativeFix(:,1));
yIndices = find(relativeFix(:,2));

% Get the exact gain for each point and average them together to get experimental gain.
xGain = nanmean( relativeFix(xIndices,1) ./ relativeEye(xIndices,1) , 1);
yGain = nanmean( relativeFix(yIndices,2) ./ relativeEye(yIndices,2) , 1);

% Reset the gain to the default value if no points exist
if isnan(xGain)
    xGain = p.trial.eyeCalib.defaultGain(1);
end

if isnan(yGain)
    yGain = p.trial.eyeCalib.defaultGain(2);
end

oldGain = p.trial.eyeCalib.gain;
newGain = [xGain, yGain] + gainTweak;
p.trial.eyeCalib.gain = newGain;

%% Display info
disp('Current Calibration:')

% Offset
if all(oldOffset == newOffset)
    % Nothing changed, just display the offset
    fprintf('Offset  = [%.4f, %.4f]\n',newOffset);
else
    % Offset changed, display the change
    fprintf('Offset  = [%.4f, %.4f] <- [%.4f, %.4f]\n', newOffset, oldOffset);
end

% Gain
if all(oldGain == newGain)
    % Nothing changed, just display the gain
    fprintf('Gain    = [%.4f, %.4f]\n\n',newGain);
else
    % Offset changed, display the change
    fprintf('Gain    = [%.4f, %.4f] <- [%.4f, %.4f]\n\n', newGain, oldGain);
end

% Tweaks
fprintf('offsetTweak = [%.4f, %.4f]\n',offsetTweak);
fprintf('gainTweak   = [%.4f, %.4f]\n\n',gainTweak);

% Calibration points
fprintf('nCalibPoints: %d\n\n', nFixPos)

% save the new calibration to file
pds.eyecalib.save(p);