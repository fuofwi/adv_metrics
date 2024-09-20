% California Test Score Analysis .. Analysis for Chapter 14
% 9/16/2017
%
clear all;
small = 1.0e-10;
big = 1.0e+10;
this_date = datestr(now,'yyyymmdd');

% -----  File Directories -- overhead, etc.
 outdir = 'out/';
 figdir = 'fig/';
 matdir = 'mat/';
 
% Cross validation parameters
i_parallel = 1;  % 1 = use parallel processing for cross-validation
i_random = 0;    % 1 .. randomize for cross-validation;  Note: data were randomized in caschools_insample_outofsample_data.m ... no need to randomize here
k_cv = 10;       % k-fold cross validation

% Step 1: Read in Data (Data were saved in caschools_read_data.m)
load([matdir 'varname_string']);
load([matdir 'varlabel_string']);
load([matdir 'varvalue_string_insample']);
load([matdir 'varvalue_string_oos']);
load([matdir 'varname']);
load([matdir 'varlabel']);
load([matdir 'varvalue_insample']);
load([matdir 'varvalue_oos']);
 
% ---- Label Associated with this run ---
 model_label = 'small';  % label for model
 %model_label = 'large';
 %model_label = 'verylarge';
 % Get variables for this model
 [xdata_insample,xdata_oos,var_names] = variable_setup(model_label,varname, varvalue_insample, varvalue_oos);
 % Output files for this model
 outfile_name = [outdir [model_label '_' this_date '.asc'] ];
 fileID = fopen(outfile_name,'w');
 
 % Y Variable
 yname = 'testscore';   % Dependent variable
 ydata_insample = getvar(yname,varname,varvalue_insample);
 ydata_oos = getvar(yname,varname,varvalue_oos);
 
% Means and standard deviations
ymean_insample = mean(ydata_insample);
ystd_insample = std(ydata_insample);
ymean_oos = mean(ydata_oos);
ystd_oos = std(ydata_oos);
nobs_insample = size(ydata_insample,1);
nobs_oos = size(ydata_oos,1);

% Print Some Results
fprintf(fileID,'In-sample and out-of-sample values \n');
fprintf(fileID,'Number of obs: %5i  %5i \n',[nobs_insample nobs_oos]);
fprintf(fileID,'Mean of Y: %5.1f  %5.1f \n',[ymean_insample ymean_oos]);
fprintf(fileID,'StdDev of Y: %5.1f  %5.1f \n',[ystd_insample ystd_oos]);

% ---------------- OLS Estimates and Forecasts -----------
tic;
xreg = [xdata_insample ones(nobs_insample,1)];
yreg = ydata_insample;
nreg_large = size(xreg,2)-1;

% Estimate in-sample beta
bols = NaN(size(xreg,2),1);
[bols,i_singular] = ols_compute_std(xreg,yreg);

% Estimate RMSPE using cross-validation
rmspe_insample_ols = NaN;
if i_singular == 0;
  k_cv = 10;
  rmspe_insample_ols = ols_crossval(xreg,yreg,k_cv,i_random,i_parallel);
end;
% Out of sample --- 
xreg = [xdata_oos ones(nobs_oos,1)];
ypredict_ols = xreg*bols;
u = ydata_oos-xreg*bols;
ssr = sum(u.^2);
rmspe_oos_ols = sqrt(ssr/nobs_oos);
fprintf(fileID,'\n OLS Regression Model Results \n');
toc;
fprintf(fileID,'  Number of regressors: %3i \n',nreg_large);
fprintf(fileID,'  Number of regressors/n_insample: %5.2f \n',nreg_large/nobs_insample);
if i_singular == 1;
    fprintf(fileID,'    XX is singular .. OLS not calculatied \n');
else
    fprintf(fileID,'  RMSPE_is RMSPE_oos:  %5.1f  %5.1f \n',[rmspe_insample_ols rmspe_oos_ols]);
end;

% ---------------- Ridge Estimates and Forecasts -----------
tic;
xreg = [xdata_insample ones(nobs_insample,1)];
yreg = ydata_insample;
b_ridge = NaN(size(xreg,2),1);
% Set up Grid of Ridge Parameters for min CV-MSPE estimation
% Step 1: Ridge parameter, relative to n (= sample size)
ridge_rat_max = 50;
ridge_rat_min = .002;
nridge = 100;
ridge_vec = ridge_grid(ridge_rat_max,ridge_rat_min,nridge,nobs_insample);
% Cross validation for ridge parameter
[ridge_parm_cv,rmse_ridge] = ridge_crossval(xreg,yreg,ridge_vec,k_cv,i_parallel,i_random);
rmspe_insample_ridge = min(rmse_ridge(:,2));
% Compute ridge estimate using in-sample data
b_ridge = ridge_compute(xreg,yreg,ridge_parm_cv);
% Out of sample --- 
xreg = [xdata_oos ones(nobs_oos,1)];
ypredict_ridge = xreg*b_ridge;
u = ydata_oos-xreg*b_ridge;
ssr = sum(u.^2);
rmspe_oos_ridge = sqrt(ssr/nobs_oos);
fprintf(fileID,'\n Ridge - CV  Regression Model Results \n');
toc;
fprintf(fileID,'  Ridge Parameter: %5.2f \n',ridge_parm_cv);
fprintf(fileID,'  RMSPE_is RMSPE_oos:  %5.1f  %5.1f \n',[rmspe_insample_ridge rmspe_oos_ridge]);

% ---------------- Lasso Estimates and Forecasts -----------
xreg = [xdata_insample ones(nobs_insample,1)];
yreg = ydata_insample;
b_lasso = NaN(size(xreg,2),1);
% Set up Grid of Lasso Parameters for min CV-MSPE estimation .. these are relative to value that 'just' sets all coefficient to zero
lasso_rat_min = .001;
lasso_rat_max = 1.02;
nlasso = 100;
lasso_rat_vec = lasso_rat_grid(lasso_rat_max,lasso_rat_min,nlasso);
% Cross-validation for lasso parameter
[lasso_parm_cv,rmse_lasso] = lasso_crossval(xreg,yreg,lasso_rat_vec,k_cv,i_parallel,i_random);
rmspe_insample_lasso = min(rmse_lasso(:,2));
 % Note: Matlab uses the objective function: SSR/(2N) + lam*sum(abs(b));
 %       SW textbook uses SSR + lam*sum(abs(b));
 %       So multiply lam by 2*N for textbook results
 lasso_parm_cv_ssr_normalization = 2*size(yreg,1)*lasso_parm_cv;
 rmse_lasso_ssr_normalization = rmse_lasso;
 rmse_lasso_ssr_normalization(:,1) = 2*size(yreg,1)*rmse_lasso_ssr_normalization(:,1);
% Compute lasso coefficients using in-sample data
b_lasso = lasso_compute(xreg,yreg,lasso_parm_cv);
n_lasso = sum(b_lasso ~= 0) - 1;
% Out of sample --- 
xreg = [xdata_oos ones(nobs_oos,1)];
ypredict_lasso = xreg*b_lasso;
u = ydata_oos-xreg*b_lasso;
ssr = sum(u.^2);
rmspe_oos_lasso = sqrt(ssr/nobs_oos);
fprintf(fileID,'\n Lasso - CV  Regression Model Results \n');
toc;
fprintf(fileID,'  Number of non-zero coefficients: %3i \n',n_lasso);
fprintf(fileID,'  Lasso Parameter -- Matlab Normalization (Uses SSR/(2N) + lam*(sum(abs(b))): %5.2f \n',lasso_parm_cv);
fprintf(fileID,'  Lasso Parameter -- Textbook Normalization (Uses SSR  + lam*(sum(abs(b)): %5.2f \n',lasso_parm_cv_ssr_normalization);
fprintf(fileID,'  RMSPE_is RMSPE_oos:  %5.1f  %5.1f \n',[rmspe_insample_lasso rmspe_oos_lasso]);


% ---------------- PC Estimates and Forecasts -----------
tic;
% Scree Plot
x = xdata_insample;  % Last column of xreg is vector of 1s
xm = mean(x)';
xs = std(x)';
xstd = (x-repmat(xm',size(x,1),1))./repmat(xs',size(x,1),1);
[coeff,score,latent] = pca(xstd);
n = size(latent,1);
t = (1:1:n)';
scree = latent/sum(latent);
pc_scree = [t scree];
% Estimation and Forecasting
xreg = [xdata_insample ones(nobs_insample,1)];
yreg = ydata_insample;
bpc = NaN(size(xreg,2),1);
npcmin = 0;
npcmax = min([size(xdata_insample,1) size(xdata_insample,2)]');
npcmax = min([npcmax 500]');
[npc_cv,rmse_pc] = pc_crossval(xreg,yreg,npcmin,npcmax,k_cv,i_parallel,i_random);
npc = npc_cv;
xreg = [xdata_insample ones(nobs_insample,1)];
yreg = ydata_insample;
bpc = pc_compute_std(xreg,yreg,npc);
rmspe_insample_pc = min(rmse_pc(:,2));
% Out of sample --- 
xreg = [xdata_oos ones(nobs_oos,1)];
ypredict_pc = xreg*bpc;
u = ydata_oos-xreg*bpc;
ssr = sum(u.^2);
rmspe_oos_pc = sqrt(ssr/nobs_oos);
fprintf(fileID,'\n PC - CV  Regression Model Results \n');
toc;
fprintf(fileID,'  Number of PCs: %3i \n',npc_cv);
fprintf(fileID,'  RMSPE_is RMSPE_oos:  %5.1f  %5.1f \n',[rmspe_insample_pc rmspe_oos_pc]);

% ------------------- Save Matrices for future use;
save([matdir model_label '_var_names'],'var_names');
save([matdir model_label '_xs'],'xs');

% Regression Coefficient on Raw variables, last is intercept
save([matdir model_label '_bols'],'bols');
save([matdir model_label '_bpc'],'bpc');
save([matdir model_label '_b_ridge'],'b_ridge');
save([matdir model_label '_b_lasso'],'b_lasso');

% Regression coefficients on standardized regressors, no intercept
bols_std = bols(1:end-1).*xs;
bpc_std = bpc(1:end-1).*xs;
b_ridge_std = b_ridge(1:end-1).*xs;
b_lasso_std = b_lasso(1:end-1).*xs;
save([matdir model_label '_bols_std'],'bols_std');
save([matdir model_label '_bpc_std'],'bpc_std');
save([matdir model_label '_b_ridge_std'],'b_ridge_std');
save([matdir model_label '_b_lasso_std'],'b_lasso_std');

save([matdir model_label '_pc_scree'],'pc_scree');
save([matdir model_label '_rmspe_insample_ols'],'rmspe_insample_ols')
save([matdir model_label '_rmspe_insample_pc'],'rmspe_insample_pc');
save([matdir model_label '_rmspe_insample_ridde'],'rmspe_insample_ridge');
save([matdir model_label '_rmspe_insample_lasso'],'rmspe_insample_lasso');
save([matdir model_label '_rmspe_oos_ols'],'rmspe_oos_ols')
save([matdir model_label '_rmspe_oos_pc'],'rmspe_oos_pc');
save([matdir model_label '_rmspe_oos_ridde'],'rmspe_oos_ridge');
save([matdir model_label '_rmspe_oos_lasso'],'rmspe_oos_lasso');
save([matdir model_label '_ydata_oos'],'ydata_oos');
save([matdir model_label '_ypredict_ols'],'ypredict_ols');
save([matdir model_label '_ypredict_pc'],'ypredict_pc');
save([matdir model_label '_ypredict_ridge'],'ypredict_ridge');
save([matdir model_label '_ypredict_lasso'],'ypredict_lasso');

% Cross-validation detail 
save([matdir model_label '_rmse_ridge'],'rmse_ridge');
save([matdir model_label '_rmse_lasso_matlab_normalization'],'rmse_lasso');
save([matdir model_label '_rmse_lasso_ssr_normalization'],'rmse_lasso_ssr_normalization');
save([matdir model_label '_rmse_pc'],'rmse_pc');
