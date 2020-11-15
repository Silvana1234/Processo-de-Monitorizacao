
proc freq data=tab.tabela_final_c;
tables i_incumprimento*scoring / chisq;
run;

