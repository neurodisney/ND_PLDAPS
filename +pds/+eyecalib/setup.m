function p = setup(p)
% pds.eyecalib.setup(p) setup calibration for eye position. 
% If calibration is enabled for this experiment (i.e., for the actual calibration experiment),
% setup will create the files necessary to store the information, and setup any keys.
%
% For other experiments, setup will load the most recent eye calibration file for the day
% If none exist, the user will be given a warning.
%
% wolf zinke, april 2017
% Nate Faber, may 2017


if p.trial.behavior.fixation.enableCalib
    %% Prepare to calibrate the eye position
    
    % TODO: Allow for loading of previous calibrations as a starting point
    
    % Name of calibration setup (uses the current time to differentiate different calibrations taken on the same day
    p.trial.eyeCalib.name = [p.trial.session.subject, datestr(now,'yyyymmdd') '_EyeCalib_' , datestr(now,'HHMM')];
    p.trial.eyeCalib.file = [p.trial.session.dir, filesep, p.trial.eyeCalib.name, '.cal');    
    
    % define keys used for eye calibration
    KbName('UnifyKeyNames');
    p.trial.eyeCalib.GridKey     = KbName(arrayfun(@num2str, 1:9, 'unif', 0));
    p.trial.eyeCalib.GridKeyCell = num2cell(p.trial.eyeCalib.GridKey);
    p.trial.key.resetCalib    = KbName('z');  % Clear the calibration matrices and start over
    p.trial.key.rmLastCalib   = KbName('BackSpace'); % reset offset to previous one
    p.trial.key.enableCalib   = KbName('Insert');    % allow changing calibration parameters
    p.trial.key.addCalibPoint  = 37; % KbName('Return') returns two numbers;    % accept current fixation
    
    % save calibration file
    pds.eyecalib.save(p);
    
else
    %% Load the most recent eye position of the day
    eyeCalibDir = fullfile(p.trial.pldaps.dirs.data, p.trial.session.subject, 'EyeCalib', datestr(now,'yyyy_mm_dd'));
    dailyCalibs = dir([eyeCalibDir,filesep,'*.cal']);
    
    % Warn the user if no calibration files exist
    if isempty(dailyCalibs)
        warning('No calibrations performed today. eye position likely highly inaccurate');
    end
    
    % Load the most recent calibration file
    calibrationFileName = [eyeCalibDir, filesep, dailyCalibs(end).name];
    eyeCalib = load(calibrationFileName);
    p.trial.eyeCalib = eyeCalib;
    
    disp(['\n >>> Eye Calibration loaded: ', dailyCalibs(end).name])
    
end


