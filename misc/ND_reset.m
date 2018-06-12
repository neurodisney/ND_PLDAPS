% quick&dirty hack to restart pldaps after crash/breakpoint

% if(feature('IsDebugMode'))
%     dbquit;
% end

ListenChar(0);
if Datapixx('IsReady')
    Datapixx('Close');
end
%clear all; 
close all;
sca;
