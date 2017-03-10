/ND_PLDAPS/tasks/get_fix_wip 

03/02/2017 created (AB)
03/02/2017 last updated (AB)
modified from/based on: /ND_PLDAPS/tasks/get_joy (WZ)

layout of folder scripts:
------

i. start_fix_train.m - run this script to begin the experiment
	it calls fix_train_task

ii. fix_train_task.m - called by start_fix_train.m
	if the experiment run is being initialized, 
	it calls fix_train_taskdef.m

iii. fix_train_taskdef.m - 


todos:
------
- implement variable position of fixation spot


03/08/2017 Update/Notes:
------
- need to check if eye position is displayed
- ensure kb button press to pause task and modify specific settings
- plot at end of each trial of eye behavior


p.trial.behavior.fixation.FixPos(1)=x coordinate of interest/ref
p.trial.behavior.fixation.FixPos(2)=y coordinate of interest/ref

