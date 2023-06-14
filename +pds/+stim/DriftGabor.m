classdef DriftGabor < pds.stim.BaseStim
% Drifting grating stimulus
% John Amodeo, Apr 2023    

    % Properties of class
    properties
        size % Rectangle in which stim is presented on screen 
        frequency
        sigma
        phase
        angle
        speed % Measured in Hertz: cycles(360 deg) per sec
        contrast
        
        gaborTex
        genTime
    end
    
    % Functions for class
    methods
           
        function obj = DriftGabor(p, pos, fixWin, size, frequency, sigma, phase, angle, speed, contrast)
           
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
            
            if nargin < 9 || isempty(sigma)
                sigma = p.trial.stim.DRIFTGABOR.sigma;
            end
            
            if nargin < 10 || isempty(contrast)
                contrast = p.trial.stim.DRIFTGABOR.contrast;
            end
            
            
            % Load the BaseStim superclass
            obj@pds.stim.BaseStim(p, pos, fixWin)
            
            % Integer to define object (for sending event code)
            obj.classCode = p.trial.event.STIM.DriftGrat;

            % This cell array determines the order of properties when the propertyArray attribute is calculated
            obj.recordProps = {};

            obj.size = size;
            obj.frequency = frequency;
            obj.angle = angle;
            obj.phase = phase;
            obj.speed = speed;
            obj.sigma = sigma;
            obj.contrast = contrast;
            
            obj.gaborTex = CreateProceduralGabor(p.trial.display.ptr, size(1), size(2));
            obj.genTime = p.trial.CurTime;

        end % Close obj function
     

        % Function to present cue and distractor rings on screen
        function draw(obj, p)
                if obj.on
                    destRect = CenterRectOnPoint([0, 0, obj.size(1), obj.size(2)], obj.pos(1), obj.pos(2));
                    
                    elapsedTime = p.trial.CurTime - obj.genTime;
                    phaseShift = obj.phase + ((360 * obj.speed) * elapsedTime);     
                    
                    Screen('DrawTexture', p.trial.display.ptr, obj.gaborTex, [], destRect, obj.angle, [], [],...
                        [], [], kPsychDontDoRotation,[phaseShift, obj.frequency, obj.sigma, obj.contrast]);   
                end
       
        end % Close draw function


    end % Close methods

end % Close class
