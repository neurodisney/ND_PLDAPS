function p = load(p,eyeCalibrationFile)
% pds.eyecalib.load, loads a previously saved eye calibration file
eyeCalibStruct = load(eyeCalibrationFile);

p.trial.eyeCalib = eyeCalibStruct;