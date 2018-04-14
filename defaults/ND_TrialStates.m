function p = ND_TrialStates(p)
% Default trial states used in the ND_runTrial function. 
% This is a minimal set of states based on the original PLDAPS code
% that determines the flow within a trial
%
%
% wolf zinke, Feb 2017

disp('****************************************************************')
disp('>>>>  ND:  Defining Trial States <<<<')
disp('****************************************************************')
disp('');

% ------------------------------------------------------------------------%
%% states flanking the main trial loop
% trial states that are not called during the main trial loop but flanking it
% are indicated by negative codes, just to allow both to be more independent
p.defaultParameters.pldaps.trialStates.trialSetup             = -1;  % get ready for a trial, set default parameters, make calculations that could be anticipated
p.defaultParameters.pldaps.trialStates.trialPrepare           = -2;  % last trial preparation that ends with a screen refresh defining tral start
p.defaultParameters.pldaps.trialStates.trialCleanUpandSave    = -3;  % save data, clear buffer, complete trial
p.defaultParameters.pldaps.trialStates.experimentAfterTrials  = -4;
%p.defaultParameters.pldaps.trialStates.InterTrial            = -5;  % Do whatever needed between two trials

% ------------------------------------------------------------------------%
%% actual trial loop
% this should be increasing numbers because states are used as numeric
% index to store timings for each frame in a 2D matrix for debugging purposes
p.defaultParameters.pldaps.trialStates.frameUpdate           =  1;  % read in hardware information
p.defaultParameters.pldaps.trialStates.framePrepareDrawing   =  2;  % determine current task state and prepare whatever needed based on current time and behavior
p.defaultParameters.pldaps.trialStates.frameDraw             =  3;  % update graphic buffer as preparation to be shown on screen
p.defaultParameters.pldaps.trialStates.frameFlip             =  4;  % screen refresh, put stuff on screen


% put the trial states in an array to simplify going through them later on
p.defaultParameters.pldaps.trialStates.InTrialList = [p.defaultParameters.pldaps.trialStates.frameUpdate, ...
                                                      p.defaultParameters.pldaps.trialStates.framePrepareDrawing, ...
                                                      p.defaultParameters.pldaps.trialStates.frameDraw, ...
                                                      p.defaultParameters.pldaps.trialStates.frameFlip];

p.defaultParameters.pldaps.trialStates.Current = NaN;  %  keep track of the current active trial state
    