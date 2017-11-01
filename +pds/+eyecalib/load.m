function p = load(p,eyeCalibrationFile)
% pds.eyecalib.load, loads a previously saved eye calibration file

loadedStruct = load(eyeCalibrationFile);

p.defaultParameters.eyeCalib = loadedStruct.eyeCalib;
