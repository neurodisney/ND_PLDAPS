function p=plainAMBHack1(p,state)
% plainAMBHack1.m 
% 10/24/16 changelog for everything up to date:
% - removed call to pdsDefaultTrialStructure.m 
% - everything called by this is defaultParameters.(stimulusname). stuff
% - may piggy back onto this method of functionality at some point
% - added whatever is called to lines in this script, lets move them as
% high level as possible
%
% last modified 10/24/16 AMB
% created 09/01/16 AMB
% 
% based on plain.m from pldaps
%
% original comments below:
%
%plain    a plain stimulus file for use with a pldaps class. This file
%         serves both as the expriment setup file and the trial state function
% example:
% load settingsStruct
% p=pldaps(@plain,'demo', settingsStruct);
% p.run
if nargin==1 %initial call to setup conditions
    disp('plainAMBHack1.m called with nargin==1');
    %         p = pdsDefaultTrialStructure(p); % this *probably* doesnt need to be called
    % meaningful stuff that is called
    p = defaultColors(p);
    p = defaultBitNames(p);
    p.defaultParameters.pldaps.finish = inf;
    %p.defaultParameters.good = 1; % lol rly huklab?
    
    
    %% the below before else should prolly be moved outside... why hide it??
    
    %         dv.defaultParameters.pldaps.trialMasterFunction='runTrial';
    p.defaultParameters.pldaps.trialFunction='plainAMBHack1';
    %five seconds per trial.
    %         p.trial.pldaps.maxTrialLength = 5;
    p.trial.pldaps.maxTrialLength = 20;
    p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
    % how does this not crash???
    c.Nr=1; %one condition;
    p.conditions=repmat({c},1,10);
    %         p.conditions=repmat({c},1,200);
    
    p.defaultParameters.pldaps.finish = length(p.conditions);
else
    %if you don't want all the pldapsDefaultTrialFucntions states to be used,
    %just call them in the states you want to use it.
    %otherwise just leave it here
    %disp('plainAMBHack1.m called with nargin==1');
    pldapsDefaultTrialFunctionAMBHack1(p,state);
    
    
    % so you can either do things from here for a state, or do it
    % within the subfxn/method/WHATEVER itself. SO MUCH REDUNDANCY
    switch state
        %             case dv.trial.pldaps.trialStates.frameUpdate
        %             case dv.trial.pldaps.trialStates.framePrepareDrawing;
        %             case dv.trial.pldaps.trialStates.frameDraw;
        % %             case dv.trial.pldaps.trialStates.frameIdlePreLastDraw;
        % %             case dv.trial.pldaps.trialStates.frameDrawTimecritical;
        %             case dv.trial.pldaps.trialStates.frameDrawingFinished;
        % %             case dv.trial.pldaps.trialStates.frameIdlePostDraw;
        %
        %             case dv.trial.pldaps.trialStates.trialSetup
        %             case dv.trial.pldaps.trialStates.trialPrepare
        %             case dv.trial.pldaps.trialStates.trialCleanUpandSave
        
        case p.trial.pldaps.trialStates.frameFlip;
            if p.trial.iFrame == p.trial.pldaps.maxFrames
                p.trial.flagNextTrial=true;
            end
    end
end