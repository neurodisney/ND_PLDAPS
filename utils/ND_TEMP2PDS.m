function ND_TEMP2PDS(TEMP, pdsflnm)
% read in the single trial pds files stored in a TEMP directory and create
% a PDS file. Data with different experiment start time will be combined to 
% a single PDS file and trial numbers will be adjusted (check times in
% respect to session start time).
%
% This right now is a placeholder 