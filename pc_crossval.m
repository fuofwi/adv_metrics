function [npc_hat,rmse_pc] = pc_crossval(xreg,yreg,npcmin,npcmax,k,i_parallel,i_random)
% Estimate number of PCs by Cross-validation

nobs = size(yreg,1);
n_pc = npcmax-npcmin+1;  % Number of PCs
pc_vec = (npcmin:1:npcmax)';

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
ssr_rslt = NaN(k,n_pc);
if i_parallel == 0;
 for j = 1:k;
  xreg_is = xreg(kindex ~= j,:);
  xreg_os = xreg(kindex == j,:);
  yreg_is = yreg(kindex ~= j,:);
  yreg_os = yreg(kindex == j,:);
  x = xreg_is(:,1:end-1);  % Last column of xreg is vector of 1s
  xm = mean(x)';
  xs = std(x)';
  xstd = (x-repmat(xm',size(x,1),1))./repmat(xs',size(x,1),1);
  coef = pca(xstd,'NumComponents',npcmax);
  xpc = xstd*coef;
  ym = mean(yreg_is);
  ydm = yreg_is - ym;
  b_all = xpc\ydm;
  ssr_tmp = NaN(n_pc,1);
  for ipc = npcmin:npcmax;
    b = zeros(size(coef,1),1);
    if ipc > 0;
    	b = coef(:,1:ipc)*b_all(1:ipc);
    end;
    bs = b./xs;
    b_c = ym - bs'*xm;
    bpc = [bs;b_c];
    u = yreg_os-xreg_os*bpc;
    ssr = sum(u.^2);
    ssr_tmp(ipc-npcmin+1) = ssr;
  end;
  ssr_rslt(j,:) = ssr_tmp';
 end;
end;

if i_parallel == 1;
 parfor j = 1:k;
  xreg_is = xreg(kindex ~= j,:);
  xreg_os = xreg(kindex == j,:);
  yreg_is = yreg(kindex ~= j,:);
  yreg_os = yreg(kindex == j,:);
  x = xreg_is(:,1:end-1);  % Last column of xreg is vector of 1s
  xm = mean(x)';
  xs = std(x)';
  xstd = (x-repmat(xm',size(x,1),1))./repmat(xs',size(x,1),1);
  coef = pca(xstd,'NumComponents',npcmax);
  xpc = xstd*coef;
  ym = mean(yreg_is);
  ydm = yreg_is - ym;
  b_all = xpc\ydm;
  ssr_tmp = NaN(n_pc,1);
  for ipc = npcmin:npcmax;
    b = zeros(size(coef,1),1);
    if ipc > 0;
    	b = coef(:,1:ipc)*b_all(1:ipc);
    end;
    bs = b./xs;
    b_c = ym - bs'*xm;
    bpc = [bs;b_c];
    u = yreg_os-xreg_os*bpc;
    ssr = sum(u.^2);
    ssr_tmp(ipc-npcmin+1) = ssr;
  end;
  ssr_rslt(j,:) = ssr_tmp';
 end;
end;

rmse_rslt = sqrt(sum(ssr_rslt)/nobs)';
[blank,ii] = min(rmse_rslt);
npc_hat = pc_vec(ii);
rmse_pc = [pc_vec rmse_rslt];

end

