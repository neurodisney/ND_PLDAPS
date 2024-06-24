classdef DriftGabor < pds.stim.BaseStim
% Drifting gabor stimulus
% John Amodeo, Apr 2023    

    % Public properties of class
    properties
        size % Rectangle in which stim is presented on screen (pixels) 
        frequency % Cycles per pixel
        sigma % Standard deviation of Gaussian envelope
        phase % Starting point of cycle (degrees)
        angle % Angle (degrees) of gabor lines (i.e., orientation)
        speed % Measured in Hertz: cycles (360 degrees) per sec
        contrast % Michelson contrast value (0, no difference from bg, to 1, max difference)
        alpha % Controls transparency (0, fully transparent, to 1, fully opaque)
        radius % Stores stim size in *visual angle degrees* based on sigma
    end
    
    % Hidden properties of class
    properties (SetAccess = private, Hidden = true)
        gaborTex % Texture used to draw gabor
        genTime % Time at which gabor created, later used for drifting
        bg % Array used to apply contrast
    end
    
    % Functions for class
    methods
           
        function obj = DriftGabor(p, pos, fixWin, size, frequency, radius, phase, angle, speed, contrast, alpha)
            % Loading stimulus paramters
            if nargin < 2 || isempty(pos)
                pos = p.trial.stim.DRIFTGABOR.pos;
            end
            
            if nargin < 3 || isempty(fixWin)
                fixWin = p.trial.stim.DRIFTGABOR.fixWin;
            end

            if nargin < 4 || isempty(size)
                size = p.trial.stim.DRIFTGABOR.size;
            end
            
            if nargin < 5 || isempty(frequency)
                frequency = p.trial.stim.DRIFTGABOR.frequency;
            end
            
            if nargin < 6 || isempty(angle)
                angle = p.trial.stim.DRIFTGABOR.angle;
            end
            
            if nargin < 7 || isempty(phase)
                phase = p.trial.stim.DRIFTGABOR.phase;
            end
            
            if nargin < 8 || isempty(speed)
                speed = p.trial.stim.DRIFTGABOR.speed;
            end
            
            if nargin < 9 || isempty(radius)
                radius = p.trial.stim.DRIFTGABOR.radius;
            end
            
            if nargin < 10 || isempty(contrast)
                contrast = p.trial.stim.DRIFTGABOR.contrast;
            end

            if nargin < 11 || isempty(alpha)
                alpha = p.trial.stim.DRIFTGABOR.alpha;
            end
            
            % Loading BaseStim superclass
            obj@pds.stim.BaseStim(p, pos, fixWin)
            
            % Giving object integer ID for sending event code
            obj.classCode = p.trial.event.STIM.DriftGabor;

            % Assigning order of properties when propertyArray attribute is calculated
            % Storing this info in ascii table instead
            obj.recordProps = {};

            obj.size = size;
            obj.frequency = frequency;
            obj.angle = mod(angle + 180, 360) - 180; % Returning angle always within range [-180, 180]
            obj.phase = phase;
            obj.speed = speed;
            obj.contrast = contrast;
            obj.radius = radius;
            % Converting radius to sigma to use for Gaussian  
            obj.sigma = (radius * 3.5) / 10;  
            obj.bg = [p.trial.display.bgColor alpha];
            obj.gaborTex = CreateProceduralGabor(p.trial.display.ptr, size(1), size(2), [], obj.bg, 1, contrast);
            obj.genTime = p.trial.CurTime;
        end
     
        % Function to present cue and distractor rings on screen
        function draw(obj, p)
                if obj.on
                    destRect = CenterRectOnPoint([0, 0, obj.size(1), obj.size(2)], obj.pos(1), obj.pos(2));
                    
                    elapsedTime = p.trial.CurTime - obj.genTime;
                    phaseOffset = obj.phase + ((360 * obj.speed) * elapsedTime);     
                    
                    Screen('DrawTexture', p.trial.display.ptr, obj.gaborTex, [], destRect, obj.angle, [], [],...
                        [], [], kPsychDontDoRotation,[phaseOffset + 180, obj.frequency, obj.sigma obj.contrast]);   
                end  
        end

    end % Close methods

end % Close class
