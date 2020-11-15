
proc upload inlib=tab outlib=WORK;
select junta_icpt_final_n_ctto;
run; 



proc append base= PDA.junta_icpt_final_n_ctto  data=WORK.junta_icpt_final_n_ctto force;
run; 


proc sql;
create table V_TBS00021_C as
select distinct ns_exe_mtor_scrg, c_VARL_rslt_scrg, v_VARL_rslt_scrg
from ctrl.V_TBS00021
where ns_exe_mtor_scrg in (select distinct ns_exe_mtor_scrg from PDA.junta_icpt_final_n_ctto)  ;
run;


proc download inlib=WORK outlib=tab;
select V_TBS00021_C;
run; * copia tabela de aix para windows;

endrsubmit;
endrsubmit;

proc transpose data=tab.V_TBS00021_C out=V_TBS00021_T_C_aux (keep= */variaveis*/);
by ns_exe_mtor_scrg;
id c_VARL_rslt_scrg;
var v_VARL_rslt_scrg;	
run;


proc sql;
create table tab.tabela_final_aux_c as
select a.*,*/variaveis*/
from tab.tabela_final b left join V_TBS00021_T_C_aux a
on a.ns_exe_mtor_scrg=b.ns_exe_mtor_scrg;
run;

data tab.tabela_final_c (drop=c_fin1);
set tab.tabela_final_aux_c; 
if c_fin1=34 then finhc='4.000000';
if c_fin1=29 then finhc='2.000000';
run;




proc transpose data=tab.tabela_final_c out=work.variaveis_c;
var */variaveis*/;					
run;

data tab.list_var_C (keep=_name_);
set work.variaveis_c;
run;


