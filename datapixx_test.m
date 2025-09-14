fprintf('--- Trying to open Datapixx ---\n');

try
    ok = Datapixx('Open');
catch ME
    warning('First attempt threw an error:\n%s', ME.message);
    ok = 0;
end

if ok == 0
    fprintf('⚠️  Datapixx did not open. Retrying once...\n');
    Datapixx('Close'); % just in case something half-open
    pause(0.5);        % small delay
    try
        ok = Datapixx('Open');
    catch ME
        warning('Retry also threw an error:\n%s', ME.message);
        ok = 0;
    end
end

if ok == 1
    fprintf('✅ Datapixx successfully opened.\n');
else
    warning('❌ Datapixx could not be opened. Is the device free?\n');
end

if ok
    Datapixx('RegWrRd');
    fw = Datapixx('GetFirmwareRev');
    fprintf('Firmware rev: %d\n', fw);
    Datapixx('Close');
end

