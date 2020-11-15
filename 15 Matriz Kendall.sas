
/*Matriz de correlações: selecção de variáveis numéricas a categorizar  */

/*Matriz de correlações para a janela temporal de 48 meses*/
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
/* Colar lista de variáveis a testar */
    var i_incumprimento
/*VARIÁVEIS AQUI:*/



;

with i_incumprimento
/*VARIÁVEIS AQUI:*/



;
run;



proc export data= &dset._Kendall
dbms=xlsx
outfile= "\(...)\&dset._KendallMatriz.xlsx" 
replace;
run;


%mend;

%correlation_matrix;




