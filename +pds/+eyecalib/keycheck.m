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

            gpos = find(p.trial.Calib.GridKey == p.trial.LastKeyPress(1));
            p.trial.behavior.fixation.GridPos = gpos;
            
            p.trial.behavior.fixation.FixPos   = [p.trial.Calib.Grid_X(gpos),  [p.trial.Calib.Grid_Y(gpos)];

            pds.fixation.move(p);

        % accept current fixation
        case KbName('return')      
        
        
        
        % move target by steps
        case KbName('RightArrow')
            p.trial.behavior.fixation.FixPos(1) = p.trial.behavior.fixation.FixPos(1) + ...
                                                  p.trial.behavior.fixation.FixWinStp;               
            pds.fixation.move(p);
            
        case KbName('LeftArrow')
            p.trial.behavior.fixation.FixPos(1) = p.trial.behavior.fixation.FixPos(1) - ...
                                                  p.trial.behavior.fixation.FixWinStp;
            pds.fixation.move(p);
            
        case KbName('UpArrow')
            p.trial.behavior.fixation.FixPos(2) = p.trial.behavior.fixation.FixPos(2) + ...
                                                  p.trial.behavior.fixation.FixWinStp;
            pds.fixation.move(p);
            
        case KbName('DownArrow')
            p.trial.behavior.fixation.FixPos(2) = p.trial.behavior.fixation.FixPos(2) - ...
                                                  p.trial.behavior.fixation.FixWinStp;
            pds.fixation.move(p);
    end
    
end
