# joy_train

Basic paradigm to familiarize an animal with the use of a joystick.

This task has a basic outline. To start a trial, the joystick needs to be in a released stated for a specified time period. Then a frame is shown to indicate the start of a trial. The animal has to press the joystick within a defined time window to indicate its readiness to work. Upon joystick press a patch is shown at the center of the screen that changes color or contrast after a variable hold period. The animal has to release the joystick after the central stimulus changed. The animal will receive fluid reward when releasing in time, and also could get an optional reward for correct joystick presses.

### **start_joy_train.m**
Main script to start the task. It sets some parameters that deviate from the settings in ND_RigDefaults.

### **joy_train_taskdef.m**
This file contains task related parameters and settings defining stimulus features and task timing as well as reward parameters.

### **joy_train.m**
Main trial function that defines the time course of the task.
