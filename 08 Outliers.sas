Data results;
	INPUT ctup ctdn varname $50.;
	CARDS;
run;

data NAMES_NumericContin1(rename=(_name_=name));
set tab.var_R_col;
if Tipologia='Nominal' or Tipologia='Ordinal' then delete;
run;

data NAMES_NumericContin1(rename=(_name_=name));
set NAMES_NumericContin1;
num=_n_;
run;


%macro outliers(dset=,numset=,Outlimtset=);


	Data results1;
		set results;
	run;

	Data results2;
		set results;
	run;


	data outset;
		set &dset.;	
	run;

	data outset2;
		set &dset.;	
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

/*	Para usar percentil 2.5 e percentil 97.5	*/
		data limites (where=(varname="&variab"));
			set &Outlimtset. (keep= varname p2_5 p97_5);
		run;	


		proc sql noprint; 
			select p97_5 into :upper_limit 
				from limites;
		quit;

		proc sql noprint; 
			select p2_5 into :lower_limit 
				from limites;
		quit;



/*	Para usar distancia interquartil	*/
		data limites (where=(varname="&variab"));
			set &Outlimtset. (keep= varname out_inf2_c out_sup2);
		run;	


		proc sql noprint; 
			select out_sup2 into :upper_limit2 
				from limites;
		quit;

		proc sql noprint; 
			select out_inf2_c  into :lower_limit2 
				from limites;
		quit;


/*Correccao com percentil	*/

		data outset;
			set outset;
			retain u&variab. 0;
			if &variab > &upper_limit then do;
				&variab=&upper_limit;
				u&variab.+1;
			end;
			retain d&variab. 0;
			if not missing(&variab) and &variab < &lower_limit then do;
				&variab=&lower_limit;
				d&variab.+1;
			end;

		run;


			data add1 ;
				set outset (keep= u&variab. d&variab.) nobs=nobs;
				if _n_=nobs then keep=1;
				if keep ne 1 then delete;
				drop keep;
				length varname $50;
				varname="&variab";
				rename u&variab.=ctup  
					d&variab.=ctdn;
			run;


			proc append base=results1 data=add1;
			run;

			proc delete data=work.add1;


			data outset;
				set outset;
				drop u&variab. d&variab.;
			run;



/*Correccao com distancia interquartil	*/
		data outset2;
			set outset2;
			retain u&variab. 0;
			if &variab > &upper_limit2 then do;
				&variab=&upper_limit2;
				u&variab.+1;
			end;
			retain d&variab. 0;
			if not missing(&variab) and &variab < &lower_limit2 then do;
				&variab=&lower_limit2;
				d&variab.+1;
			end;

		run;


			data add1 ;
				set outset2 (keep= u&variab. d&variab.) nobs=nobs;
				if _n_=nobs then keep=1;
				if keep ne 1 then delete;
				drop keep;
				length varname $50;
				varname="&variab";
				rename u&variab.=ctup  
					d&variab.=ctdn;
			run;


			proc append base=results2 data=add1;
			run;

			proc delete data=work.add1;

			data outset2;
				set outset2;
				drop u&variab. d&variab.;
			run;


	%end;

	data &dset._Corr_Outl1;
		set outset;	
	run;

	data &dset._Corr_Outl2;
		set outset2;	
	run;

			data results2;
			retain varname;
				set results2;

			run;

		   data results1;
		   retain varname;
				set results1;
				
			run;



%mend;


%outliers(dset=tab.tabela_final,numset=NAMES_NumericContin1,Outlimtset=tab.tabela_final_NORM);


proc export data= results1
dbms=xlsx
outfile= "\TBS00019_T9_CorrOut_count_percentil.xlsx" 
replace;
run;

proc export data= results2
dbms=xlsx
outfile= "TBS00019_T9_CorrOut_count_interquartil.xlsx" 
replace;
run;
