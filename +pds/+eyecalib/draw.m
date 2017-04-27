function draw(p)
% Draw relevant stimuli for the eye calibration process
% Should draw:
%
% Light Green Box - Active fixation position
%    Dark Green Dots   - Calibration points for the active fixPos (aligned with current Gain/Offset values)   
%    Yellow Dot        - Most recently added calibration point
%    Medium Green Plus - Median of calibration point cloud
%
% Light Red Boxes - Inactive fixation positions
%    Dark Red Dots     - Calibration points for inactive fix positions
%    Medium Red Plus   - Median of calibration point clouds

% pointer to the screen
window = p.trial.display.overlayptr;

%% Hard coded values
boxSize = 0.4;
boxPenWidth = 0.05;
plusSize = 0.25;
plusPenWidth = 0.05;
dotSize = 1;

%% Draw calibrated fixation positions (Light Red Boxes)
medFixPos = p.trial.Calib.medFixPos;

for iFixPos = 1:size(medFixPos,1)
    fixPos = medFixPos(fixPos,:);
    fixPosRect = ND_GetRect(fixPos,boxSize);
    
    % Draw the box
    Screen('FrameRect', window, p.trial.display.clut.Calib_LG, fixPosRect, boxPenWidth)
end


%% Draw current fixation position (Light Green Box)
currFixPos = p.trial.behavior.fixation.FixPos;
fixPosRect = ND_GetRect(currFixPos,boxSize);

% Draw the box
Screen('FrameRect', window, p.trial.display.clut.Calib_LG, fixPosRect, boxPenWidth)


%% Draw the median calibration point (Red/Green Plus)
medRawEye = p.trial.Calib.medRawEye;
currentFixPosIndex = find(ismember(medFixPos,currFixPos));

for iMedian = 1:size(medRawEye,1)
    if iMedian == currentFixPosIndex
        plusColor = p.trial.display.clut.Calib_G;
    else
        plusColor = p.trial.display.clus.Calib_R;
    end
    
    % Draw the plus
    Screen('DrawLines', window, [plusSize -plusSize 0 0; 0 0 plusSize -plusSize], ...
        plusPenWidth, plusColor, medianRawEye(iMedian,:));
end

%% Draw all the calibration points mapped with current gain and offset values (Dark Red/Dark Green Dots)
calibPointsRaw = p.trial.Calib.rawEye;
allFixPos = p.trial.Calib.fixPos;

gain = p.trial.behavior.fixation.FixGain;
offset = p.trial.behavior.fixation.Offset;

calibPoints = gain * (calibPointsRaw - offset);
nPoints = size(calibPoints,1);


% Get the colors
% Most are dark red so start with that
dotColors = repmat(p.trial.display.clut.Calib_DR,nPoints,1);
% Make the ones corresponding to the current FixPos dark green
dotColors(ismember(allFixPos,currFixPos,'rows'),:) = p.trial.display.clut.Calib_DG;
% Make the most recent calibration point yellow
dotColors(end,:) = p.trial.display.clut.Calib_Y;

% Draw the dots
Screen('DrawDots', window, calibPoints', dotSize, dotColors)
