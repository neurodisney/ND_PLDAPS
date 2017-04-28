function ND_TrialHDR(p)
% encode information about a trial in a header format that is a chunk of
% fixed length for an experiment.
%
% TODO: - implement robust method to encode relevant task parameters
%       - initialize to store information in the pldaps data file or additional text
%         file about the header format to allow for easy/robust reconstruction
%
% BUG?  - TDT will not encode zero as value because it is no state change!
%         This is a potential issue when encoding time stams...
%
% wolf zinke, Feb 2017

% ------------------------------------------------------------------------%
%% encode begin of header/tail
pds.datapixx.strobe(p.trial.event.TRIAL_HDR_ON);

% ------------------------------------------------------------------------%
%% default information
% this should be minimal information that is valid/applicable for all tasks.

pds.datapixx.strobe(p.trial.pldaps.iTrial);  % trial number

% get time stamp as encoded for trial start
cpos = find(p.trial.TrialStart == ':');
if(length(cpos) < 3)
    error('Something unexpected happened with the time string for trial start!')
else
    % add one to time to avoid an encode with 0 which will not be recognized
    HH = str2num(p.trial.TrialStart(        1:cpos(1)-1)) +1; % hour
    MM = str2num(p.trial.TrialStart(cpos(1)+1:cpos(2)-1)) +1; % minutes
    SS = str2num(p.trial.TrialStart(cpos(2)+1:cpos(3)-1)) +1; % seconds
    MS = str2num(p.trial.TrialStart(cpos(3)+1:end)) +1;       % milliseconds

    pds.datapixx.strobe(HH);   % hour
    pds.datapixx.strobe(MM);   % minutes
    pds.datapixx.strobe(SS);   % seconds
    pds.datapixx.strobe(MS);   % milliseconds
end

pds.datapixx.strobe(p.trial.Nr);                  % condition number
pds.datapixx.strobe(p.trial.outcome.CurrOutcome); % outcome

% ------------------------------------------------------------------------%
%% task dependent information


% ------------------------------------------------------------------------%
%% encode end of header/tail
pds.datapixx.strobe(p.trial.event.TRIAL_HDR_OFF);


