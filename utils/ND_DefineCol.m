function ND_DefineCol(p, colname, pos, hCol, mCol)
% define a color entry for the color lookup tables used for the monkey display
% and experimenter display. These colors need to be defined in the experimental
% setup before pds.datapixx.init is called.
%
% RGB values are specified in the range from 0 to 1.
%
% Arguments:
%      - p:       pldaps object
%      - colname: string that defines a handle for this color, i.e. p.defaultParameters.display.clut.(colname)
%      - pos:     position in the lookup table
%      - hCol:    color used for the experimenter (human) screen
%      - mCol:    color used for the monkey screen
%
%
% TODO: Right now, based on PLDAPS defaults, several CLUT positions contain
% the same color values. To use the CLUT more efficient, these color entry
% should refer to the same CLUT location...
%
%
%
% wolf zinke, Jan. 2017

% if only one color is specified, use it for both, experimenter and animal screen
if(nargin < 5)
    mCol = hCol;
end

% assume grey defined by equal RGB values if color is defiend by only one number
if(length(hCol) == 1)
   hCol = [hCol, hCol, hCol];
end

if(length(mCol) == 1)
   mCol = [mCol, mCol, mCol];
end

% index for the CLUT is 0 based, in matlab it is 1 based, thus shift position by 1
p.defaultParameters.display.humanCLUT( pos+1,:) = hCol;
p.defaultParameters.display.monkeyCLUT(pos+1,:) = mCol;

if(p.defaultParameters.display.useOverlay)  % apparently, both, datapixx and software overlays use indexed colors
    p.defaultParameters.display.clut.(colname) = pos; % use color lookup table indices
else
    p.defaultParameters.display.clut.(colname) = p.defaultParameters.display.monkeyCLUT(pos+1,:)'; % just copy colors defined for monkey screen, no overlay
end
