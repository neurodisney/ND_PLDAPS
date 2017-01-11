ND_PLDAPS
==========

This repository contains helper tools and experiments to use in combination with the PLDAPS software (https://github.com/HukLab/PLDAPS).

***
## Tools and utilities

### trial_routines
This are mainly stand-alone functions that were extracted from pldapsDefaultTrialFunction in the PLDAPS package and adapted if needed. These functions execute standard routines for hardware interaction that should use in the same way for all tasks.

* __ND_RigDefaults__ 
Generate a settings struct with default parameters for the Disney-Lab that will be used to initialize the pldaps class.

* __ND_InitSession__

* __ND_TrialSetup__ 

* __ND_TrialPrepare__ 

* __ND_FrameDraw__

* __ND_FrameFlip__

* __ND_TrialCleanUpandSave__ 


### utils

A set of function modules that will be used for various task and therefore are kept as stand-alone functions here instead of replicating the code inside each task file.

* __ND_CheckFixation__ 

* __ND_CheckKeyMouse__ 

* __ND_CheckTrialState__ 

* __ND_DrawControlScreen__ 

* __ND_CheckCondRepeat__ 

* __ND_GetConditionList__ 

* __ND_CtrlMsg__ 

* __ND_DefaultColors__ 

* __ND_DefaultBitNames__ 


***
## Experiments

### get_joystick

Task code for initial training step with the purpose to use a joystick (i.e. lever) in order to receive juice rewards.

* __start_joy_train__

* __joy_run__

* __joy_train_taskdef__


***



