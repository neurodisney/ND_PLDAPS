function p = rndrew_plots(p, offln)
%% online analysis for joystick training task
%
% TODO: - For offline analysis, allow specification of pds file, or open file selector if p is empty.
%       - add only new trial data but keep the previous without re-doing complete plot
%
%
% wolf zinke, March 2017

%% plot parameters
resp_bin = 50;

hit_col   = [0, 0.65, 0];
early_col = [0.65, 0, 0];
late_col  = [0, 0, 0.65];

fig_sz = [100, 100, 1000, 800];

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

try
    %% get relevant data
    Ntrials  = length(p.data);

    Cond     = cellfun(@(x) x.Nr, p.data);
    Results  = cellfun(@(x) x.outcome.CurrOutcome, p.data);

    Trial_tm = cellfun(@(x) x.EV.TaskStart, p.data);
    Trial_tm = (Trial_tm - Trial_tm(1)) / 60; % first trial defines zero, convert to minutes

    Resp_tm  = cellfun(@(x) x.EV.JoyRelease, p.data) * 1000; % convert to ms
    Go_tm    = cellfun(@(x) x.task.Timing.HoldTime, p.data) * 1000; % convert to ms

    RT = Resp_tm - Go_tm;

    %% get plots

    % release times
    subplot(3,2,1);

    if(any(isfinite(Resp_tm)))
        bv = 0 : resp_bin : max(Resp_tm)+resp_bin;

        hist(Resp_tm, bv);
        title('Release times')
        ylabel('count');
        xlabel('time trial start [ms]')
        axis tight;

%         h = findobj(gca,'Type','patch');
%         h.FaceColor = [0 0 0];
%         h.EdgeColor = [0 0 0];

        hold on;
        yl = ylim;
        medResp = nanmedian(Resp_tm);
        plot([medResp,medResp], yl,'-r','LineWidth', 2.5);
        hold off
    end

    % reaction times
    subplot(3,2,2);
    if(any(isfinite(RT)))
        bv = min(RT)-resp_bin : resp_bin : max(RT)+resp_bin;

        hist(RT, bv);
        title('Reaction times')
        ylabel('count');
        xlabel('time from stimulus change [ms]')

%         h = findobj(gca,'Type','patch');
%         h.FaceColor = [0 0 0];
%         h.EdgeColor = [0 0 0];

        hold on;
        yl = ylim;
        medRT = nanmedian(RT);
        plot([medRT,medRT], yl,'-r','LineWidth', 2.5);
        hold off
    end

    % release times in trial
    subplot(3,1,2);

    hp = Results == p.data{1}.outcome.Correct;
    he = Results == p.data{1}.outcome.Early;
%    hl = Results == p.data{1}.outcome.Late | Results == p.data{1}.outcome.Miss;

    plot(Trial_tm(hp), Resp_tm(hp), 'o', 'MarkerSize', 6, ...
        'MarkerEdgeColor', hit_col,'MarkerFaceColor',hit_col)
    hold on;
    plot(Trial_tm(he), Resp_tm(he), 'o', 'MarkerSize', 6, ...
        'MarkerEdgeColor', early_col,'MarkerFaceColor',early_col)
%     plot(Trial_tm(hl), Resp_tm(hl), 'o', 'MarkerSize', 6, ...
%         'MarkerEdgeColor', late_col,'MarkerFaceColor',late_col)

    ylim([min(Resp_tm), max(Resp_tm)]);
    ylabel('time trial start [ms]');
    xlabel('trial time [min]');


    % reaction times in trial
    subplot(3,1,3);

    plot(Trial_tm(hp), RT(hp), 'o', 'MarkerSize', 6, ...
        'MarkerEdgeColor', hit_col,'MarkerFaceColor',hit_col)
    hold on;
    plot(Trial_tm(he), RT(he), 'o', 'MarkerSize', 6, ...
        'MarkerEdgeColor', early_col,'MarkerFaceColor',early_col)
%     plot(Trial_tm(hl), RT(hl), 'o', 'MarkerSize', 6, ...
%         'MarkerEdgeColor', late_col,'MarkerFaceColor',late_col)

    ylim([min(RT), max(RT)]);
    ylabel('time from stimulus change [ms]');
    xlabel('trial time [min]');



    %% update plot
    drawnow

catch me
    disp('Online plot failed!');
    disp(me.message);
end
