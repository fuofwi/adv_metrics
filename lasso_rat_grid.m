function [lasso_rat_vec] = lasso_rat_grid(lasso_rat_max,lasso_rat_min,nlasso);
% Form vector of ridge values for use in cross validation

log_min = log(lasso_rat_min);
log_max = log(lasso_rat_max);
step = (log_max-log_min)/(nlasso-1);
log_lasso_rat_vec = (log_min:step:log_max)';
lasso_rat_vec = exp(log_lasso_rat_vec);

end

