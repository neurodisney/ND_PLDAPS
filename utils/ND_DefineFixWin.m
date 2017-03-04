function coords_px=ND_DefineFixWin(coords_dva,screen_sz_px, ...
    px2dva_factor,window_shape)
%
% created     03/03/2017 AB
% last edited 03/03/2017 AB
%
% inputs:
% 1. coords_dva - coordinates of window in dva
%               - interacts with input 4. window_shape
% 2. screen_sz_px - 2-integer vector of X (horiz) and Y (vert) screen
%                 - resolution
% 3. dva2pix_factor - scalar factor to weigh/multiply/divide dva values by
%                     to obtain corresponding pixel units,
%                     given viewing distance and physical screen size
%                     obtain this value from fxn: _______
% 4. window_shape - string which can take on the following values:
%                   denotes the shape of the fixation window
%       A. 'rectilinear' - 
%       B. 
%       no other shapes planning on being
%
%
% TODO:
% - have output be in format ready for plotting either via direct
%   ptb Screen/Draw call or ND_PLDAPS grfx wrapper