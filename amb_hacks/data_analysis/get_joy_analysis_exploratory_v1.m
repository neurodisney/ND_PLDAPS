% exploratory data analysis for get_joy task

params.datdir='C:\Users\RA\Documents\DisneyLab\Data\170224\';
params.datfnm='bandy20170224get_joy1233';

load([params.datdir params.datfnm '.mat']);

params.ntrials=numel(PDS.data);

% plot first 25 trials of eye data in 5x5 subplot
figure('Name','Eye Data')
for spix=1:25
    PDS.data{spix}.datapixx.adc.dataSampleTimes=...
        PDS.data{spix}.datapixx.adc.dataSampleTimes-...
        PDS.data{spix}.datapixx.adc.dataSampleTimes(1);
    subplot(5,5,spix)
    plot(PDS.data{spix}.datapixx.adc.dataSampleTimes,...
        PDS.data{spix}.AI.Eye.X,'r')
    hold on
    plot(PDS.data{spix}.datapixx.adc.dataSampleTimes,...
        PDS.data{spix}.AI.Eye.Y,'b')
   
    plot(PDS.data{spix}.datapixx.adc.dataSampleTimes,...
        PDS.data{spix}.AI.Eye.PD,'m ')
    
    set(gca,'XLim',...
        PDS.data{spix}.datapixx.adc.dataSampleTimes([1 end]),'YLim',...
        [-10.5 10.5])
end

% plot first 25 trials of joy data in 5x5 subplot
figure('Name','Joy Data')
for spix=1:25
    PDS.data{spix}.datapixx.adc.dataSampleTimes=...
        PDS.data{spix}.datapixx.adc.dataSampleTimes-...
        PDS.data{spix}.datapixx.adc.dataSampleTimes(1);
    subplot(5,5,spix)
    plot(PDS.data{spix}.datapixx.adc.dataSampleTimes,...
        PDS.data{spix}.AI.Joy.X,'r')
    hold on
    plot(PDS.data{spix}.datapixx.adc.dataSampleTimes,...
        PDS.data{spix}.AI.Joy.Y,'b')
   
    plot(PDS.data{spix}.datapixx.adc.dataSampleTimes,...
        PDS.data{spix}.AI.Joy.Amp,'m ')
    
    set(gca,'XLim',...
        PDS.data{spix}.datapixx.adc.dataSampleTimes([1 end]),'YLim',...
        [-0.5 5.5])
end

% mean PD by x,y coord
% assess whether there is any eccentricity/extreme gaze bias effects
% transform [-10,10] interval to 1...N
% via
% +10, now 0,20
% *100
% ceil
% now 
PDbyXYdist=cell(2000,2000);
for trialind=1:params.ntrials
disp(['starting trial ' num2str(trialind) ' of ' num2str(params.ntrials) ...
    ' with ' num2str(numel(PDS.data{trialind}.AI.Eye.Y)) ' samples.' ])
    %     trialind
    for sampind=1:numel(PDS.data{trialind}.AI.Eye.Y)
%         sampind
        PDbyXYdist{floor((PDS.data{trialind}.AI.Eye.Y(sampind)+10)*100)+1,...
            floor((PDS.data{trialind}.AI.Eye.X(sampind)+10)*100)+1}=...
            [PDbyXYdist{floor((PDS.data{trialind}.AI.Eye.Y(sampind)+10)*100)+1,...
            floor((PDS.data{trialind}.AI.Eye.X(sampind)+10)*100)+1}, ...
            PDS.data{trialind}.AI.Eye.PD(sampind)];
    end
end
% this cell-based histogram takes >1Hr to compute on RA-PC; consider saving
% results to avoid lengthly recalculation
PDbyXYmean=NaN(2000,2000);
disp('calculating means')
for indx=1:numel(PDbyXYdist)
    PDbyXYmean(indx)=mean(PDbyXYdist{indx});
end
figure; imagesc(PDbyXYmean)

