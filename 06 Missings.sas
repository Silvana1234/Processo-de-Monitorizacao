*Análise de Missings e zeros de cada variável;
/************************** Missing count **************************/
data tabela_final_1 (drop=*/variaveis*/);
set tab.tabela_final;
run;
	
	

proc contents noprint data =tabela_final_1 out=Lista_Var_Missings (keep=name type varnum);
run;

proc sql noprint;
     select count (name) into: dscnt
          from Lista_Var_Missings;
     %let dscnt=%trim(&dscnt);
     select name into: var1 -: var&dscnt
          from Lista_Var_Missings;
quit;

%put &dscnt;

%macro fac;

     proc sql;
          create table missing_count as 
                select

                %do i=1 %to &dscnt.;
                     count("&&var&i"n) as "&&var&i"n,
                %end;

          count(*) as TOTAL 
          from   tabela_final_1  
     quit;

%mend fac;

%fac;

proc transpose data=missing_count out=missing_count_temp;
run;

proc sql;
     create table tab_missing as 
          select    a._NAME_ as factor,
                a.COL1 as non_miss, 
                b.TOTAL as TOTAL,
                (1-(non_miss / total))*100 as miss_rate
          from missing_count_temp as a, missing_count as b
                order by factor;
quit;

/************************** Zero count **************************/
proc contents data= tabela_final_1     out=Lista_Variaveis_Zeros(keep=name type varnum) noprint;
run;

proc sort data=Lista_Variaveis_Zeros;
     by varnum;
run;

proc sql noprint;
     select count (name) into: dscnt
          from Lista_Variaveis_Zeros;
     %let dscnt=%trim(&dscnt);
     select name into: name1 -: name&dscnt
          from Lista_Variaveis_Zeros;
     select type into: var_type1 -: var_type&dscnt
          from Lista_Variaveis_Zeros;
quit;

%macro zero_count;

     data zeros_missings_rep;
          set   tabela_final_1  ;

          %do i = 1 %to &dscnt.;
                %if &&var_type&i.=2 %then
                     %do;
                          if &&name&i.="" then
                               &&name&i.="9999";

                          if &&name&i.="0" then
                               &&name&i.="";
                     %end;
                %else %if &&var_type&i.=1 %then
                     %do;
                          if &&name&i.=. then
                               &&name&i.=9999;

                          if &&name&i.=0 then
                               &&name&i.=.;
                     %end;
          %end;
     run;

     proc sql;
          create table zero_missings
                as select

                %do i=1 %to &dscnt.;
                     count("&&name&i"n) as "&&name&i"n,
                %end;

          count(*) as TOTAL from zeros_missings_rep;
     quit;

%mend zero_count;

%zero_count;

proc transpose data=zero_missings out=zero_missings_temp;
run;

proc sql;
     create table tab_zero as 
          select    a._NAME_ as factor,
                a.COL1 as non_zero, 
                b.TOTAL as TOTAL,
                (1-(non_zero / total))*100 as zero_rate
          from zero_missings_temp as a, zero_missings as b
                order by factor;
quit;

Proc sql;
     create table Missing_Results
          as select a.*, b.non_zero, b.zero_rate
                from tab_missing as a
                     left join tab_zero as b 
                          on a.factor=b.factor

     ;
quit;

data TAB.Missings_zeros (drop=ns_exe_mtor_scrg);
     retain factor TOTAL;
          set Missing_Results;

          if factor='TOTAL' then
                delete;
run;
