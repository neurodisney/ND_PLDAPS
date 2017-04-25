function p = update(p)
% pds.eyecalib.update(p) update current eye calibration with current
% information about eye positions
%
% wolf zinke, april 2017



switch p.trial.behavior.fixation.CalibMethod
    case 'gain'
        zeroPos = p.trial.Calib.Grid_XY(5,:); 
        
        
        
    otherwise
        error('only available method for eye calibration riht now is "gain", %s is not supported!', ...
              p.trial.behavior.fixation.CalibMethod);
end


