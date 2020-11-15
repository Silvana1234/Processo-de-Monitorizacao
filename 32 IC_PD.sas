*/lista com PD para cada nível de risco;
proc sql;
create table tab.score_pd as
select distinct Scoring, PD
from output.CH_CONC_MOD_NEW;
run;

proc sql;
create table PD as
select PD
from tab.score_pd;
run;

data PD_n_ (rename=(PD=name));
set PD;
num3=_n_;
run;


*/ #contratos por scoring na modelização;
proc sql;
create table scrg_total as
select count(scoring_n10b) as Contratos
from tab.CH_CPH_CALIB_PRED_4_CPAX_MUT
group by scoring_n10b;
run;

data scrg_total_n_ ;
set scrg_total;
num2=_n_;
run;





proc delete
 	data=IC_PD;
run;

%macro discrim(numset=,varset=);

proc sql;
select count(*) into: num from &numset.;
quit;

proc sql;
select count(*) into: num1 from &varset.;
quit;




%do i=1 %to &num;
	proc sql noprint;
			select name into:PD
				from &numset.
					where num3=&i;
	quit;

	proc sql noprint;
			select Contratos into:Total
				from &varset.
					where num2=&i;
	quit;


data score_pd_&i. ;
scoring=&i.;
lim_inf=(&PD.-(quantile('normal',0.975))*(sqrt(((&PD.*(1-&PD.))/&Total.))));
lim_sup=(&PD.+(quantile('normal',0.975))*(sqrt(((&PD.*(1-&PD.))/&Total.))));
if lim_inf<0 then lim_inf=0;
run;


proc append base=IC_PD data=score_pd_&i.;
run;

%end;
%mend;
%discrim(numset= PD_n_ , varset=scrg_total_n_);


data IC_PD (rename=(name=PD));
merge IC_PD PD_N_;
run;

data tab.IC_PD (drop=num3 name);
merge IC_PD;
run;
