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


data &dset._Cramer;
	retain varname N NMISS _PCHI_ DF_PCHI P_PCHI _LRCHI_ DF_LRCHI P_LRCHI _CONTGY_ _CRAMV_;
	set cont_results2;
run;

proc delete data=work.cont_results2;
proc export data= &dset._Cramer
dbms=xlsx
outfile= "(...)&dset._Cramer.xlsx" 
replace;
run;

%mend;

%discrim(dset=tab.tabela_final,numset=NAMES_NumericContin33,target=i_incumprimento);

proc delete data=work.cont_results;

