function p = setup(p)
% pds.eyecalib.setup(p) setup calibration for eye position
%
% wolf zinke, april 2017
% Nate Faber, may 2017

%% existing calibration data
% refer to default struct with calibration information
% if(isempty(p.trial.behavior.fixation.CalibMat))
%     [pathStr,~,~] = fileparts(mfilename('fullpath'));
%     p.trial.behavior.fixation.CalibMat = [pathStr,filesep,'FixCal.mat'];
% end
% 
% % load data
% p.trial.eyeCalib.Eye = load(p.trial.behavior.fixation.CalibMat);

% update name for calibration file
p.trial.behavior.fixation.CalibMat = [p.defaultParameters.session.dir,filesep,'FixCal.mat'];


% define keys used for eye calibration
KbName('UnifyKeyNames');
p.trial.eyeCalib.GridKey     = KbName(arrayfun(@num2str, 1:9, 'unif', 0));
p.trial.eyeCalib.GridKeyCell = num2cell(p.trial.eyeCalib.GridKey);
p.trial.key.resetCalib    = KbName('z');  % Clear the calibration matrices and start over
p.trial.key.rmLastCalib   = KbName('BackSpace'); % reset offset to previous one
p.trial.key.enableCalib   = KbName('Insert');    % allow changing calibration parameters
p.trial.key.acceptCalPos  = 37; % KbName('Return') returns two numbers;    % accept current fixation 

% save calibration file
pds.eyecalib.save(p);


