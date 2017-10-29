function p = setup(p)
% pds.eyecalib.setup(p) setup calibration for eye position. 
% If calibration is enabled for this experiment (i.e., for the actual calibration experiment),
% setup will create the files necessary to store the information, and setup any keys.
%
% For other experiments, setup will load the most recent eye calibration file for the day
% If none exist, the user will be given a warning.
%
% wolf zinke, april 2017
% Nate Faber, May 2017

if p.defaultParameters.behavior.fixation.enableCalib
    %% Prepare to calibrate the eye position

    % Name of calibration setup (uses the current time to differentiate different calibrations taken on the same day
    p.defaultParameters.eyeCalib.name = [p.defaultParameters.session.subject, '_', datestr(now,'yyyymmdd') '_EyeCalib_' , datestr(now,'HHMM')];
    p.defaultParameters.eyeCalib.file = [p.defaultParameters.session.eyeCalibDir, filesep, p.defaultParameters.eyeCalib.name, '.mat'];    
    
    % make sure eye calibration directory exists
    if(~exist(p.defaultParameters.session.eyeCalibDir,'dir'))
        mkdir(p.defaultParameters.session.eyeCalibDir);
    end
 
    % Load in the default gain and offset
    p.defaultParameters.eyeCalib.gain   = p.defaultParameters.eyeCalib.defaultGain;
    p.defaultParameters.eyeCalib.offset = p.defaultParameters.eyeCalib.defaultOffset;
    
    % define keys used for eye calibration
    KbName('UnifyKeyNames');
    p.defaultParameters.key.resetCalib    = KbName('z');          % Clear the calibration matrices and start over
    p.defaultParameters.key.wipeCalibPos  = KbName('w');          % Clear the calibration points at the current fixPos 
    p.defaultParameters.key.rmLastCalib   = KbName('BackSpace');  % reset offset to previous one
    p.defaultParameters.key.addCalibPoint  = 37;                  % KbName('Return') returns two numbers;    % accept current fixation
  
    % Tweak calibration
    p.defaultParameters.key.offsetTweak   = KbName('Home');       % Alternate between xTweak, yTweak, and off
    p.defaultParameters.key.gainTweak     = KbName('End');        % Alternate between xTweak, yTweak, and off
    p.defaultParameters.key.tweakUp       = KbName('PageUp');     % Increase the currently tweaked parameter
    p.defaultParameters.key.tweakDown     = KbName('PageDown');   % Decrease the currently tweaked parameter
    
    % check for previous calibration
    eyeCalibDir = p.defaultParameters.session.eyeCalibDir;
    dailyCalibs = dir([eyeCalibDir,filesep,'*.mat']);
    
   if(~isempty(dailyCalibs))
        promptMessage   = sprintf('Previous claibration file found. \n Load this file?');
        titleBarCaption = sprintf('Load previous calibration?');

        button = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'No');
        if(strcmpi(button, 'Yes'))
            calibFileName = [eyeCalibDir, filesep, dailyCalibs(end).name];
            pds.eyecalib.load(p, calibFileName);
        end
    end

    % save calibration file
    pds.eyecalib.save(p);
    
else
    %% Load the most recent eye position of the day
    eyeCalibDir = p.defaultParameters.session.eyeCalibDir;
    dailyCalibs = dir([eyeCalibDir,filesep,'*.mat']);
    
    % Warn the user if no calibration files exist
    if(isempty(dailyCalibs))
        warning('No calibrations performed today. eye position likely highly inaccurate');
        p.defaultParameters.eyeCalib.offset = p.defaultParameters.eyeCalib.defaultOffset;
        p.defaultParameters.eyeCalib.gain   = p.defaultParameters.eyeCalib.defaultGain;
        return;
    end
    
    % define keys used for tweaking eye calibration
    KbName('UnifyKeyNames');
    
    % Don't allow points to be changed in this mode, only tweaking
    p.defaultParameters.key.resetCalib    = [];
    p.defaultParameters.key.wipeCalibPos  = [];
    p.defaultParameters.key.rmLastCalib   = [];
    p.defaultParameters.key.enableCalib   = [];
    p.defaultParameters.key.addCalibPoint = [];
    
    % Tweak calibration
    p.defaultParameters.key.offsetTweak   = KbName('Home');
    p.defaultParameters.key.gainTweak     = KbName('End');
    p.defaultParameters.key.tweakUp       = KbName('PageUp');
    p.defaultParameters.key.tweakDown     = KbName('PageDown');
    
    % Load the most recent calibration file
    calibFileName = [eyeCalibDir, filesep, dailyCalibs(end).name];
    pds.eyecalib.load(p, calibFileName);
    
end


