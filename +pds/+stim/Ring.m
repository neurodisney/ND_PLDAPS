classdef Ring < pds.stim.BaseStim
% Fix spot stimulus
% Nate Faber, July 2017

properties
    radius
    contrast
    displayRect
    isCue
    lineWeight
    
    color
    % texture
    % angle
    % size
    % res
    % alpha
    
end

methods
             
   function obj = Ring(p, radius, contrast, pos, isCue, lineWeight, color, fixWin)
       
        if nargin < 2 || isempty(radius)
            radius = p.trial.stim.RING.radius;
        end
       
         if nargin < 3 || isempty(contrast)
            contrast = p.trial.stim.RING.contrast;
        end
      
        if nargin < 4 || isempty(pos)
            pos = p.trial.stim.RING.pos;
        end
        
        if nargin < 5 || isempty(isCue)
            isCue = p.trial.stim.RING.isCue;
        end
        
        if nargin < 6 || isempty(lineWeight)
            lineWeight = p.trial.stim.RING.lineWeight;
        end
        
        if nargin < 7 || isempty(color)
            color = p.trial.stim.RING.color;
        end
        
        if nargin < 8 || isempty(fixWin)
            fixWin = p.trial.stim.RING.fixWin;
        end
           
        % Load the BaseStim superclass
        obj@pds.stim.BaseStim(p, pos, fixWin)
        
        % Integer to define object (for sending event code)
        obj.classCode = p.trial.event.STIM.Ring;
        
        % Fixspot is not counted as a stimulus, so it should not record its properties
        obj.recordProps = {};
       
        obj.radius        = radius;
        obj.contrast      = contrast;
        obj.displayRect   = [pos - [radius, radius], pos + [radius, radius]];
        obj.isCue         = isCue;
        obj.lineWeight    = lineWeight;
        
        obj.color     = color;
        
        % obj.size      = size;
        % obj.linewidth = linewidth;
        % obj.res       = 1000;
        % obj.alpha     = alpha;
        % obj.res       = 1000;
        
        % Save a reference to this object in a dependable place in the p struct
        p.trial.behavior.cue.ring = obj;
        
        % Create a special texture drawing shader for masked texture drawing:
            % glsl = p.trial.display.glsl;
               
        % Create the texture matrix
            % CoorVec = linspace(-obj.size/2, obj.size/2, obj.res);
            % [x,y] = meshgrid(CoorVec, CoorVec);
        
        % Create a circular aperture using the separate alpha-channel:
            % ringmat = ones(1000) * 255;
        
        % Make the texture that gets drawn
            % obj.texture = Screen('MakeTexture', p.trial.display.ptr, ringmat, [], [], 2, [], glsl);     
   end
    
    % Function to present cue and distractor rings on screen
    function draw(obj, p)
        if obj.on
            if obj.isCue  
                % Draw cue ring texture on screen
                Screen('FrameOval', p.trial.display.ptr, obj.color, obj.displayRect, obj.lineWeight(1), obj.lineWeight(2));
            elseif ~obj.isCue  
                % Draw distractor ring texture on screen
                Screen('FrameOval', p.trial.display.ptr, obj.color, obj.displayRect, obj.lineWeight(1), obj.lineWeight(2));
                
            end
        end
    end
    
end
end

