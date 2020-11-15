proc transpose data=tab.tabela_final out=work.tabela_final_var;
var C_FIN1 CAE_EMPG_R_max COD_PROF_R_min INIBCHEQ_R_max med6rac1
		rac4_m12 RelSaldoDODP_Rend_PAX_M3_max TP_TRAB_R_max tplgimov txesf_ch;
run;


data list_var_R_col (keep=_name_);
set tabela_final_var;
run;

proc sql;
create table TAB.var_R_col as
select *,
case
when _NAME_='*/variaveis*/' then 'Nominal' 
when _NAME_='*/variaveis*/' then 'Ordinal'
when _NAME_='*/variaveis*/' then 'Numerica'
end as Tipologia
from list_var_R_col;
run;


data NAMES_NumericContin(rename=(_name_=name));
set tab.var_R_col;
if Tipologia='Nominal' then delete;
run;

data NAMES_NumericContin(rename=(_name_=name));
set NAMES_NumericContin;
num=_n_;
run;

Data norm_results;
	INPUT mean min p5 p95 max n nmiss median std norm pval Q1 Q3 P2_5 P97_5 P1 P99 varname $50.;
	CARDS;
run;


%macro normality(dset=,numset=);

	Data norm_results2;
		set norm_results;
	run;

	proc sql;
		select count(*) into: num from &numset.;
	quit;

	%do i=1 %to &num;

		proc sql noprint;
			select name into:variab
				from &numset.
					where num=&i;
		quit;

		PROC UNIVARIATE DATA = &dset. NORMAL;
			VAR &variab;
			OUTPUT OUT=Analise_Out
				MEAN=mean MIN=min p5=p5 p95=p95 MAX=max N=n nmiss=nmiss Median=median STD=std NORMALTEST=norm probn=pval p25=Q1 p75=Q3 pctlpts=2.5 97.5 p1=p1 p99=p99 pctlpre=P;
			HISTOGRAM / NOPLOT;
		run;

		data Analise_Out2;
			set Analise_Out;
			length varname $50;
			varname="&variab";
		run;

		

		proc append base=norm_results2 data=Analise_Out2;
		run;

		proc delete data=work.Analise_Out;

		proc delete data=work.Analise_Out2;

	
	%end;


data &dset._Norm;
	retain varname mean min p5 p95 max n nmiss median std norm pval;
	set norm_results2;
	IRQ=Q3-Q1;
	out_inf=Q1-3*IRQ;
	out_sup=Q3+3*IRQ;
	out_inf2=Q1-4*IRQ;
	out_sup2=Q3+4*IRQ;
	if out_inf<min then out_inf_c=min;
	else out_inf_c=out_inf;
	if out_inf2<min then out_inf2_c=min;
	else out_inf2_c=out_inf2;
run;

/*proc delete data=work.norm_results2;*/

%mend;



%normality(dset=tab.tabela_final,numset=NAMES_NumericContin);

proc delete data=norm_results;


data tab.tabela_final_descritiva (drop=P1 P99);
set tab.tabela_final_norm;
run;


