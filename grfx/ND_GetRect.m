function [rect] = ND_GetRect(pos, sz)
% get a Psychtoolbox rect for stimulus drawing based on cartesian
% coordinates (screen centered). This function expects pixel coordinates,
% hence make sure to convert dva (see +pds/deg2px.m).
%
%
% wolf zinke, Jan. 2017

if(length(sz) == 1)
    sz = [sz sz];
end

r = sz./2;
rect = kron([1,1], pos) + kron([-1,1],r);
rect = floor(rect); % pixels
