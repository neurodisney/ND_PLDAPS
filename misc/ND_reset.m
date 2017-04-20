% quick&dirty hack to restart pldaps after crash/breakpoint

% if(feature('IsDebugMode'))
%     dbquit;
% end

ListenChar(0);
Datapixx('Close');
clear all; 
close all;
sca;
