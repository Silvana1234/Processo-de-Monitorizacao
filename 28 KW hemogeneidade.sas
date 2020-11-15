

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
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 785 /*número de registos em cada subamostra*/, s=1); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 2579 /*número de registos em cada subamostra*/, s=2); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 3419 /*número de registos em cada subamostra*/, s=3); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 4137 /*número de registos em cada subamostra*/,s=4); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 3606 /*número de registos em cada subamostra*/,s=5); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 2062 /*número de registos em cada subamostra*/,s=6); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 735/*número de registos em cada subamostra*/,s=7); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 136/*número de registos em cada subamostra*/,s=8); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 10/*número de registos em cada subamostra*/,s=9); 
%amostra(numset=tab.tabela_final_c/*amostra*/ , n= 2/*número de registos em cada subamostra*/,s=10); 





%macro amostra_scrg(dset=);
%do j=1 %to 10; 
%do k=1 %to 2;


data part_&j._&k.; 
	do sampnum= 1 to 30;
		do i=1 to nobs;				
		x=round(ranuni(0) * nobs);
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
select  count(*) as t_sampnum, sum(i_incumprimento) as soma_inc
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
%amostra_scrg(dset=tab.tabela_final_c);



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
		exact wilcoxon;
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


