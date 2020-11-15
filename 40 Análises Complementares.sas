*/Tempo em média de entrada em incumprimento MODELIZAÇÃO;
proc sql;
create table icpt as
select *
from  tab.CH_CPH_CALIB_PRED_4_CPAX_MUT
where i_icpt=1;
run;

proc sql;
create table data as
select (dt_entd_icpt-z_inic_ctto) as data
from icpt;
run;

proc sql;
create table data1 as
select mean(data) as data
from data;
run;



*/Tempo em média de entrada em incumprimento MONITORIZAÇÃO;
proc sql;
create table data_moni as
select (dt_entra_icpt_f-z_inic_ctto) as data
from output.junta_icpt_final
where dt_entra_icpt_f <>.;
run;

proc sql;
create table data_moni as
select mean(data) as data
from data_moni;
run;







*/Verificar todas as operações dos clientes da amostra e se se observa incumprimento nalguma delas;



proc upload inlib=output outlib=WORK;
select junta_icpt_final;
run; * copia tabela de windows para aix;

proc append base= PDA.junta_icpt_final (bulkload=yes) data=WORK.junta_icpt_final force;
run; * carrega tabela temporaria;

proc sql;
create table  clientes_aux as
      select distinct a.*, b.n_cliente, b.i_tipo_itvt                                                                                       
      from PDA.junta_icpt_final a left join PDA.tdw00006 b
            on a.n_ctto_dw=b.n_ctto_dw;
quit; 
proc download inlib=WORK outlib=tab;
select clientes_aux;
run; * copia tabela de aix para windows;

endrsubmit;
endrsubmit;


proc sql;
create table clientes_tabela_final as
select *
from tab.clientes_aux 
where n_ctto_dw in (select n_ctto_dw from tab.tabela_final);
run;

proc sql;
create table clientes_tabela_final_1 as
select */variaveis*/
from clientes_tabela_final
where i_tipo_itvt=101 or i_tipo_itvt=1 ;
run;

proc sql;
create table carteira as
select *
from tab.def_quar_new
where z_dia>'04Jun2018'd and z_dia<'01Jun2020'd;
run;

proc sql;
create table clientes_tab as
select * , case when n_cliente in (select n_cliente from carteira) then 1 else 0 end as icpt
from clientes_tabela_final_1 ;
run;

proc sql;
create table clientes_tab_1 as
select n_ctto_dw, max(icpt) as icpt1
from clientes_tab
group by n_ctto_dw;
run;

proc sql;
create table tab.tabela_final_icpt as
select a.*, b.icpt1
from tab.tabela_final a left join clientes_tab_1 b
on a.n_ctto_dw=b.n_ctto_dw;
run;

proc sql;
create table tab.tabela_final_C_icpt as
select a.*, b.icpt1
from tab.tabela_final_c a left join clientes_tab_1 b
on a.n_ctto_dw=b.n_ctto_dw;
run;





*/ KRUSKAL_WALLIS;

data NAMES_NumericContin2(rename=(_name_=name));
set tab.var_R_col;
if Tipologia='Nominal' then delete;
run;

data NAMES_NumericContin2(rename=(_name_=name));
set NAMES_NumericContin2;
num=_n_;
run;


Data disc_results;
	INPUT _WIL_ Z_WIL PL_WIL PR_WIL P2_WIL PTL_WIL PTR_WIL PT2_WIL XPL_WIL XPR_WIL XP2_WIL _KW_ DF_KW P_KW varname $50.;
	CARDS;
run;



%macro discrim(dset=,numset=,target=);

proc sql;
select count(*) into: num from &numset.;
quit;

	Data disc_results2;
		set disc_results;
	run;


%do i=1 %to &num;
	proc sql noprint;
		select name into:variab
		from &numset.
		where num=&i;
	quit;

	proc npar1way data = &dset. wilcoxon correct = NO;
/*	 	exact wilcoxon / maxtime=60;*/
	 	var &variab;
	 	class  &target.;
	 	output out=dn_&variab wilcoxon;
    run;

	 data dn2_&variab;
			set dn_&variab (drop= _var_);
			length varname $50;
			varname="&variab";
		run;


	proc append base=disc_results2 data=dn2_&variab;
	run;

		proc delete data=work.dn_&variab;

		proc delete data=work.dn2_&variab;

%end;


%mend;


%discrim(dset=tab.tabela_final_icpt,numset=NAMES_NumericContin2,target=icpt1);

data Analise_KW;
  retain varname;
	set disc_results2;
run;


proc delete data=work.disc_results2;


proc export data= Analise_KW
dbms=xlsx
outfile= "KW_TODOS_ICPT.xlsx" 
replace;
run;


*/CRAMER;

data NAMES_NumericContin3(rename=(_name_=name));
set tab.var_R_col;
if Tipologia='Numerica' or Tipologia='Ordinal' then delete;
run;

data NAMES_NumericContin33(rename=(_name_=name));
set NAMES_NumericContin3;
num=_n_;
run;

Data cont_results;
	INPUT N NMISS _PCHI_ DF_PCHI P_PCHI _LRCHI_ DF_LRCHI P_LRCHI _CONTGY_ _CRAMV_ varname $50.;
	CARDS;
run;

%macro discrim(dset=,numset=,target=);

	Data cont_results2;
		set cont_results;
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

		proc freq data = &dset
			order=internal;
			tables &target.*&variab /
				norow
				nopercent
				expected
				nocum
				chisq
				scores=table;
			OUTPUT OUT=Analise_Out_dc N NMISS PCHI LRCHI contgy cramv;
		run;

		data Analise_Out_dc2;
			set Analise_Out_dc;
			length varname $50;
			varname="&variab";
		run;

		

		proc append base=cont_results2 data=Analise_Out_dc2;
		run;

		proc delete data=work.Analise_Out_dc;

		proc delete data=work.Analise_Out_dc2;
	%end;


data Cramer;
	retain varname N NMISS _PCHI_ DF_PCHI P_PCHI _LRCHI_ DF_LRCHI P_LRCHI _CONTGY_ _CRAMV_;
	set cont_results2;
run;

proc delete data=work.cont_results2;
proc export data=Cramer
dbms=xlsx
outfile= "CRAMER_T_ICPT.xlsx" 
replace;
run;

%mend;

%discrim(dset=tab.tabela_final_icpt,numset=NAMES_NumericContin33,target=icpt1);

proc delete data=work.cont_results;






*/ KENDALL;
data NAMES_NumericContin4(rename=(_name_=name));
set tab.var_R_col;
if Tipologia='Nominal' then delete;
run;

data NAMES_NumericContin44(rename=(_name_=name));
set NAMES_NumericContin4;
num=_n_;
run;

Title;

Data corr_results;
	INPUT varname $50. corr_kend pcorr_kend corr_spear pcorr_spear;
	CARDS;
run;


%macro correlation(dset=,numset=,target=);


	Data corr_results2;
		set corr_results;
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

		ods output kendallcorr=Kendcorr;
		ods output Spearmancorr=Spearcorr;

		proc corr data = &dset
			kendall 
			spearman
/*			vardef=DF*/
		;
			var &variab;
			with &target.;
		run;

		data Kendcorr_t2 (keep= varname  corr_kend pcorr_kend );
			set Kendcorr;
			length varname $50;
			varname="&variab";
			corr_kend=&variab;
			pcorr_kend=p&variab;
		run;


		data Spearcorr_t2 (keep=  varname corr_spear pcorr_spear);
			set Spearcorr;
			length varname $50;
			varname="&variab";
			corr_spear=&variab;
			pcorr_spear=p&variab;
		run;

		

		Proc sql;
			create table correl
				as select a.*, b.corr_spear , b.pcorr_spear
					from Kendcorr_t2 as a
						left join Spearcorr_t2  as b 
							on a.varname=b.varname						
		;   
		quit;


		proc append base=corr_results2 data=correl;
		run;

		proc delete data=correl;
		proc delete data=Spearcorr_t2;
		proc delete data=Kendcorr_t2;
		proc delete data=Spearcorr;
		proc delete data=Kendcorr;

	%end;

data &dset._kendal;
	set corr_results2;
run;

proc delete data=work.corr_results2;

proc export data= &dset._kendal
dbms=xlsx
outfile= "\&dset._Kendall_icpt_.xls" 
replace;
run;

%mend;




%correlation(dset=tab.tabela_final_icpt,numset=NAMES_NumericContin44,target=icpt1);


proc delete data=work.corr_results;







*/ KENDALL MATRIZ;

/*Matriz de correlações: selecção de variáveis numéricas a categorizar  */

/*Matriz de correlações para a janela temporal de 48 meses*/
%macro correlation_matrix(dset=tab.tabela_final_icpt);

proc corr data = &dset.
    nomiss
	cov
	kendall
	outk=&dset._Kendall
	spearman
	outs=&dset._Spearman
	vardef=DF
;
/* Colar lista de variáveis a testar */
    var ICPT1
/*VARIÁVEIS AQUI:*/



;

with ICPT1
/*VARIÁVEIS AQUI:*/
;
run;



proc export data= &dset._Kendall
dbms=xlsx
outfile= "\&dset._KendallMatriz_ICPT.xlsx" 
replace;
run;


%mend;

%correlation_matrix;




*/APÓS CATEGORIZAÇÃO;

data NAMES_NumericContin_C23(rename=(_name_=name));
set  tab.list_var_C;
num=_n_;
run;



Data disc_results1;
	INPUT _WIL_ Z_WIL PL_WIL PR_WIL P2_WIL PTL_WIL PTR_WIL PT2_WIL XPL_WIL XPR_WIL XP2_WIL _KW_ DF_KW P_KW varname $50.;
	CARDS;
run;



%macro discrim(dset=,numset=,target=);

proc sql;
select count(*) into: num from &numset.;
quit;

	Data disc_results21;
		set disc_results1;
	run;


%do i=1 %to &num;
	proc sql noprint;
		select name into:variab
		from &numset.
		where num=&i;
	quit;

	proc npar1way data = &dset. wilcoxon correct = NO;
/*	 	exact wilcoxon / maxtime=60;*/
	 	var &variab;
	 	class  &target.;
	 	output out=&variab wilcoxon;
    run;

	 data &variab;
			set &variab (drop= _var_);
			length varname $50;
			varname="&variab";
		run;


	proc append base=disc_results21 data=&variab force;
	run;

		proc delete data=work.&variab;

		proc delete data=work.&variab;

%end;


%mend;


%discrim(dset= tab.tabela_final_C_icpt ,numset=NAMES_NumericContin_C23,target=ICPT1);

data Analise_KW1;
  retain varname;
	set disc_results21;
run;

proc delete data=work.disc_results21;

proc export data= Analise_KW1
dbms=xlsx
outfile= "outfile\KW_ICPT_C.xlsx" 
replace;
run;






Data cont_results;
	INPUT N NMISS _PCHI_ DF_PCHI P_PCHI _LRCHI_ DF_LRCHI P_LRCHI _CONTGY_ _CRAMV_ varname $50.;
	CARDS;
run;

%macro discrim(dset=,numset=,target=);

	Data cont_results2;
		set cont_results;
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

		proc freq data = &dset
			order=internal;
			tables &target.*&variab /
				norow
				nopercent
				expected
				nocum
				chisq
				scores=table;
			OUTPUT OUT=Analise_Out_dc N NMISS PCHI LRCHI contgy cramv;
		run;

		data Analise_Out_dc2;
			set Analise_Out_dc;
			length varname $50;
			varname="&variab";
		run;

		

		proc append base=cont_results2 data=Analise_Out_dc2;
		run;

		proc delete data=work.Analise_Out_dc;

		proc delete data=work.Analise_Out_dc2;
	%end;


data &dset._dcat;
	retain varname N NMISS _PCHI_ DF_PCHI P_PCHI _LRCHI_ DF_LRCHI P_LRCHI _CONTGY_ _CRAMV_;
	set cont_results2;
run;

proc delete data=work.cont_results2;
proc export data= &dset._dcat
dbms=xlsx
outfile= "\._Cramer_ICPT_C.xlsx" 
replace;
run;

%mend;



%discrim(dset= tab.tabela_final_C_icpt,numset=NAMES_NumericContin_C23,target=ICPT1);



proc delete data=work.cont_results;







Data corr_results;
	INPUT varname $50. corr_kend pcorr_kend corr_spear pcorr_spear;
	CARDS;
run;


%macro correlation(dset=,numset=,target=);


	Data corr_results2;
		set corr_results;
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

		ods output kendallcorr=Kendcorr;
		ods output Spearmancorr=Spearcorr;

		proc corr data = &dset
			kendall 
			spearman
/*			vardef=DF*/
		;
			var &variab;
			with &target.;
		run;

		data Kendcorr_t2 (keep= varname  corr_kend pcorr_kend );
			set Kendcorr;
			length varname $50;
			varname="&variab";
			corr_kend=&variab;
			pcorr_kend=p&variab;
		run;


		data Spearcorr_t2 (keep=  varname corr_spear pcorr_spear);
			set Spearcorr;
			length varname $50;
			varname="&variab";
			corr_spear=&variab;
			pcorr_spear=p&variab;
		run;

		

		Proc sql;
			create table correl
				as select a.*, b.corr_spear , b.pcorr_spear
					from Kendcorr_t2 as a
						left join Spearcorr_t2  as b 
							on a.varname=b.varname						
		;   
		quit;


		proc append base=corr_results2 data=correl;
		run;

		proc delete data=correl;
		proc delete data=Spearcorr_t2;
		proc delete data=Kendcorr_t2;
		proc delete data=Spearcorr;
		proc delete data=Kendcorr;

	%end;

data &dset._c;
	set corr_results2;
run;

proc delete data=work.corr_results2;

proc export data= &dset._c
dbms=xlsx
outfile= "\Kendal_ICPT_C.xls" 
replace;
run;

%mend;




/*Amostra .....*/
/* Testa variáveis categorizadas*/
%correlation(dset= tab.tabela_final_C_icpt,numset=NAMES_NumericContin_C23,target=ICPT1);


proc delete data=work.corr_results;








/*Matriz de correlações: selecção de variáveis numéricas a categorizar  */

/*Matriz de correlações para a janela temporal de 48 meses*/
%macro correlation_matrix(dset=tab.tabela_final_C_icpt);

proc corr data = &dset.
    nomiss
	cov
	kendall
	outk=&dset._Kendall
	spearman
	outs=&dset._Spearman
	vardef=DF
;
/* Colar lista de variáveis a testar */
    var ICPT1
/*VARIÁVEIS AQUI:*/




;

with ICPT1
/*VARIÁVEIS AQUI:*/



;
run;



proc export data= &dset._Kendall
dbms=xlsx
outfile= "KendallMatriz_ICPT_C.xlsx" 
replace;
run;


%mend;

%correlation_matrix;






*/IC TX INCUMPRIMENTO;

%macro amostra(numset=, n=, s=);

proc sql;
select count(distinct scoring) into: num from &numset.; /*determina número de níveis de risco */
quit;

%do i=1 %to &num.;

proc sql;
create table scoring_&s. as
select *
from &numset. 
where scoring=&s.;
run;

proc sql;
select count(*) into: num1 from scoring_&s.; /*determina número de registos em cada nível de risco */
quit;

proc plan seed=230878; ;           */cria coluna com nº aleatorios para cada obs;
  factors id=&num1. /noprint; 
  output out=ID_&s.;
run;

data scoring_rand_&s.;
merge scoring_&s. id_&s.;
run;

proc sort data=scoring_rand_&s.;	
by id;
run;

%let j=%sysevalf(&num1./&n.,ceil); /*determina quantas amostras vai ter criar */
%put &j.; 
  
	%let k1=1; 
	%let k2=&n.;

	%do k=1 %to &j.;

	data scoring_&s._&k.;
	set scoring_rand_&s.(firstobs=&k1. obs=&k2.);
	run;

	%let k1=%eval(&k1.+&n.);       
	%let k2=%eval(&k2.+&n.);       

	%end;
%end;

%mend;
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 392 /*número de registos em cada subamostra*/, s=1); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 1289 /*número de registos em cada subamostra*/, s=2); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 1709 /*número de registos em cada subamostra*/, s=3); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 2068 /*número de registos em cada subamostra*/,s=4); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n=1803 /*número de registos em cada subamostra*/,s=5); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 1031 /*número de registos em cada subamostra*/,s=6); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 367/*número de registos em cada subamostra*/,s=7); 


%MACRO DO_MEAN ; 
%DO k = 1 %TO 8; 
PROC delete DATA=Scrg_amostra_&k._tx_inc; 
RUN; 
%END; 
%MEND DO_MEAN;
%do_mean;


%macro IC(k=, i=, j=, t=);

proc sql;
create table Scrg_amostra_&k._&i._tx as
select distinct scoring, sum(ICPT1)/&j. as tx_incump
from Scoring_&k._&i.
run;

proc sql;
create table Scrg_amostra_&k._tx as
select sum(ICPT1)/&t. as tx_incump
from Scoring_&k.
run;


proc append base=Scrg_amostra_&k._tx_inc data=Scrg_amostra_&k._&i._tx force;
run;

proc sql;
create table Scrg_&k._tx as
select sum(ICPT1)/&t. as tx_incump
from Scoring_&k.;
run;


%mend;
%IC(k=1,j=392,i=1,t=1571);
%IC(k=1,j=392,i=2,t=1571);
%IC(k=1,j=392,i=3,t=1571);
%IC(k=1,j=392,i=4,t=1571);
%IC(k=2,j=1289,i=1,t=5158);
%IC(k=2,j=1289,i=2,t=5158);
%IC(k=2,j=1289,i=3,t=5158);
%IC(k=2,j=1289,i=4,t=5158);
%IC(k=3,j=1709,i=1,t=6839);
%IC(k=3,j=1709,i=2,t=6839);
%IC(k=3,j=1709,i=3,t=6839);
%IC(k=3,j=1709,i=4,t=6839);
%IC(k=4,j=2068,i=1,t=8274);
%IC(k=4,j=2068,i=2,t=8274);
%IC(k=4,j=2068,i=3,t=8274);
%IC(k=4,j=2068,i=4,t=8274);
%IC(k=5,j=1803,i=1,t=7213);
%IC(k=5,j=1803,i=2,t=7213);
%IC(k=5,j=1803,i=3,t=7213);
%IC(k=5,j=1803,i=4,t=7213);
%IC(k=6,j=1031,i=1,t=4125);
%IC(k=6,j=1031,i=2,t=4125);
%IC(k=6,j=1031,i=3,t=4125);
%IC(k=6,j=1031,i=4,t=4125);
%IC(k=7,j=367,i=1,t=1471);
%IC(k=7,j=367,i=2,t=1471);
%IC(k=7,j=367,i=3,t=1471);
%IC(k=7,j=367,i=4,t=1471);



%macro tx_incump (k=, t=);

proc sql;
create table scoring_&k. as
select *
from TAB.tabela_final_C_icpt
where scoring=&k.;
run;

proc sql;
create table Scrg_&k._tx as
select sum(ICPT1)/&t. as tx_incump
from Scoring_&k.;
run;

%mend;
%tx_incump(k=8 ,t=273);
%tx_incump(k=8 ,t=273 );
%tx_incump(k=8 ,t=273 );
%tx_incump(k=8 ,t=273 );
%tx_incump(k=9 ,t=20 );
%tx_incump(k=9 ,t=20 );
%tx_incump(k=9 ,t=20 );
%tx_incump(k=9 ,t=20 );
%tx_incump(k=10 ,t=4 );
%tx_incump(k=10 ,t=4 );
%tx_incump(k=10 ,t=4 );
%tx_incump(k=10 ,t=4 );



data tx_inc_scrg ;
set Scrg_1_tx Scrg_2_tx Scrg_3_tx Scrg_4_tx Scrg_5_tx Scrg_6_tx Scrg_7_tx Scrg_8_tx Scrg_9_tx Scrg_10_tx;
run;


proc sql;
create table total_scrg as
select count(scoring) as n_scrg
from tab.tabela_final_C_icpt
group by scoring;
run;
 
data tx_inc_scrg;
set tx_inc_scrg;
num=_n_;
run;

data t_scrg;
set total_scrg;
num1=_n_;
run;

%macro IC(numset=, dset=);

%do i=1 %to 10;
	proc sql noprint;
			select tx_incump into: tx_inc
				from &numset.
					where num=&i;
	quit;

	proc sql noprint;
			select n_scrg into: total
				from &dset.
					where num1=&i;
	quit;



data IC_&i.;
lim_inf=(&tx_inc.-(quantile('normal',0.975)*sqrt(((&tx_inc.*(1-&tx_inc.))/&total.))));
lim_sup=(&tx_inc.+(quantile('normal',0.975)*sqrt(((&tx_inc.*(1-&tx_inc.))/&total.))));
if lim_inf<0 then lim_inf=0;
run;

%end;
%mend;
%IC(numset=tx_inc_scrg, dset=t_scrg);




data IC_SCRG;
set IC_1 IC_2 IC_3 IC_4 IC_5 IC_6 IC_7 IC_8 IC_9 IC_10;
run;

data IC_TX;
merge IC_SCRG tx_inc_scrg ;
run;






*/ QUI QUADRADO HOMOGENEIDADE;


%macro amostra(numset=, n=, s=);

proc sql;
select count(distinct scoring) into: num from &numset.; /*determina número de níveis de risco */
quit;

%do i=1 %to &num.;

proc sql;
create table scoring_&s._h as
select *
from &numset. 
where scoring=&s.;
run;

proc sql;
select count(*) into: num1 from scoring_&s._h; /*determina número de registos em cada nível de risco */
quit;

proc plan seed=230860; ;           */cria coluna com nº aleatorios para cada obs;
  factors id=&num1. /noprint; 
  output out=ID_&s.;
run;

data scoring_rand_&s._h;
merge scoring_&s._h id_&s.;
run;

proc sort data=scoring_rand_&s._h;	
by id;
run;

%let j=%sysevalf(&num1./&n.,ceil); /*determina quantas amostras vai ter criar */
%put &j.; 
  
	%let k1=1; 
	%let k2=&n.;

	%do k=1 %to &j.;

	data scoring_&s._&k._h;
	set scoring_rand_&s._h(firstobs=&k1. obs=&k2.);
	run;

	%let k1=%eval(&k1.+&n.);       
	%let k2=%eval(&k2.+&n.);       

	%end;
%end;

%mend;
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 785 /*número de registos em cada subamostra*/, s=1); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 2579 /*número de registos em cada subamostra*/, s=2); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 3419 /*número de registos em cada subamostra*/, s=3); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 4137 /*número de registos em cada subamostra*/,s=4); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 3606 /*número de registos em cada subamostra*/,s=5); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 2062 /*número de registos em cada subamostra*/,s=6); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 735/*número de registos em cada subamostra*/,s=7); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 136/*número de registos em cada subamostra*/,s=8); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 10/*número de registos em cada subamostra*/,s=9); 
%amostra(numset=tab.tabela_final_C_icpt/*amostra*/ , n= 2/*número de registos em cada subamostra*/,s=10); 





%macro amostra_scrg(dset=);
%do j=1 %to 10; 
%do k=1 %to 2;


data part_&j._&k.; 
	do sampnum= 1 to 30;
		do i=1 to nobs;				
		x=round(ranuni(230860) * nobs);
		set scoring_&j._&k._h
			nobs=nobs
			point=x;
		output;
	end;
end;
 stop;
run;

proc sql;
create table part_tx_&j._&k._h as
select  count(*) as t_sampnum, sum(ICPT1) as soma_inc
from part_&j._&k.
group by sampnum
;
run;


proc sql;
create table part_txinc_&j._&k._h as
select  t_sampnum, soma_inc, soma_inc/t_sampnum as tx_icpt, &k. as amostra
from part_tx_&j._&k._h;
run;



%end;
%end;
%mend;
%amostra_scrg(dset=tab.tabela_final_C_icpt);



%macro amostra_scrg(j=);

data part_txinc_&j._h as ;
set part_txinc_&j._1_h part_txinc_&j._2_h;
run;


%mend;
%amostra_scrg(j=1);
%amostra_scrg(j=2);
%amostra_scrg(j=3);
%amostra_scrg(j=4);
%amostra_scrg(j=5);
%amostra_scrg(j=6);
%amostra_scrg(j=7);
%amostra_scrg(j=8);
%amostra_scrg(j=9);
%amostra_scrg(j=10);






%macro amostra_scrg(j=);
	proc npar1way data = part_txinc_&j._h  wilcoxon correct = NO;
/*	 	exact wilcoxon / maxtime=60;*/
	 	var tx_icpt ;
	 	class amostra ;
		output out=tx_icpt wilcoxon;
    run;

%mend;
%amostra_scrg(j=1);
%amostra_scrg(j=2);
%amostra_scrg(j=3);
%amostra_scrg(j=4);
%amostra_scrg(j=5);
%amostra_scrg(j=6);
%amostra_scrg(j=7);
%amostra_scrg(j=8);
%amostra_scrg(j=9);
%amostra_scrg(j=10);




*/CHI QUADRADO HETEROGENEIDADE;

proc freq data=tab.tabela_final_C_icpt;
tables ICPT1*scoring / chisq;
run;




*/ KW HETEROGENEIDADE;

%macro amostra_scrg(dset=);

%do j=1 %to 10; 

proc sql;
create table scoring_&j. as
select *
from tab.tabela_final_C_icpt
where scoring=&j.;
run;

data part_&j.; 
	do sampnum= 1 to 30;
		do i=1 to nobs;				
		x=round(ranuni(230860) * nobs);
		set scoring_&j.
			nobs=nobs
			point=x;
		output;
	end;
end;
 stop;
run;

proc sql;
create table part_tx_&j._h as
select  count(*) as t_sampnum, sum(ICPT1) as soma_inc
from part_&j.
group by sampnum
;
run;

proc sql;
create table part_txinc_&j._h as
select  t_sampnum, soma_inc, soma_inc/t_sampnum as tx_icpt, &j. as scoring
from part_tx_&j._h;
run;

%end;
%mend;
%amostra_scrg(dset=tab.tabela_final_C_icpt);


%macro amostra_scrg(i=);
%do j=1 %to 10;
%do k=&j.+1 %to 10;
data part_txinc_&j._&k._h;
set part_txinc_&j._h part_txinc_&k._h;
run;
%end;
%end;
%mend;
%amostra_scrg(i=1);




%macro amostra_scrg(i=);
%do j=1 %to 10;
%do k=&j.+1 %to 10;
	proc npar1way data = part_txinc_&j._&k._h  wilcoxon correct = NO;
/*	 	exact wilcoxon / maxtime=60;*/
	 	var tx_icpt ;
	 	class scoring ;
    run;
%end;
%end;
%mend;
%amostra_scrg(i=1);






*/ROC;
proc sort data=tab.tabela_final_C_icpt out=sort;
by scoring;
run; 

ods graphics on;
proc logistic data=sort;
	model ICPT1 (event='1') = scoring / nofit;
	roc 'ROC' pred=scoring;
	ods select ROCcurve;
run;


*/KS DISTANCE;
proc sort data=tab.tabela_final_C_icpt out=sort;
by scoring;
run; 

proc npar1way 
	data=SORT wilcoxon edf;
    class ICPT1 ;
    var SCORING;
	output out= tabela_KS;
run;



PROC SQL;
CREATE TABLE ANALISE AS
SELECT COUNT(SCORING) AS SCRG, SUM(ICPT1) AS ICPT
FROM TAB.tabela_final_C_icpt
GROUP BY SCORING;
RUN;


*/ Tendencia  das variáveis apos categorização MONITORIZAÇÃO;
%macro Categorias_Tx(var=);
proc sql; 
create table &VAR. as
select icpt1, &var., sum(icpt1) as incump, count(&var.) as tipo
from tab.tabela_final_C_icpt
group by &var.;
run;

%mend;
%Categorias_Tx(var=);
%Categorias_Tx(var=);
%Categorias_Tx(var=);
%Categorias_Tx(var=);
%Categorias_Tx(var=);
%Categorias_Tx(var=);
%Categorias_Tx(var=);
%Categorias_Tx(var=);
%Categorias_Tx(var=);
%Categorias_Tx(var=);