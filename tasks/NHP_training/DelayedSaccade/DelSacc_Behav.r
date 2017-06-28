#!/usr/bin/Rscript

## load required packages
require(useful)
require(catspec) 

# Load in arguments from the command line
args = commandArgs()
datadir = args[1]
fname = args[-1]

# Function for plotting data from the delayed saccade task
DelSacc_Behav = function(datadir=NULL, fname=NULL) {

## specify analysis/graph parameters
avrgwin  =   90  # moving average window for performance plot in seconds
avrgstep =   10  # step between two subsequent moving average windows (should be smaller than avrgwin to ensure overlap)
RTbw     = 0.025 # kernel width for density estimate of response times

Corr_Col      = 'limegreen'
Early_Col     = 'cornflowerblue' 
StimBreak_Col = 'tomato'
FixBreak_Col  = 'darkgoldenrod1'
HoldBreak_Col = 'violet'
Miss_Col      = 'khaki1' 
False_Col     = 'lightsalmon4' 

###########################################################################################
## Read in data
if(is.null(datadir)) {
  print("No datadir specified, exiting")
  return()
}

setwd(datadir)

# If no fname is specified, use all the .dat files in the datadir
if(is.null(fname)) {
  fname = Sys.glob('*.dat')
}

dt=read.table(fname[1], header=TRUE)

if(length(fname)>1) {
  for(i in 2:length(fname)) { dt = rbind(dt, read.table(fname[i], header=TRUE))}
}
  
## prepare data

# get rid of un-started trials
# (ToDo: keep times when experimenter initiated breaks starts)
dt=droplevels(subset(dt, dt$Outcome != 'NoFix' & dt$Outcome != 'Break'  & dt$Outcome != 'NoStart'))

Ntrials = length(dt$Outcome)

###########################################################################################
# standardize outcomes
dt$Outcome = as.character(dt$Outcome)
dt$Outcome[dt$Outcome == 'goodSaccade']  = 'Correct'
dt$Outcome[dt$Outcome == 'earlySaccade'] = 'Early'
dt$Outcome[dt$Outcome == 'Abort']        = 'FixBreak_BSL'
dt$Outcome[dt$Outcome == 'FixBreak']     = 'FixBreak_Stim'
dt$Outcome[dt$Outcome == 'wrongSaccade'] = 'FixBreak_Stim'
dt$Outcome[dt$Outcome == 'glance']       = 'TargetBreak'
dt$Outcome[dt$Outcome == 'TargetBreak']  = 'FixBreak_Trgt'
dt$Outcome[dt$Outcome == 'noSaccade']    = 'Miss'

#dt$Outcome[dt$Outcome == 'NoFix']        = 'NoStart'
dt$Outcome = as.factor(dt$Outcome)

###########################################################################################
# identify outcomes
pCorr      = dt$Outcome == 'Correct'
pEarly     = dt$Outcome == 'Early'
pFalse     = dt$Outcome == 'False'
pHoldErr   = dt$Outcome == 'FixBreak_Trgt'
pStimBreak = dt$Outcome == 'FixBreak_Stim'
pFixBreak  = dt$Outcome == 'FixBreak_BSL'
pMiss      = dt$Outcome == 'Miss'
pStim      = pCorr | dt$Outcome == pHoldErr

###########################################################################################
# get relevant variables
Ttime    = (dt$FixSpotOn - dt$FixSpotOn[1]) / 60  # in minutes, define trial start times as fixation spot onset
FixStart = dt$FixStart   - dt$FixSpotOn
# TDur     = dt$TaskEnd    - dt$FixStart

TDur = dt$StimOn - dt$FixStart + dt$SRT_StimOn
TDur[pFixBreak]  = dt$FixBreak[pFixBreak] - dt$FixStart[pFixBreak]


GoCue    = dt$FixSpotOff - dt$FixStart
SaccTime = dt$StimFix    - dt$FixSpotOff
HoldTime = dt$StimBreak  - dt$StimOn

IntGo = dt$StimOn + dt$GoLatency
IntGo[pStim] = dt$FixSpotOff[pStim]

###########################################################################################
# derive RT times
# SRT = dt$FixSpotOff - IntGo
SRT = dt$SRT_Go

SRT[pFixBreak]     = dt$FixBreak[pFixBreak] - (dt$FixStart[pFixBreak] + dt$StimLatency[pFixBreak] + dt$GoLatency[pFixBreak])

StimSRT = dt$SRT_StimOn
StimSRT[pFixBreak] = dt$FixBreak[pFixBreak] - (dt$FixStart[pFixBreak] + dt$StimLatency[pFixBreak])


# SRT[pStim]  = SaccTime[pStim]
# SRT[pFalse] = dt$TaskEnd[pStim] - dt$FixSpotOff[pStim]

# create plots
Trng = range(Ttime)

# open figure of defined size
x11(width=19.5, height=10.5, pointsize=10, title='DelSacc_Behav')

# create plot layout
pllyt = matrix(c(1,1,1,1,1,1, 2,2,2,2,2,2, 3,3,3,3,3,3, 4,5,6,7,8,9), 4, 6, byrow=TRUE)
layout(pllyt,  heights=c(2,2,1.5,2.5))
par(mar=c(5,5,1,1)) 

###########################################################################################
# plot 1: saccade time
plot(Trng, range(TDur, na.rm = TRUE), type='n', xaxs='i', yaxs='i', main='Response after Target Onset',
     xlab='', ylab='Time after Target Onset [s]', xaxt="n")

points(Ttime[pCorr],      TDur[pCorr],      pch=19, col=Corr_Col)
points(Ttime[pFixBreak],  TDur[pFixBreak],  pch=19, col=FixBreak_Col)
points(Ttime[pStimBreak], TDur[pStimBreak], pch=19, col=StimBreak_Col)
points(Ttime[pHoldErr],   TDur[pHoldErr],   pch=19, col=HoldBreak_Col)
points(Ttime[pEarly],     TDur[pEarly],     pch=19, col=Early_Col)
points(Ttime[pMiss],      TDur[pMiss],      pch=19, col=Miss_Col)
points(Ttime[pFalse],     TDur[pFalse],     pch=19, col=False_Col)

legend("bottom", legend=c("Correct","Early", "FixBreak", "StimBreak", "HoldBreak", "Miss", "False"), 
       pch=c(15), col=c(Corr_Col, Early_Col, FixBreak_Col, StimBreak_Col, HoldBreak_Col, Miss_Col, False_Col), 
       inset=c(0,-0.2), title=NULL, xpd=NA, ncol=7, cex=2, bty='n', horiz=TRUE)

###########################################################################################
# plot 2: reaction times
plot(Trng, range(SRT, na.rm = TRUE), type='n', xaxs='i', yaxs='i', main='Response after Go Cue',
     xlab='Trial Time [s]', ylab='SRTs [s]')

points(Ttime[pCorr],      SRT[pCorr],      pch=19, col=Corr_Col)
points(Ttime[pFixBreak],  SRT[pFixBreak],  pch=19, col=FixBreak_Col)
points(Ttime[pStimBreak], SRT[pStimBreak], pch=19, col=StimBreak_Col)
points(Ttime[pHoldErr],   SRT[pHoldErr],   pch=19, col=HoldBreak_Col)
points(Ttime[pEarly],     SRT[pEarly],     pch=19, col=Early_Col)
points(Ttime[pMiss],      SRT[pMiss],      pch=19, col=Miss_Col)
points(Ttime[pFalse],     SRT[pFalse],     pch=19, col=False_Col)

abline(h=0,lty=2)

###########################################################################################
# plot 3: time resolved performance
Tavrg = seq(from=Trng[1], to=Trng[2], by=avrgstep/60)

Rcorr      = rep(0, length(Tavrg))
Rfixbreak  = rep(0, length(Tavrg))
Rstimbreak = rep(0, length(Tavrg))
Rearly     = rep(0, length(Tavrg))
Rmiss      = rep(0, length(Tavrg))
Rfalse     = rep(0, length(Tavrg))
Rholderr   = rep(0, length(Tavrg))

cnt = 0
for(i in 1:length(Tavrg)) { 
  cnt = cnt + 1
  cpos = Ttime > Tavrg[cnt]-avrgwin/120 &  Ttime < Tavrg[cnt]+avrgwin/120
  
  Nall = sum(cpos)
  
  if(Nall > 0){
    Rcorr[cnt]      = 100 * sum(cpos & pCorr)      /Nall
    Rfixbreak[cnt]  = 100 * sum(cpos & pFixBreak)  /Nall
    Rstimbreak[cnt] = 100 * sum(cpos & pStimBreak) /Nall
    Rearly[cnt]     = 100 * sum(cpos & pEarly)     /Nall
    Rmiss[cnt]      = 100 * sum(cpos & pMiss)      /Nall
    Rfalse[cnt]     = 100 * sum(cpos & pFalse)     /Nall
    Rholderr[cnt]   = 100 * sum(cpos & pHoldErr)   /Nall
  }
}

# Rcorr[Rcorr==0]           = NA
# Rfixbreak[Rfixbreak==0]   = NA
# Rstimbreak[Rstimbreak==0] = NA
# Rearly[Rearly==0]         = NA
# Rmiss[Rmiss==0]           = NA
# Rfalse[Rfalse==0]         = NA
# Rholderr[Rholderr==0]     = NA

plot(Trng, c(0, 100), type='n', xaxs='i', yaxs='i', main = 'Performance',
     xlab='Trial Time [s]', ylab='performance [s]')

abline(h=50, lty=2)
abline(h=c(25,75), lty=3)

lines(Tavrg, Rcorr,      col=Corr_Col,       lwd=2.5)
lines(Tavrg, Rfixbreak,  col=FixBreak_Col,   lwd=1)
lines(Tavrg, Rstimbreak, col=StimBreak_Col,  lwd=1)
lines(Tavrg, Rearly,     col=Early_Col,      lwd=1)
lines(Tavrg, Rmiss,      col=Miss_Col,       lwd=1)
lines(Tavrg, Rfalse,     col=False_Col,      lwd=1)
lines(Tavrg, Rholderr,   col=HoldBreak_Col,  lwd=1)
 
abline(h=0, lty=1)

###########################################################################################
# plot 4: RT over Go
GoSig = dt$GoLatency

plot(GoSig, StimSRT, type='n', xaxs='i', yaxs='i', main = 'RT over GoCue',
     ylab='Time after Target Onset[s]', xlab='Contrast change [s]')

points(GoSig[pCorr],      StimSRT[pCorr],      pch=19, col=Corr_Col)
points(GoSig[pFixBreak],  StimSRT[pFixBreak],  pch=19, col=FixBreak_Col)
points(GoSig[pStimBreak], StimSRT[pStimBreak], pch=19, col=StimBreak_Col)
points(GoSig[pHoldErr],   StimSRT[pHoldErr],   pch=19, col=HoldBreak_Col)
points(GoSig[pEarly],     StimSRT[pEarly],     pch=19, col=Early_Col)
points(GoSig[pMiss],      StimSRT[pMiss],      pch=19, col=Miss_Col)
points(GoSig[pFalse],     StimSRT[pFalse],     pch=19, col=False_Col)

lines(GoSig, GoSig, lty=3, col='black')
abline(h=0, lty=2)

###########################################################################################
# plot 5: Trial duration
all_vals_X = c()
all_vals_Y = c()

if(sum(pCorr) > 1) {
  TDurhit   = density(TDur[pCorr], bw=RTbw, na.rm=TRUE)
  TDurhit$y = TDurhit$y  * sum(pCorr)  * RTbw
  all_vals_X = c(all_vals_X, TDurhit$x)
  all_vals_Y = c(all_vals_Y, TDurhit$y)
}

if(sum(pHoldErr) > 1) {
  TDurhold   = density(TDur[pHoldErr], bw=RTbw, na.rm=TRUE)
  TDurhold$y = TDurhold$y  * sum(pHoldErr)  * RTbw
  all_vals_X = c(all_vals_X, TDurhold$x)
  all_vals_Y = c(all_vals_Y, TDurhold$y)
}

if(sum(pEarly) > 1) {
  TDurearly   = density(TDur[pEarly], bw=RTbw, na.rm=TRUE)
  TDurearly$y = TDurearly$y  * sum(pEarly)  * RTbw
  all_vals_X = c(all_vals_X, TDurearly$x)
  all_vals_Y = c(all_vals_Y, TDurearly$y)
}

if(sum(pFixBreak) > 1) {
  TDurfixbreak   = density(TDur[pFixBreak], bw=RTbw, na.rm=TRUE)
  TDurfixbreak$y = TDurfixbreak$y  * sum(pFixBreak)  * RTbw
  all_vals_X = c(all_vals_X, TDurfixbreak$x)
  all_vals_Y = c(all_vals_Y, TDurfixbreak$y)
}

if(sum(pStimBreak) > 1) {
  TDurstimbreak   = density(TDur[pStimBreak], bw=RTbw, na.rm=TRUE)
  TDurstimbreak$y = TDurstimbreak$y  * sum(pStimBreak)  * RTbw
  all_vals_X = c(all_vals_X, TDurstimbreak$x)
  all_vals_Y = c(all_vals_Y, TDurstimbreak$y)
}
plot(range(all_vals_X), range(all_vals_Y), type='n', xaxs='i', yaxs='i', main='Response after Target Onset',
     ylab='count', xlab='Trial Duration [s]')

if(sum(pCorr) > 1) {
  lines(TDurhit, lwd=2, col=Corr_Col)
}

if(sum(pHoldErr) > 1) {
  lines(TDurhold, lwd=2, col=HoldBreak_Col)
}

if(sum(pEarly) > 1) {
  lines(TDurearly, lwd=2, col=Early_Col)
}

if(sum(pFixBreak) > 1) {
  lines(TDurfixbreak, lwd=2, col=FixBreak_Col)
}

if(sum(pStimBreak) > 1) {
  lines(TDurstimbreak, lwd=2, col=StimBreak_Col)
}

###########################################################################################
# plot 6: response times
all_vals_X = c()
all_vals_Y = c()

# RTall  = density(SRT, bw=RTbw, na.rm=TRUE)
# RTall$y = RTall$y  * length(SRT)  * RTbw

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

plot(range(all_vals_X), range(all_vals_Y), type='n', xaxs='i', yaxs='i', main='Response after Go Cue',
     ylab='count', xlab='SRTs [s]')

#lines(RTall, lwd=2, col='grey')

if(sum(pCorr) > 1) {
  lines(RThit, lwd=2, col=Corr_Col)
}

if(sum(pHoldErr) > 1) {
  lines(RThold, lwd=2, col=HoldBreak_Col)
}

if(sum(pEarly) > 1) {
  lines(RTearly, lwd=2, col=Early_Col)
}

if(sum(pFixBreak) > 1) {
  lines(RTfixbreak, lwd=2, col=FixBreak_Col)
}

if(sum(pStimBreak) > 1) {
  lines(RTstimbreak, lwd=2, col=StimBreak_Col)
}

###########################################################################################
# plot 7: performance barplot
All_perf =  c(sum(pStim), sum(pEarly), sum(pFixBreak), sum(pStimBreak), sum(pFalse), sum(pMiss))

All_typ = c('Correct', 'Early', 'FixBreak', 'StimBreak', 'False', 'Miss')
All_col = c(Corr_Col, Early_Col, FixBreak_Col, StimBreak_Col, False_Col, Miss_Col)

x = barplot(100*All_perf/Ntrials, beside=TRUE, col=All_col, xaxt="n", main='Session Performance', ylab='Proportion [%]', border=NA)

text(cex=0.9, x=x-.25, y=-1.5, All_typ, xpd=TRUE, srt=45, pos=1, offset=1)
text(cex=1.5, x=x, y=0, All_perf, xpd=TRUE, srt=0, pos=3, offset=0.1)

###########################################################################################
# plot 8: Delay dependent performance
NumCond = 6  # -1 because it defines start and end of interval

DelBrks = seq(floor(min(GoSig*10))/10, ceiling(max(GoSig*10))/10, length=NumCond)

All_Cnt       = hist(GoSig,                   DelBrks, plot=FALSE)$counts
Hit_Cnt       = hist(GoSig[pCorr | pHoldErr], DelBrks, plot=FALSE)$counts
FixBreak_Cnt  = hist(GoSig[pFixBreak],        DelBrks, plot=FALSE)$counts
StimBreak_Cnt = hist(GoSig[pStimBreak],       DelBrks, plot=FALSE)$counts
Early_Cnt     = hist(GoSig[pEarly],           DelBrks, plot=FALSE)$counts

PerfTbl = 100 * rbind(Hit_Cnt/All_Cnt, Early_Cnt/All_Cnt, FixBreak_Cnt/All_Cnt, StimBreak_Cnt/All_Cnt)

x = barplot(PerfTbl, beside=TRUE, col=c(Corr_Col, Early_Col, FixBreak_Col, StimBreak_Col), border=NA,
            main='Delay Performance', xlab='Delay [s]', ylab='Proportion [%]', xaxt="n")
xl = colMeans(x)
stp = unique(diff(colMeans(x)))
lblpos = seq(from=1, to=NumCond*stp, by=stp)-0.5

text(cex=1, x=lblpos, y=-1.5, DelBrks, xpd=TRUE, srt=0, pos=1, offset=0.5)

text(cex=1.5, x=xl, y=0, All_Cnt, xpd=TRUE, srt=0, pos=3, offset=0.1)

###########################################################################################
# plot 9: Position dependent performance
TPos = cart2pol(dt$StimPosX, dt$StimPosY,degree=TRUE)$theta
TPos[TPos==315] = -45
TPos = as.factor(TPos)

All_Cnt       = as.numeric(table(TPos))
Hit_Cnt       = as.numeric(table(TPos[pCorr | pHoldErr]))
FixBreak_Cnt  = as.numeric(table(TPos[pFixBreak]))
StimBreak_Cnt = as.numeric(table(TPos[pStimBreak]))
Early_Cnt     = as.numeric(table(TPos[pEarly]))

if(length(Hit_Cnt)       == 0 ) {Hit_Cnt       = All_Cnt * 0}
if(length(FixBreak_Cnt)  == 0 ) {FixBreak_Cnt  = All_Cnt * 0}
if(length(StimBreak_Cnt) == 0 ) {StimBreak_Cnt = All_Cnt * 0}
if(length(Early_Cnt)     == 0 ) {Early_Cnt     = All_Cnt * 0}

PerfTbl = 100 * rbind(Hit_Cnt/All_Cnt, Early_Cnt/All_Cnt, FixBreak_Cnt/All_Cnt, StimBreak_Cnt/All_Cnt) 

x = barplot(PerfTbl, beside=TRUE, col=c(Corr_Col, Early_Col, FixBreak_Col, StimBreak_Col), border=NA,
            main='Location Performance', xlab='Target Location [degree]', ylab='Proportion [%]', xaxt="n")
xl = colMeans(x)

text(cex=1, x=colMeans(x), y=0, levels(TPos), xpd=TRUE, srt=0, pos=1, offset=0.5)
text(cex=1.5, x=xl, y=0, All_Cnt, xpd=TRUE, srt=0, pos=3, offset=0.1)

###########################################################################################
# Get rough overview
print(ctab(table(dt$Outcome),addmargins=TRUE))

}

DelSacc_Behav(datadir, fname)