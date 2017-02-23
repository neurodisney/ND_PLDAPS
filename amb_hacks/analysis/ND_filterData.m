function [y]=ND_filterData(data,params)
% 
% ND_filterData.m
% filters continuously sampled data with a filter of specified parameters
% e.g. for eye tracker or ephys recordings
%
% started on  02/23/2017
% last edited 02/23/2017
%
% inputs:
%
% 1. data:
% a struct containing the following fields
% data = a vector of data samples to be filtered
% !! TODO : implement N-D matrix handling for efficacy/consistency
%
% 2. params:
% a struct containing the following fields
% parms.Fs = sampling frequency of data

[b,a]=butter(params.filterOrder,params.Fmax./(params.Fs./2),'low');
y=filtfilt(b,a,data);
[b,a]=butter(params.filterOrder,params.Fmin./(params.Fs./2),'high');
y=filtfilt(b,a,y);

% can also do
% [b,a]=butter(params.filterOrder,[params.Fmin params.Fmax] ...
%   ./(params.Fs./2),'bandpass');
% and then filter once