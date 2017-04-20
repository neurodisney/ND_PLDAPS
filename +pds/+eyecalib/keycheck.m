function p = keycheck(p)
% pds.eyecalib.keycheck(p) check keyboard for calibrationb relevant presses
% information about eye positions
%
% wolf zinke, april 2017

if(~isempty(p.trial.LastKeyPress))

    switch p.trial.LastKeyPress(1)


        %% TODO: accept eye position, random target position, save current calibration, update current calibration

        % move target to grid positions

        case p.trial.Calib.GridKeyCell

            p.trial.behavior.fixation.GridPos = find(p.trial.Calib.GridKey == p.trial.LastKeyPress(1));
            
            p.trial.behavior.fixation.FixPos   = [-grdX,  grdY];



        % accept current fixation
        case KbName('return')        
        
        % move target by steps
        case KbName('RightArrow')
            p.trial.behavior.fixation.FixPos(1) = p.trial.behavior.fixation.FixPos(1) + ...
                                                  p.trial.behavior.fixation.FixWinStp;               
        case KbName('LeftArrow')
            p.trial.behavior.fixation.FixPos(1) = p.trial.behavior.fixation.FixPos(1) - ...
                                                  p.trial.behavior.fixation.FixWinStp;
        case KbName('UpArrow')
            p.trial.behavior.fixation.FixPos(2) = p.trial.behavior.fixation.FixPos(2) + ...
                                                  p.trial.behavior.fixation.FixWinStp;
        case KbName('DownArrow')
            p.trial.behavior.fixation.FixPos(2) = p.trial.behavior.fixation.FixPos(2) - ...
                                                  p.trial.behavior.fixation.FixWinStp;
        case KbName('g')

            fprintf('\n#####################\n  >>  Fix Pos: %d, %d \n Eye Sig: %d, 5d \n#####################\n', ...
                    p.trial.behavior.fixation.FixPos, p.trial.behavior.fixation.FixScale);
    end
    pds.fixation.move(p);
end
