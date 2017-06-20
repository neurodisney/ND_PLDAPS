classdef Grating

% A class for creating and drawing procedurally generated sine wave gratings
% within the

% Variables that can be changed about the sine wave grating after it has been created:

% Temporal Frequency
% Orientation
% Contrast
% Position
% Alpha
%
% Variables that can't be changed (for now)
% Spatial Frequency
% radius
% Contrast Method
% Background color offset
% Resolution

properties
    tFreq
    angle
    contrast
    pos
    alpha
end

properties (SetAccess = private)
    sFreq
    contrastMethod
    radius
    bgOffset
    gratingRect
    res
end

properties (SetAccess = private, Hidden = true)
    genTime %When the grating was created (to calculate drifting phase)
    texture % The actual texture used for drawing
    pcmult
end

methods
    % The constructor method
    function obj = Grating(p, radius)
        % Load variables
        % Changeable
        obj.tFreq = p.trial.stim.grating.tFreq;
        obj.angle = p.trial.stim.grating.angle;
        obj.contrast = p.trial.stim.grating.contrast;
        obj.pos = p.trial.stim.grating.pos;
        obj.alpha = p.trial.stim.grating.alpha;
        
        % Unchangeable after loading
        obj.sFreq = p.trial.stim.grating.sFreq;
        obj.contrastMethod = p.trial.stim.grating.contrastMethod;        
        obj.radius = radius;
        obj.genTime = p.trial.CurTime;
        obj.res = p.trial.stim.grating.res;
        
        switch obj.contrastMethod
            case 'raw'
                obj.bgOffset = 0.5;
                obj.pcmult = 0.5;
                
            case 'bgshift'
                obj.bgOffset = p.trial.display.bgColor(1);
                obj.pcmult = 0.5;
                
            case 'bgscale'
                obj.bgOffset = p.trial.display.bgColor(1);
                obj.pcmult = 0.5 + abs(obj.bgOffset(1) - 0.5);
                
            otherwise
                error('Bad Contrast Method');
        end
        
        window = p.trial.display.ptr;
        
        % Create a special texture drawing shader for masked texture drawing:
        glsl = MakeTextureDrawShader(window, 'SeparateAlphaChannel');
        
        % Scale the spatial frequency to match the resolution of the grating
        sFreqTex = obj.sFreq * obj.radius / obj.res;
        
        % Make sure that at least one complete cycle is created in the texture
        %q = ceil(1/sFreqTex);
        
        % Create the texture matrix
        x = meshgrid(-obj.res:obj.res, -obj.res:obj.res);
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
        Screen('DrawTexture', window, obj.texture, [], destRect, obj.angle, filterMode, ...
            obj.contrast, [], [], [], [0, phaseOffset, 0, 0]);
        
    end
    
end

end
        

