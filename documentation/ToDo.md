# ToDo


## clean up handling of task files

Create a substruct in the pldaps object that contains fields for all relevant task files, such as init, experiment, TaskDef, aftertrial. Add default routines that execute these files at appropriate times.

Right now, the handling is a little inconsistent.

## Animal specific task definition

Create either separate files for each individual animal that will be assigned when starting up the task (*problem of duplicating a lot of settings that do not need to be modified*), make a `switch` statement in the TaskDef file that sets animal specific parameters (*problem of blowing up the code and potential impair its readability*), or add the option to call an extra file after calling a default TaskDef that changes just the parameters specific for one animal (*right now my favorite, but it sets the same parameters several time and one has to be aware of the order*).
