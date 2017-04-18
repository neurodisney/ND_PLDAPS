function p = setup(p)
% pds.eyecalib.setup(p) setup calibration for eye position
%
% wolf zinke, april 2017

%% existing calibration data
% refer to default struct with calibration information
if(isempty(p.trial.behavior.fixation.CalibMat))
    [pathStr,~,~] = fileparts(mfilename('fullpath'));
    p.trial.behavior.fixation.CalibMat = [pathStr,filesep,'FixCal.mat'];
end

% load data
p.trial.Calib.Eye = load(p.trial.behavior.fixation.CalibMat);

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

p.trial.Calib.Grid_X = [-grdX;    0; grdX; -grdX; 0; grdX; -grdX;     0;  grdX];
p.trial.Calib.Grid_Y = [ grdY; grdY; grdY;     0; 0;    0; -grdY; -grdY; -grdY];

            
% save calibration file
pds.eyecalib.save(p);
