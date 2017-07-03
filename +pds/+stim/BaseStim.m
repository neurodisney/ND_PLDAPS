classdef BaseStim < Handle
    
% A superclass that defines a bunch of useful methods and properties for use across visual stimuli


properties
    pos = [0, 0];
    on = 0;                 % Visibility
    fixWin
    fixActive = 0;          % Whether or not this stim is is checked for eye fixation
    autoDeactivate = 1;     % If fixActive automatically turns off after the stim is turned off and the eye leaves
end

properties (SetAccess = private)
    eyeDist                 % How far away the eyes are from the center of the stim
    fixState = 'inactive'    
    EV = struct             % Struct of timing arrays to store when things happen to the stim
end

methods
    % The constructor method
    function obj = BaseStim(p, pos, fixWin)
        obj.pos = pos;
        obj.fixWin = fixWin;
        
        % Initialize EV struct to contain NaNs
        obj.EV.FixEntry = NaN;
        obj.EV.FixStart = NaN;
        obj.EV.FixBreak = NaN;
        obj.EV.FixLeave = NaN;
        
        % Save the stimulus into p
        p.trial.stim.allStims{end+1} = obj;
    end
    
    function checkFix(p)
        % Only do this if fixation is relavent
        if p.trial.behavior.fixation.use
            %Determine how far away the eyes are
            obj.eyeDist = sqrt( (obj.pos(1) - p.trial.eyeX)^2 + (obj.pos(2) - p.trial.eyeY)^2 );

            % If object has been turned on, activate the fixation window
            if obj.on && ~obj.fixActive
                obj.fixActive = 1;
            end

            getFixState(p)
            
            % Deactivate the stim if it is off and eye is no longer looking at where it once was
            if obj.autoDeactivate && ~obj.on && obj.fixActive && strcmp(obj.fixState, 'FixOut')
                obj.fixActive = 0;
            end
        end
    end

end

methods (Access = private)
    
    function getFixState(p)
        %% Determine the objects fixation state
        if obj.fixActive
            
            switch obj.fixState
                case 'inactive'
                    % Fixation was just activated, determine the starting state
                    if obj.eyeDist <= obj.fixWin/2
                        obj.fixState = 'FixIn';                       
                    else
                        obj.fixState = 'FixOut';
                    end
     
                case 'FixOut'
                    %% currently not fixating
                    
                    % Eye enters the fixation window
                    if obj.eyeDist <= obj.fixWin/2
                        pds.datapixx.strobe(p.trial.event.FIX_IN);
                        obj.fixState = 'startingFix';
                        obj.EV.FixEntry = p.trial.CurTime;
                        p.trial.EV.FixEntry = p.trial.CurTime;
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