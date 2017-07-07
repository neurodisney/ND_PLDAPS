function p = setup(p)
% pds.fixation.setup(p)   create fixation spot and setup keys
%
% wolf zinke, april 2017
% Nate Faber, May 2017

% Allow using the numpad to set the fixation point:
%
%  -------------
%  | 7 | 8 | 9 |
%  -------------
%  | 4 | 5 | 6 |
%  -------------
%  | 1 | 2 | 3 |
%  -------------

grdX = p.trial.behavior.fixation.FixGridStp(1);
grdY = p.trial.behavior.fixation.FixGridStp(2);

X = [-grdX;     0;  grdX; -grdX; 0; grdX; -grdX;    0; grdX];
Y = [-grdY; -grdY; -grdY;     0; 0;    0;  grdY; grdY; grdY];

p.trial.eyeCalib.Grid_XY = [X, Y];

% define keys used for moving the fixation spot
KbName('UnifyKeyNames');
p.trial.key.GridKey       = KbName(arrayfun(@num2str, 1:9, 'unif', 0));
p.trial.key.GridKeyCell   = num2cell(p.trial.key.GridKey);






