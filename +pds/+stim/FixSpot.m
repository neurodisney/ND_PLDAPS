classdef FixSpot < pds.stim.BaseStim
% Fix spot stimulus
% Nate Faber, July 2017

properties
    size
    type
    color
end

properties (Constant)
    % Integer to define object (for sending event code)
    classCode = 7701;
    
    % Events are different for the fixspot class
    onSignal  = struct('event', 'FIXSPOT_ON', ...
        'name', 'FixOn');
    offSignal = struct('event', 'FIXSPOT_OFF', ...
        'name', 'FixOff');
    
    % This cell array determines the order of properties when the propertyArray attribute is calculated
    % Fixspot is not counted as a stimulus, so it should not record its properties
    recordProps = {};
end

methods
    
    function obj = FixSpot(p,pos,size,type,color,fixWin)
        if nargin < 6 || isempty(fixWin)
            fixWin = p.trial.stim.FIXSPOT.fixWin;
        end
        
        if nargin < 5 || isempty(color)
            color = p.trial.stim.FIXSPOT.color;
        end
        
        if nargin < 4 || isempty(type)
            type = p.trial.stim.FIXSPOT.type;
        end
        
        if nargin < 3 || isempty(size)
            size = p.trial.stim.FIXSPOT.size;
        end
        
        if nargin < 2 || isempty(pos)
            pos = p.trial.stim.FIXSPOT.pos;
        end
        
        % Load the BaseStim superclass
        obj@pds.stim.BaseStim(p, pos, fixWin)
        
        obj.color = color;
        obj.type = type;
        obj.size = size;
        obj.pos = pos;
        
        % Save a reference to this object in a dependable place in the p struct
        p.trial.behavior.fixation.fix = obj;
        
    end
    
    function draw(obj,p)
        if obj.on
            switch  obj.type
                case 'disc'
                    Screen('gluDisk', p.trial.display.overlayptr, p.trial.display.clut.(obj.color), ...
                        obj.pos(1), obj.pos(2), obj.size);
                case 'rect'
                    Screen('FillRect',  p.trial.display.overlayptr, p.trial.display.clut.(obj.color), ...
                        ND_GetRect(obj.pos, obj.size));
                    
                otherwise
                    error('Unknown type of fixation spot: %s', p.trial.behavior.fixation.FixType);
            end
        end
    end
    
end
    
end

