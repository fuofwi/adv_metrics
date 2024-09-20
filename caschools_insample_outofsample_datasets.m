% California Test Score Analysis
% This program computes in-sample and out-of-sample data sets
% These are held fixed during all of the analysis, so all models use the
% same data
% 10/02/2017
%
clear all;
small = 1.0e-10;
big = 1.0e+10;
this_date = datestr(now,'yyyymmdd');
rng(98452);   % Set Seed

% -----  File Directories -- overhead, etc.
 outdir = 'out/';
 figdir = 'fig/';
 matdir = 'mat/';
 
% Read Data From Excel File
idata = 1;  % Set = 1 to re-read Excel File
caschools_read_data;

% Step 1: Reorder observation in random order to eliminate any dependencies
nobs = size(varvalue,1);
tmp = rand(nobs,1);
[blank,isort] = sort(tmp);
varvalue = varvalue(isort,:);
varvalue_string = varvalue_string(isort,:);

% Step 2: Divide data into in-sample and out-of-sample observations
nobs = size(varvalue,1);
frac_insample = 1/2;
nobs_insample = ceil(frac_insample*nobs);
nobs_oos = nobs-nobs_insample;
varvalue_insample = varvalue(1:nobs_insample,:);
varvalue_oos = varvalue(nobs_insample+1:end,:);
varvalue_string_insample = varvalue_string(1:nobs_insample,:);
varvalue_string_oos = varvalue_string(nobs_insample+1:end,:);

% Save Variables
 save([matdir 'varvalue_string_insample'],'varvalue_string_insample');
 save([matdir 'varvalue_string_oos'],'varvalue_string_oos');
 save([matdir 'varvalue_insample'],'varvalue_insample');
 save([matdir 'varvalue_oos'],'varvalue_oos');
 
% Save Isort
% Print out some results
outfile_name = [outdir 'isort.csv'];
fileID = fopen(outfile_name,'w');
for i = 1:size(isort,1);
    fprintf(fileID,'%9i \n',isort(i));
end;





