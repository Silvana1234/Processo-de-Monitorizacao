


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


%discrim(dset=tab.tabela_final,numset=NAMES_NumericContin2,target=i_incumprimento);

data Analise_KW;
  retain varname;
	set disc_results2;
run;

proc delete data=work.disc_results2;
proc export data= Analise_KW
dbms=xlsx
outfile= "" 
replace;
run;




