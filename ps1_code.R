remove(list=ls())
set.seed(1234)

# beta = (1, 1)'
beta = matrix(c(1,1), nrow=2)
k = 2
n = 100

# (a)
X_tilda = rnorm(n, mean = 1, sd = 1) # i.
ones = rep.int(1, n)
X = cbind(X_tilda, ones)
e = rnorm(n, mean = 0, sd = 1) # ii.
Y = X%*%beta + e # iii.

# (b)
beta_hat_OLS = solve(t(X)%*%X) %*% t(X)%*%Y

residual = Y - X%*%beta_hat_OLS
s_square = sum(residual^2)/ (n - k)
  
V_hat_0 = solve(t(X)%*%X) * s_square

D_hat = diag((residual^2)[,1])
V_hat_HC1 = (n/(n -k)) * solve(t(X)%*%X) %*% t(X)%*%D_hat%*%X  %*% solve(t(X)%*%X)

# (c)



