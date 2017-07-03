classdef BaseStim < handle
    
% A superclass that defines a bunch of useful methods and properties for use across visual stimuli
%
% Nate Faber, July 2017

properties
    pos = [0,0]
    on = 0;                 % Visibility
    fixWin = 0
    fixActive = 0;          % Whether or not this stim is is checked for eye fixation
    autoDeactivate = 1;     % If fixActive automatically turns off after the stim is turned off and the eye leaves
end

properties (SetAccess = protected)
    eyeDist                 % How far away the eyes are from the center of the stim
    fixState = 'inactive'    
    EV = struct             % Struct of timing arrays to store when things happen to the stim
    fixWinRect              % The bounding box of the fixation window, used for drawing the window
    fixating = 0            % Boolean for fixation
end


methods
    % The constructor method
    function obj = BaseStim(p, pos, fixWin)
        if nargin < 3 || isempty(fixWin)
            fixWin = p.trial.stim.fixWin;
        end
        
        if nargin < 2 || isempty(pos)
            pos = p.trial.stim.pos;
        end
        
        obj.fixWin = fixWin;
        obj.pos = pos;
        
        % Initialize EV struct to contain NaNs
        obj.EV.FixEntry = NaN;
        obj.EV.FixStart = NaN;
        obj.EV.FixBreak = NaN;
        obj.EV.FixLeave = NaN;
        
        % Save the stimulus into p
        p.trial.stim.allStims{end+1} = obj;
    end
    
    function checkFix(obj,p)        
        if p.trial.behavior.fixation.use
            point = [p.trial.eyeX, p.trial.eyeY];
            
            %Determine how far away the eyes are
            obj.eyeDist = inFixWin(obj, point);
            
            % Check fixation state
            getFixState(obj,p)   
        end
    end
    
    function dist = inFixWin(obj, point)
        dist = sqrt( sum( (obj.pos - point)^2 ) );
    end
        
    
    function draw(obj,p)
        % Just draw a dot at the position for the base stimulus.
        % This function can and should be replaced by subclasses
        if obj.on
            Screen('DrawDots', p.trial.display.overlayptr,obj.pos,1,p.trial.display.clut.black)
        end
    end
    
    function drawFixWin(obj,p)
        %% Draw the fixation window around the stimulus
        if obj.fixActive
            switch obj.fixState
                case 'FixOut'
                    Screen('FrameOval', p.trial.display.overlayptr, p.trial.display.clut.eyeold, obj.fixWinRect, ...
                        p.trial.pldaps.draw.eyepos.fixwinwdth, p.trial.pldaps.draw.eyepos.fixwinwdth);
                
                case 'FixIn'
                    Screen('FrameOval', p.trial.display.overlayptr, p.trial.display.clut.eyepos, obj.fixWinRect, ...
                        p.trial.pldaps.draw.eyepos.fixwinwdth, p.trial.pldaps.draw.eyepos.fixwinwdth);
                
                otherwise
                    Screen('FrameOval', p.trial.display.overlayptr, p.trial.display.clut.window, obj.fixWinRect, ...
                        p.trial.pldaps.draw.eyepos.fixwinwdth, p.trial.pldaps.draw.eyepos.fixwinwdth);
            end
        end
    end
        
    %---------------------------------------------%
    % Methods to run on changes of properties
    
    function obj = set.fixWin(obj,value)
        % Automatically adjust the fixWinRect if the fixWin changes size
        obj.fixWin = value;
        obj.fixWinRect = ND_GetRect(obj.pos, obj.fixWin);
    end
    
    function obj = set.pos(obj,value)
        % Automatically adjust the fixWinRect if the objects position changes
        obj.pos = value;
        obj.fixWinRect = ND_GetRect(obj.pos, obj.fixWin);
    end
    
    function obj = set.on(obj,value)
        obj.on = value;
        
        if value
            % Automatically turn on fixation checking when object becomes visible
            obj.fixActive = 1;
        end
    end
    
end

methods (Access = private)
    
    function getFixState(obj,p)
        %% Determine the objects fixation state
        if obj.fixActive
            
            switch obj.fixState
                case 'inactive'
                    % Fixation was just activated, determine the starting state
                    if obj.eyeDist <= obj.fixWin/2
                        obj.fixState = 'FixIn';
                        obj.fixating = 1;
                        obj.EV.FixStart = p.trial.CurTime;
                        p.trial.EV.FixStart = p.trial.CurTime;
                    else
                        obj.fixState = 'FixOut';
                        obj.fixating = 0;
                    end
     
                case 'FixOut'
                    %% currently not fixating
                    
                    % Eye enters the fixation window
                    if obj.eyeDist <= obj.fixWin/2
                        pds.datapixx.strobe(p.trial.event.FIX_IN);
                        obj.fixState = 'startingFix';
                        obj.EV.FixEntry = p.trial.CurTime;
                        p.trial.EV.FixEntry = p.trial.CurTime;
                    else
                        % If the stim is off, deactivate the stim
                        if obj.autoDeactivate && ~obj.on
                            obj.fixActive = 0;
                        end
                    end
                    
                case 'startingFix'
                    %% gaze has momentarily entered fixation window
                    
                    % Gaze leaves again
                    if obj.eyeDist > obj.fixWin/2
                        pds.datapixx.strobe(p.trial.event.FIX_OUT);
                        obj.fixState = 'FixOut';
                        
                        % Gaze is robustly within the fixation window
                    elseif p.trial.CurTime >= obj.EV.FixEntry + p.trial.behavior.fixation.entryTime
                        pds.datapixx.strobe(p.trial.event.FIXATION);
                        obj.fixState = 'FixIn';
                        obj.fixating = 1;
                        obj.EV.FixStart = obj.EV.FixEntry;
                        p.trial.EV.FixStart = obj.EV.FixEntry;
                    end
                    
                case 'FixIn'
                    %% gaze within fixation window
                    
                    % Eye leaves the fixation window
                    if(obj.eyeDist > obj.fixWin/2)
                        pds.datapixx.strobe(p.trial.event.FIX_OUT);
                        
                        % Set state to fixbreak to ascertain if this is just jitter (time out of fixation window is very short)
                        obj.fixState = 'breakingFix';
                        obj.EV.FixLeave = p.trial.CurTime;
                        p.trial.EV.FixLeave = p.trial.CurTime;
                    end
                    
                case 'breakingFix'
                    %% gaze has momentarily left fixation window
                    
                    % Eye has re-entered fixation window
                    if obj.eyeDist <= obj.fixWin/2
                        pds.datapixx.strobe(p.trial.event.FIX_IN);
                        obj.fixState = 'FixIn';
                        
                    % Eye has not re-entered fix window in time
                    elseif p.trial.CurTime > obj.EV.FixLeave + p.trial.behavior.fixation.BreakTime
                        pds.datapixx.strobe(p.trial.event.FIX_BREAK);
                        obj.fixState = 'FixOut';
                        obj.fixating = 0;
                        obj.EV.FixBreak = obj.EV.FixLeave;
                        p.trial.EV.FixBreak = obj.EV.FixLeave;
                    end

                otherwise
                    warning(['Stimuli has unknown fixState: ' obj.fixState]) 
                    
            end       
            
        else
            % No longer care about fixation on this objects position
            obj.fixState = 'inactive';
            
        end
    end
end

end