#!/usr/bin/Rscript

## load required packages
require(useful)
require(catspec) 
require(beanplot)

#datadir="/home/rig2-user/Data/ExpData/croc/2017_10_13/InitFixTrain"
#fname=NA

# Function for plotting data from the delayed saccade task
InitFixTrain_Behav = function(datadir=NA, fname=NA) {

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

dt=read.table(fname[1], header=TRUE)

if(length(fname)>1) {
  for(i in 2:length(fname)) { dt = rbind(dt, read.table(fname[i], header=TRUE))}
}

SessTimeRng    = range(dt$Tstart)
SessTrialStart = SessTimeRng[1]
SessTrialEnd   = diff(SessTimeRng)
Break_trial    = which(dt$Outcome == 'Break')

if(length(Break_trial) == 0){
  Break_start = NA
  Break_end   = NA
}else{
  Break_start = (dt$TaskEnd[Break_trial]     - SessTrialStart) / 60
  
  if(max(Break_trial) <= length(dt$FixSpotOn)){
    Break_end = (dt$FixSpotOn[Break_trial+1] - SessTrialStart) / 60
  }else{
    Break_end = (dt$FixSpotOn[Break_trial[-length(Break_trial)]+1] - SessTrialStart) / 60
  }
  
  # if last trial started a break, set break end to 
  lastTrial = tail(dt,n=1)
  if(lastTrial$Outcome == 'Break') {
    # If the last trial ended with a break, extend the plot to the current time, if it occurred less than an hour ago
    currentTime = as.numeric(Sys.time())
    if(currentTime - lastTrial$TaskEnd < 3600) {
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
pNoStart   = dt$Outcome == 'NoStart'
pNoFix     = dt$Outcome == 'NoFix'
pFixBreak  = dt$Outcome == 'FixBreak'
pJackpot   = dt$Outcome == 'Jackpot'
pBreak     = dt$Outcome == 'Break'

pAllFix = pFix | pFixBreak | pJackpot

###########################################################################################
# get relevant variables
Ttime    = (dt$Tstart   - SessTrialStart) / 60  # in minutes, define trial start times as fixation spot onset

###########################################################################################
# create plots

# open figure of defined size
# Only display figure directly if called from the r environment (not the command line)
# If we didn't do this, when called from the command line, it would just open briefly and then close when the script ends
if(interactive()) {
  x11(width=19.5, height=10.5, pointsize=10, title='InitFixTrain_Behav')
} else {
  # Otherwise only save the figure as a pdf.
  pdf('InitFixTrain.pdf', 19.5, 10.5, pointsize=10, title='InitFixTrain_Behav')
}

# create plot layout
pllyt = matrix(c(1,1,1,1,1, 2,2,2,2,2, 3,3,3,3,3, 4,5,6,7,8), 4, 5, byrow=TRUE)
layout(pllyt,  heights=c(2,2,1.5,2.5,2.5))
par(mar=c(5,5,1,1)) 

Trng = c(0, SessTrialEnd / 60)

###########################################################################################
# plot 1: time to fixation
Ylim = range(dt$FixRT, na.rm = TRUE)
plot(Trng, Ylim, type='n', xaxs='i', yaxs='i', main='Response after Target Onset',
     xlab='', ylab='Time after Target Onset [s]', xaxt="n", cex=1.25)

if(length(Break_end) > 1){ for(i in 1:length(Break_end)){  rect(Break_start[i], Ylim[1], Break_end[i], Ylim[2], angle = 0, col='gray', border=FALSE) } }

points(Ttime[pFix],      dt$FixRT[pFix],       pch=19, col=Fix_Col)
points(Ttime[pFixBreak], dt$FixRT[pFixBreak],  pch=19, col=FixBreak_Col)
points(Ttime[pJackpot],  dt$FixRT[pJackpot], pch=19, col=JP_Col)

lines(loess.smooth(Ttime[pAllFix], dt$FixRT[pAllFix], span=NTbw/sum(pAllFix), degree=2, family="gaussian"), col='darkgreen', lw=2)

abline(h=median(dt$FixRT[pAllFix], na.rm=TRUE),lty=2)
abline(h=mean(  dt$FixRT[pAllFix], na.rm=TRUE),lty=3)

legend("bottom", legend=c("JackPost","Fixation", "FixBreak"), 
       pch=c(15), col=c(JP_Col, Fix_Col, FixBreak_Col, StimBreak_Col), 
       inset=c(0,-0.2), title=NULL, xpd=NA, cex=2, bty='n', horiz=TRUE, pt.cex=4)

###########################################################################################
# plot 2: Fxation Duration
Ylim = range(dt$FixPeriod[pAllFix], na.rm = TRUE)
plot(Trng, Ylim, type='n', xaxs='i', yaxs='i', main='Duration of Fixation',
     xlab='Trial Time [s]', ylab='Fix Duration [s]', cex=1.25)

if(length(Break_end) > 1){ for(i in 1:length(Break_end)){  rect(Break_start[i], Ylim[1], Break_end[i], Ylim[2], angle = 0, col='gray', border=FALSE) } }

points(Ttime[pFix],      dt$FixPeriod[pFix],       pch=19, col=Fix_Col)
points(Ttime[pFixBreak], dt$FixPeriod[pFixBreak],  pch=19, col=FixBreak_Col)
points(Ttime[pJackpot],  dt$FixPeriod[pJackpot], pch=19, col=JP_Col)

lines(loess.smooth(Ttime[pAllFix], dt$FixPeriod[pAllFix], span=NTbw/sum(pAllFix), degree=2, family="gaussian"), col='darkgreen', lw=2)

abline(h=median(dt$FixPeriod[pAllFix], na.rm=TRUE),lty=2)
abline(h=mean(  dt$FixPeriod[pAllFix], na.rm=TRUE),lty=3)

###########################################################################################
# plot 3: time resolved performance
Tavrg = seq(from=Trng[1], to=Trng[2], by=avrgstep/60)

RFix      = rep(0, length(Tavrg))
Rfixbreak = rep(0, length(Tavrg))
Rjackpot  = rep(0, length(Tavrg))

cnt = 0
for(i in 1:length(Tavrg)) { 
  cnt = cnt + 1
  cpos = Ttime > Tavrg[cnt]-avrgwin/120 &  Ttime < Tavrg[cnt]+avrgwin/120
  
  Nall = sum(cpos)
  
  if(Nall > 3){
    RFix[cnt]      = 100 * sum(cpos & pFix)      / Nall
    Rfixbreak[cnt] = 100 * sum(cpos & pFixBreak) / Nall
    Rjackpot[cnt]  = 100 * sum(cpos & pJackpot)  / Nall
  }
}

plot(Trng, c(0, 100), type='n', xaxs='i', yaxs='i', main = 'Performance',
     ylim=c(0, max(c(RFix, Rfixbreak, Rjackpot))), xlab='Trial Time [s]', ylab='performance [s]', cex=1.25)

if(length(Break_end) > 1){  for(i in 1:length(Break_end)){  rect(Break_start[i], 0, Break_end[i], 100, angle = 0, col='gray', border=FALSE) } }

abline(h=50, lty=2)
abline(h=c(25,75), lty=3)
abline(h=0, lty=1)

lines(Tavrg, RFix,      col=Fix_Col,       lwd=2.5)
lines(Tavrg, Rfixbreak,  col=FixBreak_Col,   lwd=1)
lines(Tavrg, Rjackpot, col=JP_Col,  lwd=1)

###########################################################################################
# plot 4: Fixation RT
p = dt$FixRT > 0.05 & is.finite(dt$FixRT) # ignore times to short to be fixation

brP = seq(from=0, to=max(dt$FixRT[p],na.rm=TRUE)+RTbw, by=RTbw)

hist(dt$FixRT[p], breaks=brP, col='black', xlab='RT [s]', 
     ylab='count', main='response time', cex=1.25)

RTdense = density(dt$FixRT[p],na.rm=TRUE, bw=RTbw, kernel='g')
RTdense$y = RTdense$y * RTdense$bw * sum(p)
lines(RTdense,col='red', lw=2)

###########################################################################################
# plot 5: Fixation durations
p = is.finite(dt$FixPeriod)

brP = seq(from=0, to=max(dt$FixPeriod[p],na.rm=TRUE)+RTbw, by=RTbw)

hist(dt$FixPeriod[p], breaks=brP, col='black', xlab='Fixation Duration [s]', 
     ylab='count', main='Fixation Duration', cex=1.25)

Fdurdense = density(dt$FixPeriod[p],na.rm=TRUE,bw=RTbw, kernel='g')
Fdurdense$y = Fdurdense$y * Fdurdense$bw * sum(p)
lines(Fdurdense,col='red', lwd=2)

###########################################################################################
# plot 6: cumulative histogram of fixation durations
plot(sort(dt$FixPeriod[p]), sum(p):1, type="l" , lwd=2.5, col='blue', xaxs='i', yaxs='i', 
     main='Duration of Fixation', xlab='Fixation Duration [s]', ylab='count [s]', cex=1.25)

abline(h=seq(from=10, by=10, to=sum(p)), lty=3, col='lightgrey')
abline(v=seq(from=0.1, by=0.1, to=max(dt$FixPeriod[p],na.rm=TRUE)), lty=3, col='lightgrey')

abline(h=sum(dt$FixPeriod[p]>1), lty=2, col='red')
abline(v=1, lty=2, col='red')

###########################################################################################
# save plot as pdf
if(interactive()) {
  # Save the figure to pdf
  dev.copy(pdf, 'InitFixTrain.pdf', 19.5, 10.5, pointsize=10, title='InitFixTrain_Behav')
}

dev.off()

###########################################################################################
# Get rough overview
print(ctab(table(dt$Outcome),addmargins=TRUE))
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
  InitFixTrain_Behav(datadir, fname)
}


