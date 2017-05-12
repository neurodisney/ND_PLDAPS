function p = save(p)
% pds.eyecalib.save(p) save current calibration for eye position to mat file
%
% Nate Faber, May 2017
 
eyeCalib = p.trial.eyeCalib;

save(eyeCalib.file,'eyeCalib');
