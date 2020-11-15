%macro ano (tabela=, tipo=, i=, k=, scoring=);

proc sql;
create table contagem_&tipo. as
select count(&scoring.) as contagem_&tipo.
from &tabela.
group by &scoring.;
run; 


data Contagem_&tipo._1(rename=(Contagem_&tipo.=name&i.)); 
set contagem_&tipo. ;
num&i.=_n_;
run;


proc sql;
create table total_&tipo. as
select sum(contagem_&tipo.)
from contagem_&tipo.;
run;

data total_&tipo._n (rename=(_TEMG001=name&k.));
set total_&tipo.;
num&k.=_n_;
run;



%mend;
%ano(tabela=tab.tabela_final_c, tipo=moni, i=1, k=3, scoring=scoring );
%ano(tabela=tab.ch_cph_calib_pred_4_cpax_mut, tipo=mode, i=2, k=4, scoring=scoring_n10b);




proc delete
data=PSI;
run;


%macro psi (numset=, varset=, set=, set1=);


proc sql;
select count(*) into: num from &numset.;
quit;

proc sql;
select count(*) into: num from &varset.;
quit;



%do i=1 %to &num;
	proc sql noprint;
			select name1 into:Moni
				from &numset.
					where num1=&i;
	quit;

	proc sql noprint;
			select name2 into:Mode
				from &varset.
					where num2=&i;

proc sql noprint;
	select name3 into:Total_moni
	from &set.;
quit;


proc sql noprint;
	select name4 into:Total_mode
	from &set1.;
quit;


data Psi_&i.;
	psi=log((&mode./&Total_mode.)/(&moni./&Total_moni.))*((&mode./&Total_mode.)-(&moni./&Total_moni.)); 
	   
run;
%end;


%mend;
%psi(numset=Contagem_moni_1, varset=Contagem_mode_1, set=total_moni_n, set1=total_mode_n);


data PSI1;
set Psi_1 Psi_2 Psi_3 Psi_4 Psi_5 Psi_6 Psi_7 Psi_8 Psi_9 Psi_10;
run;


proc sql;
create table tab.PSI_model_moni as
select sum(PSI) as psi
from PSI1;
run;

