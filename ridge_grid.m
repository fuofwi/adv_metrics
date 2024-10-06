function [ridge_vec] = ridge_grid(ridge_rat_max,ridge_rat_min,nridge,nobs_insample)
% Form vector of ridge values for use in cross validation

log_min = log(ridge_rat_min);
log_max = log(ridge_rat_max);
step = (log_max-log_min)/(nridge-1);
log_ridge_rat_vec = (log_min:step:log_max)';
ridge_rat_vec = exp(log_ridge_rat_vec);
ridge_vec = ridge_rat_vec*nobs_insample;

end

