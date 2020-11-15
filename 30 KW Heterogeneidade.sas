
%macro amostra_scrg(dset=);

%do j=1 %to 10; 

proc sql;
create table scoring_&j. as
select *
from tab.tabela_final_c
where scoring=&j.;
run;

data part_&j.; 
	do sampnum= 1 to 30;
		do i=1 to nobs;				
		x=round(ranuni(0) * nobs);
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
select  count(*) as t_sampnum, sum(i_incumprimento) as soma_inc
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
%amostra_scrg(dset=tab.tabela_final_c);


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
