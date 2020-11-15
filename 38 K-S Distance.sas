proc sort data=tab.tabela_final_c out=sort;
by scoring;
run; 

proc npar1way 
	data=SORT wilcoxon edf;
    class i_incumprimento ;
    var SCORING;
	output out= tabela_KS;
run;


