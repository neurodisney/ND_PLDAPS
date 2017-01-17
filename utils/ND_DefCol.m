function ND_DefCol(p, colname, pos, hCol, mCol)
% define a color entry for the color lookup tables used for the monkey display
% and experimenter display. These colors need to be defined in the
% experimental setup before pds.datapixx.init is called
% 
% Arguments:
%      - p:     pldaps object
%      - name:  string that defines a handle for this color, i.e. p.defaultParameters.display.clut.(colname)
%      - pos:   position in the lookup table
%      - hScr:  color hused for the experimenter (human) screen
%      - mScr:  color hused for the monkey screen
%
%
% wolf zinke, Jan. 2017

% index for the CLUT is 0 based, in matlab it is 1 based, thus shift position by 1
p.defaultParameters.display.humanCLUT(pos+1,:)  = hCol;
p.defaultParameters.display.monkeyCLUT(pos+1,:) = mCol;

if(p.defaultParameters.display.useOverlay == 1) % Datapixx overlay
    p.defaultParameters.display.clut.(colname)  =  pos * ones(3,1);
    
elseif(p.defaultParameters.display.useOverlay == 2) % software overlay
    p.defaultParameters.display.clut.(colname)  =  p.defaultParameters.display.humanCLUT(pos+1,:)';
else % screen copy, p.defaultParameters.display.useOverlay == 0
    p.defaultParameters.display.clut.(colname)  =  p.defaultParameters.display.monkeyCLUT(pos+1,:)';
end
