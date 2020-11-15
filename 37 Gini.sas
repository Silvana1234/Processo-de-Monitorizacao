proc sql;
create table AUC1 as
select area
from AUC
where ROCModel='Model';
run;

data AUC_Gini (rename=(area=AUC));
set AUC1;
Gini=2*area-1;
run;

