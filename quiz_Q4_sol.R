remove(list=ls())
set.seed(1)

library(readxl)
library(lmtest)
library(sandwich)

data = read_excel("R/ts/fig15_1_n.xlsx") # log-transformed GDP
gdp = exp(data['Y']) # US quarterly GDP, from 1960:Q1 to 2017:Q4

gdp_ts = ts(data=gdp, start=c(1960, 1), frequency = 4)
T1 = nrow(gdp_ts)

growth_rate =  400*(log(gdp_ts[5:T1]) - log(gdp_ts[4:(T2-1)])) # 1961:Q1-2017:Q4 at annual rate(%)

T2 = length(growth_rate)

gamma = rep(0, 21)
gamma[1] = var(growth_rate)
for (j in 1:20) {
  gamma[j+1] = cov(growth_rate[(1+j):T2], growth_rate[1:(T2-j)]) # j-th auto-covariance
}








# we reserve the final one(2017:Q4) to compute forecast error
ar1.mod = ar.ols(growth_rate[-T], aic=F, order.max = 1, intercept=T, demean=F)
ar1.mod 
growth_rate_level = growth_rate[2:(T-1)]
growth_rate_lag = growth_rate[1:(T-2)]
ar1.lm = lm(growth_rate_level ~ growth_rate_lag)
summary(ar1.lm)
coeftest(ar1.lm, vcov.=vcovHC, type='HC1')

pred = predict(ar1.mod, newdata=growth_rate[T-1]) # prediction for 2017:Q4 growth rate
# predict(ar1.mod, n.ahead=1)
# predict(ar1.lm, newdata=data.frame("growth_rate_lag"=growth_rate[T-1]))
print(pred)
print(growth_rate[T])
forecast_error = growth_rate[T] - pred$pred
forecast_error

SSR = sum((ar1.mod$resid[-1])^2)
MSFE_ser = SSR/(T-2 -1 -1) # SSR/(T - p - 1) (N: # of obs)
RMSFE_ser = sqrt(MSFE_ser)
MSFE_ser
RMSFE_ser

###
#AIC, BIC
#ADF
#