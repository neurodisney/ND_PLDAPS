# Getting Started: Troubleshooter's survival Guide


## Configuration not yet verified

:scream:

```{Matlab}
Configuration not yet verified. Please do it now.
errors in ValidateBitsPlusImaging line 1899
errors in BitsPlusPlus line 1629
errors in PsychImaging line 2054
errors in openScreen line 132
errors in run line 51
errors in start_NeuroCRF line 110
```

## Datapixx is not open!

```{Matlab}
Error in function SetVideoClut: 	Usage error
Datapixx is not open! Call: Datapixx('Open').
PTB-ERROR: Error during error handling! ScreenCloseAllWindows() called recursively! Trying to break out of this vicious cycle...
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

## Can not use keyboard after crash

`ListenChar(0)`
