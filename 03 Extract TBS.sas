proc upload inlib=tab outlib=WORK;
select junta_icpt_final_n_ctto;
run; 


proc append base= PDA.junta_icpt_final_n_ctto  data=WORK.junta_icpt_final_n_ctto force;
run; 


proc sql;
create table V_TBS00020 as
select distinct ns_exe_mtor_scrg, m_rspe_cgd, ts_criacao
from ctrl.V_TBS00020
where ns_exe_mtor_scrg in (select distinct ns_exe_mtor_scrg from PDA.junta_icpt_final_n_ctto);
run;


proc download inlib=WORK outlib=tab;
select V_TBS00020;
run; * copia tabela de aix para windows;

endrsubmit;
endrsubmit;



proc sql;
create table WORK.V_TBS00017 as
      select distinct *
      from CTRL.V_TBS00017 
            where ns_exe_mtor_scrg in (select distinct ns_exe_mtor_scrg from PDA.junta_icpt_final_n_ctto);
quit; 

proc sql;
create table WORK.V_TBS00019 as
      select distinct *
      from CTRL.V_TBS00019
       where ns_exe_mtor_scrg>=16331534 and ns_exe_mtor_scrg in (select distinct ns_exe_mtor_scrg from PDA.junta_icpt_final_n_ctto);
quit; * cruza tabelas e devolve resultado para sas;

proc sql;
create table V_TBS00022_score as
select distinct ns_exe_mtor_scrg, c_mtor_scrg, v_pntz_calc_scrg, c_scoring, ts_criacao
from ctrl.V_TBS00022
where c_mtor_scrg=131 and  ns_exe_mtor_scrg in (select distinct ns_exe_mtor_scrg from PDA.junta_icpt_final_n_ctto);
run;


proc download inlib=WORK outlib=tab;
select V_TBS00019 ;
run

* copia tabela de windows para aix;

* carrega tabela temporaria;


* cruza tabelas e devolve resultado para sas;

