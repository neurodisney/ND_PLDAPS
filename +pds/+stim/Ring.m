classdef Ring < pds.stim.BaseStim
% Fix spot stimulus
% Nate Faber, July 2017

properties
    size
    linewidth
    color
    alpha
    res
    srcRect
    
    %%
    texture
    radius
    angle
    %%
    
end

methods
             
   function obj = Ring(p, pos, size, linewidth, color, alpha, fixWin)
       
        if nargin < 2 || isempty(pos)
            pos = p.trial.stim.RING.pos;
        end
       
         if nargin < 3 || isempty(size)
            size = p.trial.stim.RING.size;
        end
      
        if nargin < 4 || isempty(linewidth)
            linewidth = p.trial.stim.RING.linewidth;
        end
        
        if nargin < 5 || isempty(color)
            color = p.trial.stim.RING.color;
        end
        
        if nargin < 6 || isempty(alpha)
            alpha = p.trial.stim.RING.alpha;
        end
        
        if nargin < 7 || isempty(fixWin)
            fixWin = p.trial.stim.RING.fixWin;
        end
                
        % Load the BaseStim superclass
        obj@pds.stim.BaseStim(p, pos, fixWin)
        
        % Integer to define object (for sending event code)
        obj.classCode = p.trial.event.STIM.Ring;
        
        % Fixspot is not counted as a stimulus, so it should not record its properties
        obj.recordProps = {};
       
        obj.color     = color;
        obj.linewidth = linewidth;
        obj.size      = size;
        obj.alpha     = alpha;
        obj.pos       = pos;
        obj.res       = 1000;
        obj.srcRect   = [0, 0, 2*obj.res + 1, 2*obj.res + 1];
        
        % Save a reference to this object in a dependable place in the p struct
        p.trial.behavior.cue.ring = obj;
        
        % Create a special texture drawing shader for masked texture drawing:
        glsl = p.trial.display.glsl;
               
        % Create the texture matrix
        CoorVec = linspace(-obj.size/2, obj.size/2, obj.res);
        
        [x,y] = meshgrid(CoorVec, CoorVec);
        
        % Create a circular aperture using the separate alpha-channel:
        
        ringmat = ( (x.^2 + y.^2) <= (obj.size - obj.linewidth)^2 | ...
                    (x.^2 + y.^2)  > obj.size^2  );
        
                
        ringmat(:,:,2) = ringmat; % duplicate as alpha map
        ringmat(:,:,1) = ringmat(:,:,1) * p.trial.display.clut.(obj.color); % set as CLUT index
        ringmat = double(ringmat);
        
        % Make the texture that gets drawn
        obj.texture = Screen('MakeTexture', p.trial.display.ptr, ringmat, [], [], 2, [], glsl);
    end
    
    function draw(obj, p)
        if obj.on
            % Calculate the rect using the position
            % destRect = [obj.pos - obj.radius, obj.pos + obj.radius];
            destRect = [obj.pos, obj.pos];
            
            % Filter mode (not sure what the best value is yet)
            % For more information see the PTB documentation for Screen('DrawTexture')
            filterMode = [];
            
            % Draw the texture
            Screen('DrawTexture', p.trial.display.ptr, obj.texture, obj.srcRect,destRect, ...
                                          obj.angle, filterMode, obj.alpha, [], [], []);
        end
    end
    
    function saveProperties(obj)
        % Fixspot should not save its properties. Overwrites superclass function
    end
    
end
    
end

