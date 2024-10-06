function [ bpc ] = pc_compute_std(xreg,yreg,npc)
% Compute PC Estimates after standardized data
x = xreg(:,1:end-1);  % Last column of xreg is vector of 1s
xm = mean(x)';
xs = std(x)';
xstd = (x-repmat(xm',size(x,1),1))./repmat(xs',size(x,1),1);
ym = mean(yreg);
ydm = yreg - ym;
coef = pca(xstd,'NumComponents',npc);
xpc = xstd*coef;
b = xpc\ydm;
b = coef*b;
bs = b./xs;
b_c = ym - bs'*xm;
bpc = [bs;b_c];

end

