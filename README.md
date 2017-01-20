ND_PLDAPS
==========

This repository contains helper tools and experiments to be used in combination with the PLDAPS software (https://github.com/HukLab/PLDAPS).

***
## Tools and utilities

### trial_routines
This are mainly stand-alone functions that were extracted from pldapsDefaultTrialFunction in the PLDAPS package and adapted if needed. These functions execute standard routines for hardware interaction that should use in the same way for all tasks.

* __ND_RigDefaults__ 
Generate a settings struct with default parameters for the Disney-Lab that will be used to initialize the pldaps class.

* __ND_GeneralTrialRoutines__
Current replacement for pldapsDefaultTrialFunction. First it calls functions that are now separate files so that it is more convenient to understand them and apply modifications

* __ND_InitSession__
Default processes that need to be done at session start. Call in the experimental setup file/section.

* __ND_TrialSetup__ 
What needs to be done during *p.trial.pldaps.trialStates.trialSetup*: General initializations of a trial.

* __ND_TrialPrepare__ 
What needs to be done during *p.trial.pldaps.trialStates.trialPrepare*: Do things that are time sensitive relative to the actual trial start. This call ends with a screen flip that starts the trial (and determines time 0).

* __ND_DrawControlScreen__
What needs to be done during *p.trial.pldaps.trialStates.frameDraw*: Update experimenter control showing eye position and additional information.

* __ND_FrameFlip__
What needs to be done during *p.trial.pldaps.trialStates.frameFlip*: Flip the screen and determine related frame timings.

* __ND_TrialCleanUpandSave__ 
What needs to be done during *p.trial.pldaps.trialStates.trialCleanUpandSave*: Finish the trial, flush buffer and adjust size of pre-allocated data to the actual acquired data.

### utils

A set of function modules that will be used for various task and therefore are kept as stand-alone functions here instead of replicating the code inside each task file.

* __ND_CheckFixation__ 
==WIP:== Core routine to check current fixation and adjust states accordingly.

* __ND_CheckKeyMouse__ 
Check keyboard presses and mouse actions and trigger actions accordingly. ==WIP: check carefully to avoid interference with PLDAPS standard routines==

* __ND_CheckJoystick__ 
==WIP:== Check current joystick signal and adjust states accordingly.

* __ND_CheckTrialState__ 

* __ND_GetConditionList__ 

* __ND_CheckCondRepeat__ 
Checks if a trials counts as completed trial for the current condition, if not, repeat this condition

* __ND_CtrlMsg__ 
Write tesxt messages with a formated time stamp to the command window.

* __ND_DefaultColors__ 
Create lookup table for monkey and experimenter screen and define default colors for standard features.

* __ND_DefineCol__
Wrapper to determine color lookup table entries and to created associated handles.

* __ND_DefaultBitNames__ 


### utils
utilities to facilitate the drawing process.

* __ND_GetRect__ 
Determine the rect to draw stuff.

* __ND_dva2pxl__ 
Convert dva to pixel based on the pldaps specifications.

***
## Experiments

### get_joystick

Task code for initial training step with the purpose to use a joystick (i.e. lever) in order to receive juice rewards.

* __start_joy_train__

* __joy_run__

* __joy_train_taskdef__


***



