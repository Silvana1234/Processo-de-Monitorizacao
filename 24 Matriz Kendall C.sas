
/*Matriz de correla��es: selec��o de vari�veis num�ricas a categorizar  */

/*Matriz de correla��es para a janela temporal de 48 meses*/
%macro correlation_matrix(dset=tab.tabela_final_c);

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
/*VARI�VEIS CATEGORIZADAS AQUI :*/

;
run;



proc export data= &dset._Kendall
dbms=xlsx
outfile= "(...)\KendallMatriz_C.xlsx" 
replace;
run;


%mend;

%correlation_matrix;




