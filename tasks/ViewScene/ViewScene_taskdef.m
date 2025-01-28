% Function to define task parameters
function p = ViewScene_taskdef(p)

    % Setting time window for fixation before trial marked as 'NoStart'
    p.trial.task.Timing.WaitFix = 2;
    % Selecting inter-trial interval (ITI)
    p.trial.task.Timing.ITI = ND_GetITI(1.25, 1.75, [], [], 1, 0.10);
    % Setting time-out(s) for incorrect response
    p.trial.task.Timing.TimeOut = 1; 
    % Duration offset (sec) for video at normal play rate
    p.trial.task.durOffset = 0;

    p.trial.task.stim.videoDir = '/home/rig1-user/MatlabFiles/Videos/HierarchyVideos';
    videos = dir(p.trial.task.stim.videoDir);
    p.trial.task.stim.videoNames = {videos(~[videos.isdir]).name};

    p.trial.stim.VIDEO.sizeGain = 2.1;
    p.trial.stim.VIDEO.fixWin   = 80;
    p.trial.stim.VIDEO.playRate = 1;
    
end

