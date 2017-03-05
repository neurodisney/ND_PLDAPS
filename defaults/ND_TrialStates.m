function p = ND_TrialStates(p)
% Default trial states used in the ND_runTrial function. 
% This is a minimal set of states based on original PLDAPS code that
% determines the flow within a trial
%
%
%
% wolf zinke, Feb 2017

disp('****************************************************************')
disp('>>>>  ND:  Defining Trial States <<<<')
disp('****************************************************************')
disp('');

%% states flanking the main trial loop
% trial states that are not called during the main trial loop but flanking it
% are indicated by negative codes, just to allow both to be more independent
p.trial.pldaps.trialStates.trialSetup            = -1;  % get ready for a trial, set default parameters, make calculations that could be anticipated
p.trial.pldaps.trialStates.trialPrepare          = -2;  % last trial preparation that ends with a screen refresh defining tral start
p.trial.pldaps.trialStates.trialCleanUpandSave   = -3;  % save data, clear buffer, complete trial
p.trial.pldaps.trialStates.experimentAfterTrials = -4;
%p.trial.pldaps.trialStates.InterTrial            = -5;  % Do whatever needed between two trials

%% actual trial loop
% this should be increasing numbers because states are used as numeric
% index to store timings for each frame in a 2D matrix for debugging purposes
p.trial.pldaps.trialStates.frameUpdate         =  1;  % read in hardware information
p.trial.pldaps.trialStates.framePrepareDrawing =  2;  % determine current task state and prepare whatever needed based on current time and behavior
p.trial.pldaps.trialStates.frameDraw           =  3;  % update graphic buffer as preparation to be shown on screen
p.trial.pldaps.trialStates.frameFlip           =  4;  % screen refresh, put stuff on screen

  
    