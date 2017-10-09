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
        set(0, 'CurrentFigure', p.trial.plot.fig);
    end
    
    
    nTrials = p.trial.pldaps.iTrial;
    plotRows = 4;
    plotCols = 4;
    
    % Clear the figure window
    clf;
   
    
    %% Plot the fixation duration information
    plot_fixDurs
    
    % If a new neuron has been flagged, don't draw any of the other figures
    if p.trial.RF.flag_new
        drawnow;
        return;
    end
    
    %% Plot coarse tuning information
    plot_coarseHeatmap
    plot_temporalProfile
    
    %% Plot fine tuning information
    % Only plot fine plots if fine stage is active
    if strcmp(p.trial.stim.stage, 'fine')
        plot_fineHeatmap
        plot_orientationTuning
    end
    
catch me
    disp('Online plots failed')
    warning(me.message)
end

%% Draw plots
drawnow

    function plot_fixDurs
        %% Plot of fixation time
        % Takes up the top row of the plot. Shows fixation time over the duration of the entire experiment
        subplot(plotRows, plotCols, 1:plotCols-1)
        
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
        p.plotdata.fixDur(nTrials, 1) = p.trial.task.fixDur;
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
        
        %% Plot fixation time histogram
        % Shows the histogram of fixation time
        subplot(plotRows, plotCols, plotCols)
        
        binWidth = 1;
        ibw = 1 / binWidth;
        
        % Get the edges of the histogram bins
        maxEdge = ceil(max(fixDurs)*ibw)/ibw;
        edges = 0:ibw:maxEdge;
        
        % Plot the histogram
        h = histogram(fixDurs,edges);
        
        % Set up x axis
        xlim([0,maxEdge]);
        xlabel('Fixation Duration [s]');
        
        % Add labels for each bar
        vals = h.Values;
        textVals = cellfun(@num2str, num2cell(vals), 'UniformOutput', false);
        
        binCenters = (edges(1:end-1) + edges(2:end)) / 2;
        textHeight = 1.1 * max(vals);
        heights = repmat(textHeight,length(binCenters),1);
        ylim([0, 1.2 * max(vals)])
        
        text(binCenters,heights,textVals,'horizontalalignment','center')
    end

    function plot_coarseHeatmap
        
        %% Plot of coarse heatmap
        % Shows where stimuli appeared before spiking activity in the coarse mapping process
        subplot(plotRows, plotCols, [plotCols+[1,2], 2*plotCols+[1,2]])
        
        rfdef = p.trial.RF.coarse;
        
        xRange = rfdef.xRange;
        yRange = rfdef.yRange;
        
        % Draw the data
        coarsehm = imagesc(xRange, yRange, rfdef.heatmap);
        
        % Flip the y axis since imagesc does y reversed for some reason
        set(gca,'YDir','normal')
        colormap(gca,coarse_colmap)
        
        % Draw an x showing where the center of the fine mapping will be
        maxPos = rfdef.maxPos;
        if rfdef.useCustPos
            selectPos = rfdef.custPos;
            % If using a custom postion, show a * where the max pos is
            hold on;
            maxHandle = plot(maxPos(1),maxPos(2), '*', 'MarkerSize', 8, 'MarkerEdgeColor', 'r');
            hold off;
            
            % Click on the maxPos marker to go back to using maxPos
            set(maxHandle, 'ButtonDownFcn', @useMaxPos);
        else
            selectPos = maxPos;
        end
        
        hold on;
        plot(selectPos(1),selectPos(2), 'x', 'MarkerSize', 35, 'MarkerEdgeColor', 'r', 'MarkerFaceColor','r')
        hold off;
        
        % Draw a rectangle showing where the fine placement will be
        hold on;
        extent = p.trial.stim.fine.extent;
        rad = p.trial.stim.fine.radius;
        corner = [p.trial.stim.fine.xRange(1), p.trial.stim.fine.yRange(1)] - rad;
        rect = [corner, 2*(extent + rad), 2*(extent + rad)];
        rectangle('Position', rect, 'LineWidth', 2, 'EdgeColor', 'r', 'LineStyle', ':');
        
        axis square;
        hold off;
        
        % Set up clicking on the heatmap to set where the point is
        set(coarsehm, 'ButtonDownFcn', @coarseHM_click);
        
    end

    function plot_temporalProfile
        %% Plot of the coarse temporal profile
        % Shows when stimuli appeared relative to spikes
        rfdef = p.trial.RF.coarse;
        
        % Get the temporal profile
        if rfdef.useCustPos
            temporalProfile = squeeze(rfdef.revCorrCube(rfdef.custInd(1), rfdef.custInd(2), :));
        else
            temporalProfile = squeeze(rfdef.revCorrCube(rfdef.maxInd(1), rfdef.maxInd(2), :));
        end
        
        subplot(plotRows, plotCols, 3*plotCols + [1:2])
        hold off;
        t = linspace(rfdef.temporalRange(1)*1000, rfdef.temporalRange(2)*1000, p.trial.RF.temporalRes);
        plot(t, temporalProfile, 'r')
        xlabel('Stim temporal profile relative to spikes [ms]')
        ylabel('Proportion');
        
        % Display vertical lines where the fine mapping cutoffs will be
        hold on;
        h = vline(p.trial.RF.fine.temporalRange*1000,'k--');
        set(h,'LineWidth',2);
        hold off;
        
        %% Plot of the fine temporal profile
        % This will be plotted on top of the coarse profile
        if strcmp(p.trial.stim.stage, 'fine')
            hold on;
            rfdef = p.trial.RF.fine;
            temporalProfile = squeeze(rfdef.revCorrCube(rfdef.maxInd(1), rfdef.maxInd(2), :));
            t = linspace(rfdef.temporalRange(1)*1000, rfdef.temporalRange(2)*1000, p.trial.RF.temporalRes);
            plot(t, temporalProfile,'b');
            hold off;
        end
        
    end

    function plot_fineHeatmap
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
        
    end

    function plot_orientationTuning
        %% Plot of the orientation tuning
        rfdef = p.trial.RF.fine;
        stimdef = p.trial.stim.fine;
        
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

    function coarseHM_click(imageHandle, eventData)
        % Only effect change if in coarse mode
        if strcmp(p.trial.stim.stage, 'coarse')
            rfdef = p.trial.RF.coarse;
            
            % Start using the custom position rather than the max pos
            rfdef.useCustPos = 1;

            axesHandle = get(imageHandle, 'Parent');
            clickPos = get(axesHandle, 'CurrentPoint');

            xClick = clickPos(1,1);
            yClick = clickPos(1,2);

            %% Round the click position to the nearest grid position on the heatmap
            sRes = p.trial.RF.spatialRes;
            xRange = rfdef.xRange;
            yRange = rfdef.yRange;
            xSpace = linspace(xRange(1), xRange(2), sRes);
            ySpace = linspace(yRange(1), yRange(2), sRes);

            xInd = round( (xClick - xRange(1)) / (diff(xRange) / (sRes - 1)) ) + 1;
            yInd = round( (yClick - yRange(1)) / (diff(yRange) / (sRes - 1)) ) + 1;
            
            xCoord = xSpace(xInd);
            yCoord = ySpace(yInd);

            rfdef.custPos = [xCoord, yCoord];
            rfdef.custInd = [yInd, xInd];
            
            % Define the xRange and yRange for the fine stage
            p.trial.stim.fine.xRange = xCoord + [-p.trial.stim.fine.extent, p.trial.stim.fine.extent];
            p.trial.stim.fine.yRange = yCoord + [-p.trial.stim.fine.extent, p.trial.stim.fine.extent];
            
            
            p.trial.RF.coarse = rfdef;

            plot_coarseHeatmap
            plot_temporalProfile
        end
        
    end

    function useMaxPos(imageHandle, eventData)
        % Swithc back to using the max pos instead of custom position
        % Only do this if in the coarse mapping mode
        if strcmp(p.trial.stim.stage, 'coarse')
            p.trial.RF.coarse.useCustPos = 0;
            
            % Define the xRange and yRange for the fine stage
            p.trial.stim.fine.xRange = p.trial.RF.coarse.maxPos(1) + [-p.trial.stim.fine.extent, p.trial.stim.fine.extent];
            p.trial.stim.fine.yRange = p.trial.RF.coarse.maxPos(2) + [-p.trial.stim.fine.extent, p.trial.stim.fine.extent];
            
            plot_coarseHeatmap;
            plot_temporalProfile;
        end
    end

end
