function p = RevCorr_plots(p)
%% Online analysis for Reverse Correlation RF mapping
% Shows fixation length as well as metrics about the coarse and fine grained receptive field
% Nate Faber, Aug 2017


% Don't error out if this file fails
try
    %% Plot Parameters
    fig_sz = [300, 50, 1200, 900];
    correct_col = [0, 0.65, 0];
    break_col = [0.65, 0, 0];
    
    coarse_colmap = 'pink';
    fine_colmap = 'bone';
    
    %% Initialize Plot
    if isempty(p.trial.plot.fig)
        p.trial.plot.fig = figure('Position', fig_sz, 'Units', 'normalized');
    else
        figure(p.trial.plot.fig);
    end
    
    
    nTrials = p.trial.pldaps.iTrial;
    plotRows = 4;
    plotCols = 4;
    
    % Clear the figure window
    clf;
   
    %% Plot of fixation time
    % Takes up the top row of the plot. Shows fixation time over the duration of the entire experiment
    subplot(plotRows, plotCols, 1:plotCols)
    
    % Get and save relavent information
        % Trial times relative to start of experiment
    p.plotdata.TaskStart(nTrials) = p.trial.EV.TaskStart;
    p.plotdata.times(nTrials) = (p.trial.EV.TaskStart - p.plotdata.TaskStart(1)) / 60;
    times = p.plotdata.times;
    
    
    % Outcomes
    currOutcome = p.trial.outcome.CurrOutcome;    
    p.plotdata.outcome(nTrials, 1) = currOutcome;
    allOutcomes = p.plotdata.outcome;
    
    iCorrect = allOutcomes == p.trial.outcome.Correct;
    iBreak = allOutcomes == p.trial.outcome.FixBreak;
    
    % Fix Times
    if currOutcome == p.trial.outcome.Correct
        currFixDur = p.trial.EV.TaskEnd - p.trial.EV.FixStart;
    elseif currOutcome == p.trial.outcome.FixBreak
        currFixDur = p.trial.EV.FixBreak - p.trial.EV.FixStart;
    else
        currFixDur = NaN;
    end
    p.plotdata.fixDur(nTrials, 1) = currFixDur;
    fixDurs = p.plotdata.fixDur;
    
    % Plot it    
    plot(times(iCorrect),  fixDurs(iCorrect),  'o', 'MarkerSize', 6, ...
        'MarkerEdgeColor', correct_col, 'MarkerFaceColor', correct_col);
    hold on;
    plot(times(iBreak), fixDurs(iBreak), 'o', 'MarkerSize', 6, ...
        'MarkerEdgeColor', break_col, 'MarkerFaceColor', break_col);
    
%     if(Ntrials > 4)
%         X = [ones(length(Tm),1) Tm(:)];
%         cFit = X\RT(:);
%         cFitln = X*cFit;
%         
%         plot(Tm,cFitln,'-g', 'LineWidth', 2);
%     end
    
%     if(Ntrials > smPT)
%         RTsm = smooth(Tm,RT,smPT/Ntrials,'rloess');
%         plot(Tm,RTsm,'-r');
%     end

    ylabel('fixation duration [s]');
    xlabel('trial time [min]');
    ylim([0, max(fixDurs)]);
    if nTrials > 1
        xlim([0, max(times)]);
    end
    set(gca, 'TickDir', 'out');
    hold off

    %--------------------------------------------------%
    % If a new neuron has been flagged, don't draw any of the other figures
    if p.trial.RF.flag_new
        drawnow;
        return;
    end
    %--------------------------------------------------%
    
    %% Plot of coarse heatmap
    % Shows where stimuli appeared before spiking activity in the coarse mapping process
    subplot(plotRows, plotCols, [plotCols+[1,2], 2*plotCols+[1,2]])
    
    rfdef = p.trial.RF.coarse;
    
    xRange = rfdef.xRange;
    yRange = rfdef.yRange;
	
    % Draw the data
    imagesc(xRange, yRange, rfdef.heatmap);
    
    % Flip the y axis since imagesc does y reversed for some reason
    set(gca,'YDir','normal')
    colormap(gca,coarse_colmap)
    
    % Draw an x showing where the maxPos is
    maxPos = rfdef.maxPos;
    hold on;
    plot(maxPos(1),maxPos(2), 'x', 'MarkerSize', 50, 'MarkerEdgeColor', 'r', 'MarkerFaceColor','r')
    hold off;
    
    % Draw a rectangle showing where the fine placement will be
    hold on;
    extent = p.trial.stim.fine.extent;
    rad = p.trial.stim.fine.radius;
    rect = [maxPos - (extent + rad), 2*(extent + rad), 2*(extent + rad)];
    rectangle('Position', rect, 'LineWidth', 2, 'EdgeColor', 'r', 'LineStyle', ':');
    
    axis square;
    hold off;
    
    %--------------------------------------------------%
    %% Plot of the coarse temporal profile
    % Shows when stimuli appeared relative to spikes
    subplot(plotRows, plotCols, 3*plotCols + [1:2])
    hold off;
    t = linspace(rfdef.temporalRange(1)*1000, rfdef.temporalRange(2)*1000, p.trial.RF.temporalRes);
    plot(t, rfdef.maxTemporalProfile, 'r')
    xlabel('Stim temporal profile relative to spikes [ms]')
    ylabel('Proportion');
    
    % Display vertical lines where the fine mapping cutoffs will be
    hold on;
    h = vline(p.trial.RF.fine.temporalRange*1000,'k--');
    set(h,'LineWidth',2);
    hold off;
    
    %--------------------------------------------------%
    % Only plot fine plots if fine stage is active
    if strcmp(p.trial.stim.stage, 'fine')
        %% Plot of fine heatmap
        % Shows where stimuli appeared before spiking activity in the fine mapping process
        subplot(plotRows, plotCols, [plotCols+[3,4],plotCols*2+[3,4]])

        rfdef = p.trial.RF.fine;
        stimdef = p.trial.stim.fine;

        xRange = rfdef.xRange;
        yRange = rfdef.yRange;

        % Draw the data
        imagesc(xRange, yRange, rfdef.heatmap);

        % Flip the y axis since imagesc does y reversed for some reason
        set(gca,'YDir','normal')
        
        % Change colorscheme and make square
        colormap(gca,fine_colmap)
        axis square

        % Draw an x showing where the maxPos
        maxPos = rfdef.maxPos;
        hold on;
        plot(maxPos(1),maxPos(2), 'x', 'MarkerSize', 50, 'MarkerEdgeColor', 'r', 'MarkerFaceColor','r')
        hold off;
        
        %% Plot of the fine temporal profile
        % This will be plotted on top of the coarse profile
        subplot(plotRows, plotCols, 3*plotCols + [1:2])
        hold on;
        t = linspace(rfdef.temporalRange(1)*1000, rfdef.temporalRange(2)*1000, p.trial.RF.temporalRes);
        plot(t, rfdef.maxTemporalProfile,'b');
        hold off;
        
        
        %% Plot of the orientation tuning
        subplot(plotRows, plotCols, 3*plotCols + [3:4])
        angles = stimdef.angle;
        tuning = rfdef.orientationTuning;
        plot(angles,tuning,'k','LineWidth', 2)
        
        xlabel('Stim Orientation Tuning')
        
        % Set bottom of y axis to 0
        currYMax = max(ylim(gca));
        ylim([0 currYMax]);
        
        % Use visual x axis lables
        set(gca, 'XTick', [0 45 90 135])
        set(gca, 'XTickLabel',{'|','\','—','/'})
        
        
    end
    
    
    
catch me
    disp('Online plots failed')
    warning(me.message)
end

%% Draw plots
drawnow