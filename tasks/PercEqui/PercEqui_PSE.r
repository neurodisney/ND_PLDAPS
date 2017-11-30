#!/usr/bin/Rscript

## load required packages
require(useful,   quietly=TRUE)
require(catspec,  quietly=TRUE)
require(beanplot, quietly=TRUE)
require(MixedPsy, quietly=TRUE)
require(psyphy,   quietly=TRUE)

# Function for plotting data from the delayed saccade task
PercEqui_PSE = function(datadir=NA, fname=NA, ) {

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
if(!is.na(datadir)) { setwd(datadir) }

# If no fname is specified, use all the .dat files in the datadir
if(is.na(fname)) {
  fname = Sys.glob('*.dat')
}

dt=read.table(fname[1], header=TRUE)

if(length(fname)>1) {
  for(i in 2:length(fname)) { dt = rbind(dt, read.table(fname[i], header=TRUE, fill = TRUE))}
}

###########################################################################################
## prepare data

# get only trials where the target was selected

RespPos = dt$Outcome == 'Correct' | dt$Outcome == 'False' | dt$Outcome == 'TargetBreak'

dt = droplevels(subset(dt, RespPos))

allContr = sort(unique(dt$TargetContr))
ContrCnt = as.numeric(table(dt$TargetContr))
vCtr = ContrCnt > 20

vPos = dt$TargetContr %in% allContr[vCtr]

dt = droplevels(subset(dt, vPos))

# correct item chosen, ignore target breaks
CorrItm = dt$Good 
CorrItm[dt$Outcome == 'TargetBreak'] = 1

# chosen item was target or reference
TrgtHigh = dt$TargetContr > dt$RefContr
TrgtSel = rep(NA, length(dt$Good))
TrgtSel[TrgtHigh == 1 & dt$Good == 1] = 1
TrgtSel[TrgtHigh == 0 & dt$Good == 1] = 0
TrgtSel[TrgtHigh == 1 & dt$Good == 0] = 0
TrgtSel[TrgtHigh == 0 & dt$Good == 0] = 1

dt$TrgtSel = TrgtSel

###########################################################################################
## PSE estimate
fitS = quickpsy(d=dt, x=TargetContr, k=TrgtSel,  grouping = .(Hemi), fun=logistic_fun,
                B=10, bootstrap='nonparametric' , xmin=0, xmax=1, lapses=F, guess=T)
plotcurves(fitS)


fitA = quickpsy(d=dt, x=TargetContr, k=TrgtSel,   fun=cum_normal_fun, 
                B=10, bootstrap='nonparametric' , xmin=0, xmax=1, lapses=F, guess=T)
plotcurves(fitA)

# ###########################################################################################
# ## PSE estimate
# 
# lH = dt$Hemi == 'l'
# intensity  = sort(unique(dt$TargetContr[lH]))
# Nall       = as.numeric(table(dt$TargetContr[lH]))
# nCorrect   = table(TrgtSel[lH], dt$TargetContr[lH])[2,]
# nIncorrect = table(TrgtSel[lH], dt$TargetContr[lH])[1,]
# Hemi       = rep('left', length(Nall))
# 
# datL = data.frame(intensity, nCorrect, nIncorrect, Nall, Hemi)
# 
# rH = dt$Hemi == 'r'
# intensity  = sort(unique(dt$TargetContr[rH]))
# Nall       = as.numeric(table(dt$TargetContr[rH]))
# nCorrect   = table(TrgtSel[rH], dt$TargetContr[rH])[2,]
# nIncorrect = table(TrgtSel[rH], dt$TargetContr[rH])[1,]
# Hemi       = rep('right', length(Nall))
# 
# datR = data.frame(intensity, nCorrect, nIncorrect, Nall, Hemi)
# 
# dat = rbind(datL, datR)
# 
# dat$p = dat$nCorrect/(dat$nCorrect + dat$nIncorrect)
# 
# 
# fit = quickpsy(dat, intensity, nCorrect, Nall,  grouping = .(Hemi), fun=logistic_fun,
#                B=10, bootstrap='nonparametric' , xmin=0, xmax=1, lapses = T, guess=0.5)
# plotcurves(fit)



}