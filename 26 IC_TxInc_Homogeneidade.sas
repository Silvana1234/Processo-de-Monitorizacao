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
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 392 /*número de registos em cada subamostra*/, s=1); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 1289 /*número de registos em cada subamostra*/, s=2); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 1709 /*número de registos em cada subamostra*/, s=3); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 2068 /*número de registos em cada subamostra*/,s=4); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n=1803 /*número de registos em cada subamostra*/,s=5); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 1031 /*número de registos em cada subamostra*/,s=6); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 367/*número de registos em cada subamostra*/,s=7); 


%MACRO DO_MEAN ; 
%DO k = 1 %TO 8; 
PROC delete DATA=wtab.Scrg_amostra_&k._tx_inc; 
RUN; 
%END; 
%MEND DO_MEAN;
%do_mean;


%macro IC(k=, i=, j=, t=);

proc sql;
create table Scrg_amostra_&k._&i._tx as
select distinct scoring, sum(i_incumprimento)/&j. as tx_incump
from Scoring_&k._&i.
run;

proc sql;
create table Scrg_amostra_&k._tx as
select sum(i_incumprimento)/&t. as tx_incump
from Scoring_&k.
run;


proc append base=wtab.Scrg_amostra_&k._tx_inc data=Scrg_amostra_&k._&i._tx force;
run;

proc sql;
create table Scrg_&k._tx as
select sum(i_incumprimento)/&t. as tx_incump
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
from tab.tabela_final_c
where scoring=&k.;
run;

proc sql;
create table Scrg_&k._tx as
select sum(i_incumprimento)/&t. as tx_incump
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



data wtab.tx_inc_scrg ;
set Scrg_1_tx Scrg_2_tx Scrg_3_tx Scrg_4_tx Scrg_5_tx Scrg_6_tx Scrg_7_tx Scrg_8_tx Scrg_9_tx Scrg_10_tx;
run;


proc sql;
create table total_scrg as
select count(scoring) as n_scrg
from tab.tabela_final
group by scoring;
run;
 
data tx_inc_scrg;
set wtab.tx_inc_scrg;
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




data wtab.IC_SCRG;
set IC_1 IC_2 IC_3 IC_4 IC_5 IC_6 IC_7 IC_8 IC_9 IC_10;
run;

data tab.IC_TX;
merge wtab.IC_SCRG wtab.tx_inc_scrg ;
run;
