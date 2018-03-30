ND_PLDAPS
==========

A NeuroDisney flavor of the PLDAPS software provided by the Huk-Lab (https://github.com/HukLab/PLDAPS) and described by Eastman & Huk (2012) in Frontiers in Neuroinformatics:

> Eastman, K.M. & Huk, A.C. (2012). PLDAPS: A hardware architecture and software toolbox for neurophysiology requiring complex visual stimuli and online behavioral control. *Frontiers in Neuroinformatics*, **6**:1. doi: 10.3389/fninf.2012.00001

This repository contains a stripped down and slightly re-organized version of the PLDAPS code derived from the *openreception* branch (Version 4.2). ND_PLDAPS is tailored for the hardware used in the Disney-Lab and provides additional functions and task code. The software is under ongoing development and we do not guarantee that it will work for other experimental set-ups without putting a considerable effort into it. Our approach is to give up flexibility and generalizability of the code in favor of more accurate timing control. Please feel free to use this code as inspiration and example, but do not expect that it will work for you out of the box.

Modifications to the original PLDAPS code include removal of hardware related routines that are not needed for our set-up, i.e. instead of using EyeLink we have an SMI Eye Tracking system and utilize the analog channels to pass on information about eye position, and instead of Plexon we use a system from Tucker Davis Technologies for data acquisition and signal processing. We utilize a joystick as one-axis response lever, and use spatially separate auditory stimuli.

We modified the initialization of the screen in a way that the reference coordinates are using degree visual angle as unit with [0,0] defined as the center of the screen. This implementation eases the way to determine the position of items that are shown on the screen and avoids unnecessary conversions from dva to pixel coordinates.

Instead of trying to get each single screen refresh we use two options depending on whether new stuff will be shown on the experimenter screen only or also on the animal screen (i.e. visual stimulus onset or changes of the stimuli). In the first case, we do not wait for the screen synch, for the second case we get the exact screen flip timings and also use a photo diode flash in addition.


__**Be aware that this is work in progress and we update the code frequently at the moment. Use this code at your own risk, we can not promise that it will function without problems!**__


To cite this repository use: [![DOI](https://zenodo.org/badge/80133270.svg)](https://zenodo.org/badge/latestdoi/80133270)

Some more documentation about the use of ND_PLDAPS can be found here: [ND_PLDAPS Documentation](documentation/ND_PLDAPS_documentation.md) 