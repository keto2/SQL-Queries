/*Triplett wants to know how many students have received Dean's funding AND then only graduated with a MS*/

--FINAL CODE

--Step 1: Selecting all the payroll transactions that fall under the indexes listed below from 2014 - 2020, and summing them into total pay per semester
with cte_paid as (
        select ppe.payroll_id, ppe.payroll_name, ppe.time_pp_term_code, ppe.time_pp_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, ppe.sum_of_transaction_amount1
        from GOLD_PAYPERIOD_EFFORT ppe
        where ppe.time_pp_term_code between '201330' and '202020'
	    and ppe.assignment_org_level_7 in ('130327', '137074','137086','137087','137088','137089','137167','130199')  --137167 might not be necessary since it seems to be used randomly for students, and 130199 is from Grad School MBU
    )
select payroll_id, payroll_name, time_pp_term_code, assignment_org_level_7, assignment_org_desc_7, sum(sum_of_transaction_amount1) total_paid
into ##kr_paid1
from cte_paid
group by payroll_id, payroll_name, time_pp_term_code, assignment_org_level_7, assignment_org_desc_7
order by payroll_id, time_pp_term_code desc
--2027
--drop table ##kr_paid1

        select * from ##kr_paid1

        select distinct time_pp_term_code from ##kr_paid1 order by time_pp_term_code desc

        --testing to see if anyone was paid for undergrad work
        select fee.payroll_id, fee.time_pp_term_code, reg.student_level1
        into ##kr_test1 
        from ##kr_paid1 fee
        left join gold_registration_bio reg on fee.payroll_id=reg.id and fee.time_pp_term_code=reg.academic_period

            select distinct student_level1, count(*)
            from ##kr_test1
            group by student_level1
        

--Step 2: Summing total pay to create one line per student (stipend)
select payroll_id, payroll_name, sum(total_paid) final_paid
into ##kr_paid2
from ##kr_paid1
group by payroll_id, payroll_name
order by payroll_id desc
--348
--drop table ##kr_paid2

       select * from ##kr_paid2



--Step 3: Selecting all Tuition and fees that were charged to those indexes only when the students were graduate students
select distinct fee.id, fee.name, fee.academic_period, fee.a_account_index, fee.category_desc, fee.moe_amount_total_paid, reg.student_level1
into ##kr_tu1
from TR_tuitionfees fee
	left join gold_registration_bio reg on fee.id=reg.id and fee.academic_period=reg.academic_period
where fee.academic_period between '201410' and '202020'
	and a_account_index in ('130327', '137074','137086','137087','137088','137089','137167','130199')  --137167 might not be necessary since it seems to be used randomly for students, and 130199 is from Grad School MBU)
	and student_level1 = 'GR'
--drop table ##kr_tu1
--3472

		select * from ##kr_tu1

--Step 4:  Subtotaling the tuition and fees (will turn into CTE later)
select id, name, academic_period, a_account_index, category_desc, sum(moe_amount_total_paid) total_paid
into ##kr_tu2
from ##kr_tu1
group by id, name, academic_period, a_account_index, category_desc
having sum(moe_amount_total_paid) > 0
order by name desc
--drop table ##kr_tu2
--2159

		select * from ##kr_tu2


--Step 5: combining total tuition and fee help over the 5 years per student
select id, name, sum(total_paid) total_tu_paid
from ##kr_tu2
group by id, name
order by id desc



