function p = save(p)
% pds.eyecalib.save(p) save current calibration for eye position to mat file
%
% Nate Faber, May 2017
 
eyeCalib = p.defaultParameters.eyeCalib;

save(eyeCalib.file,'eyeCalib');
