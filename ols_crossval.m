function [rmse_rslt] = ols_crossval(xreg,yreg,k,i_random,i_parallel)
% Estimate number of PCs by k-fold Cross-validation

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
ssr_rslt = NaN(k,1);
if i_parallel == 1;

 parfor j = 1:k;
  xreg_is = xreg(kindex ~= j,:);
  xreg_os = xreg(kindex == j,:);
  yreg_is = yreg(kindex ~= j,:);
  yreg_os = yreg(kindex == j,:);
  [bols,i_singular] = ols_compute_std(xreg_is,yreg_is);
  u = yreg_os-xreg_os*bols;
  ssr_rslt(j) = sum(u.^2);
 end;

else;

 for j = 1:k;
  xreg_is = xreg(kindex ~= j,:);
  xreg_os = xreg(kindex == j,:);
  yreg_is = yreg(kindex ~= j,:);
  yreg_os = yreg(kindex == j,:);
  [bols,i_singular] = ols_compute_std(xreg_is,yreg_is);
  u = yreg_os-xreg_os*bols;
  ssr_rslt(j) = sum(u.^2);
 end;

end;
rmse_rslt = sqrt(sum(ssr_rslt)/nobs)';

end

