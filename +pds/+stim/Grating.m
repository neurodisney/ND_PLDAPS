classdef Grating < pds.stim.BaseStim

% A class for creating and drawing procedurally generated sine wave gratings
% within the

%%% Variables that can be changed about the sine wave grating after it has been created:
% Temporal Frequency
% Orientation
% Position
% Alpha
%
%%% Variables that can't be changed (for now)
% Contrast
% Spatial Frequency
% radius
% Contrast Method
% Background color offset
% Resolution

% Nate Faber, July 2017

properties
    tFreq
    angle
    alpha
end

properties (SetAccess = private)
    sFreq
    contrastMethod
    radius
    bgOffset
    gratingRect
    res
    contrast
end

properties (SetAccess = private, Hidden = true)
    genTime %When the grating was created (to calculate drifting phase)
    texture % The actual texture used for drawing
    pcmult
    srcRect
end

methods
    % The constructor method
    function obj = Grating(p, radius, contrast, pos, angle, sFreq, tFreq, res, alpha, fixWin)
        
        %% Load variables
        if nargin < 10 || isempty(fixWin)
            fixWin = p.trial.stim.grating.fixWin;
        end
        
        if nargin < 9 || isempty(alpha)
            alpha = p.trial.stim.grating.alpha;
        end
        
        if nargin < 8 || isempty(res)
            res = p.trial.stim.grating.res;
        end
        
        if nargin < 7 || isempty(tFreq)
            tFreq = p.trial.stim.grating.tFreq;
        end
                
        if nargin < 6 || isempty(sFreq)
            sFreq = p.trial.stim.grating.sFreq;
        end
        
        if nargin < 5 || isempty(angle)
            angle = p.trial.stim.grating.angle;
        end
        
        if nargin < 4 || isempty(pos)
            pos = p.trial.stim.grating.pos;
        end
        
        if nargin < 3 || isempty(contrast)
            contrast = p.trial.stim.grating.contrast;
        end
        
        if nargin < 2 || isempty(radius)
            radius = p.trial.stim.grating.radius;
        end
        
        % Load the superclass
        obj@pds.stim.BaseStim(p, pos, fixWin);
       
        obj.alpha = alpha;
        obj.res = res;
        obj.tFreq = tFreq;
        obj.sFreq = sFreq;
        obj.angle = angle;
        obj.contrast = contrast;
        obj.radius = radius;

        
        % Unchangeable after loading
        obj.contrastMethod = p.trial.stim.grating.contrastMethod;
        obj.genTime = p.trial.CurTime;
        obj.srcRect = [0, 0, 2*obj.res + 1, 2*obj.res + 1];
        
        switch obj.contrastMethod
            case 'raw'
                % Always centered at 0.5, will not match bg at low contrasts
                obj.bgOffset = 0.5;
                obj.pcmult = obj.contrast / 2;
                
            case 'bgshift'
                % Will match bg at low contrasts, but not be correct at high contrasts.
                obj.bgOffset = p.trial.display.bgColor(1);
                obj.pcmult = obj.contrast / 2;
                
            case 'balanced'
                % Probably the best bet. This will be background at 0 contrast, and white - black = contrast
                bg = p.trial.display.bgColor(1);
                bgdiff = 0.5 - bg; % goes from 0 to (+/-)0.5
                if obj.contrast/2 > (0.5 - abs(bgdiff))
                    obj.bgOffset = round(bg) + sign(bgdiff) * contrast / 2;
                else
                    obj.bgOffset = bg;
                end
                obj.pcmult = obj.contrast/2;
                
            otherwise
                error('Bad Contrast Method');
        end
        
        window = p.trial.display.ptr;
        
        % Create a special texture drawing shader for masked texture drawing:
        glsl = p.trial.display.glsl;
        
        % Scale the spatial frequency to match the resolution of the grating
        sFreqTex = obj.sFreq * obj.radius / obj.res;
        
        % Make sure that at least one complete cycle is created in the texture
        q = ceil(1/sFreqTex);
        
        % Create the texture matrix
        x = meshgrid(-obj.res:obj.res + q, -obj.res:obj.res);
        grating = obj.bgOffset + obj.pcmult * cos(sFreqTex*2*pi*x); 
        
        % Create a circular aperture using the separate alpha-channel:
        [x,y] = meshgrid(-obj.res:obj.res, -obj.res:obj.res);
        circle = (x.^2 + y.^2 <= obj.res^2);
        grating(:,:,2) = 0;
        grating(1:2*obj.res+1, 1:2*obj.res+1, 2) = circle;
               
        % Make the texture that gets drawn
        obj.texture = Screen('MakeTexture', window, grating, [], [], 2, [], glsl);

    end
    
    function draw(obj,p)
        if obj.on
            window = p.trial.display.ptr;
            
            % Use the current time to calculate the phase for accurate temporal frequency
            elapsedTime = p.trial.CurTime - obj.genTime;
            sFreqTex = obj.sFreq * obj.radius / obj.res;
            phaseOffset =  mod(elapsedTime * obj.tFreq,1) / sFreqTex;
            
            % Calculate the rect using the position
            destRect = [obj.pos - obj.radius, obj.pos + obj.radius];
            
            % Filter mode (not sure what the best value is yet)
            % For more information see the PTB documentation for Screen('DrawTexture')
            filterMode = [];
            
            % Draw the texture
            Screen('DrawTexture', window, obj.texture, obj.srcRect, destRect, obj.angle, filterMode, ...
                obj.alpha, [], [], [], [0, phaseOffset, 0, 0]);
        end
    end
    
end

end
        

