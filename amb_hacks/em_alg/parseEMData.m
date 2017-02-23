function [varargout]=parseEMData(data,params)
% 
% started on  02/23/2017
% last edited 02/23/2017
%
% inputs:
%
% 1. data:
% a struct containing the following fields
% data.x = horizontal eye position
% data.y = vertical eye position
% data.p = pupil diameter
%
% 2. params:
% a struct containing the following fields
% parms.Fs = sampling frequency of data
% params.sac_min_vel = minimum velocity for first-pass saccade detection
% params.sac_min_acc = min acceleration for second-pass saccade refinement
% params.sac_max_sep = max # of samples a first-pass saccade may be
%   separated by
% params.



% check data for equal length?

% generate time axes?

% filter data?
% position
% size

% take difference of position data to get marginal velocities
xvel=diff(data.x);
yvel=diff(data.y);
xyvel=sqrt(xvel.^2+yvel.^2); % get directionless velocity
xyacc=diff(xyvel);

ind_aboveVelThresh=find(xyvel<params.sac_min_vel); % get indices of 
% velocity samples above threshold
dind_AVT=diff(ind_aboveVelThresh); % take the difference of vel sample 
% indices above threshold to find first-pass segment-points
ind_dind_AVT=find(dind_AVT>params.sac_max_sep); % find 