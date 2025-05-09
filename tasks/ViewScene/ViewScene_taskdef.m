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

<<<<<<< HEAD
    % Setting scene configs
    p.trial.task.stim.sceneType = 'image'; % options: 'video' or 'image'
    %p.trial.task.stim.sceneDir = '/home/rig1-user/MatlabFiles/Videos/HierarchyVideos';
    p.trial.task.stim.sceneDir = '/home/rig1-user/MatlabFiles/Images/macaque_faces';
=======
    p.trial.task.stim.videoDir = '/home/rig2-user/Videos/HierarchyVideos';
    videos = dir(p.trial.task.stim.videoDir);
    p.trial.task.stim.videoNames = {videos(~[videos.isdir]).name};
>>>>>>> 76286abd520102913990037e5c0aadd90d2f20a6

    scenes = dir(p.trial.task.stim.sceneDir);
    p.trial.task.stim.sceneNames = {scenes(~[scenes.isdir]).name};

    % Setting image props
    p.trial.stim.IMAGE.sizeGain = 2.1;
    p.trial.stim.IMAGE.fixWin   = 80;
    p.trial.stim.IMAGE.duration = 5;

    % Setting video props
    p.trial.stim.VIDEO.sizeGain = 2.1;
    p.trial.stim.VIDEO.fixWin   = 80;
    p.trial.stim.VIDEO.playRate = 1;


    % Setting properties for fixation point
    p.trial.stim.FIXSPOT.type = 'rect';    
    p.trial.stim.FIXSPOT.color = 'red';
    p.trial.stim.FIXSPOT.size = 0.4;
    p.trial.stim.FIXSPOT.fixWin = 1.5;

    
end

