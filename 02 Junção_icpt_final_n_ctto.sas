
proc delete
	data=tab.invoc_ctto_hip_f_new_2018;
run;

%macro junta_mod_new_2018;

	%let month_names=jun/jul/aug/sep/oct/nov/dec;
	%do i=1 %to %sysfunc(countw(&month_names)); 
	%let month=%scan(&month_names, &i, %str(/));
	
proc append base=&tabela..invoc_ctto_hip_f_new_2018 data=&hip..invoc_ctto_hip_f_new_&month.18 force;
run;

%end;
%mend junta_mod_new_2018;
%junta_mod_new_2018;  *\8588;



proc delete
	data=tab.invoc_ctto_hip_f_new_2019;
run;
%macro junta_mod_new_2019;

%let month_names=jan/feb/mar/apr/may/jun/jul/aug/sep/oct/nov/dec;
	%do i=1 %to %sysfunc(countw(&month_names)); 
	%let month=%scan(&month_names, &i, %str(/));
	
proc append base=&tabela..invoc_ctto_hip_f_new_2019 data=&hip..invoc_ctto_hip_f_new_&month.19 force;
run;

%end;
%mend junta_mod_new_2019;
%junta_mod_new_2019; *\19458;


/******/
/*2020*/
/******/
proc delete
	data=tab.invoc_ctto_hip_f_new_2020;
run;

%macro junta_mod_new_2020;

%let month_names=jan/feb/mar/apr/may;
	%do i=1 %to %sysfunc(countw(&month_names)); 
	%let month=%scan(&month_names, &i, %str(/));
	
proc append base=&tabela..invoc_ctto_hip_f_new_2020 data=&hip..invoc_ctto_hip_f_new_&month.20 force;
run;

%end;
%mend junta_mod_new_2020; *\7019;
%junta_mod_new_2020; 






proc delete
	data=tab.invoc_ctto_hip_new_f;
run;

%macro junta_mod_new_all;

%do i=2018 %to 2020;

proc append base=&tabela..invoc_ctto_hip_new_f data=&tabela..invoc_ctto_hip_f_new_&i. force;
run;

%end;
%mend junta_mod_new_all;
%junta_mod_new_all; *35065;



proc sql;
create table tab.junta_icpt_final_n_ctto as
select distinct a.*, b.ns_exe_mtor_scrg 
from output.junta_icpt_final a left join tab.invoc_ctto_hip_new_f b 
on a.n_ctto_dw = b.n_ctto_dw;
quit;


