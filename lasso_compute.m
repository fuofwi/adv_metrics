function [ b_lasso ] = lasso_compute_std(xreg,yreg,lasso_parm)
% Compute lasso

  [br,FitInfo] = lasso(xreg(:,1:end-1),yreg,'Lambda',lasso_parm);
  b_lasso=[br; FitInfo.Intercept];

end

