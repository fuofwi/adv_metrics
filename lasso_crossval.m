function [lambda_hat,rmse_lambda] = pc_crossval(xreg,yreg,lamrat_vec,k,i_parallel,i_random)
% Estimate lasso parameter by cross-validation

nlam = size(lamrat_vec,1);  % Number of Ridge Values

% Step 0: Find grid of lambda values
[blank,FitInfo] = lasso(xreg(:,1:end-1),yreg,'NumLambda',1);
lambda_max = FitInfo.Lambda;                % Value of Lambda that "just" sets all coefficieints = 0
lambda_vec = lamrat_vec*lambda_max;
nobs = size(yreg,1);

% Step 1: randomize order of Xreg and Yreg
if i_random == 1;
 tmp = rand(nobs,1);
 [blank,isort] = sort(tmp);
 xreg = xreg(isort,:);
 yreg = yreg(isort,:);
end;

% Step 2: set up index for each of k groups
kfrac = floor(nobs/k);
kindex = NaN(nobs,1);
for i = 1:k-1;
  jfirst = (i-1)*kfrac+1;
  jlast = i*kfrac;
  kindex(jfirst:jlast,1)=i;
end;
kindex((k-1)*kfrac+1:end,1)=k;

% Step 3: Compute oos msfe for each partition
ssr_rslt = NaN(k,nlam);
if i_parallel == 0;
 for j = 1:k;
  xreg_is = xreg(kindex ~= j,:);
  xreg_os = xreg(kindex == j,:);
  yreg_is = yreg(kindex ~= j,:);
  yreg_os = yreg(kindex == j,:);
  [br_mat,FitInfo] = lasso(xreg_is(:,1:end-1),yreg_is,'Lambda',lambda_vec);
  b_lasso_mat = [br_mat; FitInfo.Intercept];
  for ir = 1:nlam;
    b = b_lasso_mat(:,ir);
    u = yreg_os-xreg_os*b;
    ssr = sum(u.^2);
    ssr_rslt(j,ir) = ssr;
  end;
 end;
end;
if i_parallel == 1;
 parfor j = 1:k;
  xreg_is = xreg(kindex ~= j,:);
  xreg_os = xreg(kindex == j,:);
  yreg_is = yreg(kindex ~= j,:);
  yreg_os = yreg(kindex == j,:);
  [br_mat,FitInfo] = lasso(xreg_is(:,1:end-1),yreg_is,'Lambda',lambda_vec);
  b_lasso_mat = [br_mat; FitInfo.Intercept];
  for ir = 1:nlam;
    b = b_lasso_mat(:,ir);
    u = yreg_os-xreg_os*b;
    ssr = sum(u.^2);
    ssr_rslt(j,ir) = ssr;
  end;
 end;
end;

rmse_rslt = sqrt(sum(ssr_rslt)/nobs)';
[blank,ii] = min(rmse_rslt);
lambda_hat = lambda_vec(ii);
rmse_lambda = [lambda_vec rmse_rslt];
  
end

