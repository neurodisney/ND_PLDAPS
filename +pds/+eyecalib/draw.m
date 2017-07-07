function draw(p)
% Draw relevant stimuli for the eye calibration process
% Should draw:
%
% Light Green Box - Active fixation position
%    Green Dots   - Calibration points for the active fixPos (aligned with current Gain/Offset values)   
%    Yellow Dot   - Most recently added calibration point
%    Dark Green X - Median of calibration point cloud
%
% Light Red Boxes - Inactive fixation positions
%    Red Dots     - Calibration points for inactive fix positions
%    Dark Red X   - Median of calibration point clouds

% Nate Faber, April 2017


% Colors
currPointsCol = p.trial.display.clut.greenbg;
currFixPosCol = p.trial.display.clut.lGreenbg;
currMedianCol = p.trial.display.clut.dGreenbg;

otherPointsCol = p.trial.display.clut.redbg;
otherFixPosCol = p.trial.display.clut.lRedbg;
otherMedianCol = p.trial.display.clut.dRedbg;

recentPointCol = p.trial.display.clut.yellowbg;


% pointer to the screen
window = p.trial.display.overlayptr;

%% Hard coded values
boxSize = 0.6;
boxPenWidth = 0.05;
crossSize = 0.25;
crossPenWidth = 2;
dotSize = 5;

%% Draw calibrated fixation positions (Light Red Boxes)
medFixPos = p.trial.eyeCalib.medFixPos;

for iFixPos = 1:size(medFixPos,1)
    fixPos = medFixPos(iFixPos,:);
    fixPosRect = ND_GetRect(fixPos,boxSize);
    
    % Draw the box
    Screen('FrameRect', window, otherFixPosCol, fixPosRect, boxPenWidth)
end


%% Draw current fixation position (Light Green Box)
currFixPos = p.trial.behavior.fixation.fix.pos;
fixPosRect = ND_GetRect(currFixPos,boxSize);

% Draw the box
Screen('FrameRect', window, currFixPosCol, fixPosRect, boxPenWidth)


%% Draw the median calibration point (Red/Green X)
medRawEye = p.trial.eyeCalib.medRawEye;

if ~isempty(medRawEye)
    currentFixPosIndex = find(ismember(medFixPos,currFixPos,'rows'));
    
    gain = p.trial.eyeCalib.gain;
    offset = p.trial.eyeCalib.offset;
    
    for iMedian = 1:size(medRawEye,1)
        if iMedian == currentFixPosIndex
            crossColor = currMedianCol;
        else
            crossColor = otherMedianCol;
        end
        
        crossCenter = gain .* (medRawEye(iMedian,:) - offset);
        
        % Draw the plus
        Screen('DrawLines', window, [crossSize -crossSize crossSize -crossSize; -crossSize crossSize crossSize -crossSize], ...
            crossPenWidth, crossColor, crossCenter);
    end
    
    %% Draw all the calibration points mapped with current gain and offset values (Dark Red/Dark Green Dots)
    calibPointsRaw = p.trial.eyeCalib.rawEye;
    allFixPos = p.trial.eyeCalib.fixPos;
    
    
    
    calibPointsX = gain(1) * (calibPointsRaw(:,1) - offset(1));
    calibPointsY = gain(2) * (calibPointsRaw(:,2) - offset(2));
    calibPoints = [calibPointsX calibPointsY];
    nPoints = size(calibPoints,1);
    
    
    % Get the colors
    % Most are dark red so start with that
    dotColors = repmat(otherPointsCol,nPoints,3);
    % Make the ones corresponding to the current fixPos dark green
    dotColors(ismember(allFixPos,currFixPos,'rows'),:) = currPointsCol;
    % Make the most recent calibration point yellow
    dotColors(end,:) = recentPointCol;
    
    % Make the last dot bigger for visibility
    dotSizes = repmat(dotSize,1,nPoints);
    dotSizes(end) = dotSize + 4;
    
    % Draw the dots
    Screen('DrawDots', window, calibPoints', dotSizes, dotColors');
end
