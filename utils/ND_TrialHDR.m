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
pds.tdt.strobe(p.trial.pldaps.iTrial);       % trial number

% TODO?
%  strobe hour
%  strobe min
%  strobe sec
%  strobe ms

pds.tdt.strobe(p.trial.Nr);                  % condition number
pds.tdt.strobe(p.trial.outcome.CurrOutcome); % outcome

% ------------------------------------------------------------------------%
%% task dependent information 


% ------------------------------------------------------------------------%
%% encode end of header/tail
pds.tdt.strobe(p.trial.event.TRIAL_HDR_OFF);  


