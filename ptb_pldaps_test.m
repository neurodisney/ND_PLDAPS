
% PTB + PLDAPS smoke test
% Run this after boot to verify your rig is healthy.

fprintf('--- Psychtoolbox + PLDAPS check ---\n');

%% 1. Psychtoolbox sanity
try
    AssertOpenGL;
    fprintf('✅ AssertOpenGL passed.\n');
catch ME
    warning('❌ AssertOpenGL failed:\n%s', ME.message);
    return
end

%% 2. Screen test
try
    sca; % close any stray windows
    Screen('Preference','SkipSyncTests',0);
    w = Screen('OpenWindow', max(Screen('Screens')), 0);
    t = Screen('Flip', w);
    WaitSecs(0.2);
    Screen('FillRect', w, 255);
    Screen('Flip', w, t+0.5);
    fprintf('✅ Screen opened & flipped. Press any key to close.\n');
    KbStrokeWait;
    sca;
catch ME
    sca;
    warning('❌ Screen test failed:\n%s', ME.message);
end

%% 3. Keyboard / HID
try
    KbName('UnifyKeyNames');
    [~,~,kc] = KbCheck;
    if any(kc)
        fprintf('✅ Keyboard check: detected key(s): %s\n', mat2str(find(kc)));
    else
        fprintf('✅ Keyboard check: no key pressed (normal).\n');
    end
    PsychHID('Devices');
catch ME
    warning('❌ Keyboard/HID test failed:\n%s', ME.message);
end

%% 4. Datapixx (if connected)
try
    Datapixx('Open');
    Datapixx('Close');
    fprintf('✅ Datapixx opened/closed.\n');
catch ME
    warning('⚠️ Datapixx not detected or busy:\n%s', ME.message);
end

%% 5. Minimal PLDAPS run
try
    p = pldaps(@pDefaultTrial, 1); % 1 dummy trial
    fprintf('✅ PLDAPS object created. Running minimal trial...\n');
    p.run;
    fprintf('✅ PLDAPS trial completed.\n');
catch ME
    warning('⚠️ PLDAPS check failed:\n%s', ME.message);
end

fprintf('--- Check complete ---\n');
