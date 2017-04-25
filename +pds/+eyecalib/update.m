function p = update(p)
% pds.eyecalib.update(p) update current eye calibration with current
% information about eye positions
%
% wolf zinke, april 2017

zeroPos = p.trial.Calib.Grid_XY(5,:); 

X_pos = p.trial.Calib.Grid_XY(:,1) ~= 0 & isfinite(p.trial.Calib.EyePos_X_raw)';
Y_pos = p.trial.Calib.Grid_XY(:,2) ~= 0 & isfinite(p.trial.Calib.EyePos_Y_raw)';
        
grdX = p.trial.behavior.fixation.FixGridStp(1);
grdY = p.trial.behavior.fixation.FixGridStp(2);

oldGain = p.trial.behavior.fixation.FixGain;

switch p.trial.behavior.fixation.CalibMethod
    case 'gain'
    
        if(any(X_pos))
            X_delta = median(abs(p.trial.Calib.EyePos_X_raw(X_pos) - zeroPos(1)));
            p.trial.behavior.fixation.FixGain(1) = X_delta / grdX;
        end
               
        if(any(Y_pos))
            Y_delta = median(abs(p.trial.Calib.EyePos_X_raw(Y_pos) - zeroPos(2)));
            p.trial.behavior.fixation.FixGain(2) = Y_delta / grdY;
        end
        
    otherwise
        error('only available method for eye calibration riht now is "gain", %s is not supported!', ...
              p.trial.behavior.fixation.CalibMethod);
end


if(any((p.trial.behavior.fixation.FixGain == oldGain) == 0))
    fprintf('/n >>> Fixation gain changed to [%.4f, %.4f] (was before [%.4f, %.4f]\n', ...
            p.trial.behavior.fixation.FixGain, oldGain);
end
