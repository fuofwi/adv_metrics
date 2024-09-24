% Read Data for California Schools

if idata == 1;
 % Read in Data, Variable Names, and Descriptors
 xlsname = '../data/ca_school_testscore.xlsx';
 % String Variables
 [blank, varname_string] = xlsread(xlsname,'Sheet1','A1:C1');
 [blank, varlabel_string] = xlsread(xlsname,'Sheet1','A2:C2');
 [blank, varvalue_string] = xlsread(xlsname,'Sheet1','A3:C4056');
 varname_string = varname_string';
 varlabel_string = varlabel_string';

 % Numberic Variables
 [blank, varname] = xlsread(xlsname,'Sheet1','D1:DF1');
 [blank, varlabel] = xlsread(xlsname,'Sheet1','D2:DF2');
 [varvalue,blank] = xlsread(xlsname,'Sheet1','D3:DF4056');
 varname = varname';
 varlabel = varlabel'; 

 % Save these
 save([matdir 'varname_string'],'varname_string');
 save([matdir 'varlabel_string'],'varlabel_string');
 save([matdir 'varvalue_string'],'varvalue_string');
 save([matdir 'varname'],'varname');
 save([matdir 'varlabel'],'varlabel');
 save([matdir 'varvalue'],'varvalue');
end;

load([matdir 'varname_string']);
load([matdir 'varlabel_string']);
load([matdir 'varvalue_string']);
load([matdir 'varname']);
load([matdir 'varlabel']);
load([matdir 'varvalue']);