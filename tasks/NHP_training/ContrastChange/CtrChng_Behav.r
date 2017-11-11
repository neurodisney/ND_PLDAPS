#!/usr/bin/Rscript

## load required packages
require(useful,   quietly=TRUE)
require(catspec,  quietly=TRUE)
require(beanplot, quietly=TRUE)

# Function for plotting data from the delayed saccade task
DelSacc_Behav = function(datadir=NA, fname=NA) {

## specify analysis/graph parameters
avrgwin  =   180  # moving average window for performance plot in seconds
avrgstep =     1  # step between two subsequent moving average windows (should be smaller than avrgwin to ensure overlap)
RTbw     =  0.02  # kernel width for density estimate of response times

Corr_Col        = 'limegreen'
Early_Col       = 'cornflowerblue'
StimBreak_Col   = 'tomato'
FixBreak_Col    = 'darkgoldenrod1'
TargetBreak_Col = 'violet'
Miss_Col        = 'khaki1'
False_Col       = 'lightsalmon4'
EarlyFalse_Col  = 'hotpink4'

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

## prepare data

###########################################################################################
# standardize outcomes

SessTimeRng    = range(c(dt$FixSpotOn, dt$FixSpotOff), na.rm=TRUE)
SessTrialStart = SessTimeRng[1]
SessTrialEnd   = diff(SessTimeRng)
Break_trial    = which(dt$Outcome == 'Break')

if(length(Break_trial) == 0){
  Break_start = NA
  Break_end = NA
}else{
  Break_start = (dt$TaskEnd[Break_trial]     - SessTrialStart) / 60

  if(max(Break_trial) <= length(dt$FixSpotOn)){
    Break_end = (dt$FixSpotOn[Break_trial+1] - SessTrialStart) / 60
  }else{
    Break_end = (dt$FixSpotOn[Break_trial[-length(Break_trial)]+1] - SessTrialStart) / 60
  }

  # if last trial started a break, set break end to
  #if(length(Break_start) > length(Break_end)) { Break_end = c(Break_end, SessTrialEnd / 60) }
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
#dt = droplevels(subset(dt, dt$Outcome != 'NoFix' & dt$Outcome != 'Break'  & dt$Outcome != 'NoStart'))
#dt = droplevels(subset(dt, dt$Outcome != 'NoFix' & dt$Outcome != 'Break'  & dt$Outcome != 'NoStart'))

#dt$Outcome[dt$Outcome == 'NoFix']        = 'NoStart'
dt$Outcome = as.factor(dt$Outcome)

###########################################################################################
# identify outcomes
pCorr       = dt$Outcome == 'Correct'
pEarly      = dt$Outcome == 'Early'
pEarlyFalse = dt$Outcome == 'EarlyFalse'
pFalse      = dt$Outcome == 'False'
pHoldErr    = dt$Outcome == 'TargetBreak'
pStimBreak  = dt$Outcome == 'StimBreak'
pFixBreak   = dt$Outcome == 'FixBreak'
pMiss       = dt$Outcome == 'Miss'
pStim       = pCorr | dt$Outcome == pHoldErr

# pAll       = pCorr | pHoldErr | pEarly | pFixBreak | pStimBreak

pAll       = dt$Outcome != 'NoStart' & dt$Outcome != 'NoFix' & dt$Outcome != 'Break'
Ntrials    = sum(pAll)

###########################################################################################
# get relevant variables
Ttime     = (dt$FixSpotOn - SessTrialStart) / 60  # in minutes, define trial start times as fixation spot onset

corp = pCorr == 1 | pHoldErr == 1 | pFalse == 1

# derive RT times
SRT     = dt$SRT_Go
SRT[corp] = dt$SRT_StimOn[corp]

StimSRT = dt$SRT_StimOn

# StimSRT[corp] = dt$FixBreak[corp]  - dt$StimOn[corp]
StimSRT[corp] = StimSRT[corp] + (dt$GoLatency[corp])

# StimSRT[corp] = (dt$FixBreak[corp] - dt$StimOn[corp])+ (dt$FixSpotOff[corp]

###########################################################################################
# create plots

# open figure of defined size
# Only display figure directly if called from the r environment (not the command line)
# If we didn't do this, when called from the command line, it would just open briefly and then close when the script ends
if(interactive()) {
  x11(width=20.5, height=10.5, pointsize=20, title='CtrChng_Behav')
} else {
  # Otherwise only save the figure as a pdf.
  pdf('DelSacc.pdf', 20.5, 10.5, pointsize=12, title='CtrChng_Behav')
}

# create plot layout
#pllyt = matrix(c(1,1,1,1,1,1,1, 2,2,2,2,2,2,2, 3,3,3,3,3,3,3, 4,5,6,10,10,11,11,  7,8,9,10,10,11,11 ), 5, 7, byrow=TRUE)
pllyt = matrix(c(1,1,1,1,1,1,1,1,
                 2,2,2,2,2,2,2,2,
                 3,3,3,3,3,3,3,3,
                 4,4,5,5,6,6,8,7,
                 4,4,5,5,6,6,9,9), 5, 8, byrow=TRUE)
layout(pllyt,  heights=c(2.5,2.5,2,2.75,2.75))
par(mar=c(5,5,2,0.5))

Trng = c(0, SessTrialEnd / 60)

###########################################################################################
# plot 1: saccade time
Ylim = range(StimSRT, na.rm = TRUE)
plot(Trng, Ylim, type='n', xaxs='i', yaxs='i', main='Response after Target Onset',
     xlab='', ylab='Time after Target Onset [s]', xaxt="n")

if(length(Break_end) > 1){ for(i in 1:length(Break_end)){  rect(Break_start[i], Ylim[1], Break_end[i], Ylim[2], angle = 0, col='gray', border=FALSE) } }

points(Ttime[pCorr],       StimSRT[pCorr],       pch=19, col=Corr_Col)
points(Ttime[pFixBreak],   StimSRT[pFixBreak],   pch=19, col=FixBreak_Col)
points(Ttime[pStimBreak],  StimSRT[pStimBreak],  pch=19, col=StimBreak_Col)
points(Ttime[pHoldErr],    StimSRT[pHoldErr],    pch=19, col=TargetBreak_Col)
points(Ttime[pEarly],      StimSRT[pEarly],      pch=19, col=Early_Col)
points(Ttime[pMiss],       StimSRT[pMiss],       pch=19, col=Miss_Col)
points(Ttime[pFalse],      StimSRT[pFalse],      pch=19, col=False_Col)
points(Ttime[pEarlyFalse], StimSRT[pEarlyFalse], pch=19, col=EarlyFalse_Col)

abline(h=0,lty=2)

legend("bottom", legend=c("Correct","Early", "FixBreak", "StimBreak", "TargetBreak", "Miss", "False", "EarlyFalse"),
       pch=c(15), col=c(Corr_Col, Early_Col, FixBreak_Col, StimBreak_Col, TargetBreak_Col, Miss_Col, False_Col, EarlyFalse_Col),
       inset=c(0,-0.4), title=NULL, xpd=NA, cex=2, bty='n', horiz=TRUE, pt.cex=4)

###########################################################################################
# plot 2: reaction times
Ylim = range(SRT, na.rm = TRUE)
plot(Trng, Ylim, type='n', xaxs='i', yaxs='i', main='Response after Go Cue',
     xlab='', ylab='SRTs [s]', xaxt="n")

if(length(Break_end) > 1){ for(i in 1:length(Break_end)){  rect(Break_start[i], Ylim[1], Break_end[i], Ylim[2], angle = 0, col='gray', border=FALSE) } }

points(Ttime[pCorr],       SRT[pCorr],       pch=19, col=Corr_Col)
points(Ttime[pFixBreak],   SRT[pFixBreak],   pch=19, col=FixBreak_Col)
points(Ttime[pStimBreak],  SRT[pStimBreak],  pch=19, col=StimBreak_Col)
points(Ttime[pHoldErr],    SRT[pHoldErr],    pch=19, col=TargetBreak_Col)
points(Ttime[pEarly],      SRT[pEarly],      pch=19, col=Early_Col)
points(Ttime[pMiss],       SRT[pMiss],       pch=19, col=Miss_Col)
points(Ttime[pFalse],      SRT[pFalse],      pch=19, col=False_Col)
points(Ttime[pEarlyFalse], SRT[pEarlyFalse], pch=19, col=EarlyFalse_Col)

abline(h=0,lty=2)

###########################################################################################
# plot 3: time resolved performance
Tavrg = seq(from=Trng[1], to=Trng[2], by=avrgstep/60)

Rcorr       = rep(0, length(Tavrg))
Rfixbreak   = rep(0, length(Tavrg))
Rstimbreak  = rep(0, length(Tavrg))
Rearly      = rep(0, length(Tavrg))
Rmiss       = rep(0, length(Tavrg))
Rfalse      = rep(0, length(Tavrg))
Rholderr    = rep(0, length(Tavrg))
Rearlyfalse = rep(0, length(Tavrg))

cnt = 0
for(i in 1:length(Tavrg)) {
  cnt = cnt + 1
  cpos = Ttime > Tavrg[cnt]-avrgwin/120 & Ttime < Tavrg[cnt]+avrgwin/120 & pAll == 1

  Nall = sum(cpos)

  if(Nall > 1){
    Rcorr[cnt]       = 100 * sum(cpos & pCorr)       /Nall
    Rfixbreak[cnt]   = 100 * sum(cpos & pFixBreak)   /Nall
    Rstimbreak[cnt]  = 100 * sum(cpos & pStimBreak)  /Nall
    Rearly[cnt]      = 100 * sum(cpos & pEarly)      /Nall
    Rmiss[cnt]       = 100 * sum(cpos & pMiss)       /Nall
    Rfalse[cnt]      = 100 * sum(cpos & pFalse)      /Nall
    Rearlyfalse[cnt] = 100 * sum(cpos & pEarlyFalse) /Nall
  }
}

plot(Trng, c(0, 100), type='n', xaxs='i', yaxs='i', main = 'Performance',
     xlab='Trial Time [s]', ylab='performance [s]')

if(length(Break_end) > 1){  for(i in 1:length(Break_end)){  rect(Break_start[i], 0, Break_end[i], 100, angle = 0, col='gray', border=FALSE) } }

abline(h=50, lty=2)
abline(h=c(25,75), lty=3)
abline(h=0, lty=1)

lines(Tavrg, Rcorr,       col=Corr_Col,        lwd=2.5)
lines(Tavrg, Rfixbreak,   col=FixBreak_Col,    lwd=1)
lines(Tavrg, Rstimbreak,  col=StimBreak_Col,   lwd=1)
lines(Tavrg, Rearly,      col=Early_Col,       lwd=1)
lines(Tavrg, Rmiss,       col=Miss_Col,        lwd=1)
lines(Tavrg, Rfalse,      col=False_Col,       lwd=1)
lines(Tavrg, Rholderr,    col=TargetBreak_Col, lwd=1)
lines(Tavrg, Rearlyfalse, col=EarlyFalse_Col,  lwd=1)

###########################################################################################
# plot 4: RT over Go
GoSig = dt$GoLatency

plot(GoSig, StimSRT, type='n', xaxs='i', yaxs='i', main = 'RT over GoCue',
     ylab='Time after Target Onset[s]', xlab='Contrast change [s]')

points(GoSig[pCorr],       StimSRT[pCorr],       pch=19, col=Corr_Col)
points(GoSig[pFixBreak],   StimSRT[pFixBreak],   pch=19, col=FixBreak_Col)
points(GoSig[pStimBreak],  StimSRT[pStimBreak],  pch=19, col=StimBreak_Col)
points(GoSig[pHoldErr],    StimSRT[pHoldErr],    pch=19, col=TargetBreak_Col)
points(GoSig[pEarly],      StimSRT[pEarly],      pch=19, col=Early_Col)
points(GoSig[pMiss],       StimSRT[pMiss],       pch=19, col=Miss_Col)
points(GoSig[pFalse],      StimSRT[pFalse],      pch=19, col=False_Col)
points(GoSig[pEarlyFalse], StimSRT[pEarlyFalse], pch=19, col=EarlyFalse_Col)

lines(GoSig, GoSig, lty=3, col='black')
abline(h=0, lty=2)

###########################################################################################
# plot 5: response after target onset
all_vals_X = c()
all_vals_Y = c()

if(sum(pCorr) > 1) {
  TDurhit   = density(StimSRT[pCorr], bw=RTbw, na.rm=TRUE)
  TDurhit$y = TDurhit$y  * sum(pCorr)  * RTbw
  all_vals_X = c(all_vals_X, TDurhit$x)
  all_vals_Y = c(all_vals_Y, TDurhit$y)
}

if(sum(pHoldErr) > 1) {
  TDurhold   = density(StimSRT[pHoldErr], bw=RTbw, na.rm=TRUE)
  TDurhold$y = TDurhold$y  * sum(pHoldErr)  * RTbw
  all_vals_X = c(all_vals_X, TDurhold$x)
  all_vals_Y = c(all_vals_Y, TDurhold$y)
}

if(sum(pEarly) > 1) {
  TDurearly   = density(StimSRT[pEarly], bw=RTbw, na.rm=TRUE)
  TDurearly$y = TDurearly$y  * sum(pEarly)  * RTbw
  all_vals_X = c(all_vals_X, TDurearly$x)
  all_vals_Y = c(all_vals_Y, TDurearly$y)
}

if(sum(pFalse) > 1) {
  TDurfalse   = density(StimSRT[pFalse], bw=RTbw, na.rm=TRUE)
  TDurfalse$y = TDurfalse$y  * sum(pFalse)  * RTbw
  all_vals_X = c(all_vals_X, TDurfalse$x)
  all_vals_Y = c(all_vals_Y, TDurfalse$y)
}

if(sum(pEarlyFalse) > 1) {
  TDurfalseearly   = density(StimSRT[pEarlyFalse], bw=RTbw, na.rm=TRUE)
  TDurfalseearly$y = TDurfalseearly$y  * sum(pEarlyFalse)  * RTbw
  all_vals_X = c(all_vals_X, TDurfalseearly$x)
  all_vals_Y = c(all_vals_Y, TDurfalseearly$y)
}

if(sum(pFixBreak) > 1) {
  TDurfixbreak   = density(StimSRT[pFixBreak], bw=RTbw, na.rm=TRUE)
  TDurfixbreak$y = TDurfixbreak$y  * sum(pFixBreak)  * RTbw
  all_vals_X = c(all_vals_X, TDurfixbreak$x)
  all_vals_Y = c(all_vals_Y, TDurfixbreak$y)
}

if(sum(pStimBreak) > 1) {
  TDurstimbreak   = density(StimSRT[pStimBreak], bw=RTbw, na.rm=TRUE)
  TDurstimbreak$y = TDurstimbreak$y  * sum(pStimBreak)  * RTbw
  all_vals_X = c(all_vals_X, TDurstimbreak$x)
  all_vals_Y = c(all_vals_Y, TDurstimbreak$y)
}

TDurall    = density(StimSRT[pAll], bw=RTbw, na.rm=TRUE)
TDurall$y  = TDurall$y  * sum(pAll)  * RTbw
all_vals_X = c(all_vals_X, TDurall$x)
all_vals_Y = c(all_vals_Y, TDurall$y)

GoBrks  = seq(from=floor(min(dt$GoLatency*10))/10, to=ceiling(max(dt$GoLatency*10))/10, by=RTbw)
All_Cnt = hist(dt$GoLatency, breaks=GoBrks, plot=FALSE)

All_Cnt$counts = 0.2 * max(all_vals_Y) * All_Cnt$counts / max(All_Cnt$counts)

plot(All_Cnt, xaxs='i', yaxs='i', main='Response after Target Onset', xlim=range(all_vals_X), ylim=range(all_vals_Y),
     ylab='count', xlab='Trial Duration [s]', col='gray50', border=NA)

lines(TDurall, lwd=2, col='darkgrey')

if(sum(pCorr) > 1) {
  lines(TDurhit, lwd=2, col=Corr_Col)
}

if(sum(pHoldErr) > 1) {
  lines(TDurhold, lwd=2, col=TargetBreak_Col)
}

if(sum(pEarly) > 1) {
  lines(TDurearly, lwd=2, col=Early_Col)
}

if(sum(pFalse) > 1) {
  lines(TDurfalse, lwd=2, col=False_Col)
}

if(sum(pEarlyFalse) > 1) {
  lines(TDurfalseearly, lwd=2, col=EarlyFalse_Col)
}

if(sum(pFixBreak) > 1) {
  lines(TDurfixbreak, lwd=2, col=FixBreak_Col)
}

if(sum(pStimBreak) > 1) {
  lines(TDurstimbreak, lwd=2, col=StimBreak_Col)
}

abline(v=median(StimSRT[pCorr], na.rm=TRUE), col=Corr_Col, lty=2, lwd=2)
abline(v=median(StimSRT[pEarly], na.rm=TRUE), col=Early_Col, lty=2, lwd=2)

box()

###########################################################################################
# plot 6: response times
all_vals_X = c()
all_vals_Y = c()

if(sum(pCorr) > 1) {
  RThit   = density(SRT[pCorr], bw=RTbw, na.rm=TRUE)
  RThit$y = RThit$y  * sum(pCorr)  * RTbw
  all_vals_X = c(all_vals_X, RThit$x)
  all_vals_Y = c(all_vals_Y, RThit$y)
}

if(sum(pHoldErr) > 1) {
  RThold   = density(SRT[pHoldErr], bw=RTbw, na.rm=TRUE)
  RThold$y = RThold$y  * sum(pHoldErr)  * RTbw
  all_vals_X = c(all_vals_X, RThold$x)
  all_vals_Y = c(all_vals_Y, RThold$y)
}

if(sum(pEarly) > 1) {
  RTearly   = density(SRT[pEarly], bw=RTbw, na.rm=TRUE)
  RTearly$y = RTearly$y  * sum(pEarly)  * RTbw
  all_vals_X = c(all_vals_X, RTearly$x)
  all_vals_Y = c(all_vals_Y, RTearly$y)
}

if(sum(pFalse) > 1) {
  RTfalse   = density(SRT[pFalse], bw=RTbw, na.rm=TRUE)
  RTfalse$y = RTfalse$y  * sum(pFalse)  * RTbw
  all_vals_X = c(all_vals_X, RTfalse$x)
  all_vals_Y = c(all_vals_Y, RTfalse$y)
}

if(sum(pEarlyFalse) > 1) {
  RTfalseearly   = density(SRT[pEarlyFalse], bw=RTbw, na.rm=TRUE)
  RTfalseearly$y = RTfalseearly$y  * sum(pEarlyFalse)  * RTbw
  all_vals_X = c(all_vals_X, RTfalseearly$x)
  all_vals_Y = c(all_vals_Y, RTfalseearly$y)
}

if(sum(pFixBreak) > 1) {
  RTfixbreak   = density(SRT[pFixBreak], bw=RTbw, na.rm=TRUE)
  RTfixbreak$y = RTfixbreak$y  * sum(pFixBreak)  * RTbw
  all_vals_X = c(all_vals_X, RTfixbreak$x)
  all_vals_Y = c(all_vals_Y, RTfixbreak$y)
}

if(sum(pStimBreak) > 1) {
  RTstimbreak   = density(SRT[pStimBreak], bw=RTbw, na.rm=TRUE)
  RTstimbreak$y = RTstimbreak$y  * sum(pStimBreak)  * RTbw
  all_vals_X = c(all_vals_X, RTstimbreak$x)
  all_vals_Y = c(all_vals_Y, RTstimbreak$y)
}

RTall   = density(SRT[pAll], bw=RTbw, na.rm=TRUE)
RTall$y = RTall$y  * sum(pAll)  * RTbw
all_vals_X = c(all_vals_X, RTall$x)
all_vals_Y = c(all_vals_Y, RTall$y)

plot(range(all_vals_X), range(all_vals_Y), type='n', xaxs='i', yaxs='i', main='Response after Go Cue',
     ylab='count', xlab='SRTs [s]')

lines(RTall, lwd=2, col='darkgrey')

if(sum(pCorr) > 1) {
  lines(RThit, lwd=2, col=Corr_Col)
}

if(sum(pHoldErr) > 1) {
  lines(RThold, lwd=2, col=TargetBreak_Col)
}

if(sum(pEarly) > 1) {
  lines(RTearly, lwd=2, col=Early_Col)
}

if(sum(pFalse) > 1) {
  lines(RTfalse, lwd=2, col=False_Col)
}

if(sum(pEarlyFalse) > 1) {
  lines(RTfalseearly, lwd=2, col=EarlyFalse_Col)
}

if(sum(pFixBreak) > 1) {
  lines(RTfixbreak, lwd=2, col=FixBreak_Col)
}

if(sum(pStimBreak) > 1) {
  lines(RTstimbreak, lwd=2, col=StimBreak_Col)
}

abline(v=median(SRT[pCorr], na.rm=TRUE), col=Corr_Col, lty=3, lwd=2)
abline(v=median(SRT[pEarly], na.rm=TRUE), col=Early_Col, lty=3, lwd=2)

###########################################################################################
# plot 7: performance barplot
All_perf =  c(sum(pCorr), sum(pEarly), sum(pFixBreak), sum(pStimBreak), sum(pHoldErr), sum(pFalse), sum(pEarlyFalse), sum(pMiss))

All_typ = c('Correct', 'Early', 'FixBreak', 'StimBreak', 'TargetBreak', 'False', 'EarlyFalse', 'Miss')
All_col = c(Corr_Col, Early_Col, FixBreak_Col, StimBreak_Col, TargetBreak_Col, False_Col, EarlyFalse_Col, Miss_Col)

x = barplot(100*All_perf/Ntrials, beside=TRUE, col=All_col, xaxt="n", main='Session Performance', ylab='Proportion [%]', border=NA)

text(cex=0.9, x=x-.25, y=-1.5, All_typ, xpd=TRUE, srt=45, pos=1, offset=1)
text(cex=1.2, x=x, y=0, All_perf, xpd=TRUE, srt=0, pos=3, offset=0.1)

box()

###########################################################################################
# plot 8: Delay dependent performance
NumCond = 5  # -1 because it defines start and end of interval

DelBrks = seq(floor(min(GoSig*10))/10, ceiling(max(GoSig*10))/10, length=NumCond)
DelCat  = as.factor(cut(GoSig, breaks=DelBrks, labels= as.character(1:(NumCond-1))))

All_Cnt        = hist(GoSig,              breaks=DelBrks, plot=FALSE)$counts
Hit_Cnt        = hist(GoSig[pCorr],       breaks=DelBrks, plot=FALSE)$counts
HoldErr_Cnt    = hist(GoSig[pHoldErr],    breaks=DelBrks, plot=FALSE)$counts
FixBreak_Cnt   = hist(GoSig[pFixBreak],   breaks=DelBrks, plot=FALSE)$counts
StimBreak_Cnt  = hist(GoSig[pStimBreak],  breaks=DelBrks, plot=FALSE)$counts
Early_Cnt      = hist(GoSig[pEarly],      breaks=DelBrks, plot=FALSE)$counts
False_Cnt      = hist(GoSig[pFalse],      breaks=DelBrks, plot=FALSE)$counts
EarlyFalse_Cnt = hist(GoSig[pEarlyFalse], breaks=DelBrks, plot=FALSE)$counts

PerfTbl = 100 * rbind(Hit_Cnt/All_Cnt, Early_Cnt/All_Cnt, FixBreak_Cnt/All_Cnt, StimBreak_Cnt/All_Cnt, False_Cnt/All_Cnt, False_Cnt/All_Cnt, HoldErr_Cnt/All_Cnt)

x = barplot(PerfTbl, beside=TRUE, col=c(Corr_Col, Early_Col, FixBreak_Col, StimBreak_Col, False_Col, EarlyFalse_Col, TargetBreak_Col), border=NA,
            main='Delay Performance', xlab='Delay [s]', ylab='Proportion [%]', xaxt="n")

xl = colMeans(x)
stp = unique(diff(colMeans(x)))
lblpos = seq(from=1, to=NumCond*stp, by=stp)-0.5

text(cex=1,   x=lblpos, y=-1.5, DelBrks, xpd=TRUE, srt=0, pos=1, offset=0.5)
text(cex=1.2, x=xl,     y=0,    All_Cnt, xpd=TRUE, srt=0, pos=3, offset=0.1)

box()

# ###########################################################################################
# plot 9: Delay dependent SRT
RespP      = pCorr | pEarly | pHoldErr
SRTresp    = SRT[RespP]
DelCatresp = DelCat[RespP]

Result = as.character(dt$Outcome[RespP])
Result[Result != 'Early'] = 'Correct'

plrng = range(SRTresp)

beanplot(SRTresp ~ Result*DelCatresp, ll = 0.1,
         main = "Delay dependent SRT", side = "both", xlab="Delay [s]", ylab='Response Time [s]', bw=RTbw,
         col = list(Corr_Col, c(Early_Col, "black")), overallline='median', beanlinese='median', what=c(0,1,1,1))

abline(h=median(SRTresp[Result== 'Correct']), col=Corr_Col,  lty=2, lwd=2.5)
abline(h=median(SRTresp[Result== 'Early']),   col=Early_Col, lty=2, lwd=2.5)
abline(h=0, col="black", lty=2, lwd=1.5)


# ###########################################################################################
# # plot 9: Position dependent performance
#
# All_Cnt       = as.numeric(table(TPos))
# Hit_Cnt       = as.numeric(table(TPos[pCorr]))
# HoldErr_Cnt   = as.numeric(table(TPos[pHoldErr]))
# FixBreak_Cnt  = as.numeric(table(TPos[pFixBreak]))
# StimBreak_Cnt = as.numeric(table(TPos[pStimBreak]))
# Early_Cnt     = as.numeric(table(TPos[pEarly]))
#
# if(length(Hit_Cnt)       == 0 ) {Hit_Cnt       = All_Cnt * 0}
# if(length(HoldErr_Cnt)   == 0 ) {HoldErr_Cnt   = All_Cnt * 0}
# if(length(FixBreak_Cnt)  == 0 ) {FixBreak_Cnt  = All_Cnt * 0}
# if(length(StimBreak_Cnt) == 0 ) {StimBreak_Cnt = All_Cnt * 0}
# if(length(Early_Cnt)     == 0 ) {Early_Cnt     = All_Cnt * 0}
#
# PerfTbl = 100 * rbind(Hit_Cnt/All_Cnt, Early_Cnt/All_Cnt, FixBreak_Cnt/All_Cnt, StimBreak_Cnt/All_Cnt, HoldErr_Cnt/All_Cnt)
#
# x = barplot(PerfTbl, beside=TRUE, col=c(Corr_Col, Early_Col, FixBreak_Col, StimBreak_Col, TargetBreak_Col), border=NA,
#             main='Location Performance', xlab='Target Location [degree]', ylab='Proportion [%]', xaxt="n")
# xl = colMeans(x)
#
# text(cex=1, x=colMeans(x), y=0, levels(TPos), xpd=TRUE, srt=0, pos=1, offset=0.5)
# text(cex=1.5, x=xl, y=0, All_Cnt, xpd=TRUE, srt=0, pos=3, offset=0.1)
#
# box()
#
# ###########################################################################################
# # plot 11: Location dependent SRT
# PosCatresp = TPos[RespP]
#
# # plrng = c(min(SRTresp[Result== 'Early']), max(SRTresp[Result== 'Correct']))
# plrng = range(SRTresp)
#
# beanplot(SRTresp ~ Result*PosCatresp, ll = 0.1,
#          main = "Location dependent SRT", side = "both", xlab="Delay [s]", ylab='Response Time [s]', bw=RTbw,
#          col = list(Corr_Col, c(Early_Col, "black")), overallline='median', beanlinese='median', what=c(0,1,1,1))
#
# abline(h=median(SRTresp[Result== 'Correct']), col=Corr_Col,  lty=2, lwd=2.5)
# abline(h=median(SRTresp[Result== 'Early']),   col=Early_Col, lty=2, lwd=2.5)
# abline(h=0, col="black", lty=2, lwd=1.5)

###########################################################################################
# save plot as pdf
if(interactive()) {
  # Save the figure to pdf
  dev.copy(pdf, 'DelSacc.pdf', 19.5, 10.5, pointsize=10, title='DelSacc_Behav')
}

dev.off()

###########################################################################################
# Get rough overview
print(ctab(table(dt$Outcome[pAll]), addmargins=TRUE))

Twork  = dt$FixSpotOff[pAll] - dt$FixSpotOn[pAll]
Pwork  = round(100 * sum(Twork, na.rm=TRUE) / SessTrialEnd, 2)
Ptrial = round(100*sum(pAll)/length(pAll), 2)

print(paste('Animal started ', Ptrial, '% of all trials (', Ntrials,') and worked ', Pwork, '% (',round(sum(Twork, na.rm=TRUE)/60,2),' min) of the session time (',round(SessTrialEnd/60,2),' min).', sep=''))

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
  DelSacc_Behav(datadir, fname)
}


