*========================================================;
*========================================================;
* 					All Project 2 Code
*========================================================;
*========================================================;
* Importing a csv file;
*proc import datafile = "/folders/myshortcuts/SASUniversityEdition/myfolders/Project/Project2/covid_with_delta1.csv"
	out=mydata.covid dbms=csv replace;
*run;

* Adding survival column;
*data mydata.covid_survival;
	*set mydata.covid;
	*survival = 0;
	*patient_new = 0;
	*intubed_new = 0;
	*pneumonia_new = 0;
	*icu_new=0;
		*IF date_died = '9999-99-99' then survival = 1;
		*IF patient_type = 1 then patient_new = 1;
		*IF intubed = 1 then intubed_new = 1;
		*IF pneumonia = 1 then pneumonia_new = 1;
		*IF icu = 1 then icu_new = 1;
*run;

*data mydata.covid_data;
	*set mydata.covid_survival (keep = survival patient_new intubed_new pneumonia_new icu_new time_delta age);
	*rename patient_new=patient_type intubed_new=intubed pneumonia_new=pneumonia icu_new=icu;
*run;

* EXPLORATORY DATA ANALYSIS (EDA);

*numerical and graphical summaries;
proc freq data = mydata.covid_sample;
run;

* correlation;
proc corr data = mydata.covid_sample;
	var patient_type age intubed pneumonia icu time_delta;
	with survival;
run;

* interaction plots for quant/qual variables;
proc sgplot data = mydata.covid_sample;
	vline patient_type / response = survival group = age stat = mean datalabel;
run;

proc sgplot data = mydata.covid_sample;
	vline patient_type / response = survival group = time_delta stat = mean datalabel;
run;

proc sgplot data = mydata.covid_sample;
	vline intubed / response = survival group = time_delta stat = mean datalabel;
run;

proc sgplot data = mydata.covid_sample;
	vline intubed / response = survival group = age stat = mean datalabel;
run;

proc sgplot data = mydata.covid_sample;
	vline pneumonia / response = survival group = time_delta stat = mean datalabel;
run;

proc sgplot data = mydata.covid_sample;
	vline pneumonia / response = survival group = age stat = mean datalabel;
run;

proc sgplot data = mydata.covid_sample;
	vline icu / response = survival group = age stat = mean datalabel;
run;

proc sgplot data = mydata.covid_sample;
	vline icu / response = survival group = time_delta stat = mean datalabel;
run;

* ANALYSIS SECTION;

* Stage 1 Model;
proc logistic data = mydata.covid_sample plot(only label) = (influence leverage dpc);
	model survival (event='1') = age time_delta / lackfit aggregate scale= none;
run;

proc logistic data = mydata.covid_sample plots = none;
	model survival (event='1') = age time_delta / vif;
run;


* Stage 2 Model;
proc logistic data = mydata.covid_sample plot(only label) = (influence leverage dpc);
	model survival (event='1') = age patient_type intubed pneumonia icu / lackfit aggregate scale = none;
run;

* Stage 3 Model;
data mydata.covid_final;
	set mydata.covid_sample;
	agePatient = age * patient_type;
	agePneumonia = age * pneumonia;
	ageICU = age * icu;
run;

proc logistic data = mydata.covid_final plot(only label) = (influence leverage dpc);
	model survival (event='1') = age patient_type intubed pneumonia icu agePatient agePneumonia ageICU/ lackfit aggregate scale = none;
run;

* GOODNESS-OF-FIT TEST (4.3 hosmer-lemeshow);
proc logistic data = mydata.covid_final plot(only label) = (influence leverage dpc);
	model survival (event='1') = age patient_type pneumonia icu / lackfit aggregate scale = none;
run;

* MEASURES OF ASSOCIATION (4.2 somer's d, tau-a, gamma);
proc logistic data = mydata.covid_final plot(only label) = (influence leverage dpc);
	model survival (event='1') = age patient_type pneumonia icu / lackfit aggregate scale = none;
run;

* ADDED TECHNIQUES;

* multicollinearity (3.3);
proc logistic data=mydata.covid_final plots=none;
model survival (event='1') = age patient_type pneumonia icu intubed time_delta / corrb; 
run;

* variable screening (3.3);
proc logistic data=mydata.covid_final plots=none;
model survival (event='1') = age patient_type pneumonia icu intubed time_delta/ selection=stepwise SLentry=0.05 SLstay=0.10 details; 
run;

* influential observations with diagnostic plots (4.3);
proc logistic data = mydata.covid_final plot(only label) = (influence leverage dpc);
	model survival (event='1') = age patient_type pneumonia icu / lackfit aggregate scale = none;
run;

* FINAL MODEL ASSESSMENT;
proc logistic data = mydata.covid_final plot(only label) = (influence leverage dpc);
	model survival (event='1') = age patient_type pneumonia icu / lackfit aggregate scale = none;
run;
