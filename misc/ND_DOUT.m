function ND_DOUT(chan)

chanmask = zeros(1, 24);
chanmask(chan) = 1;

chanmask = bin2dec(sprintf('%d',flip(chanmask)));


AssertOpenGL;   % We use PTB-3
if(~Datapixx('Open'))
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache
    get_close = 1;
else
    get_close = 0;
end


Datapixx('SetDoutValues', chanmask);
Datapixx('RegWrRd');
pause(1);
Datapixx('SetDoutValues', 0, chanmask);
Datapixx('RegWr');
