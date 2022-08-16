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
SessTimeRng    = range(c(dt$FixSpotOn, dt$FixSpotOff), na.rm=TRUE)
SessTrialStart = SessTimeRng[1]
SessTrialEnd   = diff(SessTimeRng)
Break_trial    = which(dt$Outcome == 'Break')

dt$SessTime   = (dt$FixSpotOn - SessTrialStart) / 60  # in minutes, define trial start times as fixation spot onset

# get only trials where the target was selected

RespPos = dt$Outcome == 'Correct' | dt$Outcome == 'False' | dt$Outcome == 'TargetBreak'

dt = droplevels(subset(dt, RespPos))
dt = droplevels(subset(dt, dt$SessTime < 90 & dt$RefY == 0))
dt = droplevels(subset(dt,  dt$RefY == 0))

# allContr = sort(unique(dt$TargetContr))
# ContrCnt = as.numeric(table(dt$TargetContr))
# vCtr = ContrCnt > 20
# 
# vPos = dt$TargetContr %in% allContr[vCtr]
# 
# dt = droplevels(subset(dt, vPos))

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

fitA = quickpsy(d=dt, x=TargetContr, k=TrgtSel, fun=weibull_fun, random=Date,
                B=100, bootstrap='none', xmin=0, xmax=1, lapses=T, guess=T)
Apl = plot(fitA)
Apl + theme_classic() + ylab('Proportion') + 
      theme(panel.border = element_blank()) + 
      scale_x_continuous(limits = c(0,1), expand = c(0, 0)) +
      scale_y_continuous(limits = c(0,1), expand = c(0, 0)) + 
      geom_line(data = fitA$curvesbootstrap, aes(x = x, y = y, group=paste(sample)), color = 'grey', lwd = .2, alpha = .4) + 
      geom_line(data = fitA$curves, aes(x = x, y = y),  color = 'black', lwd = 1.5) +
  stat_summary(d=dt, aes(TargetContr, TrgtSel), fun.data = "mean_cl_boot", color='red') +
  geom_segment(data = fitA$thresholds, aes(x = thre, y = 0, xend = thre, yend = prob), color='blue', lwd=0.75) +
  geom_segment(data = fitA$thresholds, aes(x = threinf, y = prob, xend = thresup, yend = prob), color = 'blue', lwd=0.75) +
  geom_segment(data = fitA$thresholds, aes(x = threinf, y = prob-0.01, xend = threinf, yend = prob+0.01), color='blue', lwd=0.75) +
  geom_segment(data = fitA$thresholds, aes(x = thresup, y = prob-0.01, xend = thresup, yend = prob+0.01), color='blue', lwd=0.75) +
  scale_alpha(guide = "none")


fitA = quickpsy(d=dt, x=TargetContr, k=TrgtSel, fun=weibull_fun, 
                B=100, bootstrap='none', xmin=0, xmax=1, lapses=T, guess=T)

ggplot(fitA$curves, aes(x = x, y = y),  color='red', lwd = 1.5) + 
  theme_classic() + ylab('Proportion') + xlab('grating contrast') +
   ggtitle('PSE', subtitle = 'Dec 4th and 5th combined')  +
  theme(plot.title = element_text(hjust = 0.5))+
  theme(plot.subtitle = element_text(hjust = 0.5))+
  theme(panel.border = element_blank()) + 
  scale_x_continuous(limits = c(0,1), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0,1), expand = c(0, 0)) + 
  geom_line(data = fitA$curves, aes(x = x, y = y),  color='red', lwd = 1.5) +
  geom_point(data = fitA$averages, aes(x = TargetContr, y = prob), color='black', size = 2) 




Apl + theme_classic() + ylab('Proportion') + 
  theme(panel.border = element_blank()) + 
  scale_x_continuous(limits = c(0,1), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0,1), expand = c(0, 0)) + 
  geom_point(data = fitA$averages, aes(x = TargetContr, y = prob), color='black', size = 2)  +
  geom_line(data = fitA$curves, aes(x = x, y = y),  color='red', lwd = 1.5) 
  

fitS = quickpsy(d=dt, x=TargetContr, k=TrgtSel,  grouping = .(Hemi), fun=weibull_fun,
                B=10, bootstrap='nonparametric' , xmin=0, xmax=1, lapses=T, guess=T)
plotcurves(fitS)


fit3 = quickpsy(d=dt, x=TargetContr, k=TrgtSel,  grouping = .(StimSize, Hemi), fun=cum_normal_fun,
                B=10, bootstrap='none' , xmin=0, xmax=1, lapses=T, guess=T) 
plotcurves(fit3)

fit3 = quickpsy(d=dt, x=TargetContr, k=TrgtSel,  grouping = .(StimSize), fun=logistic_fun,
                B=10, bootstrap='none' , xmin=0, xmax=1, lapses=T, guess=T)
plotcurves(fit3)






RTbw=0.250
cpos = dt$Good==1 & dt$SRT_StimOn < 1
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





# http://rpubs.com/dahtah/psychfun

pf <- function(x, mu, sigma, lambda = 0) (1 - lambda) * pnorm((x - mu)/sigma) + 
  lambda/2

ggplot(dt, aes(TargetContr, TrgtSel)) + 
  stat_summary(fun.data = "mean_cl_boot") + 
  labs(x = "Stim. level", y = "Response frequency")


require(rstan)
require(reshape2)
res <- stan("psychfun_lapse.stan", data = list(x = dt$TargetContr, y = dt$TrgtSel, N = length(dt$TargetContr)), 
            iter = 1000, chain = 4, thin = 10)
samples <- extract(res)
smpl <- mutate(as.data.frame(samples), index = 1:length(mu))
ggplot(melt(smpl, id.var = "index"), aes(index, value)) + geom_point() + facet_wrap(~variable, 
                                                                                    scale = "free_y")

xv <- seq(0, 1, l = 100)
dpost <- adply(smpl, 1, function(s) data.frame(xv = xv, pfun = pf(xv, s$mu, 
                                                                  s$sigma, s$lambda), index = s$index))
ggplot(dt, aes(TargetContr, TrgtSel)) + 
           stat_summary(fun.data = "mean_cl_boot") + 
           theme_classic() + theme(panel.border = element_blank()) + 
           scale_x_continuous(limits = c(0,1), expand = c(0, 0)) +
           scale_y_continuous(limits = c(0,1), expand = c(0, 0)) + 
           geom_line(data = dpost, 
           aes(xv, pfun, group = as.factor(index)), alpha = 0.03, col = "red") + labs(x = "Stim. level",  y = "Response")
                                                                                                                                                       y = "Response")
#ggplot(subset(melt(smpl, id.var = "index"), variable != "lp__"), aes(value)) + 
#  geom_density() + facet_wrap(~variable, scale = "free")



}

