function p = reset(p)
%% Resets the eye calibration to default values
if(p.trial.behavior.fixation.enableCalib)
    p.trial.eyeCalib.rawEye = [];
    p.trial.eyeCalib.fixPos = [];
    p.trial.eyeCalib.medRawEye = [];
    p.trial.eyeCalib.medFixPos = [];
    p.trial.eyeCalib.offset = p.trial.eyeCalib.defaultOffset;
    p.trial.eyeCalib.gain = p.trial.eyeCalib.defaultGain;
    
    fprintf('\n >>> fixation offset changed to [%.4f %.4f] -- gain to: [%.4f %.4f]\n\n', ...
        p.trial.eyeCalib.offset, p.trial.eyeCalib.gain);
end