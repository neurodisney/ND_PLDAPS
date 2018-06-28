#!/usr/bin/Rscript

## load required packages
require(catspec, quietly=TRUE) 
require(plotrix, quietly=TRUE) 
#require(useful, quietly=TRUE)
#require(beanplot, quietly=TRUE)

#datadir="/home/rig2-user/Data/ExpData/croc/2017_10_13/InitFixTrain"
#fname=NA

# Function for plotting data from the delayed saccade task
FixCalib_Behav = function(datadir=NA, fname=NA) {

## specify analysis/graph parameters
avrgwin  =  180  # moving average window for performance plot in seconds
avrgstep =    1  # step between two subsequent moving average windows (should be smaller than avrgwin to ensure overlap)
RTbw     = 0.02  # kernel width for density estimate of response times
NTbw     =   10  # number of trials to evaluate loess smoothing

Fix_Col      = 'limegreen'
JP_Col       = 'cornflowerblue' 
FixBreak_Col = 'darkgoldenrod1'
NoFix_Col    = 'grey'

###########################################################################################
## Read in data
if(is.na(datadir)) {
  print("No datadir specified, exiting")
  return()
}
setwd(datadir)

# If no fname is specified, use all the .dat files in the datadir
if(is.na(fname)) {
  fname = Sys.glob('*.dat')
}

dt = read.table(fname[1], header=TRUE)

if(length(fname)>1) {
  for(i in 2:length(fname)) { dt = rbind(dt, read.table(fname[i], header=TRUE))}
}

# convert clock time to seconds
dt$Tsecs = rep(NA, length(dt$Time))

for (i in 1:length(dt$Time)) {
    cprts = as.numeric(unlist(strsplit(as.character(dt$Time[i]), ':')))
    
    dt$Tsecs[i] = cprts[1] * 60*60 + cprts[2] * 60 + cprts[3] + cprts[4] / 100
}
dt$Tsecs = dt$Tsecs - dt$Tsecs[1]

# determine times
SessTimeRng    = range(dt$Tsecs , na.rm=TRUE)
SessTrialStart = SessTimeRng[1]
SessTrialEnd   = diff(SessTimeRng)
Break_trial    = which(dt$Outcome == 'Break')

Ttime = dt$Tsecs / 60  # in minutes, define trial start times as fixation spot onset

if(!any(names(dt) == "TrialStart")){
  dt$TrialStart = dt$Tsecs 
}

# Ttime = dt$TrialStart / 60  # in minutes, define trial start times as fixation spot onset

if(!any(names(dt) == "TrialEnd")){
 if(any(names(dt) == "TaskDur")){
   dt$TrialEnd = dt$Tsecs + dt$TaskDur
 }else{
   dt$TrialEnd = dt$Tsecs 
 }
}

dt$TrialEnd   = dt$TrialEnd - dt$TrialStart[1]
dt$TrialStart = dt$TrialStart - dt$TrialStart[1]

if(!any(names(dt) == "FixSpotOn")){
  dt$FixSpotOn = dt$Tstart 
}

if(length(Break_trial) == 0){
  Break_start = NA
  Break_end   = NA
}else{
  Break_start = (dt$TrialEnd[Break_trial]  - SessTrialStart) / 60
  
  if(max(Break_trial) <= length(dt$TrialStart)){
    Break_end = (dt$TrialStart[Break_trial+1]) / 60
  }else{
    Break_end = (dt$TrialStart[Break_trial[-length(Break_trial)]+1]) / 60
  }
  
  # if last trial started a break, set break end to 
  lastTrial = tail(dt,n=1)
  if(lastTrial$Outcome == 'Break') {
    # If the last trial ended with a break, extend the plot to the current time, if it occurred less than an hour ago
    currentTime = as.numeric(Sys.time())
    if(currentTime - lastTrial$TrialEnd < 3600) {
        # Extend the plot to now
        SessTrialEnd = currentTime - SessTrialStart
        
        # Add the final break
        Break_end[length(Break_end)] = SessTrialEnd / 60
    }
  }
}

# get rid of un-started trials
# (ToDo: keep times when experimenter initiated breaks starts)
# dtFix = droplevels(subset(dt, dt$Outcome != 'NoFix' & dt$Outcome != 'Break'  & dt$Outcome != 'NoStart'))

Ntrials = length(dt$Outcome)

dt$Outcome = as.factor(dt$Outcome)

###########################################################################################
# identify outcomes
pFix       = dt$Outcome == 'FullFixation' | dt$Outcome == 'Fixation' 
pFix       = pFix & is.finite(dt$FixPeriod)
pNoStart   = dt$Outcome == 'NoStart'  | is.finite(dt$FixPeriod)==0
pNoFix     = dt$Outcome == 'NoFix'    & is.finite(dt$FixPeriod)
pFixBreak  = dt$Outcome == 'FixBreak' & is.finite(dt$FixPeriod)
pJackpot   = dt$Outcome == 'Jackpot'  & is.finite(dt$FixPeriod)
pBreak     = dt$Outcome == 'Break'    & is.finite(dt$FixPeriod)

pAllFix = pFix | pFixBreak | pJackpot
pAllFix = pAllFix == 1 & is.finite(dt$FixPeriod) == 1

###########################################################################################
# create plots

# open figure of defined size
# Only display figure directly if called from the r environment (not the command line)
# If we didn't do this, when called from the command line, it would just open briefly and then close when the script ends
if(interactive()) {
  x11(width=19.5, height=10.5, pointsize=10, title='FixCalib_Behav')
} else {
  # Otherwise only save the figure as a pdf.
  pdf(paste('FixTrain_',dt$Date[1],'.pdf',sep=""), 19.5, 10.5, pointsize=10, title='FixCalib_Behav')
}

# create plot layout
pllyt = matrix(c(1,1,1,1, 2,2,2,2, 3,4,5,6), 3, 4, byrow=TRUE)
layout(pllyt,  heights=c(2,2,3))
par(mar=c(5,5,1,1)) 

Trng = c(0, SessTrialEnd / 60)

###########################################################################################
# plot 1: time to fixation
Ylim = range(dt$FixRT, na.rm=TRUE)
plot(Trng, Ylim, type='n', xaxs='i', main='Response after Target Onset',
     xlab='', ylab='Time after Target Onset [s]', xaxt="n", cex=1.25)

if(length(Break_end) > 1){ 
  for(i in 1:length(Break_end)){  
    rect(Break_start[i], Ylim[1], Break_end[i], Ylim[2], angle = 0, col='gray', border=FALSE) } }

points(Ttime[pFix],      dt$FixRT[pFix],       pch=19, col=Fix_Col)
points(Ttime[pFixBreak], dt$FixRT[pFixBreak],  pch=19, col=FixBreak_Col)
points(Ttime[pJackpot],  dt$FixRT[pJackpot],   pch=19, col=JP_Col)
 
lines(loess.smooth(Ttime[pAllFix], dt$FixRT[pAllFix], span=NTbw/sum(pAllFix), degree=2, family="gaussian", na.rm=TRUE), col='darkgreen', lw=2)

abline(h=median(dt$FixRT[pAllFix], na.rm=TRUE),lty=2)
abline(h=mean(  dt$FixRT[pAllFix], na.rm=TRUE),lty=3)

legend("bottom", legend=c("JackPot","Fixation", "FixBreak"), 
       pch=c(15), col=c(JP_Col, Fix_Col, FixBreak_Col, Fix_Col), 
       inset=c(0,-0.2), title=NULL, xpd=NA, cex=2, bty='n', horiz=TRUE, pt.cex=4)

###########################################################################################
# plot 2: Fxation Duration
Ylim = range(dt$FixPeriod[pAllFix], na.rm = TRUE)
plot(Trng, Ylim, type='n', xaxs='i', main='Duration of Fixation',
     xlab='Trial Time [s]', ylab='Fix Duration [s]', cex=1.25)

if(length(Break_end) > 1){ 
  for(i in 1:length(Break_end)){  
    rect(Break_start[i], Ylim[1], Break_end[i], Ylim[2], angle = 0, col='gray', border=FALSE) } }

points(Ttime[pFix],      dt$FixPeriod[pFix],       pch=19, col=Fix_Col)
points(Ttime[pFixBreak], dt$FixPeriod[pFixBreak],  pch=19, col=FixBreak_Col)
points(Ttime[pJackpot],  dt$FixPeriod[pJackpot],   pch=19, col=JP_Col)

lines(loess.smooth(Ttime[pAllFix], dt$FixPeriod[pAllFix], span=NTbw/sum(pAllFix), degree=2, family="gaussian"), col='darkgreen', lw=2)

abline(h=median(dt$FixPeriod[pAllFix], na.rm=TRUE),lty=2)
abline(h=mean(  dt$FixPeriod[pAllFix], na.rm=TRUE),lty=3)
abline(h=1,lty=2, col='red')

###########################################################################################
# plot 4: Fixation RT
p = is.finite(dt$FixRT) # ignore times to short to be fixation     dt$FixRT > 0.05 & 

brP = seq(from=0, to=max(dt$FixRT[p],na.rm=TRUE)+RTbw, by=RTbw)

hist(dt$FixRT[p], breaks=brP, col='black', xlab='RT [s]', 
     ylab='count', main='Response Time', cex=1.25)

RTdense = density(dt$FixRT[p],na.rm=TRUE, bw=RTbw, kernel='g')
RTdense$y = RTdense$y * RTdense$bw * sum(p)
lines(RTdense,col='red', lw=2)

abline(v=median(dt$FixRT[pAllFix], na.rm=TRUE),lty=2, col='blue', lwd=2.5)
abline(v=mean(  dt$FixRT[pAllFix], na.rm=TRUE),lty=3, col='blue', lwd=2.5)

###########################################################################################
# plot 4: Fixation RT
p = dt$FixRT > 0.05 & is.finite(dt$FixRT) # ignore times to short to be fixation

RTv  = dt$FixRT[p]
RTv  = RTv[-sum(p)]
ITIv = dt$intITI[p]
ITIv = ITIv[-1]
  
plot(ITIv, RTv, type='p', xaxs='i', main='RT dependent on ITI',
     xlab='ITI [s]', ylab='RT [s]', cex=1.25, pch=19)

abline(lm(RTv~ITIv), col='red', lty=3)

###########################################################################################
# plot 5: Fixation durations
p = is.finite(dt$FixPeriod)

brP = seq(from=0, to=max(dt$FixPeriod[p])+RTbw, length.out=50)

hist(dt$FixPeriod[p], breaks=brP, col='black', xlab='Fixation Duration [s]', 
     ylab='count', main='Fixation Duration', cex=1.25)

Fdurdense = density(dt$FixPeriod[p],na.rm=TRUE,bw=min(diff(brP)), kernel='g')
Fdurdense$y = Fdurdense$y * Fdurdense$bw * sum(p)
lines(Fdurdense,col='red', lwd=2)

abline(v=median(dt$FixPeriod[p], na.rm=TRUE),lty=2, col='blue', lwd=2.5)
abline(v=mean(  dt$FixPeriod[p], na.rm=TRUE),lty=3, col='blue', lwd=2.5)

###########################################################################################
# plot 6: cumulative histogram of fixation durations
Nfix  = sum(is.finite(dt$FixPeriod), na.rm=TRUE)
Nlong = sum(dt$FixPeriod > 1, na.rm=TRUE) 
Plong = round(100 * Nlong/Nfix,2)

FixTime = sum(dt$FixPeriod, na.rm=TRUE) / 60

plot(sort(dt$FixPeriod[p]), sum(p):1, type="l" , lwd=2.5, col='blue', xaxs='i', yaxs='i', 
     main='Duration of Fixation', xlab='Fixation Duration [s]', ylab='count [s]', cex=1.25)

abline(h=seq(from=10, by=10, to=sum(p)), lty=3, col='lightgrey')
abline(v=seq(from=0.1, by=0.1, to=max(dt$FixPeriod[p],na.rm=TRUE)), lty=3, col='lightgrey')

abline(h=Nlong, lty=2, col='red')
abline(v=1,     lty=2, col='red')

text(1, Nlong+0.025*Nfix, labels=paste(Nlong, ' (',Plong ,'%)',sep=''), pos=4, offset = 0.01, cex=1.5, col='red')
text(1, 0.025*Nfix, labels=paste(round(FixTime,4), ' min total fixation time',sep=''), pos=4, offset = 0.01, cex=1.5, col='blue')

###########################################################################################
# save plot as pdf
if(interactive()) {
  # Save the figure to pdf
  dev.copy(pdf, 'FixCalib_Behav.pdf', 19.5, 10.5, pointsize=10, title='FixCalib_Behav')
}

dev.off()

###########################################################################################
# Get rough overview
print('##############################################')
print('')
print(ctab(table(dt$Outcome),addmargins=TRUE))
print('')
print(paste('Session duration: ', round(Trng[2],2), ' minutes' ,sep=''))
print('')
print(paste(Nlong, ' fixations longer than 1 second (', Plong ,'%)',sep=''))
print('')
print(paste(round(FixTime,4),'s total fixation time (', Plong ,'%)',sep=''))
print('')
print('##############################################')
}

# If this program was called from the command line, load in the datadir and fname arguments
# and run the function once
if(!interactive()) {
  args = commandArgs(trailingOnly = TRUE)
  if (length(args) == 1) {
    datadir = args[1]
    fname = NA
  } else if(length(args) > 1) {
    datadir = args[1]
    fname = args[-1]
  } else {
    datadir = NA
    fname = NA
  }
  
  # Run the function
  FixCalib_Behav(datadir, fname)
}


