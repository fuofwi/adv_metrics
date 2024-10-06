function [ bols, i_singular ] = ols_compute_std(xreg,yreg)
% Compute OLS estimates .. use standardized regressors .. then transform back to
% raw units
i_singular = 0;
x = xreg(:,1:end-1);  % Last column of xreg is vector of 1s
xm = mean(x)';
xs = std(x)';
xstd = (x-repmat(xm',size(x,1),1))./repmat(xs',size(x,1),1);
ym = mean(yreg);
ydm = yreg - ym;
% Trap Rank Deficient matrix;
lastwarn('');
  b = xstd\ydm;
  [astr,bstr] = lastwarn;
  ii = strcmp(bstr,'MATLAB:rankDeficientMatrix');
  if ii == 1;
      b = NaN(size(xstd,2),1);
      i_singular = 1;
  end;
  bs = b./xs;
  b_c = ym - bs'*xm;
  bols = [bs;b_c];

end

