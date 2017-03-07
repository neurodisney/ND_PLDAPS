function p = ND_Outcomes(p)
% Defines numeric values for possible trial outcomes.
%
%
% wolf zinke, Feb. 2017


disp('****************************************************************')
disp('>>>>  ND:  Defining Task Outcomes <<<<')
disp('****************************************************************')
disp('');


% ------------------------------------------------------------------------%
%% Define task outcomes
p.defaultParameters.outcome.CurrOutcome   = NaN;  % just initialize, no start no outcome

p.defaultParameters.outcome.Correct       =   1004;  % correct performance, no error occurred
p.defaultParameters.outcome.NoPress       =   1;  % No joystick press occurred to initialize trial
p.defaultParameters.outcome.Abort         =   2;  % early joystick release prior stimulus onset
p.defaultParameters.outcome.Early         =   3005;  % release prior to response window
p.defaultParameters.outcome.False         =   3006;  % wrong response within response window
p.defaultParameters.outcome.Late          =   5;  % response occurred after response window
p.defaultParameters.outcome.Miss          =   3007;  % no response at a reasonable time
p.defaultParameters.outcome.NoStart       =   3004;  % trial not started
p.defaultParameters.outcome.PrematStart   =   3008;  % trial start not too early as response to cue

p.defaultParameters.outcome.FIX_BRK_BSL   =   3000; % use for fixation break from fixspot, where relevant
p.defaultParameters.outcome.FIX_BRK_CUE   =   3001; 
p.defaultParameters.outcome.FIX_BRK_STIM  =   3002;
p.defaultParameters.outcome.FIX_BRK_SPEED =   3003;

p.defaultParameters.outcome.FIXATION      =   1000;
p.defaultParameters.outcome.NO_FIX        =   3010;
p.defaultParameters.outcome.NoFix         =   3011;

%% get a string representation of the outcome
p.defaultParameters.outcome.codenames = fieldnames(p.defaultParameters.outcome);
noc = length(p.defaultParameters.outcome.codenames);
p.defaultParameters.outcome.codes = nan(1,noc);

for(i=1:noc)
    p.defaultParameters.outcome.codes(i) = p.defaultParameters.outcome.(p.defaultParameters.outcome.codenames{i});
end
