# Getting Started: Run a session

____
**Short version:**

    `start_TaskName('SubjectName');`  
____

**Slightly longer version:**

To start an experiment in PLDAPS is very simple.

First, make sure everything is ready:

  1. Turn on Datapixx and projector
  2. Turn on Eye Tracker
  3. Turn on experimental computer
  4. Start Matlab

Once this is done, you can start an experiment with a command like this:

    `p = start_TaskName('SubjectName');`  

* `TaskName` needs to be replaced with an existing task, for example one of the tasks described [here](TaskParadigms.md).

* `'SubjectName'` defines the directory where data will be stored. for future versions, it might also set subject specific task parameters. If no argument is specified, then the defualt will be `subjname = 'tst';`.

* If `'mouse'` is used as `SubjectName`, it will start a test configuration where the eye tracker is disabled and instead the mouse position is used as eye position.

* In this command variant, an output is assigned to `p`. This is not necessary but makes it possible to inspect the pldaps object once the experiment ended.

* In previous variants, a task was started with this line: `ND_reset; p = start_TaskName('SubjectName');`. The initial part (`p = start_TaskName('SubjectName');`) makes sure that DataPixx is ready and nothing from previous experiments interferes with the current task. This part is now implemented in the `start_TaskName` script and therefore does not need to be called any longer.
