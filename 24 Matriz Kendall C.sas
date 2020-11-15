
/*Matriz de correlações: selecção de variáveis numéricas a categorizar  */

/*Matriz de correlações para a janela temporal de 48 meses*/
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
/* Colar lista de variáveis a testar */
    var i_incumprimento
/*VARIÁVEIS AQUI:*/




;

with i_incumprimento
/*VARIÁVEIS CATEGORIZADAS AQUI :*/

;
run;



proc export data= &dset._Kendall
dbms=xlsx
outfile= "(...)\KendallMatriz_C.xlsx" 
replace;
run;


%mend;

%correlation_matrix;




