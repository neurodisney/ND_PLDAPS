function p = ND_CheckFixWin(p)

% goal: set p.trial.CurrFixWinState to 0 or 1

if p.trial.eyeAmp<p.trial.behavior.fixation.FixWin
    p.trial.CurrFixWinState=1;
elseif p.trial.eyeAmp>=p.trial.behavior.fixation.FixWin
    p.trial.CurrFixWinState=0;
else
    disp('Error! weird p.trial.eyeAmp')
    p.trial.CurrFixWinState=NaN;
end
