function [xyp] = ND_cart2ptb(p, xyc)
% convert cartesian pixel coordinates (origin is screen center) into coordinates
% used by the psychtoolbox, see http://docs.psychtoolbox.org/Screen:
% "All screen and window coordinates follow Apple Macintosh conventions".
%
% 
%
% wolf zinke, Jan. 2017
% 
% modified:
%
% 03/15/17 - wz: fully tailored to ND_PLDAPS without previous flexibility to increase performance


ptb_x = round(p.trial.display.pWidth/2  + xyc(:, 1) + p.trial.display.ctr(1) - p.trial.display.pWidth/2 );
ptb_y = round(p.trial.display.pHeight/2 - xyc(:, 2) + p.trial.display.ctr(2) - p.trial.display.pHeight/2 );

xyp = [ptb_x(:), ptb_y(:)];
