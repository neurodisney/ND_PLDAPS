classdef Grating

% A class for creating and drawing procedurally generated sine wave gratings
% within the

% Variables that can be changed about the sine wave grating after it has been created:
% Spatial Frequency
% Temporal Frequency
% Orientation
% Contrast
% Position
% Alpha
%
% Variables that can't be changed (for now)
% radius
% Background color offset

properties
    sFreq
    tFreq
    angle
    contrast
    pos
    alpha
end

properties (SetAccess = private)
    contrastMethod
    radius
    bgOffset
end

properties (SetAccess = private, Hidden = true)
    pcmult %Precontrast multiplier
    genTime %When the grating was created (to calculate drifting phase)
    texture % The actual texture used for drawing
end

methods
    % The constructor method
    function obj = Grating(p, radius)
        % Load variables
        % Changeable
        obj.sFreq = p.trial.stim.grating.sFreq;
        obj.tFreq = p.trial.stim.grating.tFreq;
        obj.angle = p.trial.stim.grating.angle;
        obj.contrast = p.trial.stim.grating.contrast;
        obj.pos = p.trial.stim.grating.pos;
        obj.alpha = p.trial.stim.grating.alpha;
        
        % Unchangeable after loading
        obj.contrastMethod = p.trial.stim.grating.contrastMethod;        
        obj.radius = radius;
        obj.genTime = p.trial.CurTime;
        
        switch obj.contrastMethod
            case 'raw'
                obj.bgOffset = [0.5 0.5 0.5 0];
                obj.pcmult = 0.5;
                
            case 'bgshift'
                obj.bgOffset = [p.trial.display.bgColor, 0];
                obj.pcmult = 0.5;
                
            case 'bgscale'
                obj.bgOffset = [p.trial.display.bgColor, 0];
                obj.pcmult = 0.5 + abs(obj.bgOffset(1));
                
            otherwise
                error('Bad Contrast Method');
        end
        
        window = p.trial.display.ptr;
        width = 2*radius;
        height = 2*radius;
        % The texture that gets drawn
        obj.texture = CreateProceduralSineGrating(window, width, height, obj.bgOffset, radius, obj.pcmult);

    end
    
    function draw(obj,p)
        window = p.trial.display.ptr;
        
        % Use the current time to calculate the phase for accurate temporal frequency
        elapsedTime = p.trial.CurTime - obj.genTime;
        phase = 360 * elapsedTime * obj.tFreq;
        
        % Calculate the rect using the position
        destRect = [obj.pos - obj.radius, obj.pos + obj.radius];
        
        % Filter mode (not sure what the best value is yet)
        % For more information see the PTB documentation for Screen('DrawTexture')
        filterMode = 1;
        
        % Draw the texture
        Screen('DrawTexture', window, obj.texture, [], destRect, obj.angle, filterMode, ...
            obj.alpha, [], [], [], [phase, obj.sFreq, obj.contrast, 0]);
        
    end
    
end

end
        

