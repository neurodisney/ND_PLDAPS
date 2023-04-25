classdef DriftGrat < pds.stim.BaseStim
% Drifting grating stimulus
% John Amodeo, Apr 2023
    
    properties
        
        pos
        size

        cycles_per_sec
        temp_f

        angle
        mask

    end
    
    methods
                 
        function obj = DriftGrat(p, fixWin, pos, size, cycles_per_sec, temp_f, angle, mask)
           
            if nargin < 2 || isempty(pos)
                pos = p.trial.stim.;
            end
          
            if nargin < 3 || isempty(pos)
                pos = p.trial.stim.RING.pos;
            end
            
            if nargin < 4 || isempty(lineWeight)
                lineWeight = p.trial.stim.RING.lineWeight;
            end
            
            if nargin < 5 || isempty(color)
                color = p.trial.stim.RING.color;
            end
            
            if nargin < 6 || isempty(fixWin)
                fixWin = p.trial.stim.RING.fixWin;
            end
               
            % Load the BaseStim superclass
            obj@pds.stim.BaseStim(p, pos, fixWin)
            
            % Integer to define object (for sending event code)
            obj.classCode = p.trial.event.STIM.DriftGrat;

            % Fixspot is not counted as a stimulus, so it should not record its properties
            obj.recordProps = {};
            obj.color         = p.trial.display.clut.(color);
            obj.radius        = radius;
            obj.displayRect   = [pos - [radius, radius], pos + [radius, radius]];
            obj.lineWeight    = lineWeight;
            
            % Save a reference to this object in a dependable place in the p struct
            p.trial.behavior.cue.ring = obj;

        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

