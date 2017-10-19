function p = ND_Outcomes(p)
% Defines numeric values for possible trial outcomes.
%
% The outcome will be encoded in the trial header.
%
% wolf zinke, Feb. 2017


disp('****************************************************************')
disp('>>>>  ND:  Defining Task Outcomes <<<<')
disp('****************************************************************')
disp('');

% ------------------------------------------------------------------------%
%% Define task outcomes

p.defaultParameters.outcome.Correct           =   1004;  % correct performance, no error occurred
p.defaultParameters.outcome.Abort             =   2;     % early joystick release prior stimulus onset
p.defaultParameters.outcome.Early             =   3005;  % release prior to response window
p.defaultParameters.outcome.False             =   3006;  % wrong response within response window
p.defaultParameters.outcome.Late              =   5;     % response occurred after response window
p.defaultParameters.outcome.Miss              =   3007;  % no response at a reasonable time
p.defaultParameters.outcome.NoStart           =   3004;  % trial not started
p.defaultParameters.outcome.PrematStart       =   3008;  % trial start not too early as response to cue
p.defaultParameters.outcome.TaskStart         =   3009;  % trial not started
p.defaultParameters.outcome.Break             =   9901;  % A break was triggered by the experimenter

% joystick related
if(p.defaultParameters.behavior.joystick.use)
    p.defaultParameters.outcome.NoPress       =   1;  % No joystick press occurred to initialize trial
end

% fixation related
if(p.defaultParameters.behavior.fixation.use)

    p.defaultParameters.outcome.Fixation      =   1000;
    p.defaultParameters.outcome.NoFix         =   3010;
    p.defaultParameters.outcome.FixBreak      =   3011;
    p.defaultParameters.outcome.Jackpot       =   3013;
    p.defaultParameters.outcome.TargetBreak   =   3014;
    p.defaultParameters.outcome.StimBreak     =   3015;
    p.defaultParameters.outcome.PostStimBreak =   3016;
end

% Saccade outcomes
p.defaultParameters.outcome.goodSaccade       = 4001;
p.defaultParameters.outcome.noSaccade         = 4002;  % Saccade was supposed to happen but none did
p.defaultParameters.outcome.earlySaccade      = 4003;
p.defaultParameters.outcome.lateSaccade       = 4004;  % Saccade still occured, but after it was supposed to.
p.defaultParameters.outcome.wrongSaccade      = 4005;  % saccade to wrong target or in wrong direction
p.defaultParameters.outcome.glance            = 4006;  % saccade made to target, but not held for long enough

%% get a string representation of the outcome
p.defaultParameters.outcome.codenames = fieldnames(p.defaultParameters.outcome);
noc = length(p.defaultParameters.outcome.codenames);
p.defaultParameters.outcome.codes = nan(1,noc);

for(i=1:noc)
    p.defaultParameters.outcome.codes(i) = p.defaultParameters.outcome.(p.defaultParameters.outcome.codenames{i});
end

% pre-define field for the current outcome
p.defaultParameters.outcome.CurrOutcome = NaN;  % just initialize, no start no outcome

% Create a map to store previous outcomes in to get summary information
p.defaultParameters.outcome.allOutcomes = containers.Map;
