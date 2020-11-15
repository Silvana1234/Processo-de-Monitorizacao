
%macro ano (ano= , data_ini= , data_fim=);

proc sql;
create table ano_monitorizacao_&ano. as
select *
from tab.Tabela_final_c
where &data_ini.<=z_inic_ctto<=&data_fim.;
run;

proc sql;
create table ano_monitorizacao_&ano._scrg as
select count(scoring) as Total_scoring
from ano_monitorizacao_&ano.
group by scoring;
run;


data ano_monitorizacao_&ano._scrg_n_(rename=(Total_scoring=name1)); 
set ano_monitorizacao_&ano._scrg ;
num1=_n_;
run;

proc sql;
create table total_ano_monitorizacao_&ano. as
select sum(name1)
from ano_monitorizacao_&ano._scrg_n_;
run; 
%mend;
%ano(ano=2018, data_ini='04JUN2018'd , data_fim='03JUN2019'd);
%ano(ano=2019, data_ini='04JUN2019'd , data_fim='03JUN2020'd); 





%macro ano (ano= , data_ini= , data_fim=);

proc sql;
create table ano_modelizacao_&ano. as
select *
from tab.ch_cph_calib_pred_4_cpax_mut
where &data_ini.<=z_inic_ctto<=&data_fim.;
run;

proc sql;
create table ano_modelizacao_&ano._scrg as
select count(scoring_n10b) as Total_scoring
from ano_modelizacao_&ano.
group by scoring_n10b;
run;


data ano_modelizacao_&ano._scrg_n_(rename=(Total_scoring=name2)); 
set ano_modelizacao_&ano._scrg ;
num2=_n_;
run;

proc sql;
create table total_ano_modelizacao_&ano. as
select sum(name2)
from ano_modelizacao_&ano._scrg_n_;
run; 

%mend;
%ano(ano=2009, data_ini='04JUN2009'd , data_fim='03JUN2010'd);
%ano(ano=2010, data_ini='04JUN2010'd , data_fim='03JUN2011'd);
%ano(ano=2011, data_ini='04JUN2011'd , data_fim='03JUN2012'd);
%ano(ano=2012, data_ini='04JUN2012'd , data_fim='03JUN2013'd);
%ano(ano=2013, data_ini='04JUN2013'd , data_fim='03JUN2014'd);
%ano(ano=2014, data_ini='04JUN2014'd , data_fim='03JUN2015'd);
%ano(ano=2015, data_ini='04JUN2015'd , data_fim='03JUN2016'd);




%macro psi (numset=, varset=, set=, set1=, ano1= , ano2= );

proc sql;
select count(*) into: num from &numset.;
quit;

%do i=1 %to &num;
proc delete 
data=PSI1;
run;

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
	select _TEMG001 into:Total_moni
	from &set.;
quit;


proc sql noprint;
	select _TEMG001 into:Total_mode
	from &set1.;
quit;


data Psi_&i._&ano1._&ano2.;
	psi=log((&Moni./&Total_moni.)/(&Mode./&Total_mode.))*((&Moni./&Total_moni.)-(&Mode./&Total_mode.)); 
	   
run;

proc append base=PSI1 data=Psi_&i._&ano1._&ano2. force;
run;

%end;


proc sql;
create table PSI_&ano1._&ano2. as
select "&ano1._&ano2." as Ano,  sum(PSI) as Psi
from PSI1;
run;


proc append base=PSI_MONiano_MODEano data=PSI_&ano1._&ano2. force;
run;


%mend;



%psi(numset=ano_monitorizacao_2018_scrg_n_, varset=ano_modelizacao_2009_scrg_n_, set=total_ano_monitorizacao_2018, set1=total_ano_modelizacao_2009, ano1=2018, ano2=2009);
%psi(numset=ano_monitorizacao_2018_scrg_n_, varset=ano_modelizacao_2010_scrg_n_, set=total_ano_monitorizacao_2018, set1=total_ano_modelizacao_2010, ano1=2018, ano2=2010);
%psi(numset=ano_monitorizacao_2018_scrg_n_, varset=ano_modelizacao_2011_scrg_n_, set=total_ano_monitorizacao_2018, set1=total_ano_modelizacao_2011, ano1=2018, ano2=2011);
%psi(numset=ano_monitorizacao_2018_scrg_n_, varset=ano_modelizacao_2012_scrg_n_, set=total_ano_monitorizacao_2018, set1=total_ano_modelizacao_2012, ano1=2018, ano2=2012);
%psi(numset=ano_monitorizacao_2018_scrg_n_, varset=ano_modelizacao_2013_scrg_n_, set=total_ano_monitorizacao_2018, set1=total_ano_modelizacao_2013, ano1=2018, ano2=2013);
%psi(numset=ano_monitorizacao_2018_scrg_n_, varset=ano_modelizacao_2014_scrg_n_, set=total_ano_monitorizacao_2018, set1=total_ano_modelizacao_2014, ano1=2018, ano2=2014);
%psi(numset=ano_monitorizacao_2018_scrg_n_, varset=ano_modelizacao_2015_scrg_n_, set=total_ano_monitorizacao_2018, set1=total_ano_modelizacao_2015, ano1=2018, ano2=2015);

%psi(numset=ano_monitorizacao_2019_scrg_n_, varset=ano_modelizacao_2009_scrg_n_, set=total_ano_monitorizacao_2019, set1=total_ano_modelizacao_2009, ano1=2019, ano2=2009);
%psi(numset=ano_monitorizacao_2019_scrg_n_, varset=ano_modelizacao_2010_scrg_n_, set=total_ano_monitorizacao_2019, set1=total_ano_modelizacao_2010, ano1=2019, ano2=2010);
%psi(numset=ano_monitorizacao_2019_scrg_n_, varset=ano_modelizacao_2011_scrg_n_, set=total_ano_monitorizacao_2019, set1=total_ano_modelizacao_2011, ano1=2019, ano2=2011);
%psi(numset=ano_monitorizacao_2019_scrg_n_, varset=ano_modelizacao_2012_scrg_n_, set=total_ano_monitorizacao_2019, set1=total_ano_modelizacao_2012, ano1=2019, ano2=2012);
%psi(numset=ano_monitorizacao_2019_scrg_n_, varset=ano_modelizacao_2013_scrg_n_, set=total_ano_monitorizacao_2019, set1=total_ano_modelizacao_2013, ano1=2019, ano2=2013);
%psi(numset=ano_monitorizacao_2019_scrg_n_, varset=ano_modelizacao_2014_scrg_n_, set=total_ano_monitorizacao_2019, set1=total_ano_modelizacao_2014, ano1=2019, ano2=2014);
%psi(numset=ano_monitorizacao_2019_scrg_n_, varset=ano_modelizacao_2015_scrg_n_, set=total_ano_monitorizacao_2019, set1=total_ano_modelizacao_2015, ano1=2019, ano2=2015);





