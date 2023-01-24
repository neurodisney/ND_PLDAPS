#!/usr/bin/Rscript

## load required packages
require(catspec, quietly=TRUE) 
require(plotrix, quietly=TRUE) 
#require(useful, quietly=TRUE)
#require(beanplot, quietly=TRUE)

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
pFix       = pFix & is.finite(dt$FixPeriod)
pNoStart   = dt$Outcome == 'NoStart' | is.finite(dt$FixPeriod)==0
pNoFix     = dt$Outcome == 'NoFix'    & is.finite(dt$FixPeriod)
pFixBreak  = dt$Outcome == 'FixBreak' & is.finite(dt$FixPeriod)
pJackpot   = dt$Outcome == 'Jackpot'  & is.finite(dt$FixPeriod)
pBreak     = dt$Outcome == 'Break'    & is.finite(dt$FixPeriod)

pAllFix = pFix | pFixBreak | pJackpot
pAllFix = pAllFix==1 & is.finite(dt$FixPeriod)==1

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
Ylim = range(dt$FixRT, na.rm=TRUE)
plot(Trng, Ylim, type='n', xaxs='i', yaxs='i', main='Response after Target Onset',
     xlab='', ylab='Time after Target Onset [s]', xaxt="n", cex=1.25)

if(length(Break_end) > 1){ for(i in 1:length(Break_end)){  rect(Break_start[i], Ylim[1], Break_end[i], Ylim[2], angle = 0, col='gray', border=FALSE) } }

points(Ttime[pFix],      dt$FixRT[pFix],       pch=19, col=Fix_Col)
points(Ttime[pFixBreak], dt$FixRT[pFixBreak],  pch=19, col=FixBreak_Col)
points(Ttime[pJackpot],  dt$FixRT[pJackpot], pch=19, col=JP_Col)

lines(loess.smooth(Ttime[pAllFix], dt$FixRT[pAllFix], span=NTbw/sum(pAllFix), degree=2, family="gaussian", na.rm=TRUE), col='darkgreen', lw=2)

abline(h=median(dt$FixRT[pAllFix], na.rm=TRUE),lty=2)
abline(h=mean(  dt$FixRT[pAllFix], na.rm=TRUE),lty=3)

legend("bottom", legend=c("JackPot","Fixation", "FixBreak"), 
       pch=c(15), col=c(JP_Col, Fix_Col, FixBreak_Col, Fix_Col), 
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
     ylim=c(0, max(c(RFix+Rfixbreak+Rjackpot))), xlab='Trial Time [s]', ylab='performance [s]', cex=1.25)

polygon(c(Tavrg, rev(Tavrg)), c(RFix, RFix*0), col = Fix_Col)
polygon(c(Tavrg, rev(Tavrg)), c(RFix+Rjackpot, rev(RFix)), col = JP_Col)
polygon(c(Tavrg, rev(Tavrg)), c(RFix+Rjackpot+Rfixbreak, rev(RFix+Rjackpot)), col = FixBreak_Col)

if(length(Break_end) > 1){  
  for(i in 1:length(Break_end)){  
    rect(Break_start[i], 0, Break_end[i], 100, angle = 0, col='gray', border=FALSE) } }

abline(h=50, lty=2)
abline(h=c(25,75), lty=3)
abline(h=0, lty=1)

#lines(Tavrg, RFix,      col=Fix_Col,       lwd=2.5)
#lines(Tavrg, Rfixbreak, col=FixBreak_Col,   lwd=1)
#lines(Tavrg, Rjackpot,  col=JP_Col,  lwd=1)

###########################################################################################
# plot 4: Fixation RT
p = dt$FixRT > 0.05 & is.finite(dt$FixRT) # ignore times to short to be fixation

brP = seq(from=0, to=max(dt$FixRT[p],na.rm=TRUE)+RTbw, by=RTbw)

hist(dt$FixRT[p], breaks=brP, col='black', xlab='RT [s]', 
     ylab='count', main='response time', cex=1.25)

RTdense = density(dt$FixRT[p],na.rm=TRUE, bw=RTbw, kernel='g')
RTdense$y = RTdense$y * RTdense$bw * sum(p)
lines(RTdense,col='red', lw=2)

abline(v=median(dt$FixRT[pAllFix], na.rm=TRUE),lty=2, col='blue', lwd=2.5)
abline(v=mean(  dt$FixRT[pAllFix], na.rm=TRUE),lty=3, col='blue', lwd=2.5)

###########################################################################################
# plot 5: Fixation durations
p = is.finite(dt$FixPeriod)

brP = seq(from=0, to=max(dt$FixPeriod[p],na.rm=TRUE)+RTbw, by=RTbw)

hist(dt$FixPeriod[p], breaks=brP, col='black', xlab='Fixation Duration [s]', 
     ylab='count', main='Fixation Duration', cex=1.25)

Fdurdense = density(dt$FixPeriod[p],na.rm=TRUE,bw=RTbw, kernel='g')
Fdurdense$y = Fdurdense$y * Fdurdense$bw * sum(p)
lines(Fdurdense,col='red', lwd=2)

abline(v=median(dt$FixPeriod[p], na.rm=TRUE),lty=2, col='blue', lwd=2.5)
abline(v=mean(  dt$FixPeriod[p], na.rm=TRUE),lty=3, col='blue', lwd=2.5)

###########################################################################################
# plot 6: cumulative histogram of fixation durations
Nfix  = sum(is.finite(dt$FixPeriod), na.rm=TRUE)
Nlong = sum(dt$FixPeriod > 1, na.rm=TRUE) 
Plong = round(100 * Nlong/Nfix,2)

plot(sort(dt$FixPeriod[p]), sum(p):1, type="l" , lwd=2.5, col='blue', xaxs='i', yaxs='i', 
     main='Duration of Fixation', xlab='Fixation Duration [s]', ylab='count [s]', cex=1.25)

abline(h=seq(from=10, by=10, to=sum(p)), lty=3, col='lightgrey')
abline(v=seq(from=0.1, by=0.1, to=max(dt$FixPeriod[p],na.rm=TRUE)), lty=3, col='lightgrey')

abline(h=Nlong, lty=2, col='red')
abline(v=1,     lty=2, col='red')

text(1, Nlong+0.025*Nfix, labels=paste(Nlong, ' (',Plong ,'%)',sep=''), pos=4, offset = 0.01, cex=1.5, col='red')

###########################################################################################
# plot 7: Fixation duration dependent on first reward
Ylim = range(dt$FixPeriod[pAllFix], na.rm = TRUE)
Xlim = range(dt$FirstReward[pAllFix])

plot(Xlim, Ylim, type='n', xaxs='i', yaxs='i', main='First Reward',
     xlab='time of first reward [s]', ylab='Fix Duration [s]', cex=1.25)

IRew   = density(dt$FirstReward[pAllFix], bw="SJ", cut=TRUE, na.rm=TRUE)
IRew$y = Ylim[2] * (IRew$y/(max(IRew$y)))

lines(IRew, lwd=2, col='darkgrey')

points(dt$FirstReward[pFix],      dt$FixPeriod[pFix],      pch=19, col=Fix_Col)
points(dt$FirstReward[pFixBreak], dt$FixPeriod[pFixBreak], pch=19, col=FixBreak_Col)
points(dt$FirstReward[pJackpot],  dt$FixPeriod[pJackpot],  pch=19, col=JP_Col)

abline(lm(dt$FixPeriod[pAllFix]~dt$FirstReward[pAllFix]), col='blue', lty=2, lwd=2.5)

###########################################################################################
# plot 8: Performace in respect to first reward
brks <- seq(min(dt$FirstReward[pAllFix], na.rm=TRUE), max(dt$FirstReward[pAllFix], na.rm=TRUE), length=11)
bins =cut(dt$FirstReward[pAllFix], breaks = brks) 
Xbin = brks[-length(brks)] + mean(diff(brks))/2

Prew  = 100*prop.table(table(bins,1-pFixBreak[pAllFix]),margin=1)[,2]
Fmed  = tapply(dt$FixPeriod[pAllFix], bins, median, na.rm=TRUE)
Favrg = tapply(dt$FixPeriod[pAllFix], bins, mean,   na.rm=TRUE)

par(mar=c(5, 5, 5, 6))

# plot fixation times
Yl1 = c(0, 1.05 * max(Favrg))
plot(Xbin, Favrg, pch=16, axes=FALSE, ylim=Yl1, xlim=range(dt$FirstReward[pAllFix], na.rm=TRUE), 
     xlab="", ylab="", xaxs='i', yaxs='i',  type="b",col="blue", main="Performance", lty=3, lwd=2)

lines( Xbin, Fmed, col="blue", lty=2, lwd=2)
points(Xbin, Fmed, col="blue",  pch=16)
IRew = density(dt$FirstReward[pAllFix], bw="SJ", cut=TRUE, na.rm=TRUE)
IRew$y = 0.25*max(Favrg) * (IRew$y/(max(IRew$y)))

lines(IRew, lwd=2, col='darkgrey')

box()
axis(2, ylim=Yl1, col="blue", las=1, col.axis="blue")  ## las=1 makes horizontal labels
mtext("Fixation Duration [s]",side=2, line=2.5, col="blue")

par(new=TRUE) # Allow a second plot on the same graph

## Plot the second plot and put axis scale on right
Yl2 = c(0, 1.05 * max(Prew))
plot(Xbin, Prew, pch=15, ylim=Yl2, xlim=range(dt$FirstReward[pAllFix], na.rm=TRUE), 
     xlab="", ylab="", xaxs='i', yaxs='i', axes=FALSE, type="b", col="red")
## a little farther out (line=4) to make room for labels
mtext("Fixation Rate [%]", side=4, col="red", line=4) 
axis(4, ylim=Yl2, col="red", col.axis="red", las=1)

# IRew  = density(dt$FirstReward[pAllFix], bw="SJ",    cut=TRUE, na.rm=TRUE)
FDens = density(dt$FirstReward[pFix],    bw=IRew$bw, cut=TRUE, na.rm=TRUE, from=IRew$x[1], to=max(IRew$x))
BDens = density(dt$FirstReward[pFixBreak],  bw=IRew$bw, cut=TRUE, na.rm=TRUE, from=IRew$x[1], to=max(IRew$x))

FDens$y = 100 * FDens$y/(FDens$y+BDens$y)
lines(FDens, col='salmon')

## Draw the time axis
axis(1, pretty(c(brks[1]-0.05*diff(range(brks)), max(brks)+0.05*diff(range(brks))), 6))
mtext("Time to first reward [s]", side=1, col="black", line=2.5)  

mtext(table(bins), side=3, at=Xbin)

## Add Legend
#legend("topleft",legend=c("Beta Gal","Cell Density"),
#       text.col=c("black","red"),pch=c(16,15),col=c("black","red"))



#twoord.plot(2:10, seq(3, 7, by=0.5) + rnorm(9),
#            1:15, rev(60:74) + rnorm(15), 
#            type= c("l", "l"), xaxt = 'n', yaxt = 'n')

###########################################################################################
# save plot as pdf
if(interactive()) {
  # Save the figure to pdf
  dev.copy(pdf, 'InitFixTrain.pdf', 19.5, 10.5, pointsize=10, title='InitFixTrain_Behav')
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
  InitFixTrain_Behav(datadir, fname)
}


