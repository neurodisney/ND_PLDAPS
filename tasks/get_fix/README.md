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
- remove *_wip from folder name once code is runnable
- implement variable position of fixation spot