--Graduate Credit hours over 5 Years report
select *
into ##temp1
from GOLD_REGISTRATION_ENROLLMENT
where fct_crse_crslevel1 = 'GR'
	and academic_period > '201501'  --shortening time period to lessen time pull
	and academic_period not like '%30'  --dont care about summer
	and fct_crse_college = 'EG'  --adding college of engineering filter
	and census_period = '2'      --make sure to limit to census 2 or it will double count 0 and 2 census

select *
from ##temp1
--drop table ##temp1

select academic_year,fct_crse_banner_dept,Academic_period, fct_enrl_course_classification, SUM(moe_enrl_schev_hours) Total_Hours
from ##temp1
group by academic_year,fct_crse_banner_dept,Academic_period, fct_enrl_course_classification
order by academic_year,fct_crse_banner_dept,Academic_period, fct_enrl_course_classification
