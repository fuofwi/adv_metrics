function [xdata_insample,xdata_oos,var_names] =   variable_setup_small(varname,varvalue_insample,varvalue_oos);
% Small Model list of variables

% List some variables
var_names_list = { ... 
'str_s' ...
'med_income_z' ...
'te_avgyr_s' ...
'exp_1000_1999_d' ...
}';

% Levels
var_names = var_names_list;
% Levels data
  xdata_insample = getvar(var_names(1),varname,varvalue_insample);
  xdata_oos = getvar(var_names(1),varname,varvalue_oos);
  for i = 2:size(var_names,1);
      x = getvar(var_names(i),varname,varvalue_insample);
      xdata_insample = [xdata_insample x];
      x = getvar(var_names(i),varname,varvalue_oos);
      xdata_oos = [xdata_oos x];
  end;

end

