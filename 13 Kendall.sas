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
outfile= "(...)&dset._KendallTeste_.xls" 
replace;
run;

%mend;




%correlation(dset=tab.tabela_final,numset=NAMES_NumericContin44,target=i_incumprimento);


proc delete data=work.corr_results;



