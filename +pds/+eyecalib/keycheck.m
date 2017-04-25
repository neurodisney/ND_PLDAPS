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
            
            FixPos = p.trial.Calib.Grid_XY(gpos, :);

        % ----------------------------------------------------------------%
        case p.trial.key.acceptCalPos     
        %% accept current fixation
            if(p.trial.behavior.fixation.enableCalib)
                iCalib = size(p.trial.Calib.rawEye, 1) + 1;
                
                % Position of the fixation target
                fixPos = p.trial.behavior.fixation.FixPos;
                
                % Position of eye. Gets the median X and Y values over a
                % range of samples to get a better estimate
                sampleRange = (p.trial.datapixx.adc.dataSampleCount - p.trial.behavior.fixation.NSmpls + 1) : p.trial.datapixx.adc.dataSampleCount;
                rawEye = [prctile(p.trial.AI.Eye.X(sampleRange), 50)  prctile(p.trial.AI.Eye.Y(sampleRange), 50)];
                
                % Add these samples to the list of calibration points,
                % which will be processed in pds.eyecalib.update
                p.trial.Calib.fixPos(iCalib,:) = fixPos;
                p.trial.Calib.rawEye(iCalib,:) = rawEye;
                
                pds.eyecalib.update(p);
            end
        
        % ----------------------------------------------------------------%
        case p.trial.key.updateCalib 
        %% update calibration with current eye positions    
            pds.eyecalib.update(p);
        
        % ----------------------------------------------------------------%
        case p.trial.key.resetCalib
        %% Clear the calibration matrix and reset to default values
        pds.eyecalib.reset(p);
        
        % ----------------------------------------------------------------%
        case p.trial.key.rmLastCalib 
        %% Remove the last calibration point from the calculation    
            if(p.trial.behavior.fixation.enableCalib)
                
                if size(p.trial.Calib.rawEye,1) <= 1
                    % Reset to defualts if removing one would completely clear
                    % all calibration points
                    pds.eyecalib.reset(p)
                else
                    p.trial.Calib.rawEye = p.trial.Calib.rawEye(1:end-1,:);
                    p.trial.Calib.fixPos = p.trial.Calib.fixPos(1:end-1,:);
                    pds.eyecalib.update(p);
                end
                        
            end
            
        % ----------------------------------------------------------------%
%         case p.trial.key.FixGain
%         %% adjust fixation gain
%             if(p.trial.behavior.fixation.enableCalib)
%                 cX = prctile(p.trial.eyeX_hist(1:p.trial.behavior.fixation.NumSmplCtr), 50);
%                 cY = prctile(p.trial.eyeY_hist(1:p.trial.behavior.fixation.NumSmplCtr), 50);
% 
%                 % only adjust if at least 1 dva away from 0
%                 if(p.trial.behavior.fixation.FixPos(1) > 1) % adjust X
%                     p.trial.behavior.fixation.FixGain(1) =      p.trial.behavior.fixation.FixGain(1) * ...
%                                                           (cX - p.trial.behavior.fixation.Offset(1)) / ...
%                                                                 p.trial.behavior.fixation.FixPos(1);
%                 end
% 
%                 if(p.trial.behavior.fixation.FixPos(2) > 1) % adjust Y
%                     p.trial.behavior.fixation.FixGain(2) =      p.trial.behavior.fixation.FixGain(2) * ...
%                                                           (cY - p.trial.behavior.fixation.Offset(2)) / ...
%                                                                 p.trial.behavior.fixation.FixPos(2) ;
%                 end
% 
%                 fprintf('\n >>> fixation gain changed to [%.4f; %.4f] -- current eye position: [%.4f; %.4f]\n\n', ...
%                          p.trial.behavior.fixation.FixGain, cX, cY);
%             end
            
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
