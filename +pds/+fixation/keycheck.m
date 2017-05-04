function p = keycheck(p)
% pds.fixation.keycheck. Change fixation related parameters such as
% fixation spot position, etc.
%
% Nate Faber, May 2017
% Adapted from wolf zinke, 2017

if(~isempty(p.trial.LastKeyPress))
    
    switch p.trial.LastKeyPress(1)
        
        
        %% move target to grid positions
        case p.trial.key.GridKeyCell
            
            gpos = find(p.trial.key.GridKey == p.trial.LastKeyPress(1));
            p.trial.behavior.fixation.GridPos = gpos;
            
            FixPos = p.trial.eyeCalib.Grid_XY(gpos, :);
            
            %% move target by steps
        case KbName('RightArrow')
            FixPos(1) = FixPos(1) +  p.trial.behavior.fixation.FixWinStp;
            
        case KbName('LeftArrow')
            FixPos(1) = FixPos(1) - p.trial.behavior.fixation.FixWinStp;
            
        case KbName('UpArrow')
            FixPos(2) = FixPos(2) + p.trial.behavior.fixation.FixWinStp;
            
        case KbName('DownArrow')
            FixPos(2) = FixPos(2) - p.trial.behavior.fixation.FixWinStp;
            
    end
    
    %% Update fixation position if it has changed
    if any(p.trial.behavior.fixation.FixPos ~= FixPos)
        p.trial.behavior.fixation.FixPos = FixPos;
        pds.fixation.move(p);
    end
end
