function p = justfix_plots(p, offln)
%% online analysis for joystick training task
%
% TODO: - For offline analysis, allow specification of pds file, or open file selector if p is empty.
%       - add only new trial data but keep the previous without re-doing complete plot
%
%
% wolf zinke, March 2017

%% plot parameters
resp_bin = 100;
smPT = 50;

hit_col   = [0, 0.65, 0];
early_col = [0.65, 0, 0];
late_col  = [0, 0, 0.65];

fig_sz = [100, 100, 1200, 800];

%% optional offline analysis
if(~exist('offln', 'var'))
    offln = 0;
end

        
%% initialize plot
if(offln == 1)
    figure('Position', fig_sz, 'Units', 'normalized');
elseif(isempty(p.defaultParameters.plot.fig ) || offln == 1)
    p.defaultParameters.plot.fig = figure('Position', fig_sz, 'Units', 'normalized');
    drawnow
    return;
else
    figure(p.defaultParameters.plot.fig);
end

Ntrials  = length(p.data);

Cond     = cellfun(@(x) x.Nr, p.data);
Results  = cellfun(@(x) x.outcome.CurrOutcome, p.data);

fp = Results ~= p.trial.outcome.NoFix;

try
    if(sum(fp) > 4)
        
        
        %% get relevant data
        
        TaskStart = cellfun(@(x) x.EV.TaskStart, p.data);
        Trial_tm = (TaskStart - TaskStart(1)) / 60; % first trial defines zero, convert to minutes
        
        FixStart  = cellfun(@(x) x.EV.FixStart, p.data);
        FixRT     = (FixStart - TaskStart) * 1000;
        
        FixBreak  = cellfun(@(x) x.EV.FixBreak, p.data);
        FixDur    = (FixBreak - FixStart);
        
        
        %% get plots
        
        Tm  = Trial_tm(fp);
        RT  = FixRT(fp);
        Dur = FixDur(fp);
        
        % fixation durations over session time
        subplot(3,3,1);
        
        bv = min(RT)-resp_bin : resp_bin : max(RT)+resp_bin;
        
        hist(RT, bv, 'FaceColor','k', 'EdgeColor','k');
        title('Reaction times')
        ylabel('count');
        xlabel('time from target onset [ms]')
        xlim([0,prctile(RT,90)]);
        axis tight
        
        hold on;
        yl = ylim;
        medRT = nanmedian(RT);
        plot([medRT,medRT], yl,'-r','LineWidth', 2.5);
        hold off
        
        subplot(3,3,2);
        
        rb = resp_bin/1000;
        bv = min(Dur)-rb : rb : max(Dur)+rb;
        
        hist(Dur, bv, 'FaceColor','k', 'EdgeColor','k');
        title('fixation duration')
        ylabel('count');
        xlabel('time from fixation onset [s]')
        xlim([0,prctile(Dur,98)]);
        axis tight
        
        hold on;
        yl = ylim;
        medRT = nanmedian(Dur);
        plot([medRT,medRT], yl,'-r','LineWidth', 2.5);
        hold off
        
        % fixation durations over session time
        subplot(3,1,2);
        
        plot(Tm, RT, 'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', hit_col,'MarkerFaceColor',hit_col)
        hold on;
        
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
        hold off
        
        
        % fixation durations over session time
        subplot(3,1,3);
        
        plot(Tm, Dur, 'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', hit_col,'MarkerFaceColor',hit_col)
        hold on;
        
        if(Ntrials > 4)
            
            X = [ones(length(Tm),1) Tm(:)];
            cFit = X\Dur(:);
            cFitln = X*cFit;
            
            plot(Tm,cFitln,'-g', 'LineWidth', 2);
        end
        
        if(Ntrials > smPT)
            RTsm = smooth(Tm,Dur,smPT/Ntrials,'rloess');
            plot(Tm,RTsm,'-r');
        end
        
        ylim([min(FixRT), max(FixRT)]);
        ylabel('fix duration [ms]');
        xlabel('trial time [min]');
        axis tight
        hold off
        
        
        %% update plot
        drawnow
    end
catch me
    disp('Online plot failed!');
    disp(me.message);
end
