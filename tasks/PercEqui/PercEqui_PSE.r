#!/usr/bin/Rscript

## load required packages
require(useful,   quietly=TRUE)
require(catspec,  quietly=TRUE)
require(beanplot, quietly=TRUE)
# require(MixedPsy, quietly=TRUE)
require(psyphy,   quietly=TRUE)
require(quickpsy, quietly=TRUE)

# Function for plotting data from the delayed saccade task
PercEqui_PSE = function(datadir=NA, fname=NA) {

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

dt$Hemi = as.factor(dt$Hemi)

###########################################################################################
## PSE estimate

fitA = quickpsy(d=dt, x=TargetContr, k=TrgtSel,   fun=cum_normal_fun, 
                B=10, bootstrap='nonparametric' , xmin=0, xmax=1, lapses=F, guess=T)
plotcurves(fitA)

fitS = quickpsy(d=dt, x=TargetContr, k=TrgtSel,  grouping = .(Hemi), fun=logistic_fun,
                B=100, bootstrap='nonparametric' , xmin=0, xmax=1, lapses=F, guess=T)
plotcurves(fitS)

RTbw=0.250
cpos = dt$Good==1
beanplot(dt$SRT_StimOn[cpos] ~ dt$Hemi[cpos]*dt$TargetContr[cpos], ll = 0.1,
         main = "SRT", side = "both", xlab="Delay [s]", ylab='Response Time [s]', 
         col = list('limegreen', c('cornflowerblue', "black")),
         bw=RTbw,overallline='median', beanlinese='median', what=c(0,1,1,1))

RTall = tapply(dt$SRT_StimOn[cpos], list(dt$Hemi[cpos], dt$TargetContr[cpos]), median)

Xctr = sort(unique(dt$TargetContr))
lRT  = as.numeric(RTall[1,])
rRT  = as.numeric(RTall[2,])

plot(Xctr, lRT, type='l', col='cornflowerblue', ylim=range(RTall))
lines(Xctr, rRT,  col='limegreen')

}

