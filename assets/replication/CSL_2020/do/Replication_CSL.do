clear all
set more off
set matsize 10000

local table_results "../Results/Tables" /* WHERE TO EXPORT TABLES, CHANGE THIS IF WANTED TO CHANGE DIRECTORY */

* Importing Master Database

use ../Data/dta/prices, clear

log using ../Results/output/output, replace text

* Log Prices and CPI

g log_p = ln(p)
g log_ipc = ln(ipc)

* CREATING INFLATION MEASURES

sort code date

by code: gen infp = log_p - L1.log_p
by code: gen inf_m = log_ipc - L1.log_ipc

* CONSTRUCTING PRODUCT VERSION OF RPV.

tssmooth ma infpsmooth=infp, window(11 1 0)
replace infpsmooth=. if tin(1968m1, 1968m12)
by code: gen cv_s = (infp - inf_m)^2
tssmooth ma cv=cv_s, window(11 1 0)
replace cv=. if tin(1968m1, 1968m12)
replace cv=sqrt(cv/(1+inf_m)^2)
gen synth_cv = cv*synthetic_weight

* AGGREGATE LEVEL INFLATION

g inf_a = log_ipc - L12.log_ipc
by code: gen infp12 = log_p - L12.log_p

g synth_inf_a = infp12*synthetic_weight

* ADDING INFLATION LOADS

bys date: egen sinf_a = sum(synth_inf_a)

sort code date

foreach a in pcu imacec {
g log_`a' = ln(`a')
by code: g g`a'_a = log_`a' - L.log_`a'

}


/*********************************************************************************************************************
*********************************** ESTIMATION RESULTS ***************************************************************
*********************************************************************************************************************/

local time_span "if tin(1970m1,1982m5)"

/* A. AGGREGATE LEVEL RESULTS */

* CLASSIC RPV (Parks (1979), Fischer (1981), and many others in the literature)

g classic_rpv_m = synthetic_weight*(infp - inf_m)^2  

preserve

collapse (sum) classic_rpv_m synth_inf_a (mean) inf_a inf_m gimacec_a gpcu_a year month, by(date)

corr synth_inf_a inf_a if tin(1970m1,1982m5)

* Caraballo and Dabus Definition (To account for increasing mean over time)

g cd_rpv_m = classic_rpv_m/(1+inf_m)^2 

g linf_a = ln(1+inf_a)


g free_73 = 0
replace free_73 = 1 if tin(1973m10, 1976m12)

g free_77 = 0
replace free_77 = 1 if tin(1977m1, 2005m12)

g free73_inf_a = free_73*inf_a
g free77_inf_a = free_77*inf_a

g free73_linf_a = linf_a*free_73
g free77_linf_a = linf_a*free_77


g t = _n
tsset date, m

g lclassicrpvm = L.classic_rpv_m
g lcdrpv = L.cd_rpv_m

label var inf_a "Annual Inflation ($\vspace{0pt}\pi^a_t$)"
label var free_73 "Liberalization in 1973 ($\vspace{0pt}D^{73}_t$)"
label var free_77 "Liberalization in 1977 ($\vspace{0pt}D^{77}_t$)"
label var free73_inf_a "$\vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}\times \vspace{0pt}\pi^a_t$"
label var free77_inf_a "$\vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt}\times \vspace{0pt}\pi^a_t$"
lab var linf_a "log(1+$\vspace{0pt}\pi^a_t$)"
lab var free73_linf_a "$\vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}\times \log(1+\vspace{0pt}\pi^a_t)$"
lab var free77_linf_a "$\vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt}\times \log(1+\vspace{0pt}\pi^a_t)$"
lab var lclassicrpvm "Lagged RPV"	
lab var lcdrpv "Lagged RPV"	


*********************************************** Aggregate Results *********************************************
	
* Period 1967m1 - 1979m5
local time_span2 "if tin(1970m1,1982m5)"

** TABLE 1. CLASSIC MEASURE 1970 - 1982

tempvar d73 d77


reg classic_rpv_m inf_a lclassicrpvm `time_span2', vce(r)
outreg2 using `table_results'/Table1.tex, replace bdec(3) sdec(2) tex(fragment) label ///
		keep(inf_a lclassicrpvm) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar


reg classic_rpv_m inf_a free73_inf_a free77_inf_a lclassicrpvm `time_span2', vce(r)
outreg2 using `table_results'/Table1.tex, append bdec(3) sdec(2) tex(fragment) label ///
		keep(inf_a free73_inf_a free77_inf_a lclassicrpvm) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar

reg classic_rpv_m inf_a free73_inf_a free77_inf_a gimacec_a gpcu_a lclassicrpvm `time_span2', vce(r)
outreg2 using `table_results'/Table1.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Macroeconomic Control Variables, \checkmark) keep(inf_a free73_inf_a free77_inf_a lclassicrpvm) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar

		

** TABLE 2. CARABALLO - DABUS MEASURE 1970 - 1982	
		
			
reg cd_rpv_m inf_a lcdrpv `time_span2', vce(r)
outreg2 using `table_results'/Table2.tex, replace bdec(3) sdec(2) tex(fragment) label ///
		keep(inf_a lcdrpv) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar

reg cd_rpv_m inf_a free73_inf_a free77_inf_a lcdrpv `time_span2', vce(r)
outreg2 using `table_results'/Table2.tex, append bdec(3) sdec(2) tex(fragment) label ///
		keep(inf_a free73_inf_a free77_inf_a lcdrpv) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar

reg cd_rpv_m inf_a free73_inf_a free77_inf_a gimacec_a gpcu_a lcdrpv `time_span2', vce(r)
outreg2 using `table_results'/Table2.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Macroeconomic Control Variables, \checkmark) keep(inf_a free73_inf_a free77_inf_a lcdrpv) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar
		

* TABLE 3. USING LOG INFLATION  

reg classic_rpv_m linf_a free73_linf_a free77_linf_a lclassicrpvm `time_span2', vce(r)
outreg2 using `table_results'/Table3.tex, replace bdec(3) sdec(2) tex(fragment) label ///
		addtext( ) keep(linf_a free73_linf_a free77_linf_a lclassicrpvm) ///
		ctitle("Classic") nocons nonotes nor2 noni nodepvar


reg classic_rpv_m linf_a free73_linf_a free77_linf_a gimacec_a gpcu_a lclassicrpvm `time_span2', vce(r)
outreg2 using `table_results'/Table3.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Macroeconomic Control Variables, \checkmark) keep(linf_a free73_linf_a free77_linf_a lclassicrpvm) ///
		ctitle("Classic") nocons nonotes nor2 noni nodepvar
		
reg cd_rpv_m linf_a free73_linf_a free77_linf_a lcdrpv `time_span2', vce(r)
outreg2 using `table_results'/Table3.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext() keep(linf_a free73_linf_a free77_linf_a lcdrpv) ///
		ctitle("CD") nocons nonotes nor2 noni nodepvar

reg cd_rpv_m linf_a free73_linf_a free77_linf_a gimacec_a gpcu_a lcdrpv `time_span2', vce(r)
outreg2 using `table_results'/Table3.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Macroeconomic Control Variables, \checkmark) keep(linf_a free73_linf_a free77_linf_a lcdrpv) ///
		ctitle("CD") nocons nonotes nor2 noni nodepvar
		
restore

************************** AGGREGATE RESULTS USING PRODUCT LEVEL DATA

preserve

collapse (sum) synth_cv (mean) inf_a gimacec_a gpcu_a year month, by(date)

g linf_a = ln(1+inf_a)

g free_73 = 0
replace free_73 = 1 if tin(1973m10, 1976m12)

g free_77 = 0
replace free_77 = 1 if tin(1977m1, 2005m12)


g free73_inf_a = free_73*inf_a
g free77_inf_a = free_77*inf_a

g free73_linf_a = linf_a*free_73
g free77_linf_a = linf_a*free_77

label var inf_a "Annual Inflation ($\vspace{0pt}\pi^a_t$)"
label var free_73 "Liberalization in 1973 ($\vspace{0pt}D^{73}_t$)"
label var free_77 "Liberalization in 1977 ($\vspace{0pt}D^{73}_t$)"

label var free73_inf_a "$\vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}\times \vspace{0pt}\pi^a_t$"
label var free77_inf_a "$\vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt}\times \vspace{0pt}\pi^a_t$"
lab var linf_a "log(1+$\vspace{0pt}\pi^a_t$)"
lab var free73_linf_a "$\vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}\times \log(1+\vspace{0pt}\pi^a_t)$"
lab var free77_linf_a "$\vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt}\times \log(1+\vspace{0pt}\pi^a_t)$"	

tsset date, m

g lsynth_cv = L.synth_cv

label var lsynth_cv "Lagged RPV"


local time_span2 "if tin(1970m1,1982m5)"

** TABLE 4. AGGREGATE RESULTS USING SYNTHETIC INFLATION

tempvar d73 d77

reg synth_cv inf_a lsynth_cv `time_span2', vce(r)
outreg2 using `table_results'/Table4.tex, replace ///
bdec(3) sdec(2) tex(fragment) label ///
		keep(lsynth_cv inf_a) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar

reg synth_cv inf_a free73_inf_a free77_inf_a lsynth_cv `time_span2', vce(r)
outreg2 using `table_results'/Table4.tex, append bdec(3) sdec(2) tex(fragment) label ///
		keep( lsynth_cv inf_a free73_inf_a free77_inf_a) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar



reg synth_cv inf_a free73_inf_a free77_inf_a gimacec_a gpcu_a lsynth_cv `time_span2', vce(r)
outreg2 using `table_results'/Table4.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Macroeconomic Control Variables, \checkmark) keep(lsynth_cv inf_a free73_inf_a free77_inf_a ) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar
		
		
reg synth_cv linf_a free73_linf_a free77_linf_a lsynth_cv `time_span2', vce(r)
outreg2 using `table_results'/Table4.tex, append bdec(3) sdec(2) tex(fragment) label ///
		keep(lsynth_cv linf_a free73_linf_a free77_linf_a) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar

reg synth_cv linf_a free73_linf_a free77_linf_a gimacec_a gpcu_a lsynth_cv `time_span2', vce(r)
outreg2 using `table_results'/Table4.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Macroeconomic Control Variables, \checkmark) keep(lsynth_cv linf_a free73_linf_a free77_linf_a ) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar
		

restore


************************* END AGGREGATE RESULTS ***********************************

* treated_code: prices that were fixed up to 1976m12
local treated_code 2 3 4 5 6 7 9 10 21 23 
* free_code: prices that were fixed up to 1973m9
local free_code 1 8 11 12 13 14 15 16 17 18 19 20 22

* Free Prices

g dtreated_free=0

foreach i in `free_code'{
replace dtreated_free=1 if code==`i'
}

*******************************************************************************

* free_code_73: prices that were fixed up to 1973m10
local free_code_73 1 8 11 12 13 14 15 16 17 18 19 20 22
* free_code_73: prices that were fixed up to 1976m12
local free_code_77 2 3 4 5 6 7 9 10 21 23


g dtreated_1973=0

foreach i in `free_code_73'{
replace dtreated_1973=1 if code==`i'
}

g dtreated_1977=0

foreach i in `free_code_77'{
replace dtreated_1977=1 if code==`i'
}

g dperiod_1973=0
replace dperiod_1973=1 if tin(1973m11, 1982m05)
g dperiod_1977=0
replace dperiod_1977=1 if tin(1977m01, 1982m05)

g dint_1=dperiod_1973*dtreated_1973
g dint_2=dperiod_1977*dtreated_1977

foreach v of varlist infp inf_a {
g dtreated_1973_`v'=dtreated_1973*`v'
g dtreated_1977_`v'=dtreated_1977*`v'

g dperiod_1973_`v'=dperiod_1973*`v'
g dperiod_1977_`v'=dperiod_1977*`v'

g dint1_`v'=dint_1*`v'
g dint2_`v'=dint_2*`v'
}
*******************************************************************************
sort code date

g pinicial=p
*replace p=p/ipc
g p2=p/L12.p-1
drop p
g p=p2
drop p2

*** Creating ID

sort code date
encode code_name, gen(id)
label var id "Product"


***** Labelling variables

label var gimacec_a "Production (Annual Growth rate)"
label var gpcu_a "Copper Price (Annual Growth rate)"

label var infp "Product-Specific Inflation (Annual)"
label var inf_a "Annual Inflation $\left[\phi_1\right]$"
label var dtreated_1973_inf_a  "$\vspace{0pt}D_i \vspace{0pt}\times \pi_t^a \left[\phi_2\right]$"
label var dtreated_1977_inf_a  "$\vspace{0pt}D_i \vspace{0pt}\times \pi_t^a \left[\phi_2\right]$"
label var dperiod_1973_inf_a "$\vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}\times \pi_t^a \left[\phi_3\right]$"
label var dperiod_1977_inf_a "$\vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt}\times \pi_t^a \left[\phi_3\right]$"


label var dperiod_1973 "Liberalization Period ($\vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}$)"
label var dperiod_1977 "Liberalization Period ($\vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt})$"
label var dtreated_1973 "Liberalized Prices $\vspace{0pt}(D_i)$"
label var dtreated_1977 "Liberalized Prices $\vspace{0pt}(D_i)$"
label var dint_1 "$\vspace{0pt} D_{i}\times \vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}$"
label var dint_2 "$\vspace{0pt} D_{i}\times \vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt}$"
label var dint1_inf_a "$\vspace{0pt}D\vspace{0pt}_{it}^{73}\times \pi_t^a \left[\phi_4\right]$"
label var dint2_inf_a "$\vspace{0pt}D\vspace{0pt}_{it}^{77}\times \pi_t^a \left[\phi_4\right]$"




label var code "Products"

local time_span "if tin(1970m1,2005m12)"

keep if tin(1970m1,1982m5)

tab year, gen(y_)
tab month, gen(m_)
egen yearmonth = group(year month)
tab yearmonth, gen(ym_)

********************* TABLE 5. RESULTS USING WITHIN RPV (1970 - 1976)

xtreg cv inf_a if tin(1970m1, 1976m12), fe vce(r)
outreg2 using `table_results'/Table5.tex, replace bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark) keep(inf_a) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar
		
xtreg cv inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a  if tin(1970m1, 1976m12), fe vce(r)
outreg2 using `table_results'/Table5.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark) keep(inf_a dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar
		
xtreg cv inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a i.month i.year i.month#i.year  if tin(1970m1, 1976m12), fe vce(r)
outreg2 using `table_results'/Table5.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(inf_a dint_1 dtreated_1973_inf_a dint1_inf_a) ///
		ctitle(" ") nocons nonotes nor2 noni nodepvar
		
xtabond cv inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a  if tin(1970m1, 1976m12)
outreg2 using `table_results'/Table5.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark) keep(inf_a dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a ) ///
		ctitle("AB Estimates") nocons nonotes nor2 noni nodepvar		

xtabond cv inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a m_* y_* ym_* if tin(1970m1, 1976m12)
outreg2 using `table_results'/Table5.tex, append bdec(3) sdec(2) tex(fragment) label ///
addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(inf_a dperiod_1973 dint_1 dtreated_1973_inf_a dint1_inf_a) ///
ctitle("AB Estimates") nocons nonotes nor2 noni nodepvar

******************* TABLE 6. RESULTS USING WITHIN RPV (1973 - 1982)

xtreg cv inf_a if tin(1973m11, 1982m5), fe vce(r)
outreg2 using `table_results'/Table6.tex, replace bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark) keep(inf_a) ///
ctitle(" ") nocons nonotes nor2 noni nodepvar
	
xtreg cv inf_a dtreated_1977 dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a  if tin(1973m11, 1982m5), fe vce(r)
outreg2 using `table_results'/Table6.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark) keep(inf_a dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a ) ///
ctitle(" ") nocons nonotes nor2 noni nodepvar

xtreg cv inf_a dtreated_1977 dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a i.month i.year i.month#i.year if tin(1973m11, 1982m5), fe vce(r)
outreg2 using `table_results'/Table6.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(inf_a dint_2 dtreated_1977_inf_a dint2_inf_a ) ///
ctitle(" ") nocons nonotes nor2 noni nodepvar

xtabond cv inf_a dtreated_1977 dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a  if tin(1973m11, 1982m5)
outreg2 using `table_results'/Table6.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark) keep(  inf_a dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a ) ///
ctitle(" ") nocons nonotes nor2 noni nodepvar

xtabond cv inf_a dtreated_1977 dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a m_* y_* ym_* if tin(1973m11, 1982m5)
outreg2 using `table_results'/Table6.tex, append bdec(3) sdec(2) tex(fragment) label ///
addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(inf_a dint_2 dtreated_1977_inf_a dint2_inf_a ) ///
ctitle(" ") nocons nonotes nor2 noni nodepvar

* Redefining labels

label var inf_a "Annual Inflation"
label var dtreated_1973_inf_a  "$\vspace{0pt}D_i^{73} \vspace{0pt}\times \pi_t^a $"
label var dtreated_1977_inf_a  "$\vspace{0pt}D_i^{77} \vspace{0pt}\times \pi_t^a $"
label var dperiod_1973_inf_a "$\vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}\times \pi_t^a $"
label var dperiod_1977_inf_a "$\vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt}\times \pi_t^a $"


label var dperiod_1973 "Liberalization Period ($\vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}$)"
label var dperiod_1977 "Liberalization Period ($\vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt})$"
label var dtreated_1973 "Liberalized Prices $\vspace{0pt}(D_i)$"
label var dtreated_1977 "Liberalized Prices $\vspace{0pt}(D_i)$"
label var dint_1 "$\vspace{0pt} D_i^{73}\times \vspace{0pt}D\vspace{0pt}_t^{73}\vspace{0pt}$"
label var dint_2 "$\vspace{0pt} D_i^{77}\times \vspace{0pt}D\vspace{0pt}_t^{77}\vspace{0pt}$"
label var dint1_inf_a "$\vspace{0pt}D\vspace{0pt}_{it}^{73}\times \pi_t^a $"
label var dint2_inf_a "$\vspace{0pt}D\vspace{0pt}_{it}^{77}\times \pi_t^a $"

********************************************************************************

************* TABLE 7. NESTED MODEL 1970 m1 - 1982m5


xtreg cv inf_a if tin(1970m1, 1982m5), fe vce(r)
outreg2 using `table_results'/Table7.tex, replace bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark) keep(inf_a) ///
ctitle(" ") nocons nonotes nor2 noni nodepvar
	
xtreg cv inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a dtreated_1977 dperiod_1977 dint_2  dperiod_1977_inf_a dint2_inf_a   if tin(1970m1, 1982m5), fe vce(r)
outreg2 using `table_results'/Table7.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark) keep(inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a dperiod_1977 dint_2 dperiod_1977_inf_a dint2_inf_a) ///
ctitle(" ") nocons nonotes nor2 noni nodepvar

xtabond cv inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a dtreated_1977 dperiod_1977 dint_2  dperiod_1977_inf_a dint2_inf_a   if tin(1970m1, 1982m5)
outreg2 using `table_results'/Table7.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark) keep(inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a dperiod_1977 dint_2 dperiod_1977_inf_a dint2_inf_a) ///
ctitle("AB Estimates") nocons nonotes nor2 noni nodepvar


****************************************************************************

**************** TABLE 8. COMPARISON ACROSS SPECIFICATIONS

xtreg cv inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a i.year i.month i.month#i.year if tin(1970m1, 1976m12), fe vce(r)
outreg2 using `table_results'/Table8.tex, replace bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(dint1_inf_a) ///
ctitle("1970 -- 1976") nocons nonotes nor2 noni nodepvar

xtreg cv inf_a dtreated_1977 dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a i.year i.month i.month#i.year if tin(1973m1, 1982m5), fe vce(r)
outreg2 using `table_results'/Table8.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(dint2_inf_a) ///
ctitle("1973 -- 1982") nocons nonotes nor2 noni nodepvar


xtreg cv inf_a dtreated_1977 dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a  dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a i.year i.month i.month#i.year if tin(1970m1, 1982m5), fe vce(r)
outreg2 using `table_results'/Table8.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(dint1_inf_a dint2_inf_a) ///
ctitle("1970 -- 1982") nocons nonotes nor2 noni nodepvar

xtabond cv inf_a dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a m_* y_* ym_* if tin(1970m1, 1976m12)
outreg2 using `table_results'/Table8.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(dint1_inf_a) ///
ctitle("1970 -- 1976 (AB)") nocons nonotes nor2 noni nodepvar

xtabond cv inf_a dtreated_1977 dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a m_* y_* ym_* if tin(1973m11, 1982m5)
outreg2 using `table_results'/Table8.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(dint2_inf_a) ///
ctitle("1973 -- 1982 (AB)") nocons nonotes nor2 noni nodepvar


xtabond cv inf_a dtreated_1977 dperiod_1977 dint_2 dtreated_1977_inf_a dperiod_1977_inf_a dint2_inf_a  dtreated_1973 dperiod_1973 dint_1 dtreated_1973_inf_a dperiod_1973_inf_a dint1_inf_a m_* y_* ym_* if tin(1970m1, 1982m5)
outreg2 using `table_results'/Table8.tex, append bdec(3) sdec(2) tex(fragment) label ///
		addtext(Product FE, \checkmark, Month FE, \checkmark, Year FE, \checkmark, Month $\times$ Year FE, \checkmark) keep(dint1_inf_a dint2_inf_a) ///
ctitle("1970 -- 1982 (AB)") nocons nonotes nor2 noni nodepvar

log close
