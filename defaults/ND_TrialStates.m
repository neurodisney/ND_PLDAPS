function p = ND_TrialStates(p)
% Default trial states used between subsequent screen refreshes. 
%
%
%
%
% wolf zinke, Feb 2017

disp('****************************************************************')
disp('>>>>  ND:  Defining Trial States <<<<')
disp('****************************************************************')
disp('');

%% states flanking themain trial loop
% trial states that are not in a frame are negative, just to allow both to be more independent
p.trial.pldaps.trialStates.trialSetup          = -1;
p.trial.pldaps.trialStates.trialPrepare        = -2;
p.trial.pldaps.trialStates.trialCleanUpandSave = -3;

%% actual trial loop
% this should be increasing numbers because states are used as numeric
% index to store timings for each frame in a 2D matrix
p.trial.pldaps.trialStates.frameUpdate         =  1;
p.trial.pldaps.trialStates.framePrepareDrawing =  2; 
p.trial.pldaps.trialStates.frameDraw           =  3;
p.trial.pldaps.trialStates.frameFlip           =  4;

  
    