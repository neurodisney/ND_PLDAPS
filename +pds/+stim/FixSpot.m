classdef FixSpot < pds.stim.BaseStim
% Fix spot stimulus
% Nate Faber, July 2017

    properties
        size
        type
        color
    end

    methods
    
        function obj = FixSpot(p, pos, size, type, color, fixWin, image) %image added by Kennedy 1/14/25
        
            if nargin < 2 || isempty(pos)
                pos = p.trial.stim.FIXSPOT.pos;
            end
        
            if nargin < 3 || isempty(size)
                size = p.trial.stim.FIXSPOT.size;
            end
        
            if nargin < 4 || isempty(type)
                type = p.trial.stim.FIXSPOT.type;
            end
        
            if nargin < 5 || isempty(color)
                color = p.trial.stim.FIXSPOT.color;
            end
        
            if nargin < 6 || isempty(fixWin)
                fixWin = p.trial.stim.FIXSPOT.fixWin;
            end

        
            % Load the BaseStim superclass
            obj@pds.stim.BaseStim(p, pos, fixWin)
        
            % Integer to define object (for sending event code)
            obj.classCode = p.trial.event.STIM.FixSpot;
        
            % Fixspot is not counted as a stimulus, so it should not record its properties
            obj.recordProps = {};
        
            % Events are different for the fixspot class
            obj.onSignal  = struct('event', 'FIXSPOT_ON', ...
            'name', 'FixOn');
            obj.offSignal = struct('event', 'FIXSPOT_OFF', ...
            'name', 'FixOff');
        
            obj.color = color;
            obj.type  = type;
            obj.size  = size;
            obj.pos   = pos;
            
        end
    
        function draw(obj,p)
            if obj.on
                Window = p.trial.display.overlayptr;
                Color  = p.trial.display.clut.(obj.color);
            
                switch  obj.type
                    case 'disc'
                        Screen('gluDisk', Window, Color, obj.pos(1), obj.pos(2), obj.size);
                    
                    case 'rect'
                        Screen('FillRect', Window, Color, ND_GetRect(obj.pos, obj.size));

                    otherwise   
 
                        error('Unknown type of fixation spot: %s', p.trial.behavior.fixation.FixType);
                end
            end
        end
    
        function saveProperties(obj)
        % Fixspot should not save its properties. Overwrites superclass function
        end
    end 
end

