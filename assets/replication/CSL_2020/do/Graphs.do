clear all
set more off
set matsize 10000

local graphs_to_paper "../Results/Graphs"
local treated_code 2 3 4 5 6 7 9 10 21 23 
local free_code 1 8 11 12 13 14 15 16 17 18 19 20 22

* Importing Master Database

use ../Data/dta/prices, clear

xtset code date
sort code date  

****** Aggregate 

*** Annualized Aggregate Inflation and Aggregate Inflation of Producers
g log_p = ln(p)
g log_ipc = ln(ipc)

by code: g inf_a = log_ipc - L12.log_ipc 

by code: gen infp = log_p - L1.log_p
by code: gen inf_m = log_ipc - L1.log_ipc

tssmooth ma infpsmooth=infp, window(11 1 0)
replace infpsmooth=. if tin(1969m1, 1969m12)
by code: gen cv_s = (infp - inf_m)^2
tssmooth ma cv=cv_s, window(11 1 0)
replace cv=. if tin(1969m1, 1969m12)
replace cv=sqrt(cv/(1+inf_m)^2)
gen synth_cv = cv*synthetic_weight


g pinicial=p
replace p=p/ipc

***** Labelling variables

sort code date

gen DV_70 = 0
bysort code (date): replace DV_70 = p if _n == 13
bysort code: replace DV_70=DV_70[13]
gen rp_index_70=p/DV_70

gen DV_lib_it = 0
bysort code (date): replace DV_lib_it = pinicial if _n == 13
bysort code: replace DV_lib_it=DV_lib_it[13]
gen p_index_lib_it=pinicial/DV_lib_it

sort code date

*** Annualized Inflation

by code: gen infp_m = log_p - L.log_p
by code: gen infp_a= log_p - L12.log_p

g synth_inf_a = infp_a*synthetic_weight
bys date: egen sinf_a = sum(synth_inf_a)


g classic_rpv_m = synthetic_weight*(infp_m - inf_m)^2 


/* C: GRAPHS */

replace p_index_lib_it = ln(p_index_lib_it)
replace rp_index_70 = ln(rp_index_70)


**** Product level Comparison 

* Figure 1

twoway (connected p_index_lib_it date if code==2 & tin(1970m1,1982m5), lcolor(black) mcolor(black) msize(small) mfcolor(black) lwidth(medthin) ylabel(, labsize(small))) (connected p_index_lib_it date if code==1 & tin(1970m1,1982m5),lcolor(gray) lwidth(medthin) msize(small)  mfcolor(white) mcolor(gray) ylabel(0(2)11, labsize(small) angle(0))), graphregion(color(white) fcolor(white)) legend(label(1 "Flour (F)") label(2 "Rice (L)") colgap(2) size(small) symxsize(8) width(45)) xtitle("") ytitle("{bf: Product Price (1970m1 = 0, Log Scale)}") yscale(titlegap(2)) ylabel(, nogrid) tlabel(1970m1  1970m12 1971m12(12)1981m12 1982m5, labsize(small) angle(45)) bgcolor(white) tline(1973m10 1977m1, lcolor(black) lwidth(medthick)) text(2 167 "{bf:Partial Liberalization}", place(e) size(small)) text(3 220 "{bf:Full Liberalization}", place(e) size(small)) 
graph export `graphs_to_paper'/product_price_example_m1.pdf, replace

* Figure 2

twoway (connected rp_index_70 date if code==2 & tin(1970m1,1982m5), lcolor(black) msize(small) mfcolor(black) mcolor(black) lwidth(medthin) ylabel(, labsize(small))) (connected rp_index_70 date if code==1 & tin(1970m1,1982m5), lcolor(gray) lwidth(medthin) msize(small)  mfcolor(white) mcolor(gray) ylabel(, angle(0))), graphregion(color(white) fcolor(white)) legend(label(1 "Flour (F)") label(2 "Rice (L)") colgap(2) symxsize(8) width(45)) xtitle("") ytitle("{bf:Relative Price (1970m1 ==0, Log Scale)}") ylabel(, nogrid) tlabel(1970m1  1970m12 1971m12(12)1981m12 1982m5, labsize(small) angle(45)) tline(1973m10 1977m1, lcolor(black) lwidth(medthick)) text(-1 167 "{bf:Partial Liberalization}", place(e) size(small)) text(-1 220 "{bf:Full Liberalization}", place(e) size(small)) 
graph export `graphs_to_paper'/product_rprice_example_m1.pdf, replace

collapse (mean) inf_a sinf_a inf_m (sum) classic_rpv_m, by(date)

* Caraballo and Dabus Definition (To account for hyperinflation).

g cd_rpv_m = classic_rpv_m/(1+inf_m)^2


replace inf_a = ln(1 + inf_a)
replace sinf_a = ln(1 + sinf_a)
replace classic_rpv_m = ln(classic_rpv_m)
replace cd_rpv_m = ln(cd_rpv_m)


* Figure 3

twoway  (line inf_a date, lcolor(gray) lwidth(thick) ) ///
		(connected sinf_a date, lcolor(black) msize(small) mfcolor(black) mcolor(black)) ///
	    (line classic_rpv_m date, lcolor(black) lwidth(medthick) lpattern(dash) yaxis(2)) ///
	   if tin(1970m1,1982m5), legend(label(1 "Inflation") label(2 "Synthetic Inflation") label(3 "RPV") cols(3) size(small)) ytitle("{bf:Log(1 + Inflation)}") ytitle("{bf:Log RPV}", axis(2)) ylabel(, angle(0)) ylabel(, angle(0) axis(2)) ///
	   graphregion(color(white) fcolor(white)) xtitle("") tlabel(1970m1 1970m12 1971m12(12)1981m12 1982m5, labsize(small) angle(45)) tline(1973m10 1977m1, lcolor(black) lwidth(medthick)) text(0.3 168 "{bf:Partial Liberalization}", place(e) size(vsmall)) text(1.25 220 "{bf:Full Liberalization}", place(e) size(vsmall)) 
graph export `graphs_to_paper'/classicrpvm1.pdf, replace
	   
* Figure 4
	   
twoway  (line inf_a date, lcolor(gray) lwidth(thick) ) ///
		(connected sinf_a date, lcolor(black) msize(small) mfcolor(black) mcolor(black)) ///
	    (line cd_rpv_m date, lcolor(black) lwidth(medthick) lpattern(dash) yaxis(2)) ///
	   if tin(1970m1,1982m5), legend(label(1 "Inflation") label(2 "Synthetic Inflation") label(3 "RPV") cols(3) size(small)) ytitle("{bf:Log(1 + Inflation)}") ytitle("{bf:Log RPV}", axis(2)) ylabel(, angle(0)) ylabel(, angle(0) axis(2)) ///
	   graphregion(color(white) fcolor(white)) xtitle("") tlabel(1970m1 1970m12 1971m12(12)1981m12 1982m5, labsize(small) angle(45)) tline(1973m10 1977m1, lcolor(black) lwidth(medthick)) text(0.3 168 "{bf:Partial Liberalization}", place(e) size(vsmall)) text(1.25 220 "{bf:Full Liberalization}", place(e) size(vsmall)) 
graph export `graphs_to_paper'/cdrpvm1.pdf, replace

