# Task Protocols

__________
Quick summary of available task code.
__________

## General key assignments

While running ND_PLDAPS the keyboard is usually disabled. However, it is possible to assign keyboard keys to certain functions. There are general key assignments for all tasks that are checked by the [ND_CheckKey function](../utils/ND_CheckKey.m). The keys itself are assigned in [ND_RigDefaults](../defaults/ND_RigDefaults.m) in the "*key assignment*" section. Besides this it is possible to assign keys in keys for each task as well, usually done in the main task file in the `KeyAction` inline function.

:warning: **Be careful to make only unique key assignments!**

Below is a list of default task assignments as it should be specified in  [ND_RigDefaults](../defaults/ND_RigDefaults.m).


Key          | Action
-------------|--------------
esc          | end experiment
space        | trigger reward
p            | toggle pause experiments (no background change)
b            | toggle black-out break (background color changes)
tab          | trigger manual drug delivery
a            | advance to next block
s            | toggle to accept only correct versus all trials
insert       | View the calibration points to adjust current parameters
Home         | (Needs view of calibration points) toggle change of offset (x/y/off)
End          | (Needs view of calibration points) toggle change of gain (x/y/off)
PgUp/Down    | (Needs view of calibration points) increase/decrease calibration parameter
k            | enable keyboard input, therefore no key assignments functional
End          | (If the keyboard is enabled) disable keyboard


## Main tasks

________________________________________________________________________________
### FixCalib

Calibrate eye position by adjusting gain and offset of the analog input to match the locations where the fixation spot is presented.


#### Task specific keys

Key          | Action
-------------|--------------
f            | toggle fixation spot
r            | random fixation spot location for each trial
NumPad Keys  | location for fixation spot on 9 point grid
Arrow Keys   | Move fixation spot in small steps
Enter        | Accept current location
Backspace    | remove last position
z            | remove all positions
w            | remove all positions from current location
+/-          | increase/decrease size of fixation window

________________________________________________________________________________
### RFmap

#### Task specific keys

This task does not have any specific key assignments right now.

Key          | Action
-------------|--------------
             |

________________________________________________________________________________
### manual_rf_map

________________________________________________________________________________
### ScreenReversal

#### Task specific keys

Key          | Action
-------------|--------------
f            | toggle fixation spot
BackSpace    | reload task definition file

________________________________________________________________________________
### DetectGrat

#### Task specific keys

Key          | Action
-------------|--------------
f            | toggle fixation spot
r            | random fixation spot location for each trial
e            | random fixation spot eccentricity for each trial
a            | random fixation spot angular location for each trial
o            | randomly set a new orientation of the grating
g            | randomly select grating parameters for each trial
h            | randomly select hemifield to present grating
Right/Left Arrow | present grating in right/left hemifield
NumPad Keys  | location of the grating corresponding to key location


________________________________________________________________________________
### PercEqui

#### Task specific keys

Key          | Action
-------------|--------------
f            | toggle fixation spot
r            | random fixation spot location for each trial
e            | random fixation spot eccentricity for each trial
a            | random fixation spot angular location for each trial
o            | randomly set a new orientation of the grating
g            | randomly select grating parameters for each trial
h            | randomly select hemifield to present grating
Right/Left Arrow | present grating in right/left hemifield
Down Arrow   | toggle if both gratings share the same parameters
________________________________________________________________________________
### CuedChangeDetect
In development.

## training tasks

________________________________________________________________________________
### NHP_training/InitFixTrain

________________________________________________________________________________
### NHP_training/FixTrain

________________________________________________________________________________
### NHP_training/DelayedSaccade

________________________________________________________________________________
### NHP_training/ContrastChange

________________________________________________________________________________
### NHP_training/DistractFix

## archived
Archived task code will not added to the Matlab paths when initializing ND_PLDAPS and is no longer being maintained. Might be completely dysfunctional.

### archived/revcorr_rfmap
### archived/ScreenFlash
### archived/EyeCalib
### archived/get_fix
### archived/get_joy
### archived/joy_train
### archived/JustFix
### archived/rndrew
