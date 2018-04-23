classdef BaseStim < handle
    
% A superclass that defines a bunch of useful methods and properties for use across visual stimuli
%
% Nate Faber, July 2017

properties (AbortSet = true)
    pos = [0,0]
    on = 0;                 % Visibility
    fixWin = 0
    fixActive = 0;          % Whether or not this stim is is checked for eye fixation
    autoFixWin = 1;         % If fixActive automatically turns on/off with stim and eye movement
    p                       % Holds the handle for p
end

properties (SetAccess = protected)
    eyeDist                 % How far away the eyes are from the center of the stim
    fixState = 'inactive'    
    EV = struct             % Struct of timing arrays to store when things happen to the stim
    fixWinRect              % The bounding box of the fixation window, used for drawing the window
    fixating = 0            % Boolean for fixation
    looking  = 0            % Less stringent than fixation. Eye is in the fix window
    
    % Integer to define object (for sending event code)
    classCode = [];
    
    % Signals to send upon turning on or off
    onSignal  = struct('event', 'STIM_ON', ...
        'name', 'StimOn');
    offSignal = struct('event', 'STIM_OFF', ...
        'name', 'StimOff');
    
    % This cell array determines the order of properties when the propertyArray attribute is calculated
    recordProps = {'xpos','ypos'};
end

properties (Dependent)
    xpos
    ypos
    
    % This attribute has all the current properties of the object when called
    propertyStruct
    % The attribute the generates a cell of values for transmitting as event codes
    propertyArray
    
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
        
        pos   = pos(:)';
        obj.pos = pos;
        
        % Store the handle for the PLDAPS object
        obj.p = p;
        
        % Integer to define object (for sending event code)
        obj.classCode = p.trial.event.STIM.BaseStim;
        
        % Initialize EV struct to contain NaNs
        obj.EV.FixEntry = NaN;
        obj.EV.FixStart = NaN;
        obj.EV.FixBreak = NaN;
        obj.EV.FixLeave = NaN;
        
        % Save the stimulus into p
        p.trial.stim.allStims{end+1} = obj;
    end
    
    %---------------------------------------------%
    function checkFix(obj,p)        
        if p.trial.behavior.fixation.use
            point = [p.trial.eyeX, p.trial.eyeY];
            
            %Determine how far away the eyes are
            obj.eyeDist = dist(obj, point);
            
            % Check fixation state
            getFixState(obj, p) 
            
            % Update the fixation variables
            switch obj.fixState
                case 'startingFix'
                    obj.fixating = 0;
                    obj.looking  = 1;
                case 'FixIn'
                    obj.fixating = 1;
                    obj.looking  = 1;
                case 'breakingFix'
                    obj.fixating = 1;
                    obj.looking  = 0;
                case 'FixOut'
                    obj.fixating = 0;
                    obj.looking  = 0;
            end
        end
    end
    
    %---------------------------------------------%
    function bool = inFixWin(obj, point)
        bool = dist(obj, point) <= obj.fixWin/2;
    end
    
    %---------------------------------------------%
    function dist = dist(obj, point)
        point = point(:)';

        dist = sqrt( sum( (obj.pos - point).^2 ) );
    end
    
    %---------------------------------------------%
    function draw(obj,p)
        % Just draw a dot at the position for the base stimulus.
        % This function can and should be replaced by subclasses
        if obj.on
            Screen('DrawDots', p.trial.display.overlayptr,obj.pos,1,p.trial.display.clut.black)
        end
    end
    
    %---------------------------------------------%
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
    function cleanup(obj)
        %% Removes handle to p and handles any other clean up operations
        obj.p = [];
    end
        
    %---------------------------------------------%
    %% Methods to run on changes of properties
    
    %---------------------------------------------%
    function obj = set.fixWin(obj,value)
        % Ensure fixWin stays nonnegative
        obj.fixWin = max(value,0);        
        
        % Automatically adjust the fixWinRect if the fixWin changes size
        obj.fixWinRect = ND_GetRect(obj.pos, obj.fixWin);
    end
    
    %---------------------------------------------%
    function obj = set.pos(obj,value)
        % Automatically adjust the fixWinRect if the objects position changes
        obj.pos = value;
        obj.fixWinRect = ND_GetRect(obj.pos, obj.fixWin);
    end
    
    %---------------------------------------------%
    function obj = set.on(obj,value)
        obj.on = value;
        
        %% Signal that object is turning on or off
        % Get the event/name
        if value
            event     = obj.onSignal.event;
            eventName = obj.onSignal.name;
        else
            event     = obj.offSignal.event;
            eventName = obj.offSignal.name;
        end
        
        % Queue up the signals (for accurate temporal precision)
        ND_AddScreenEvent(obj.p, obj.p.trial.event.(event), eventName);
        
        % When stim first comes on, record the stimulus in the stimRecord for signal transmission after the trial is over
        if value
            saveProperties(obj);
        end
        
        %% If enabled, automatically turn on fixation checking when object becomes visible
        if value && obj.autoFixWin           
            obj.fixActive = 1;
        end
    end
    
    %------------------------------------------%
    %% Methods for getting dependent variables
    
    function value = get.xpos(obj)
        value = obj.pos(1);
    end
    
    %---------------------------------------------%
    function value = get.ypos(obj)
        value = obj.pos(2);
    end
    
    %---------------------------------------------%
    function array = get.propertyArray(obj)
        nVals = 1 + length(obj.recordProps);
        array = zeros(1, nVals);
        
        % Array starts with a code identifying the objects type
        array(1) = obj.classCode;
        
        for i = 2:nVals
            prop = obj.recordProps{i-1};
            array(i) = obj.(prop);
        end
    
    end
    
    %---------------------------------------------%
    function propStruct = get.propertyStruct(obj)
        nVals = length(obj.recordProps);
        propStruct = struct;
        
        propStruct.classCode = obj.classCode;
        for i = 1:nVals
            prop = obj.recordProps{i};
            propStruct.(prop) = obj.(prop);
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
                        obj.EV.FixStart     = p.trial.CurTime;
                        p.trial.EV.FixStart = p.trial.CurTime;
                    else
                        obj.fixState = 'FixOut';
                    end
     
                case 'FixOut'
                    %% currently not fixating
                    
                    % Eye enters the fixation window
                    if obj.eyeDist <= obj.fixWin/2
                        pds.datapixx.strobe(p.trial.event.FIX_IN);
                        obj.fixState = 'startingFix';
                        obj.EV.FixEntry     = p.trial.CurTime;
                        p.trial.EV.FixEntry = p.trial.CurTime;
                    else
                        % If the stim is off, deactivate the stim
                        if obj.autoFixWin && ~obj.on
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
                        obj.EV.FixStart     = obj.EV.FixEntry;
                        p.trial.EV.FixStart = obj.EV.FixEntry;
                    end
                    
                case 'FixIn'
                    %% gaze within fixation window
                    
                    % Eye leaves the fixation window
                    if(obj.eyeDist > obj.fixWin/2)
                        pds.datapixx.strobe(p.trial.event.FIX_OUT);
                        
                        % Set state to fixbreak to ascertain if this is just jitter (time out of fixation window is very short)
                        obj.fixState = 'breakingFix';
                        obj.EV.FixLeave     = p.trial.CurTime;
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
                        obj.EV.FixBreak     = obj.EV.FixLeave;
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
    
    %---------------------------------------------%
    function saveProperties(obj)
        obj.p.trial.stim.record.arrays{end+1}  = obj.propertyArray;
        obj.p.trial.stim.record.structs{end+1} = obj.propertyStruct;
    end
        
        
end

end