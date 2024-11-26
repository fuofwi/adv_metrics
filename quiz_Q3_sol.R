remove(list = ls())
set.seed(1)

library(readxl)

data_all = read_excel("R/ca_school_testscore.xlsx", # for this data file, we should specify the type of variables.
                         col_types="numeric")[-1, ]    # '[-1, ]' to discard the descriptions
data = subset(data_all, select=c(             
  'testscore',
  'str_s',
  'med_income_z'
))

folds = sample(rep(1:10, length=nrow(data)))
MSPE = 0

for (j in 1:10) {
    data_train = data[folds!=j, ]
    data_test =  data[folds==j, ]
    
    lm.mod = lm(testscore ~ str_s + med_income_z, data=data_train)
    y_pred = predict(lm.mod, newdata=data_test) # data_test[c('str_s', 'med_income_z')] is optional
    
    MSPE = MSPE + (nrow(data_test)/nrow(data)) * mean((data_test$testscore - y_pred)^2)
}

print(MSPE)
