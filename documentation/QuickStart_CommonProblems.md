# Getting Started: Troubleshooter's survival Guide


## Configuration not yet verified

```{Matlab}
Configuration not yet verified. Please do it now.
errors in ValidateBitsPlusImaging line 1899
errors in BitsPlusPlus line 1629
errors in PsychImaging line 2054
errors in openScreen line 132
errors in run line 51
errors in start_NeuroCRF line 110
```

:scream:

This error message could mean change of plans, allocate a good amount of time and get it solved!

  1. Take a breath and keep calm.
  2. check that Datapixx is switched on.
  3. Run the following two commands in Matlab:
    * `BitsPlusImagingPipelineTest(1);`
    * `BitsPlusIdentityClutTest(1, 1);`
  4. Try again and hope for the best.

If this did not work it could mean several things, either the environment is not set-up at all, i.e. you are just starting to play with ND_PLDAPS, or a system update happened that screwed up the graphic driver configuration. Make sure that the installed graphic driver is *nvidia-340*. Newer versions are causing problems with Matlab. Restart the computer, run the two above commands again and hope everything is OK.

More information could be found in the documentation of Psychtoolbox about [BitsPlusPlus](https://github.com/kleinerm/Psychtoolbox-3/blob/master/Psychtoolbox/PsychGLImageProcessing/BitsPlusPlus.m).

## Datapixx is not open!

```{Matlab}
Error in function SetVideoClut: 	Usage error
Datapixx is not open! Call: Datapixx('Open').
PTB-ERROR: Error during error handling! ScreenCloseAllWindows() called recursively!
Trying to break out of this vicious cycle...
PTB-ERROR: Maybe it is a good idea to exit and restart Matlab/Octave.
Error using Datapixx
Usage:

Datapixx('SetVideoClut', clut);

Error in PsychDataPixx>doDatapixx (line 1145)
            Datapixx(varargin{:});

Error in PsychDataPixx (line 592)
    doDatapixx('SetVideoClut', linear_lut);

Error in ND_reset (line 11)
clear all;
```

## Can not use keyboard after crash / in debug mode

ND_PLDAPS locks the keyboard to be able to use dedicated keyboard functions. If ND_PLDAPS crashes or you go into debug mode it could happen that the keyboard lock is not removed. To remove it manually, type the following command: `ListenChar(0);`. *Just kidding, copy and paste it or find it in the Matlab history where you can double-click it.*
