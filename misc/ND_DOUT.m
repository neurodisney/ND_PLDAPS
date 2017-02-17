function ND_DOUT(num, chan)

if(nargin<2)
    high = hex2dec('000FFFF'); % first 16 bitsw
else
    high = (2^chan)-2^(chan-1);
end

AssertOpenGL;   % We use PTB-3
if(~Datapixx('Open'))
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache
    get_close = 1;
else
    get_close = 0;
end


Datapixx('SetDoutValues', num, high);
Datapixx('RegWrRd');

% %pause(1);
% input;
% 
% Datapixx('SetDoutValues', 0);
% 
% 
% Datapixx('RegWrRd');
% 
% % Job done
% if(get_close)
%     Datapixx('Close');
%     fprintf('\n\nDemo completed\n\n');
% end
