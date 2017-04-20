function p = getData(p)
%pds.datapixx.adc.getData    getData from the Datapixx buffer
%
% p = pds.datapixx.adc.getData(p)
%
% Retrieves new samples from the datapixx buffer during the trial
% (c) lnk 2012
%     jly modified 2013
%     jk  reqrote  2014 to use new parameter structure and add flexibilty
%                       and proper tracking of sample times

%consider having a preallocated bufferData and bufferTimeTags
Datapixx('RegWrRd');
adcStatus = Datapixx('GetAdcStatus');
p.trial.datapixx.adc.status = adcStatus;
[bufferData, bufferTimetags, underflow, overflow] = Datapixx('ReadAdcBuffer', adcStatus.newBufferFrames,-1);
if underflow
    warning('pds:datapixxadcgetData','underflow: getData is called to often');
end
if overflow
    warning('pds:datapixxadcgetData','overflow: getData was not called often enough. Some data is lost.');
end

%transform data:
bufferData=diag(p.trial.datapixx.adc.channelGains)*(bufferData+diag(p.trial.datapixx.adc.channelOffsets)*ones(size(bufferData)));

starti=p.trial.datapixx.adc.dataSampleCount+1;
endi=p.trial.datapixx.adc.dataSampleCount+adcStatus.newBufferFrames;
inds=starti:endi;
p.trial.datapixx.adc.dataSampleCount=endi;

p.trial.datapixx.adc.dataSampleTimes(inds)=bufferTimetags;

nMaps=length(p.trial.datapixx.adc.channelMappingChannels);
for imap=1:nMaps
%     iChannels=p.trial.datapixx.adc.channelMappingChannels{imap};
    iSub = p.trial.datapixx.adc.channelMappingSubs{imap};
    iSub(end).subs{2}=inds;

    p=subsasgn(p,iSub,bufferData(p.trial.datapixx.adc.channelMappingChannelInds{imap},:));
end
