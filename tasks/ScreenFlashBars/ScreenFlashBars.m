function p = ScreenFlashBars(p, state)
% A stripped down task loop that is designed to flash the screen at a random interval with options for drug delivery via pressure injection.
%
%
%Nilupaer Abudukeyoumu 2021


% ####################################################################### %
%% define the task name that will be used to create a sub-structure in the trial struct

if(~exist('state', 'var'))
    state = [];
end

% ####################################################################### %
%% Initial call of this function. Use this to define general settings of the experiment/session.
% Here, default parameters of the pldaps class could be adjusted if needed.
% This part corresponds to the experimental setup file and could be a separate
% file. In this case p.defaultParameters.pldaps.trialFunction needs to be 
% defined here to refer to the file with the actual trial.
% At this stage, p.trial is not yet defined. All assignments need
% to go to p.defaultparameters

if(isempty(state))

    % --------------------------------------------------------------------%
    %% define ascii output file
    % call this after ND_InitSession to be sure that output directory exists!
    
    p = ND_AddAsciiEntry(p, 'Date',        'p.trial.DateStr',                     '%s');
    p = ND_AddAsciiEntry(p, 'Time',        'p.trial.EV.TaskStartTime',            '%s');
    p = ND_AddAsciiEntry(p, 'Secs',        'p.trial.EV.DPX_TaskOn',               '%s');
    p = ND_AddAsciiEntry(p, 'Subject',     'p.trial.session.subject',             '%s');
    p = ND_AddAsciiEntry(p, 'Experiment',  'p.trial.session.experimentSetupFile', '%s');
    p = ND_AddAsciiEntry(p, 'Tcnt',        'p.trial.pldaps.iTrial',               '%d');
    p = ND_AddAsciiEntry(p, 'Cond',        'p.trial.Nr',                          '%d');
    p = ND_AddAsciiEntry(p, 'Tstart',      'p.trial.EV.TaskStart - p.trial.timing.datapixxSessionStart',   '%d');
    p = ND_AddAsciiEntry(p, 'FixRT',       'p.trial.EV.FixStart-p.trial.EV.TaskStart',                     '%d');
    p = ND_AddAsciiEntry(p, 'RewCnt',      'p.trial.reward.count',                '%d');
    p = ND_AddAsciiEntry(p, 'Result',      'p.trial.outcome.CurrOutcome',         '%d');
    p = ND_AddAsciiEntry(p, 'Outcome',     'p.trial.outcome.CurrOutcomeStr',      '%s');
    p = ND_AddAsciiEntry(p, 'FixPeriod',   'p.trial.EV.FixBreak-p.trial.EV.FixStart', '%.5f');
    p = ND_AddAsciiEntry(p, 'FixColor',    'p.trial.stim.FIXSPOT.color',          '%s');
    p = ND_AddAsciiEntry(p, 'ITI',         'p.trial.task.Timing.ITI',             '%.5f');
    p = ND_AddAsciiEntry(p, 'FixWin',      'p.trial.stim.fix.fixWin',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_X',    'p.trial.stim.fix.pos(1)',             '%.5f');
    p = ND_AddAsciiEntry(p, 'fixPos_Y',    'p.trial.stim.fix.pos(2)',             '.%5f');
    
    
    % call this after ND_InitSession to be sure that output directory exists!
    ND_Trial2Ascii(p, 'init');

    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries later in the lookup table for the definition of task related colors.
 
    p.trial.task.Color_list = {'white'};
    
    % --------------------------------------------------------------------%
    
    %% Determine conditions and their sequence
    % define conditions (conditions could be passed to the pldaps call as
    % cell array, or defined here within the main trial function. The
    % control of trials, especially the use of blocks, i.e. the repetition
    % of a defined number of trials per condition, needs to be clarified.


else
    % ####################################################################### %
    %% Call standard routines before executing task related code
    % This carries out standard routines, mainly in respect to hardware interfacing.
    % Be aware that this is done first for each trial state!
    p = ND_GeneralTrialRoutines(p, state);

    % ####################################################################### %
    %% Subsequent calls during actual trials
    % execute trial specific commands here.

    switch state
% ------------------------------------------------------------------------%
% DONE BEFORE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialSetup
        %% trial set-up
        % prepare everything for the trial, including allocation of stimuli
        % and all other more time demanding stuff.
            TaskSetUp(p);
            
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialPrepare
        %% trial preparation
        % just prior to actual trial start, use it for time sensitive preparations;
            p.trial.EV.TrialStart = p.trial.CurTime;
            
% ------------------------------------------------------------------------%
% DONE DURING THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.framePrepareDrawing
        %% Get ready to display
        % prepare the stimuli that should be shown, do some required calculations
            if(~isempty(p.trial.LastKeyPress))
                KeyAction(p);
            end
            
            TaskDesign(p);
            
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameDraw
        %% Display stuff on the screen
        % Just call graphic routines, avoid any computations
            TaskDraw(p)
            
% ------------------------------------------------------------------------%
% DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
            TaskCleanAndSave(p);   
                        
    end  %/ switch state
    
end  %/  if(nargin == 1) [...] else [...]

% ------------------------------------------------------------------------%
%% Task related functions

% ####################################################################### %

function TaskSetUp(p)
%% main task outline
% Determine everything here that can be specified/calculated before the actual trial start
    p.trial.task.Timing.ITI  =  ND_GetITI(p.trial.task.Timing.MinITI,  ...
                                         p.trial.task.Timing.MaxITI,  [], [], 1, 0.10);

    p.trial.CurrEpoch = p.trial.epoch.ITI;

    % Flag to indicate if ITI was too long (set to 0 if ITI epoch is reached before it expires)
    p.trial.task.longITI = 1;
      
    % Reward
    nRewards = p.trial.reward.nRewards;
    
    % Reset the reward counter (separate from iReward to allow for manual rewards)
    p.trial.reward.count = 0;
  
    % Outcome if no fixation occurs at all during the trial
    p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;        
    p.trial.task.Good   = 0;
    
    % State for acheiving fixation
    p.trial.task.fixFix = 0;
   
    % If the fixspot color is a cell, choose one of the strings from the cell to be the color
    if iscell(p.trial.stim.FIXSPOT.color)
       nColors = length(p.trial.stim.FIXSPOT.color);
       iColor = randi(nColors);
       p.trial.stim.FIXSPOT.color = p.trial.stim.FIXSPOT.color{iColor};
    end
        
    
    %% Make the visual stimuli
%     % Fixation spot
    p.trial.stim.fix = pds.stim.FixSpot(p);
p.trial.stim.Trgt.Contrast    = p.trial.stim.trgtconts(p.trial.Nr); % contrast determined by condition number

    p.trial.stim.GRATING.contrastMethod = 'bgshift';
    p.trial.stim.GRATING.sFreq    = p.trial.stim.Trgt.sFreq;
    p.trial.stim.GRATING.ori      = p.trial.stim.Trgt.ori;
    p.trial.stim.GRATING.pos      = [p.trial.stim.PosX, p.trial.stim.PosY];
    p.trial.stim.GRATING.contrast = p.trial.stim.Trgt.Contrast;

    if(p.trial.stim.Hemi == 'r')
        p.trial.stim.GRATING.pos(1)  = -1*p.trial.stim.GRATING.pos(1);
    end
    
    if(p.trial.task.RandomPar == 1)
        p.trial.stim.Trgt.sFreq = datasample(p.trial.stim.sFreqLst, 1); % spatial frequency as cycles per degree
        p.trial.stim.Trgt.ori   = datasample(p.trial.stim.OriLst,   1); % orientation of grating
    end
    
      if(p.trial.task.RandomPar == 1)
        p.trial.stim.Trgt.sFreq = datasample(p.trial.stim.sFreqLst, 1); % spatial frequency as cycles per degree
        p.trial.stim.Trgt.ori   = datasample(p.trial.stim.OriLst,   1); % orientation of grating
      end
    
         if(p.trial.task.RandomPar == 1)
            p.trial.stim.GRATING.sFreq = datasample(p.trial.stim.sFreqLst, 1); % spatial frequency as cycles per degree
               end

%  % ------------------------
%     % set line field parameters
%     % ------------------------
% 
%     nframes     = 1000; % number of animation frames in loop
%     mon_width   = 39;   % horizontal dimension of viewable screen (cm)
%     v_dist      = 60;   % viewing distance (cm)
%     dot_speed   = 2;    % line speed (deg/sec)
%     ndots       = 2000; % number of lines
%     max_d       = 15;   % maximum radius of  annulus (degrees)
%     min_d       = 1;    % minumum
%     dot_w       = 0.1;  % width of line (deg)
%     fix_r       = 0.15; % radius of fixation point (deg)
%     f_kill      = 0.01; % fraction of lines to kill each frame (limited lifetime)
%     differentcolors =1; % Use a different color for each point if == 1. Use common color white if == 0.
%     differentsizes = 0; % Use different sizes for each point if >= 1. Use one common size if == 0.
%     waitframes = 1;     % Show new line-images at each waitframes'th monitor refresh.
% 
%     if differentsizes>0  % drawing large lines is a bit slower
%         ndots=round(ndots/5);
%     end
% 
%     % ---------------
%     % open the screen
%     % ---------------
% 
%     screens=Screen('Screens');
%     screenNumber=max(screens);
% 
%     PsychImaging('PrepareConfiguration');
%     %PsychImaging('AddTask', 'General', 'UseRetinaResolution');
%     %PsychImaging('AddTask', 'General', 'UseVulkanDisplay');
%     [w, rect] = PsychImaging('OpenWindow', screenNumber, 0);
% 
%     % Enable alpha blending with proper blend-function. We need it
%     % for drawing of smoothed points:
%     Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%     [center(1), center(2)] = RectCenter(rect);
%     fps=Screen('FrameRate',w);      % frames per second
%     ifi=Screen('GetFlipInterval', w);
%     if fps==0
%         fps=1/ifi;
%     end;
% 
%     white = WhiteIndex(w);
%     HideCursor; % Hide the mouse cursor
% 
%     % Do initial flip...
%     vbl=Screen('Flip', w);
% 
%     % ---------------------------------------
%     % initialize line positions and velocities
%     % ---------------------------------------
% 
%     ppd = pi * (rect(3)-rect(1)) / atan(mon_width/v_dist/2) / 360;    % pixels per degree
%     pfs = dot_speed * ppd / fps;                            % line speed (pixels/frame)
%     s = dot_w * ppd;                                        % line size (pixels)
%     fix_cord = [center-fix_r*ppd center+fix_r*ppd];
% 
%     rmax = max_d * ppd; % maximum radius of annulus (pixels from center)
%     rmin = min_d * ppd; % minimum
%     r = rmax * sqrt(rand(ndots,1)); % r
%     r(r<rmin) = rmin;
%     t = 2*pi*rand(ndots,1);                     % theta polar coordinate
%     cs = [cos(t), sin(t)];
%     xy = [r r] .* cs;   % line positions in Cartesian coordinates (pixels from center)
% 
%     mdir = 2 * floor(rand(ndots,1)+0.5) - 1;    % motion direction (in or out) for each line
%     dr = pfs * mdir;                            % change in radius per frame (pixels)
%     dxdy = [dr dr] .* cs;                       % change in x and y per frame (pixels)
% 
%     % Create a vector with different colors for each single line, if
%     % requested:
%     if (differentcolors==1)
%         colvect = uint8(round(rand(3,ndots*2)*255));
%     else
%         colvect=white;
%     end;
% 
%     % Create a vector with different point sizes for each single line, if
%     % requested:
%     if (differentsizes>0)
%         s=(1+rand(1, ndots)*(differentsizes-1))*s;
%     end;
% 
%     % Clamp line widths to range supported by graphics hardware:
%     [minsmooth,maxsmooth] = Screen('DrawLines', w)
%     s = min(max(s, minsmooth), maxsmooth);
% 
%     xymatrix=zeros(2, ndots*2);
% 
%     % --------------
%     % animation loop
%     % --------------
%     for i = 1:nframes
%         if (i>1)
%             Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot (flip erases it)
%             Screen('DrawLines', w, xymatrix, s, colvect, center,1);  % change 1 to 0 to draw non anti-aliased lines.
%             Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
%         end;
% 
%         if KbCheck % break out of loop
%             break;
%         end;
% 
%         oldxy = xy - 15*dxdy;
%         xy = xy + dxdy; % move lines
%         r = r + dr; % update polar coordinates too
% 
%         % check to see which lines have gone beyond the borders of the
%         % annuli
%         r_out = find(r > rmax | r < rmin | rand(ndots,1) < f_kill); % lines to reposition
%         nout = length(r_out);
% 
%         if nout
%             % choose new coordinates
%             r(r_out) = rmax * sqrt(rand(nout,1));
%             r(r<rmin) = rmin;
%             t(r_out) = 2*pi*(rand(nout,1));
% 
%             % now convert the polar coordinates to Cartesian
% 
%             cs(r_out,:) = [cos(t(r_out)), sin(t(r_out))];
%             xy(r_out,:) = [r(r_out) r(r_out)] .* cs(r_out,:);
% 
%             % compute the new cartesian velocities
%             dxdy(r_out,:) = [dr(r_out) dr(r_out)] .* cs(r_out,:);
%             oldxy(r_out, :)= xy(r_out,:);
%         end;
% 
%         % Set this 1 to 0 to test performance of slooow non-vectorized code:
%         if 1
%             % Vectorized synthesis of lines matrix for next frame:
%             xymatrix(:, 1:2:(1+(2*ndots-2))) = xy';
%             xymatrix(:, 2:2:(2+(2*ndots-2))) = oldxy';
%         else
%             % Slow synthesis of lines matrix for next frame:
%             % This is 10-13x slower on Matlab, 320x slower on Octave 3.2!
%             for j=0:ndots - 1
%                 xymatrix(:, 1 + i*2) = transpose(xy(i+1, :));
%                 xymatrix(:, 2 + i*2) = transpose(oldxy(i+1, :));
%             end
%         end
% 
%         vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
%     end;
% 
%     ShowCursor;
%     sca;
% %catch
%     ShowCursor;
%     sca;
% end
% ####################################################################### %
function TaskDesign(p)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.
    switch p.trial.CurrEpoch
        
        case p.trial.epoch.ITI
        %% inter-trial interval: wait until sufficient time has passed from the last trial
        if p.trial.CurTime < p.trial.EV.PlanStart
            % All intertrial processing was completed before the ITI expired
            p.trial.task.longITI = 0;
            
        else
            if isnan(p.trial.EV.PlanStart)
                % First trial, or after a break
                p.trial.task.longITI = 0;
            end
            
            % If intertrial processing took too long, display a warning
            if p.trial.task.longITI
                disp('Warning: longer ITI than specified');
            end
            
            switchEpoch(p,'WaitStart');
            
        end
        
        % ----------------------------------------------------------------%  
        case p.trial.epoch.WaitStart
            %% Press TAB to trigger the PicoSpitzer 
             
            % Manual Key Board Drug Pulse 
             p.trial.task.drugSent = 1;
    
            if p.trial.task.useDrug && ~p.trial.task.drugSent
                ND_PulseSeries(p.trial.datapixx.TTL_spritzerChan,    p.trial.datapixx.TTL_spritzerDur,       ...
                               p.trial.datapixx.TTL_spritzerNpulse,  p.trial.datapixx.TTL_spritzerPulseGap,  ...
                               p.trial.datapixx.TTL_spritzerNseries, p.trial.datapixx.TTL_spritzerSeriesGap, ...
                               p.trial.event.INJECT);
                           
                p.trial.task.drugSent = 1;
            
            end
            
            if p.trial.CurTime > p.trial.EV.epochEnd + p.trial.task.Timing.drugFlashDelay
                switchEpoch(p,'TrialStart');
            end
        % ----------------------------------------------------------------%  
        case p.trial.epoch.TrialStart
        %% trial starts with onset of fixation spot    
            ND_FixSpot(p,1); % generates flash            
            tms = pds.datapixx.strobe(p.trial.event.TASK_ON);   

            p.trial.EV.TaskStart = p.trial.CurTime;
            p.trial.EV.TaskStartTime = datestr(now,'HH:MM:SS:FFF');
            
            if(p.trial.datapixx.TTL_trialOn)
                pds.datapixx.TTL(p.trial.datapixx.TTL_trialOnChan, 1);
            end
            
             if p.trial.datapixx.TTL_ON == 1  
                                
                                % Send the event code for drug pulse
                                pds.datapixx.strobe(p.trial.datapixx.TTL_InjStrobe);
                                
                                % Run the drug pulse
                                for(i=1:p.trial.datapixx.TTL_Npulse)
                                    pds.datapixx.TTL(p.trial.datapixx.TTL_chan, 1, p.trial.datapixx.TTL_PulseDur);
                                    
                                    if(i < p.trial.datapixx.TTL_Npulse)
                                        WaitSecs(p.trial.datapixx.TTL_GapDur);
                                    end
                                end     
             end
             
            switchEpoch(p,'WaitFix');
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitFix
            %% Fixation target shown, waiting for a sufficiently held gaze
            
             %Gaze is outside fixation window
                if p.trial.task.fixFix == 0
               
                % Fixation has occured
                if p.trial.stim.fix.fixating
                    p.trial.task.fixFix = 1;
                
                % Time to fixate has expired
                elseif p.trial.CurTime > p.trial.EV.TaskStart + p.trial.task.Timing.WaitFix
                    
                    %Turn off fixation spot
                    ND_FixSpot(p,0);
                    
                    %Mark trial NoFix, go directly to TaskEnd, do not start task, do not collect reward
                    p.trial.outcome.CurrOutcome = p.trial.outcome.NoFix;
                    switchEpoch(p,'TaskEnd')                   
                end
                                  
        end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
        
        % Run standard TaskEnd routine
        Task_OFF(p);
        
        % Flag next trial ITI is done at begining
        p.trial.flagNextTrial = 1;
        
            
    end  % switch p.trial.CurrEpoch

% ####################################################################### %
function TaskDraw(p)
%% show epoch dependent stimuli
% go through the task epochs as defined in TaskDesign and draw the stimulus
% content that needs to be shown during this epoch.

    
% ####################################################################### %
function TaskCleanAndSave(p)
%% Clean up textures, variables, and save useful info to ascii table
Task_Finish(p);

% Get the text name of the outcome
p.trial.outcome.CurrOutcomeStr = p.trial.outcome.codenames{p.trial.outcome.codes == p.trial.outcome.CurrOutcome};

% Save useful info to an ascii table for plotting
ND_Trial2Ascii(p, 'save');
% ####################################################################### %



function KeyAction(p)
%% task specific action upon key press
    if(~isempty(p.trial.LastKeyPress))

        switch p.trial.LastKeyPress(1)
            
            case KbName('p')  % change color ('paint')
                 p.trial.task.Color_list = Shuffle(p.trial.task.Color_list);
                 p.trial.task.FixCol     = p.trial.task.Color_list{mod(p.trial.blocks(p.trial.pldaps.iTrial), ...
                                           length(p.trial.task.Color_list))+1};
                                
        end
    end

% ####################################################################### %
%% additional inline functions
% ####################################################################### %
function switchEpoch(p,epochName)
p.trial.CurrEpoch = p.trial.epoch.(epochName);
p.trial.EV.epochEnd = p.trial.CurTime;

%function fixspot(p,bool)
%if bool && ~p.trial.stim.fix.on
    %p.trial.stim.fix.on = 1;
    %p.trial.EV.FixOn = p.trial.CurTime;
    %pds.datapixx.strobe(p.trial.event.FIXSPOT_ON);
%elseif ~bool && p.trial.stim.fix.on
    %p.trial.stim.fix.on = 0;
    %p.trial.EV.FixOff = p.trial.CurTime;
    %pds.datapixx.strobe(p.trial.event.FIXSPOT_OFF);
%end