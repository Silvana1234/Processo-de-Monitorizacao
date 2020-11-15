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


%discrim(dset= tab.tabela_final_c ,numset=NAMES_NumericContin_C23,target=i_incumprimento);

data Analise_KW1;
  retain varname;
	set disc_results21;
run;

proc delete data=work.disc_results21;

proc export data= Analise_KW1
dbms=xlsx
outfile= "(...)KW_C.xlsx" 
replace;
run;




