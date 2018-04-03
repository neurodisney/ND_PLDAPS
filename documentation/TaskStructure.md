# Task Structure

__________
Organization of a Task.
__________

## File Types

Task files should be stored in the `tasks` directory, and each task should have its own subdirectory that is named with the task name. A task could consist of several files, not all of them are needed for every task. The general naming convention is described below, however, there is some flexibility in naming. It might be good to adhere to the main convention to make it easier for other people to understand the organization.

________________________________________________________________________________
* `start_<TaskName>.m`

  This function is needs to be called in Matlab for starting the experiment. In this function, the PLDAPS object will be created and the names of the other task files are defined, as well as it is defined what configuration is used and what hardware will be activated. It defines the core minimal configuration for the task.

  :construction: **ToDo:** This function could be modified to use the subject name to select animal specific TaskDef files.

  :warning: **This function only needs to be edited when creating a task.**
________________________________________________________________________________
* `<TaskName>.m`

  This is the core task routine that contains all the code for running a task.

  :warning: **This function only needs to be edited when creating a task.**
________________________________________________________________________________
* `<TaskName>_taskdef.m`

  This function defines the task parameters that could be changed online. Since this function will be execute prior to running a trial it allows to edit and modify task parameters online.

  :construction: **ToDo:** Right now there is only a single task definition file. Either, as mentioned above, the `start_<TaskName>.m` could be modified to call different files depending on the animal used, or the task defintion file itself could be modified to define animal specific parameters.

  :warning: **This function likely will be edited continuously between exprimental sessions or even while running an experiment.**

________________________________________________________________________________
* `<TaskName>_init.m`

  Sometimes this function is used to outsource a code chunk from the main task function that sets all initialization parameters for the task that could be changed while running the task, or the code definition for generation a trial summary text file.

  :warning: **This function only needs to be edited when creating a task.**
________________________________________________________________________________
* `<TaskName>_aftertrial.m`

  Right now, this function is not used but it provides the infrastructure for executing code that for example uses the outcome from the current trial. The idea was to provide an interface for running  code from the [Palamedes Toolbox](http://www.palamedestoolbox.org).

________________________________________________________________________________
* `<TaskName>_plots.m`

  With a previous variant this function was providing the infrastructure to generate online plots. Though the option using an `R` script as described below is the recommended option at the moment, the matlab plotting option is still available in principle (if the flag is set active in `start_<TaskName>.m`). However, be aware that calling plots from within Matlab will interfer with the run time and might cause extended delays between trials.
________________________________________________________________________________
* `<TaskName>_Behav.r`
  This R code can be used to visualize the results online. It is executable code that can be run from a linux terminal. The code example below shows example code that can be saved as executable bash script (:wrench:*change text within '<>' accordingly*) and executed in order to create every 10 seconds an updated pdf file in the current session/task directory with behavioral results.

  ```bash
  #!/bin/bash

  while true
  do
  	arg="/home/rig2-user/Data/ExpData/<AnimalName>/$(date '+%Y_%m_%d')/<TaskName>/"
  	~/Experiments/ND_PLDAPS/tasks/<TaskName>/<TaskName>_Behav.r $arg
  	sleep 10
  done
  ```

## Task Code
