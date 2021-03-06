function p = justfix_plots(p, offln)
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

hit_col   = [0, 0.65, 0];
early_col = [0.65, 0, 0];
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
elseif(isempty(p.plotdata.fig ) || offln == 1)
    p.plotdata.fig = figure('Position', fig_sz, 'Units', 'normalized');
    drawnow
    return;
else
    figure(p.plotdata.fig);
end

Ntrials  = length(p.data);

%Cond     = cellfun(@(x) x.Nr, p.data);
Results  = cellfun(@(x) x.outcome.CurrOutcome, p.data);

fp = Results ~= p.data{1}.outcome.NoFix;

% try
    if(sum(fp) > 4)
        
        %% get relevant data
        
        TaskStart = cellfun(@(x) x.EV.TaskStart, p.data);
        Trial_tm = (TaskStart - TaskStart(1)) / 60; % first trial defines zero, convert to minutes
        
        ITI = [NaN, diff(Trial_tm)];
        
        FixStart  = cellfun(@(x) x.EV.FixStart, p.data);
        FixRT     = (FixStart - TaskStart) * 1000;
        
        FixBreak  = cellfun(@(x) x.EV.FixBreak, p.data);
        FixDur    = (FixBreak - FixStart);

        CurrRew   = cellfun(@(x) x.task.CurRewDelay, p.data) / 1000;
        RewCnt    = cellfun(@(x) x.reward.iReward,   p.data);        

        Tm      = Trial_tm(fp);
        RT      = FixRT(fp);
        Dur     = FixDur(fp);
        medRT   = nanmedian(RT);
        medDur  = nanmedian(Dur);
        FrstRew = CurrRew(fp);
        ITI     = ITI(fp);
        
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
        
        hold on;
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
        
        hold on;
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
        hold off
       
        % fixation duration depending on initial reward time
        subplot(3,5,3);
        plot(FrstRew(RewCnt(fp)>0),  Dur(RewCnt(fp)>0),  '.', 'color', hit_col);
        hold on;
        plot(FrstRew(RewCnt(fp)==0), Dur(RewCnt(fp)==0), '.', 'color', early_col);
        
        title('fix duration depending on first reward')
        xlabel('time of first reward [ms]');
        ylabel('fixation duration [s]')
        xlim([0,prctile(RT,90)]);
        ylim([0,prctile(Dur,98)]);
        axis tight
        hold off
        
        % fixation duration depending on initial reward time
        subplot(3,5,4);
        plot(ITI(RewCnt(fp) >0), Dur(RewCnt(fp) >0), '.', 'color', hit_col);
        hold on;
        plot(ITI(RewCnt(fp)==0), Dur(RewCnt(fp)==0), '.', 'color', early_col);
        
        title('RT depending on ITI')
        ylabel('RT [ms]');
        xlabel('ITI [s]')
        xlim([0, max(ITI)]);
        ylim([0, prctile(RT,90)]);
        axis tight
        hold off
        
        % fixation durations over session time
        subplot(3,1,2);
        
        plot(Tm(RewCnt(fp)>0),  RT(RewCnt(fp)>0),  'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', hit_col,'MarkerFaceColor',hit_col)
        hold on;
        plot(Tm(RewCnt(fp)==0), RT(RewCnt(fp)==0), 'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', early_col,'MarkerFaceColor',early_col)
        
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
        
        plot(Tm(RewCnt(fp)>0),  Dur(RewCnt(fp)>0),  'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', hit_col,'MarkerFaceColor',hit_col)
        hold on;
        plot(Tm(RewCnt(fp)==0), Dur(RewCnt(fp)==0), 'o', 'MarkerSize', 6, ...
            'MarkerEdgeColor', early_col,'MarkerFaceColor',early_col)
        
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
        hold off
        
        %% update plot
        drawnow
    end
% catch me
%     disp('Online plot failed!');
%     disp(me.message);
end
