#!/usr/bin/Rscript

## load required packages
require(useful,   quietly=TRUE)
require(catspec,  quietly=TRUE)
require(beanplot, quietly=TRUE)
require(ggplot2,  quietly=TRUE)
require(quickpsy, quietly=TRUE)

# Function for plotting data from the delayed saccade task
PercEqui_Behav = function(datadir=NA, fname=NA) {

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
  for(i in 2:length(fname)) { dt = rbind(dt, read.table(fname[i], header=TRUE, fill = TRUE))}
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
  Break_end   = NA
}else{
  Break_start = (dt$TaskEnd[Break_trial] - SessTrialStart) / 60

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


dt$VertPos = rep(NA, length(dt$Hemi))
dt$VertPos[dt$PosY == 0] = 'middle'
dt$VertPos[dt$PosY  > 0] = 'upper'
dt$VertPos[dt$PosY  < 0] = 'lower'

# correct item chosen, ignore target breaks
CorrItm = dt$Good
CorrItm[dt$Outcome == 'TargetBreak'] = 1

# chosen item was target or reference
TrgtHigh = dt$TargetContr > dt$RefContr
TrgtSel = rep(NA, length(dt$Good))
TrgtSel[TrgtHigh == 1 & CorrItm == 1] = 1
TrgtSel[TrgtHigh == 0 & CorrItm == 1] = 0
TrgtSel[TrgtHigh == 1 & CorrItm == 0] = 0
TrgtSel[TrgtHigh == 0 & CorrItm == 0] = 1

dt$TrgtSel = TrgtSel

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

pAll        = dt$Outcome != 'NoStart' & dt$Outcome != 'NoFix' & dt$Outcome != 'Break'
Ntrials     = sum(pAll)

###########################################################################################
# get relevant variables
Ttime   = (dt$FixSpotOn - SessTrialStart) / 60  # in minutes, define trial start times as fixation spot onset

# derive RT times
SRT     = dt$SRT_StimOn
FixSRT  = dt$SRT_FixStart


# FixSRT = dt$EV_FixLeave - dt$EV_FixStart
# SRT    = dt$EV_FixLeave - dt$StimOn
#
# p = is.na(SRT)
# SRT[p] = dt$EV_FixLeave[p] - (dt$EV_FixStart[p] + dt$StimLatency[p])


###########################################################################################
# create plots

# open figure of defined size
# Only display figure directly if called from the r environment (not the command line)
# If we didn't do this, when called from the command line, it would just open briefly and then close when the script ends
if(interactive()) {
  x11(width=20.5, height=10.5, pointsize=20, title='PercEqui_Behav')
} else {
  # Otherwise only save the figure as a pdf.
  pdf( paste('PercEqui_',dt$Date[1],'.pdf',sep=""), 19.5, 8.5, pointsize=10, title='PercEqui_Behav')

}

# create plot layout
pllyt = matrix(c(1,1,1,1,1,
                 2,2,2,2,2,
                 3,3,3,3,3,
                 4,5,6,7,8,
                 4,5,6,7,8), 5, 5, byrow=TRUE)
layout(pllyt,  heights=c(2.5,2.5,2,2.75,2.75))
par(mar=c(5,5,2,0.5))

Trng = c(0, SessTrialEnd / 60)

###########################################################################################
# plot 1: saccade time
Ylim = range(FixSRT, na.rm = TRUE)
plot(Trng, Ylim, type='n', xaxs='i', yaxs='i', main='Response after Target Onset',
     xlab='', ylab='Time after Target Onset [s]', xaxt="n")

if(length(Break_end) > 1){ for(i in 1:length(Break_end)){  rect(Break_start[i], Ylim[1], Break_end[i], Ylim[2], angle = 0, col='gray', border=FALSE) } }

points(Ttime[pCorr],       FixSRT[pCorr],       pch=19, col=Corr_Col)
points(Ttime[pFixBreak],   FixSRT[pFixBreak],   pch=19, col=FixBreak_Col)
points(Ttime[pStimBreak],  FixSRT[pStimBreak],  pch=19, col=StimBreak_Col)
points(Ttime[pHoldErr],    FixSRT[pHoldErr],    pch=19, col=TargetBreak_Col)
points(Ttime[pEarly],      FixSRT[pEarly],      pch=19, col=Early_Col)
points(Ttime[pMiss],       FixSRT[pMiss],       pch=19, col=Miss_Col)
points(Ttime[pFalse],      FixSRT[pFalse],      pch=19, col=False_Col)
points(Ttime[pEarlyFalse], FixSRT[pEarlyFalse], pch=19, col=EarlyFalse_Col)

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
GoSig = dt$StimLatency

plot(GoSig, FixSRT, type='n', xaxs='i', yaxs='i', main = 'RT over GoCue',
     ylab='Time after Target Onset[s]', xlab='Contrast change [s]')

points(GoSig[pCorr],       FixSRT[pCorr],       pch=19, col=Corr_Col)
points(GoSig[pFixBreak],   FixSRT[pFixBreak],   pch=19, col=FixBreak_Col)
points(GoSig[pStimBreak],  FixSRT[pStimBreak],  pch=19, col=StimBreak_Col)
points(GoSig[pHoldErr],    FixSRT[pHoldErr],    pch=19, col=TargetBreak_Col)
points(GoSig[pEarly],      FixSRT[pEarly],      pch=19, col=Early_Col)
points(GoSig[pMiss],       FixSRT[pMiss],       pch=19, col=Miss_Col)
points(GoSig[pFalse],      FixSRT[pFalse],      pch=19, col=False_Col)
points(GoSig[pEarlyFalse], FixSRT[pEarlyFalse], pch=19, col=EarlyFalse_Col)

lines(GoSig, GoSig, lty=3, col='black')
abline(h=0, lty=2)

###########################################################################################
# plot 5: response after target onset
all_vals_X = c()
all_vals_Y = c()

if(sum(pCorr) > 4) {
  TDurhit   = density(FixSRT[pCorr], bw=RTbw, na.rm=TRUE)
  TDurhit$y = TDurhit$y * sum(pCorr) * RTbw
  all_vals_X = c(all_vals_X, TDurhit$x)
  all_vals_Y = c(all_vals_Y, TDurhit$y)
}

if(sum(pHoldErr) > 4) {
  TDurhold   = density(FixSRT[pHoldErr], bw=RTbw, na.rm=TRUE)
  TDurhold$y = TDurhold$y * sum(pHoldErr) * RTbw
  all_vals_X = c(all_vals_X, TDurhold$x)
  all_vals_Y = c(all_vals_Y, TDurhold$y)
}

if(sum(pEarly) > 4) {
  TDurearly   = density(FixSRT[pEarly], bw=RTbw, na.rm=TRUE)
  TDurearly$y = TDurearly$y  * sum(pEarly) * RTbw
  all_vals_X = c(all_vals_X, TDurearly$x)
  all_vals_Y = c(all_vals_Y, TDurearly$y)
}

 if(sum(pFalse) > 4) {
   TDurfalse   = density(FixSRT[pFalse], bw=RTbw, na.rm=TRUE)
  TDurfalse$y = TDurfalse$y * sum(pFalse) * RTbw
   all_vals_X = c(all_vals_X, TDurfalse$x)
   all_vals_Y = c(all_vals_Y, TDurfalse$y)
 }

if(sum(pEarlyFalse) > 4) {
  TDurfalseearly   = density(FixSRT[pEarlyFalse], bw=RTbw, na.rm=TRUE)
  TDurfalseearly$y = TDurfalseearly$y * sum(pEarlyFalse)  * RTbw
  all_vals_X = c(all_vals_X, TDurfalseearly$x)
  all_vals_Y = c(all_vals_Y, TDurfalseearly$y)
}

if(sum(pFixBreak) > 4) {
  TDurfixbreak   = density(FixSRT[pFixBreak], bw=RTbw, na.rm=TRUE)
  TDurfixbreak$y = TDurfixbreak$y * sum(pFixBreak) * RTbw
  all_vals_X = c(all_vals_X, TDurfixbreak$x)
  all_vals_Y = c(all_vals_Y, TDurfixbreak$y)
}

if(sum(pStimBreak) > 4) {
  TDurstimbreak   = density(FixSRT[pStimBreak], bw=RTbw, na.rm=TRUE)
  TDurstimbreak$y = TDurstimbreak$y  * sum(pStimBreak)  * RTbw
  all_vals_X = c(all_vals_X, TDurstimbreak$x)
  all_vals_Y = c(all_vals_Y, TDurstimbreak$y)
}

TDurall    = density(FixSRT[pAll], bw=RTbw, na.rm=TRUE)
TDurall$y  = TDurall$y  * sum(pAll)  * RTbw
all_vals_X = c(all_vals_X, TDurall$x)
all_vals_Y = c(all_vals_Y, TDurall$y)

GoBrks  = seq(from=floor(min(dt$StimLatency*10))/10, to=ceiling(max(dt$StimLatency*10))/10, by=RTbw)
All_Cnt = hist(dt$StimLatency, breaks=GoBrks, plot=FALSE)

All_Cnt$counts = 0.2 * max(all_vals_Y) * All_Cnt$counts / max(All_Cnt$counts)

plot(All_Cnt, xaxs='i', yaxs='i', main='Response after Target Onset', xlim=range(all_vals_X), ylim=range(all_vals_Y),
     ylab='count', xlab='Trial Duration [s]', col='gray50', border=NA)

lines(TDurall, lwd=2, col='darkgrey')

if(sum(pCorr) > 4) {
  lines(TDurhit, lwd=2, col=Corr_Col)
}

if(sum(pHoldErr) > 4) {
  lines(TDurhold, lwd=2, col=TargetBreak_Col)
}

if(sum(pEarly) > 4) {
  lines(TDurearly, lwd=2, col=Early_Col)
}

 if(sum(pFalse) > 4) {
   lines(TDurfalse, lwd=2, col=False_Col)
 }

if(sum(pEarlyFalse) > 4) {
  lines(TDurfalseearly, lwd=2, col=EarlyFalse_Col)
}

if(sum(pFixBreak) > 4) {
  lines(TDurfixbreak, lwd=2, col=FixBreak_Col)
}

if(sum(pStimBreak) > 4) {
  lines(TDurstimbreak, lwd=2, col=StimBreak_Col)
}

abline(v=median(FixSRT[pCorr],  na.rm=TRUE), col=Corr_Col,  lty=2, lwd=2)
abline(v=median(FixSRT[pEarly], na.rm=TRUE), col=Early_Col, lty=2, lwd=2)

box()

###########################################################################################
# plot 6: response times
all_vals_X = c()
all_vals_Y = c()

if(sum(pCorr) > 4) {
  RThit   = density(SRT[pCorr], bw=RTbw, na.rm=TRUE)
  RThit$y = RThit$y  * sum(pCorr)  * RTbw
  all_vals_X = c(all_vals_X, RThit$x)
  all_vals_Y = c(all_vals_Y, RThit$y)
}

if(sum(pHoldErr) > 4) {
  RThold   = density(SRT[pHoldErr], bw=RTbw, na.rm=TRUE)
  RThold$y = RThold$y  * sum(pHoldErr)  * RTbw
  all_vals_X = c(all_vals_X, RThold$x)
  all_vals_Y = c(all_vals_Y, RThold$y)
}

if(sum(pEarly) > 4) {
  RTearly   = density(SRT[pEarly], bw=RTbw, na.rm=TRUE)
  RTearly$y = RTearly$y  * sum(pEarly)  * RTbw
  all_vals_X = c(all_vals_X, RTearly$x)
  all_vals_Y = c(all_vals_Y, RTearly$y)
}

 if(sum(pFalse) > 4) {
   RTfalse   = density(SRT[pFalse], bw=RTbw, na.rm=TRUE)
   RTfalse$y = RTfalse$y  * sum(pFalse)  * RTbw
   all_vals_X = c(all_vals_X, RTfalse$x)
   all_vals_Y = c(all_vals_Y, RTfalse$y)
 }

if(sum(pEarlyFalse) > 4) {
  RTfalseearly   = density(SRT[pEarlyFalse], bw=RTbw, na.rm=TRUE)
  RTfalseearly$y = RTfalseearly$y  * sum(pEarlyFalse)  * RTbw
  all_vals_X = c(all_vals_X, RTfalseearly$x)
  all_vals_Y = c(all_vals_Y, RTfalseearly$y)
}

if(sum(pFixBreak) > 4) {
  RTfixbreak   = density(SRT[pFixBreak], bw=RTbw, na.rm=TRUE)
  RTfixbreak$y = RTfixbreak$y  * sum(pFixBreak)  * RTbw
  all_vals_X = c(all_vals_X, RTfixbreak$x)
  all_vals_Y = c(all_vals_Y, RTfixbreak$y)
}

if(sum(pStimBreak) > 4) {
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

if(sum(pCorr) > 4) {
  lines(RThit, lwd=2, col=Corr_Col)
}

if(sum(pHoldErr) > 4) {
  lines(RThold, lwd=2, col=TargetBreak_Col)
}

if(sum(pEarly) > 4) {
  lines(RTearly, lwd=2, col=Early_Col)
}

 if(sum(pFalse) > 4) {
   lines(RTfalse, lwd=2, col=False_Col)
 }

if(sum(pEarlyFalse) > 4) {
  lines(RTfalseearly, lwd=2, col=EarlyFalse_Col)
}

if(sum(pFixBreak) > 4) {
  lines(RTfixbreak, lwd=2, col=FixBreak_Col)
}

if(sum(pStimBreak) > 4) {
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
# plot 8: psychometric function
valPos = dt$Outcome == 'Correct' | dt$Outcome == 'False' | dt$Outcome == 'TargetBreak'

#valPos = valPos == 1 & dt$SRT > 0.05

dtv = droplevels(subset(dt, valPos))

# discard conditions with too few trials
allContr = sort(unique(dtv$TargetContr))
ContrCnt = as.numeric(table(dtv$TargetContr))
vCtr     = ContrCnt >= 2 # at least 10 trials
vPos     = dtv$TargetContr %in% allContr[vCtr]
dtv     = droplevels(subset(dtv, vPos))

fitA = quickpsy(d=dtv, x=TargetContr, k=TargetSel, grouping=.(RefContr),
                fun=cum_normal_fun, prob=0.5, bootstrap='none',
                xmin=0, xmax=1, lapses=TRUE, guess=0, optimization='DE',
                parini=list(c(0.0, 0.8), c(0.15, 0.9), c(0.0, 0.6), c(0.0, 0.6)) )
#                parini=list(c(0.0, 0.8), c(0.15, 0.9), c(0.0, 0.6)) )
# #               parini=list(c(0.0001, 0.8), c(0.0001, 0.8), c(0.0001, 0.5), c(0.0001, 0.5)) )

plot(fitA$averages$TargetContr, fitA$averages$prob, type='n', xlim=c(0,1),
     ylim=c(0,1), xlab='Contrast', ylab='Proportion', main='Point of Subjective Equality')

Rclst = sort(unique(fitA$averages$RefContr))

cnt=0
for(cRef in Rclst){
    cnt = cnt + 1
    pp = fitA$averages$RefContr == cRef
    points(fitA$averages$TargetContr[pp], fitA$averages$prob[pp], pch=19, col=cnt+1)

    pp2 = fitA$curves$RefContr == cRef

    lines(fitA$curves$x[pp2], fitA$curves$y[pp2], col=cnt+1, lwd=2)
}
abline(h=0.5, lty=3)

legend("bottomright", legend=Rclst, ncol=2, cex=1.5,
       pch=c(15), col=seq(1,length(Rclst))+1, title='Reference Contrast')


###########################################################################################
# save plot as pdf
if(interactive()) {
  # Save the figure to pdf
  dev.copy(pdf, paste('PercEqui_',dt$Date[1],'.pdf',sep=""), 19.5, 10.5, pointsize=10, title='PercEqui')
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
  PercEqui_Behav(datadir, fname)
}


