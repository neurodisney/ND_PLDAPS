function ND_TrialHDR(p)
% encode information about a trial in a header format that is a chunk of
% fixed length for an experiment.
%
% TODO: - implement robust method to encode relevant task parameters
%       - initialize to store information in the pldaps data file or additional text
%         file about the header format to allow for easy/robust reconstruction
%
%
% wolf zinke, Feb 2017

% ------------------------------------------------------------------------%
%% encode begin of header/tail
pds.tdt.strobe(p.trial.event.TRIAL_HDR_ON);

% ------------------------------------------------------------------------%
%% default information
% this should be minimal information that is valid/applicable for all tasks.

pds.tdt.strobe(p.trial.pldaps.iTrial);  % trial number

% get time stamp as encoded for trial start
cpos = find(p.trial.TrialStart == ':');
if(length(cpos) < 3)
    error('Something unexpected happened with the time string for trial start!')
else
    HH = str2num(p.trial.TrialStart(        1:cpos(1)-1)); % hour
    MM = str2num(p.trial.TrialStart(cpos(1)+1:cpos(2)-1)); % minutes
    SS = str2num(p.trial.TrialStart(cpos(2)+1:cpos(3)-1)); % seconds
    MS = str2num(p.trial.TrialStart(cpos(3)+1:end));       % milliseconds

    pds.tdt.strobe(HH);   % hour
    pds.tdt.strobe(MM);   % minutes
    pds.tdt.strobe(SS);   % seconds
    pds.tdt.strobe(MS);   % milliseconds
end

pds.tdt.strobe(p.trial.Nr);                  % condition number
pds.tdt.strobe(p.trial.outcome.CurrOutcome); % outcome

% ------------------------------------------------------------------------%
%% task dependent information


% ------------------------------------------------------------------------%
%% encode end of header/tail
pds.tdt.strobe(p.trial.event.TRIAL_HDR_OFF);


