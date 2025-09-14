sca;
KbName('UnifyKeyNames');           % standardize names
ListenChar(2);                     % stop keys echoing to MATLAB
KbQueueRelease([]);                % nuke any old queues
KbQueueCreate(-1);                 % -1 = all keyboards
KbQueueStart;

disp('Press ESC to exit test');
while 1
    [pressed, firstPress] = KbQueueCheck;
    if pressed
        if firstPress(KbName('ESCAPE'))
            break;
        end
    end
end

KbQueueStop; KbQueueRelease; ListenChar(0);
