proc sort data=tab.tabela_final_c out=sort;
by scoring;
run; 

ods graphics on;
proc logistic data=sort;
	model i_incumprimento (event='1') = scoring / nofit;
	roc 'ROC' pred=scoring;
	ods select ROCcurve;
run;


ods graphics on;
PROC LOGISTIC DATA = sort PLOTS(ONLY)=ROC;
CLASS i_incumprimento;
MODEL i_incumprimento = scoring / OUTROC = ROC;
ROC ;
ODS OUTPUT ROCASSOCIATION = AUC ;
RUN;

TITLE "AUROC";

PROC PRINT DATA=AUC NOOBS LABEL;
    WHERE ROCMODEL = 'Model';
    VAR AREA;
RUN;
ods graphics off;




