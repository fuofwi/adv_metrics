function [ridge_hat,rmse_ridge] = ridge_crossval(xreg,yreg,ridge_vec,k,i_parallel,i_random)
% Estimate number of PCs by Cross-validation

nridge = size(ridge_vec,1);  % Number of Ridge Values

nobs = size(yreg,1);
 
if i_random == 1;
 % Step 1: randomize order of Xreg and Yreg
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
ssr_rslt = NaN(k,nridge);
if i_parallel == 0;
 for j = 1:k;
  xreg_is = xreg(kindex ~= j,:);
  xreg_os = xreg(kindex == j,:);
  yreg_is = yreg(kindex ~= j,:);
  yreg_os = yreg(kindex == j,:);
  br_mat = ridge(yreg_is,xreg_is(:,1:end-1),ridge_vec,0);
  b_ridge_mat = [br_mat(2:end,:);br_mat(1,:)];  % First element of br is intercept
  for ir = 1:nridge;
    b = b_ridge_mat(:,ir);
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
  br_mat = ridge(yreg_is,xreg_is(:,1:end-1),ridge_vec,0);
  b_ridge_mat = [br_mat(2:end,:);br_mat(1,:)];  % First element of br is intercept
  for ir = 1:nridge;
    b = b_ridge_mat(:,ir);
    u = yreg_os-xreg_os*b;
    ssr = sum(u.^2);
    ssr_rslt(j,ir) = ssr;
  end;
 end;
end;

rmse_rslt = sqrt(sum(ssr_rslt)/nobs)';
[blank,ii] = min(rmse_rslt);
ridge_hat = ridge_vec(ii);
rmse_ridge = [ridge_vec rmse_rslt];
  
end

