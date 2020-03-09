/*Triplett wants to know how many students have received Dean's funding AND then only graduated with a MS*/

--FINAL CODE

--Step 1: Selecting all the payroll transactions that fall under the indexes listed below from 2014 - 2020, and summing them into total pay per semester
with cte_paid as (
        select ppe.payroll_id, ppe.payroll_name, ppe.time_pp_term_code, ppe.time_pp_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, ppe.sum_of_transaction_amount1
        from GOLD_PAYPERIOD_EFFORT ppe
        where ppe.time_pp_term_code between '201410' and '202010'
        and ppe.payroll_name like '%berger%'
	    and ppe.assignment_org_level_7 in ('130327', '137074','137086','137087','137088','137089','137167','130199')  --137167 might not be necessary since it seems to be used randomly for students, and 130199 is from Grad School MBU
    )
select payroll_id, payroll_name, time_pp_term_code, assignment_org_level_7, assignment_org_desc_7, sum(sum_of_transaction_amount1) total_paid
into ##kr_paid55
from cte_paid
group by payroll_id, payroll_name, time_pp_term_code, assignment_org_level_7, assignment_org_desc_7
order by payroll_id, time_pp_term_code desc

--Step 2: Summing total pay to create one line per student (stipend)
select payroll_id, payroll_name, sum(total_paid) final_paid
into ##kr_paid33
from ##kr_paid55
group by payroll_id, payroll_name
order by payroll_id desc

select * from ##kr_paid33

