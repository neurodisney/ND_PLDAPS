function p = InitFixTrain_plots(p, offln)
%% online analysis for joystick training task
%
% TODO: - For offline analysis, allow specification of pds file, or open file selector if p is empty.
%       - add only new trial data but keep the previous without re-doing complete plot
%
%
% wolf zinke, March 2017

%% plot parameters
resp_bin = 25;
smPT = 50;

fix_col   = [0, 0.65, 0];
jkpt_col  = [0, 0, 0.65];
break_col = [0.65, 0, 0];
%late_col  = [0, 0, 0.65];

fig_sz = [25, 25, 1800, 980];

%% optional offline analysis
if(~exist('p', 'var'))
    [pdsnm, PathName] = uigetfile({'*.pds;*.PDS'},'Load pldaps data file');
    p = fullfile(PathName, pdsnm);
end

if(ischar(p))    
    % load the data file, it should give a struct called PDS
    load(p,'-mat');
    
    if(~exist('PDS','var'))
        error([pdsnm, ' does not contain a PDS variable1']);
    else
        p = PDS;
        clear PDS;
    end
    
    offln = 1;
end

if(~exist('offln', 'var'))
    offln = 0;
end

%% initialize plot
if(offln == 1)
    figure('Position', fig_sz, 'Units', 'normalized');
elseif(isempty(p.trial.plot.fig) || offln == 1)
    p.trial.plot.fig = figure('Position', fig_sz, 'Units', 'normalized');
else
    figure(p.trial.plot.fig);
end

Ntrials = p.trial.pldaps.iTrial;

% keep track of plot relevant trial data
p.plotdata.Outcome(  Ntrials, 1) = p.trial.outcome.CurrOutcome;
p.plotdata.TaskStart(Ntrials, 1) = p.trial.EV.TaskStart;
p.plotdata.FixStart( Ntrials, 1) = p.trial.EV.FixStart;
p.plotdata.FixBreak( Ntrials, 1) = p.trial.EV.FixBreak;
p.plotdata.TaskEnd(  Ntrials, 1) = p.trial.EV.TaskEnd;
p.plotdata.CurrRew(  Ntrials, 1) = p.trial.task.CurRewDelay;
p.plotdata.RewCnt(   Ntrials, 1) = p.trial.reward.iReward;

% for easier handling assign to local variables
Results   = p.plotdata.Outcome;
TaskStart = p.plotdata.TaskStart;
FixStart  = p.plotdata.FixStart;
FixBreak  = p.plotdata.FixBreak;
TaskEnd   = p.plotdata.TaskEnd;
CurrRew   = p.plotdata.CurrRew;
RewCnt    = p.plotdata.RewCnt;

fp = Results ~= p.trial.outcome.NoFix;
FixRT  = (FixStart - TaskStart) * 1000;

% Fixation either ends with a FixBreak or Jackpot (where gaze is held
% sufficiently long)
FixEnd = FixBreak;
jackpots = Results == p.trial.outcome.Jackpot;
FixEnd(jackpots) = TaskEnd(jackpots);

FixDur = FixEnd - FixStart;

try
    if(sum(fp) > 4)
        
        %% get relevant data
        Trial_tm = (TaskStart - TaskStart(1)) / 60; % first trial defines zero, convert to minutes
        ITI = [NaN; diff(Trial_tm)];

        Tm      = Trial_tm(fp);
        RT      = FixRT(fp);
        Dur     = FixDur(fp);
        medRT   = nanmedian(RT);
        medDur  = nanmedian(Dur);
        FrstRew = CurrRew(fp);
        ITI     = ITI(fp);
        
        % Determine the indices where the various outcomes occured
        OC      = Results(fp);
        iBreak  = OC == p.trial.outcome.FixBreak;
        iFix    = OC == p.trial.outcome.FullFixation;
        iJkpt   = OC == p.trial.outcome.Jackpot;
        
        %% get plots
        % time to start fixatio
        subplot(3,5,1);
        
        bv = min(RT)-resp_bin : resp_bin : max(RT)+resp_bin;
        
        histogram(RT, bv, 'FaceColor','k', 'EdgeColor','k');
        hold on;
        title('Reaction times')
        ylabel('count');
        xlabel('time from target onset [ms]')
        xlim([0, prctile(RT,90)]);
        axis tight
        set(gca, 'TickDir', 'out');
        
        yl = ylim;
        plot([medRT,medRT], yl,'-r','LineWidth', 2.5);
        hold off
        
        % duration of fixation
        subplot(3,5,2);
        
        rb = resp_bin/1000;
        bv = min(Dur)-rb : rb : max(Dur)+rb;
        
        histogram(Dur, bv, 'FaceColor','k', 'EdgeColor','k');
        hold on;
        title('fixation duration')
        ylabel('count');
        xlabel('time from fixation onset [s]')
        xlim([0,prctile(Dur,98)]);
        axis tight
        set(gca, 'TickDir', 'out');

        yl = ylim;
        plot([medDur,medDur], yl,'-r','LineWidth', 2.5);
        hold off
        
        % duration of fixation depending on RT
        subplot(3,5,3);
        plot(RT, Dur, '.k');
        hold on;
        plot([medRT,medRT], yl,':r','LineWidth', 1);
        plot(xlim, [medDur,medDur], ':r','LineWidth', 1);
        
        title('RT dependent fix duration')
        ylabel('duration [s]');
        xlabel('RT [ms]')
        xlim([0,prctile(RT,90)]);
        ylim([0,max(Dur)]);
        axis tight
        set(gca, 'TickDir', 'out');
        hold off
       
        % fixation duration depending on initial reward time
        subplot(3,5,3);
        plot(FrstRew(iFix),  Dur(iFix),  '.', 'color', fix_col);
        hold on;
        plot(FrstRew(iBreak), Dur(iBreak), '.', 'color', break_col);
        plot(FrstRew(iJkpt), Dur(iJkpt), '.', 'color', jkpt_col);
        
        title('fix duration depending on first reward')
        xlabel('time of first reward [ms]');
        ylabel('fixation duration [s]')
        xlim([0,prctile(RT,90)]);
        ylim([0,prctile(Dur,98)]);
        axis tight
        set(gca, 'TickDir', 'out');
        hold off
        
        % fixation duration depending on initial reward time
        subplot(3,5,4);
        plot(ITI(iFix), Dur(iFix), '.', 'color', fix_col);
        hold on;
        plot(ITI(iBreak), Dur(iBreak), '.', 'color', break_col);
        plot(ITI(iJkpt), Dur(iJkpt), '.', 'color', jkpt_col);
        
        title('RT depending on ITI')
        ylabel('RT [ms]');
        xlabel('ITI [s]')
        xlim([0, max(ITI)]);
        ylim([0, prctile(RT,90)]);
        axis tight
        set(gca, 'TickDir', 'out');
        hold off
        
        % fixation durations over session time
        subplot(3,1,2);
        
        plot(Tm(iFix),  RT(iFix),  'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', fix_col,'MarkerFaceColor',fix_col)
        hold on;
        plot(Tm(iBreak), RT(iBreak), 'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', break_col,'MarkerFaceColor',break_col)
        plot(Tm(iJkpt), RT(iJkpt), 'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', break_col,'MarkerFaceColor',jkpt_col)
        
        if(Ntrials > 4)
            X = [ones(length(Tm),1) Tm(:)];
            cFit = X\RT(:);
            cFitln = X*cFit;
            
            plot(Tm,cFitln,'-g', 'LineWidth', 2);
        end
        
        if(Ntrials > smPT)
            RTsm = smooth(Tm,RT,smPT/Ntrials,'rloess');
            plot(Tm,RTsm,'-r');
        end
        
        ylim([min(FixRT), max(FixRT)]);
        ylabel('RT [ms]');
        xlabel('trial time [min]');
        axis tight
        set(gca, 'TickDir', 'out');
        hold off
        
        % fixation durations over session time
        subplot(3,1,3);
        
        plot(Tm(iFix),  Dur(iFix),  'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', fix_col,'MarkerFaceColor',fix_col)
        hold on;
        plot(Tm(iBreak), Dur(iBreak), 'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', break_col,'MarkerFaceColor',break_col)
        plot(Tm(iJkpt), Dur(iJkpt), 'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', break_col,'MarkerFaceColor',jkpt_col)
        
        if(Ntrials > 4)
            vpos = isfinite(Dur);
            vTm = Tm(vpos);
            vDur = Dur(vpos);
            X = [ones(sum(vpos),1) vTm(:)];
            cFit = X\vDur(:);
            cFitln = X*cFit;
            
            plot(vTm,cFitln,'-g', 'LineWidth', 2);
        end
        
        if(Ntrials > smPT)
            RTsm = smooth(Tm,Dur,smPT/Ntrials,'rloess');
            plot(Tm,RTsm,'-r');
        end
        
        ylim([min(FixRT), max(FixRT)]);
        ylabel('fix duration [ms]');
        xlabel('trial time [min]');
        axis tight
        set(gca, 'TickDir', 'out');
        hold off
        
        %% update plot
        drawnow
    end
catch me
     disp('Online plot failed!');
     disp(me.message);
end
