*/foram retiradas as variáveis*/
rsubmit; options compress=yes;
proc sql;
      create table wtab.TBS00017_aux as
            select *,
            Case
                  when C_VARL_ELMR_SCRG not in (*/variaveis*/) and 
                  X_VAL_VARL_ELMR='' and I_VAL_MISS='N' then put(*/variaveis*/,best32.)
                  when C_VARL_ELMR_SCRG not in (*/variaveis*/) and 
                  X_VAL_VARL_ELMR='' and I_VAL_MISS='S' then ''
                  when C_VARL_ELMR_SCRG in (*/variaveis*/) and 
                  I_VAL_MISS='N' then X_VAL_VARL_ELMR
				  else ''
                  end as Valor
            from tab.V_TBS00017 (where=(*/variaveis*/ not in ('VAL-AVAL' 'VAL-AQUI')))
				order by NS_EXE_MTOR_SCRG;
quit;
endrsubmit; 

rsubmit; options compress=yes;
proc sort data=wtab.TBS00017_aux;
by NS_EXE_MTOR_SCRG ;
run;

proc transpose data=wtab.TBS00017_aux out=wtab.TBS00017_aux_t (drop=_name_);
by NS_EXE_MTOR_SCRG ;
id C_VARL_ELMR_SCRG;
var Valor;
run; 
endrsubmit;

rsubmit; options compress=yes;


proc sql;
create table tab.TBS00017_t  as
select distinct NS_EXE_MTOR_SCRG, 
input(*/variavel*/, best32.) as */variavel*/
input(*/variavel*/, best32.) as */variavel*/
input(*/variavel*/, best32.) as */variavel*/;
input(*/variavel*/, best32.) as */variavel*/;
input(*/variavel*/, best32.) as */variavel*/:
input(*/variavel*/, best32.) as */variavel*/;
input(*/variavel*/, best32.) as */variavel*/;
input(*/variavel*/, best32.) as */variavel*/;
input(*/variavel*/, best32.) as */variavel*/;
input(*/variavel*/, best32.) as */variavel*/;
input(*/variavel*/, best32.) as */variavel*/;
input(*/variavel*/, best32.) as */variavel*/;
input(*/variavel*/, best32.) as */variavel*/;
*/variaveis*/

from wtab.TBS00017_aux_t;
quit;
endrsubmit;
 
rsubmit; options compress=yes;
proc sql;
      create table wtab.TBS00019_aux as
            select *,
            Case
                  when C_VARL_ELMR_SCRG not in (*/variaveis*/) and X_VAL_VARL_ELMR='' and I_VAL_MISS='N' then put(V_VARL_ELMR_SCRG,best32.)
                  when C_VARL_ELMR_SCRG not in (*/variaveis*/') and X_VAL_VARL_ELMR='' and I_VAL_MISS='S' then ''
                  when C_VARL_ELMR_SCRG in (*/variavel*/) and I_VAL_MISS='N' then X_VAL_VARL_ELMR
                  else ''
                  end as Valor
            from tab.V_TBS00019
				order by NS_EXE_MTOR_SCRG;
quit;
endrsubmit; 



rsubmit; options compress=yes;
proc sort data=wtab.TBS00019_aux;
by NS_EXE_MTOR_SCRG NS_REG_ITVT ;
run;


proc transpose data=wtab.TBS00019_aux out=wtab.TBS00019_aux_t (drop=_name_);
by NS_EXE_MTOR_SCRG NS_REG_ITVT ;
id C_VARL_ELMR_SCRG;
var Valor;
run; 
endrsubmit;

rsubmit; options compress=yes;
proc sql;
create table tab.TBS00019_T_N   as
select distinct NS_EXE_MTOR_SCRG, NS_REG_ITVT,
input(*/variavel*/,best32.) as */variavel*/,
*/(...)*/
*/variaveis*/

from wtab.TBS00019_aux_t;
quit;  
endrsubmit;

rsubmit; options compress=yes;
proc sql;
create table tab.TBS00019_T_N  as
select distinct NS_EXE_MTOR_SCRG, NS_REG_ITVT,
input(*/variavel*/,best32.) as */variavel*/,
*/(...)*/
*/variaveis*/
from wtab.TBS00019_aux_t;
quit;  
endrsubmit;


/* Junta variáves proposta necessário para cálculo tx_esforço + resto variáveis que entram no modelo*/
rsubmit; options compress=yes;
proc sql;
create table wtab.TBS00019_T1  as
	select distinct a.* , */seleçao de variáveis para contrução de variáveis finais do modelo*/
		from tab.TBS00019_T_N a	left join tab.TBS00017_T b
			on a.ns_exe_mtor_scrg=b.ns_exe_mtor_scrg;
quit;
endrsubmit;


rsubmit;options compress=yes;
proc sql;
create table  wtab.TBS00019_T2 as
	select distinct * , sum(*/variáveis*/) as PRSTOT_E,
	(*/Construção da variaveis*/) as DODPRND3
	from wtab.TBS00019_T1;
quit;
endrsubmit;

rsubmit;options compress=yes;
proc sql;
create table wtab.TBS00019_T3 as
	select distinct */variaveis*/
	from wtab.TBS00019_T2
			;
quit;
endrsubmit;

*/código de categorização da instituição cofidencial/*


rsubmit;options compress=yes;
proc sql;
create table wtab.TBS00019_T7 as
	select distinct *,
				sum(*/construção da variavel*/) as TXESF_CH
		from wtab.TBS00019_T6;
quit;
endrsubmit;

rsubmit;options compress=yes;
data wtab.TBS00019_T8 (keep=*/variaveis*/);
set wtab.TBS00019_T7;
run;
endrsubmit;