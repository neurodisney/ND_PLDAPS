ND_PLDAPS
==========

This repository contains helper tools and experiments to be used in combination with the PLDAPS software (https://github.com/HukLab/PLDAPS), using their openreception branch.

Currently, this repository contains the 'master' branch, a developmental branch ('dev'), and a branch with stable code used for training and experiments in one rig ('rig1').

***
## Tools and utilities

### trial_routines
Please do not change these files when just working on task development!

This are mainly stand-alone functions that were extracted from pldapsDefaultTrialFunction in the PLDAPS package and adapted if needed. These functions execute standard routines for hardware interaction that should be used in the same way for all tasks. If there are adjustments necessary we need to implement it in a generalized way that works in combination with every task, or, if really needed, create a dedicated branch.

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

* __ND_FrameDraw__
What needs to be done during *p.trial.pldaps.trialStates.frameDraw*: Display base elements and update experimenter control showing eye position and additional information.

* __ND_FrameFlip__
What needs to be done during *p.trial.pldaps.trialStates.frameFlip*: Flip the screen and determine related frame timings.

* __ND_TrialCleanUpandSave__
What needs to be done during *p.trial.pldaps.trialStates.trialCleanUpandSave*: Finish the trial, flush buffer and adjust size of pre-allocated data to the actual acquired data.

* __ND_AfterTrial__
Make sure changed variable values will be passed on to the next trial. DO everything here that requires the lock on defaultParameters to be removed.

### utils

A set of function modules that will be used for various task and therefore are kept as stand-alone functions here instead of replicating the code inside each task file.

* __ND_CheckFixation__
==WIP: Just a placeholder at the moment, use ND_CheckJoystick as example to get a very simplistic fixation control.== Core routine to check current fixation and adjust states accordingly.

* __ND_CheckKey__
Check keyboard presses and mouse actions and trigger actions accordingly. ==WIP: check carefully to avoid interference with PLDAPS standard routines==

* __ND_CheckMouse__
Read the mouse position and check for button presses

* __ND_CheckJoystick__
==WIP:== Check current joystick signal and adjust states accordingly.

* __ND_GetConditionList__
Create a vector of conditions and blocks that are used during the experiment.

* __ND_CheckCondRepeat__
Checks if a trials counts as completed trial for the current condition, if not, repeat this condition

* __ND_CtrlMsg__
Write tesxt messages with a formated time stamp to the command window.

* __ND_DefaultColors__
Create lookup table for monkey and experimenter screen and define default colors for standard features.

* __ND_DefineCol__
Wrapper to determine color lookup table entries and to created associated handles.

* __ND_DefaultBitNames__
==WIP: Placeholder at the moment, we need to work on this and define a common set when working on the communication between PLDAPS and TDT.==

* __ND_GetITI__
Determine inter-trial interval within a given range based on various distributions.

* __ND_GetRewDur__
Select current reward amount depending on a scheme that increases reward at defined total correct trial numbers, or within blocks of subsequent correct trials.

### grfcs ###
Utilities to facilitate the drawing process.
==WIP: Some of these routines might already be implemented in a better way pldaps, try to identify, and if not then make it OOP to potentially speed up processing.==

==WIP: Here we should provide more basic grafic routines, e.g. for displaying fixation spots, specific items and so on to allow for an easier, user-friendly usage.==

* __ND_GetRect__
Determine the rect to draw stuff.

* __ND_dva2pxl__
Convert dva to pixel based on the pldaps specifications.

* __ND_TrialOn__
Show Cue for active trial.

***

## tasks

Files to run specific experiments are found int the `tasks` subdirectory.

### get_joystick

Task code for initial training step with the purpose to use a joystick (i.e. lever) in order to receive juice rewards.

* __start_joy_train__

* __joy_run__

* __joy_train_taskdef__


***
<<<<<<< HEAD
=======
## misc

A set of functions that support running/processing experiments but are functional outside PLDAPS.


* __ND_FlushReward__ 

Send a longer opening time to the reward system to allow flushing and cleaning.

***



>>>>>>> rig1
