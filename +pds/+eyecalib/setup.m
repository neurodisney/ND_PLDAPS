function p = setup(p)
% pds.eyecalib.setup(p) setup calibration for eye position
%
% wolf zinke, april 2017

%% existing calibration data
% refer to default struct with calibration information
% if(isempty(p.trial.behavior.fixation.CalibMat))
%     [pathStr,~,~] = fileparts(mfilename('fullpath'));
%     p.trial.behavior.fixation.CalibMat = [pathStr,filesep,'FixCal.mat'];
% end
% 
% % load data
% p.trial.Calib.Eye = load(p.trial.behavior.fixation.CalibMat);

% update name for calibration file
p.trial.behavior.fixation.CalibMat = [p.defaultParameters.session.dir,filesep,'FixCal.mat'];

%% set up positions for the 9-point calibration grid
% grid ID's follow numpad scheme:
%
%  -------------
%  | 7 | 8 | 9 |
%  -------------
%  | 4 | 5 | 6 |
%  -------------
%  | 1 | 2 | 3 |
%  -------------

% TODO: Check! currently the ID's do not match screen coordinates!

grdX = p.trial.behavior.fixation.FixGridStp(1);
grdY = p.trial.behavior.fixation.FixGridStp(2);

X = [-grdX;     0;  grdX; -grdX; 0; grdX; -grdX;    0; grdX];
Y = [-grdY; -grdY; -grdY;     0; 0;    0;  grdY; grdY; grdY];
p.trial.Calib.Grid_XY = [X, Y];

p.trial.Calib.EyePos_X = nan(1, 9);
p.trial.Calib.EyePos_Y = nan(1, 9);

% define keys used for eye calibration
KbName('UnifyKeyNames');
p.trial.Calib.GridKey     = KbName(arrayfun(@num2str, 1:9, 'unif', 0));
p.trial.Calib.GridKeyCell = num2cell(p.trial.Calib.GridKey);
p.trial.key.CtrFix        = KbName('z');         % set current eye position as center (i.e. change offset)
p.trial.key.FixGain       = KbName('g');         % adjust fixation gain
p.trial.key.OffsetReset   = KbName('BackSpace'); % reset offset to previous one
p.trial.key.enableCalib   = KbName('Insert'); % allow changing calibration parameters
p.trial.key.acceptCalPos  = KbName('return');    % accept current fixation
p.trial.key.updateCalib   = KbName('End');       % update calibration with current eye positions    


% save calibration file
pds.eyecalib.save(p);


