function p = reset(p)
%% Resets the eye calibration to default values
if(p.trial.behavior.fixation.enableCalib)
    p.trial.Calib.rawEye = [];
    p.trial.Calib.fixPos = [];
    p.trial.behavior.fixation.Offset = [0 0];
    p.trial.behavior.fixation.FixGain = [-5 -5]; % Hard coded, won't be defualt if ND_RigDefaults value is changed
    
    fprintf('\n >>> fixation offset changed to [%.4f %.4f] -- gain to: [%.4f %.4f]\n\n', ...
        p.trial.behavior.fixation.Offset, p.trial.behavior.fixation.FixGain);
end