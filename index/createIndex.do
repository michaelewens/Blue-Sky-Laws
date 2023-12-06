****
* Create the index data from what we have
clear
dropbox
cd blue_sky_history

* Load up the data from OpenAPI API
import delimited using "public_release/index/master_API_output.csv", delimiter(",") clear varnames(1) bindquote(strict) maxquotedrows(200)

drop v12

keep if stringency ~= ""

* Code to #
gen stringecy_num = 1 if stringency == "More"
replace stringecy_num = 0 if stringency == "Neutral"
replace stringecy_num = -1 if stringency == "Less"


****
* EXPORT clean-ish raw API
export delimited "public_release/index/coded_changes112923.csv", delimiter(",") replace

* Ignore banking changes
drop if banking == "Yes"



* Collapse at the state-year
collapse (sum) stringecy_num, by(state year)

* Baseline
bys state (year): gen bsl_index = 100 if _n == 1



* Final index
bys state (year): gen num = _n
sum num, d
local maxN = r(max)

forvalues v=2(1)`maxN' {
	* Note that this ignores the first year
	replace bsl_index = bsl_index[_n-1] + stringecy_num if num == `v'
}

* Export
keep state year bsl_index
export delimited "public_release/index/simple_indexAllTypes.csv", delimiter(",") replace




