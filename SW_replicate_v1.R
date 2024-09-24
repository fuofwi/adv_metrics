remove(list=ls())
set.seed(1)

library(readxl)
library(glmnet)
library(pls)


schools_all = read_excel("R/ca_school_testscore.xlsx", # data type!!!
                         col_types="numeric")[-1, ]    # disard description(check the excel file)
schools = subset(schools_all, select=c(             
  'testscore',
  'str_s',
  'med_income_z',
  'te_avgyr_s',
  'exp_1000_1999_d',
  'frpm_frac_s',
  'ell_frac_s',
  'freem_frac_s',
  'enrollment_s',
  'fep_frac_s',
  'edi_s',
  're_aian_frac_s',
  're_asian_frac_s',
  're_baa_frac_s',
  're_fil_frac_s',
  're_hl_frac_s',
  're_hpi_frac_s',
  're_tom_frac_s',
  're_nr_frac_s',
  'te_fte_s',
  'te_1yr_frac_s',
  'te_2yr_frac_s',
  'te_tot_fte_rat_s',
  'exp_2000_2999_d',
  'exp_3000_3999_d',
  'exp_4000_4999_d',
  'exp_5000_5999_d',
  'exp_6000_6999_d',
  'exp_7000_7999_d',
  'exp_8000_8999_d',
  'expoc_1000_1999_d',
  'expoc_2000_2999_d',
  'expoc_3000_3999_d',
  'expoc_4000_4999_d',
  'expoc_5000_5999_d',
  'revoc_8010_8099_d',
  'revoc_8100_8299_d',
  'revoc_8300_8599_d',
  'revoc_8600_8799_d'
))

split = sample(rep(1:2, length=nrow(schools))) # it returns random permutation of rep(1:2, length=3932)
schools_ins = schools[split==1, ] # if split[i] == 1 then select schools[i] for in-sample data. 
schools_oos = schools[split!=1, ] # if split[i] == 2 then select schools[i] for out-of-sample data

# schools_tmp = schools_ins[1:50, ] ### temporary

formula <- paste("testscore ~ .^2 + ", paste0("I(",colnames(schools)[-1],"^2)",collapse=" + "), " + ", paste0("I(",colnames(schools)[-1],"^3)",collapse=" + "))
X_ins = model.matrix(as.formula(formula), schools_ins)[,-1]
Y_ins = schools_ins$testscore


X_ins = scale(X_ins) # equivalent to: X_ins[,i] = (X_ins[,i] - mean(X_ins[,i]))/sd(X_ins[,i]) for all i's(columns)
Y_ins = Y_ins - mean(Y_ins)
X_oos = scale(model.matrix(as.formula(formula), schools_oos)[,-1])
Y_oos = schools_oos$testscore - mean(schools_oos$testscore)

grid = 10^seq(10, -2, length=100)
# folds = sample(rep(1:10, length=nrow(schools_ins)))

## Lasso
lasso.cv.mod = cv.glmnet(X_ins, Y_ins, alpha=1, lambda = grid, nfolds=10, standardize=F, intercept=F)
lambda_best_lasso = lasso.cv.mod$lambda.min
lambda_best_lasso_SW = lambda_best_lasso * 2*nrow(X_ins) # check the objective function of glmnet 
lasso.best.mod = glmnet(X_ins, Y_ins, alpha=1, lambda = lambda_best_lasso, standardize=F, intercept=F) # notice the changes in the parameters lambda, nfolds
mspe_ins_lasso = mean((Y_ins - predict(lasso.best.mod, s=lambda_best_lasso, newx=X_ins))^2)
mspe_oos_lasso = mean((Y_oos - predict(lasso.best.mod, s=lambda_best_lasso, newx=X_oos))^2)

## PCA
df_ins = as.data.frame(cbind(Y_ins, X_ins))
pcr.fit = pcr(Y_ins ~ ., data=df_ins, validation="CV", scale=F, center=F)
summary(pcr.fit) # MSPE and Variance(of X and Y) along with the number of components
validationplot(pcr.fit, val.type="MSEP")
p_best = 48 # find from the plot and summary ... (48?)
mspe_ins_pcr = mean((Y_ins - predict(pcr.fit, X_ins, ncomp = p_best))^2)
mspe_oos_pcr = mean((Y_oos - predict(pcr.fit, X_oos, ncomp = p_best))^2)

## Ridge

## OLS