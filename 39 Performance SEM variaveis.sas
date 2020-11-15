libname mod "\\spc6001sas18\AGR6\BasileiaCGD\Silvana\Modelização";


data wtab.tabela_final_rename_c;
set tab.tabela_final_c;
*/variáveis renomeadas*/
*/ exemplo: rename CAEHC=CAE_EMPG_R_max_C;*/
run;


%macro logistic(dset=);

ods graphics on;

ods trace on;
ods output ParameterEstimates=estimates;
ods output  GlobalScore=global;
ods output ROCAssociation=roac;

/*out=modelbuildingsummary out=exactParmEST out=CLPARMWald*/

PROC LOGISTIC DATA=&dset. plots=roc outmodel=modelo1   ;
	CLASS 
*/variáveis aqui à exceção da retirada*/



			 / param = ref;


	MODEL i_icpt (event='1')= 
*/variáveis aqui à exceção da retirada*/

		/
		SELECTION=stepwise
		SLE=0.05
		SLS=0.05
		LACKFIT
		RSQUARE		
		CTABLE
		LINK=LOGIT
		CLPARM=WALD
		CLODDS=WALD
		ALPHA=0.05
		OUTROC=EGOUT_ROC_STEP_TRAIN_F ROCEPS=0.0001
	;
	roc; roccontrast;
	OUTPUT OUT=LogReg_Pred_STEP_TRAIN_F 
        PREDPROBS=INDIVIDUAL ;


/*		Scoring Base dados */
		score DATA=wtab.tabela_final_rename_c OUT=tab.tabela_final_result_new2 OUTROC=EGOUT_ROC;


RUN;
QUIT;



ods graphics off;

ods trace off;
TITLE;
%mend;

%logistic (dset= mod.CH_CPh_Filt3nm_b_t_model);






%macro logistic(dset=);

ods graphics on;

ods trace on;
ods output ParameterEstimates=estimates;
ods output  GlobalScore=global;
ods output ROCAssociation=roac;

/*out=modelbuildingsummary out=exactParmEST out=CLPARMWald*/

PROC LOGISTIC DATA=&dset. plots=roc outmodel=modelo1   ;
	CLASS 
*/variáveis aqui à exceção da retirada*/


			 / param = ref;


	MODEL i_icpt (event='1')= 
*/variáveis aqui à exceção da retirada*/


		/
		SELECTION=stepwise
		SLE=0.05
		SLS=0.05
		LACKFIT
		RSQUARE		
		CTABLE
		LINK=LOGIT
		CLPARM=WALD
		CLODDS=WALD
		ALPHA=0.05
		OUTROC=EGOUT_ROC_STEP_TRAIN_F ROCEPS=0.0001
	;
	roc; roccontrast;
	OUTPUT OUT=LogReg_Pred_STEP_TRAIN_F 
        PREDPROBS=INDIVIDUAL ;


/*		Scoring Base dados */
		score DATA=wtab.tabela_final_rename_c OUT=tab.tabela_final_result_new2 OUTROC=EGOUT_ROC;


RUN;
QUIT;



ods graphics off;

ods trace off;
TITLE;
%mend;

%logistic (dset= mod.CH_CPh_Filt3nm_b_t_model);



%macro logistic(dset=);

ods graphics on;

ods trace on;
ods output ParameterEstimates=estimates;
ods output  GlobalScore=global;
ods output ROCAssociation=roac;

/*out=modelbuildingsummary out=exactParmEST out=CLPARMWald*/

PROC LOGISTIC DATA=&dset. plots=roc outmodel=modelo1   ;
	CLASS 
*/variáveis aqui à exceção das duas variáveis retiradas*/



			 / param = ref;


	MODEL i_icpt (event='1')= 
*/variáveis aqui à exceção das duas variáveis retiradas*/



		/
		SELECTION=stepwise
		SLE=0.05
		SLS=0.05
		LACKFIT
		RSQUARE		
		CTABLE
		LINK=LOGIT
		CLPARM=WALD
		CLODDS=WALD
		ALPHA=0.05
		OUTROC=EGOUT_ROC_STEP_TRAIN_F ROCEPS=0.0001
	;
	roc; roccontrast;
	OUTPUT OUT=LogReg_Pred_STEP_TRAIN_F 
        PREDPROBS=INDIVIDUAL ;


/*		Scoring Base dados */
		score DATA=wtab.tabela_final_rename_c OUT=tab.tabela_final_result_new2 OUTROC=EGOUT_ROC;


RUN;
QUIT;



ods graphics off;

ods trace off;
TITLE;
%mend;

%logistic (dset= mod.CH_CPh_Filt3nm_b_t_model);

