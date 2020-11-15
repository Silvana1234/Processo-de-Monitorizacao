
/*Matriz de correla��es: selec��o de vari�veis num�ricas a categorizar  */

/*Matriz de correla��es para a janela temporal de 48 meses*/
%macro correlation_matrix(dset=tab.tabela_final);

proc corr data = &dset.
    nomiss
	cov
	kendall
	outk=&dset._Kendall
	spearman
	outs=&dset._Spearman
	vardef=DF
;
/* Colar lista de vari�veis a testar */
    var i_incumprimento
/*VARI�VEIS AQUI:*/



;

with i_incumprimento
/*VARI�VEIS AQUI:*/



;
run;



proc export data= &dset._Kendall
dbms=xlsx
outfile= "\(...)\&dset._KendallMatriz.xlsx" 
replace;
run;


%mend;

%correlation_matrix;




