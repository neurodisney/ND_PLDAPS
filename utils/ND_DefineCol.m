function ND_DefineCol(p, colname, pos, hCol, mCol)
% define a color entry for the color lookup tables used for the monkey display
% and experimenter display. These colors need to be defined in the experimental
% setup before pds.datapixx.init is called.
%
% RGB values are specified in the range from 0 to 1.
%
% Arguments:
%      - p:     pldaps object
%      - name:  string that defines a handle for this color, i.e. p.defaultParameters.display.clut.(colname)
%      - pos:   position in the lookup table
%      - hCol:  color used for the experimenter (human) screen
%      - mCol:  color used for the monkey screen
%
%
% wolf zinke, Jan. 2017

% index for the CLUT is 0 based, in matlab it is 1 based, thus shift position by 1
p.defaultParameters.display.humanCLUT( pos+1,:) = hCol;
p.defaultParameters.display.monkeyCLUT(pos+1,:) = mCol;

if(p.defaultParameters.display.useOverlay)
    p.defaultParameters.display.clut.(colname) = pos * ones(3,1);  % use color lookup table indices
else
    p.defaultParameters.display.clut.(colname) = p.defaultParameters.display.monkeyCLUT(pos+1,:)'; % just copy colors defined for monkey screen, no overlay
end
