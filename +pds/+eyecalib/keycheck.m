function p = keycheck(p)
% pds.eyecalib.keycheck(p) check keyboard for calibrationb relevant presses
% information about eye positions
%
% wolf zinke, april 2017

if(~isempty(p.trial.LastKeyPress))

    FixPos = p.trial.behavior.fixation.FixPos;
    
    switch p.trial.LastKeyPress(1)

        %% TODO: accept eye position, random target position, save current calibration, update current calibration

        % ----------------------------------------------------------------%
        case p.trial.Calib.GridKeyCell
        %% move target to grid positions
            gpos = find(p.trial.Calib.GridKey == p.trial.LastKeyPress(1));
            p.trial.behavior.fixation.GridPos = gpos;
            
            FixPos = [p.trial.Calib.Grid_X(gpos),  p.trial.Calib.Grid_Y(gpos)];

        % ----------------------------------------------------------------%
        case p.trial.key.acceptCalPos     
        %% accept current fixation
            if(p.trial.behavior.fixation.enableCalib)
                gpos = p.trial.behavior.fixation.GridPos;
                NumSmplCtr = p.trial.behavior.fixation.NumSmplCtr;
                
                p.trial.Calib.EyePos_X(gpos) = nanmedian(p.trial.eyeX_hist(1:NumSmplCtr));
                p.trial.Calib.EyePos_Y(gpos) = nanmedian(p.trial.eyeY_hist(1:NumSmplCtr));
            end
        
        % ----------------------------------------------------------------%
        case p.trial.key.updateCalib 
        %% update calibration with current eye positions    
            pds.eyecalib.update(p);
        
        % ----------------------------------------------------------------%
        case p.trial.key.CtrFix
        %% Center fixation (define zero)
        % set current eye position as expected fixation position

            if(p.trial.behavior.fixation.enableCalib)
                % use a median for recent samples in order to be more robust and not biased by shot noise
                cX = prctile(p.trial.eyeX_hist(1:p.trial.behavior.fixation.NumSmplCtr), 50);
                cY = prctile(p.trial.eyeY_hist(1:p.trial.behavior.fixation.NumSmplCtr), 50);

                p.trial.behavior.fixation.PrevOffset = p.trial.behavior.fixation.Offset;

                p.trial.behavior.fixation.Offset = p.trial.behavior.fixation.Offset + FixPos - [cX,cY]; 

                fprintf('\n >>> fixation offset changed to [%.4f; %.4f] -- current eye position: [%.4f; %.4f]\n\n', ...
                         p.trial.behavior.fixation.Offset, cX,cY);
            end
        
        % ----------------------------------------------------------------%
        case p.trial.key.OffsetReset 
        %% update calibration with current eye positions    
            if(p.trial.behavior.fixation.enableCalib)
                p.trial.behavior.fixation.Offset = p.trial.behavior.fixation.PrevOffset;
            end
            
        % ----------------------------------------------------------------%
        case p.trial.key.FixGain
        %% adjust fixation gain
            if(p.trial.behavior.fixation.enableCalib)
                cX = prctile(p.trial.eyeX_hist(1:p.trial.behavior.fixation.NumSmplCtr), 50);
                cY = prctile(p.trial.eyeY_hist(1:p.trial.behavior.fixation.NumSmplCtr), 50);

                % only adjust if at least 1 dva away from 0
                if(p.trial.behavior.fixation.FixPos(1) > 1) % adjust X
                    p.trial.behavior.fixation.FixGain(1) =      p.trial.behavior.fixation.FixGain(1) * ...
                                                          (cX - p.trial.behavior.fixation.Offset(1)) / ...
                                                                p.trial.behavior.fixation.FixPos(1);
                end

                if(p.trial.behavior.fixation.FixPos(2) > 1) % adjust Y
                    p.trial.behavior.fixation.FixGain(2) =      p.trial.behavior.fixation.FixGain(2) * ...
                                                          (cY - p.trial.behavior.fixation.Offset(2)) / ...
                                                                p.trial.behavior.fixation.FixPos(2) ;
                end

                fprintf('\n >>> fixation gain changed to [%.4f; %.4f] -- current eye position: [%.4f; %.4f]\n\n', ...
                         p.trial.behavior.fixation.FixGain, cX, cY);
            end
            
        % ----------------------------------------------------------------%
        case p.trial.key.enableCalib 
        %% enable the option to calibrate/correct current eye position
            if(p.trial.behavior.fixation.enableCalib == 1)
                p.trial.behavior.fixation.enableCalib = 0;
            else
                p.trial.behavior.fixation.enableCalib = 1;
            end
                        
        % ----------------------------------------------------------------%
        case KbName('RightArrow')
        %% move target by steps
            FixPos(1) = FixPos(1) +  p.trial.behavior.fixation.FixWinStp;               
            
        case KbName('LeftArrow')
            FixPos(1) = FixPos(1) - p.trial.behavior.fixation.FixWinStp;
            
        case KbName('UpArrow')
            FixPos(2) = FixPos(2) + p.trial.behavior.fixation.FixWinStp;
            
        case KbName('DownArrow')
            FixPos(2) = FixPos(2) - p.trial.behavior.fixation.FixWinStp;
    end
    
    if(any((p.trial.behavior.fixation.FixPos == FixPos) == 0))
        p.trial.behavior.fixation.FixPos = FixPos;
        pds.fixation.move(p);
    end
end
