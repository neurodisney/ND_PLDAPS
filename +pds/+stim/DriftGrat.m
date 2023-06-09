classdef DriftGrat < pds.stim.BaseStim
% Drifting grating stimulus
% John Amodeo, Apr 2023    

    % Properties of class
    properties
        amplitude
        frequency
        phase
        sigma
        speed
        windowSize
        screenID
        bgColor
    end
    
    % Functions for class
    methods
           
        function obj = DriftGrat(p, pos, fixWin, frequency, phase, sigma, speed, windowSize, screenID, bgColor)
           
            if nargin < 2 || isempty(pos)
                pos = p.trial.stim.DRIFTGRAT.pos;
            end
            
            if nargin < 3 || isempty(fixWin)
                fixWin = p.trial.stim.DRIFTGRAT.fixWin;
            end

            if nargin < 4 || isempty(frequency)
                frequency = p.trial.stim.DRIFTGRAT.frequency;
            end
            
            if nargin < 5 || isempty(phase)
                phase = p.trial.stim.DRIFTGRAT.phase;
            end
            
            if nargin < 6 || isempty(sigma)
                sigma = p.trial.stim.DRIFTGRAT.sigma;
            end
            
            if nargin < 7 || isempty(speed)
                speed = p.trial.stim.DRIFTGRAT.speed;
            end
            
            if nargin < 8 || isempty(windowSize)
                windowSize = p.trial.stim.DRIFTGRAT.windowSize;
            end

            if nargin < 9 || isempty(screenID)
                screenID = p.trial.stim.DRIFTGRAT.screenID;
            end

            if nargin < 9 || isempty(bgColor)
                bgColor = p.trial.stim.DRIFTGRAT.bgColor;
            end
            
            % Load the BaseStim superclass
            obj@pds.stim.BaseStim(p, pos, fixWin)
            
            % Integer to define object (for sending event code)
            obj.classCode = p.trial.event.STIM.DriftGrat;

            % This cell array determines the order of properties when the propertyArray attribute is calculated
            obj.recordProps = {};

            obj.amplitude = amplitude;
            obj.frequency = frequency;
            obj.phase = phase;
            obj.sigma = sigma;
            obj.speed = speed;
            obj.windowSize = 100;
            obj.screenID = screenID;
            obj.bgColor = bgColor;

            obj.gaborTex = CreateProceduralGabor(p.defaultParameters.display.ptr, 100, 100);

        end % Close obj function
        

        % Function to present cue and distractor rings on screen
        function draw(obj, p)

                if obj.on

                    
                end
       
        end % Close draw function


    end % Close methods

end % Close class

