/*Triplett wants to know how many students have received Dean's funding AND then only graduated with a MS*/

/*****************************Tuition and Fees roughdraft***********************/
select top 10 *
from TR_tuitionfees

--Step 1: Finding list of students who recieved any funding from graduate sources ONLY when they were graduate students
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

select id, name, academic_period, a_account_index, category_desc, sum(moe_amount_total_paid) total_paid
into ##kr_tu2
from ##kr_tu1
group by id, name, academic_period, a_account_index, category_desc
having sum(moe_amount_total_paid) > 0
order by name desc
--drop table ##kr_tu2
--2159

		select * from ##kr_tu2

--Step 3 combining total tuition and fee help over the 5 years per student
select id, name, sum(total_paid) total_tu_paid
from ##kr_tu2
group by id, name
order by id desc

















select ppe.payroll_id, ppe.payroll_name, ppe.time_pp_term_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, deg.student_level_desc, deg.program, deg.program_desc, SUM(ppe.sum_of_transaction_amount1) subtotal_paid, sum(fee.moe_amount_total_paid) tf_paid
from GOLD_PAYPERIOD_EFFORT ppe
	left join GOLD_Degrees_awarded deg on ppe.payroll_id=deg.id
    left join TR_TuitionFees fee on ppe.payroll_id=fee.id
where ppe.time_pp_term_code between '201310' and '202010'
	and ppe.assignment_org_level_7 in ('130327', '137074','137086','137087','137088','137089','137167','130199')  --137167 might not be necessary since it seems to be used randomly for students, and 130199 is from Grad School MBU
	and a_account_index in ('130327', '137074','137086','137087','137088','137089','137167','130199')
	and deg.Degree not like 'B%'
group by ppe.payroll_id, ppe.payroll_name, ppe.time_pp_term_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, deg.student_level_desc, deg.program, deg.program_desc
having SUM(ppe.sum_of_transaction_amount1) > 0   --adding a theshold here that we can change later
order by ppe.payroll_id, ppe.payroll_name, ppe.time_pp_term_code desc
--1028

		select top 10 * from TR_tuitionfees

		select distinct(a_account_index) from TR_Tuitionfees order by a_account_index desc

/*******************************Stipend roughdraft****************************************
--Step 1: Selecting all the payroll transactions that fall under the indexes listed below from 2014 - 2020
select ppe.payroll_id, ppe.payroll_name, ppe.time_pp_term_code, ppe.time_pp_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, ppe.sum_of_transaction_amount1
into ##kr_paid1
from GOLD_PAYPERIOD_EFFORT ppe
where ppe.time_pp_term_code between '201410' and '202010'
    and ppe.payroll_name like '%berger%'
	and ppe.assignment_org_level_7 in ('130327', '137074','137086','137087','137088','137089','137167','130199')  --137167 might not be necessary since it seems to be used randomly for students, and 130199 is from Grad School MBU
	--and deg.Degree not like 'B%'
--group by ppe.payroll_id, ppe.payroll_name, ppe.time_pp_term_code, ppe.time_pp_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, deg.student_level_desc, deg.program, deg.program_desc
--having SUM(ppe.sum_of_transaction_amount1) > 0   --adding a theshold here that we can change later
order by ppe.payroll_id, ppe.time_pp_term_code desc
--100
--drop table ##kr_paid1

        select * from ##kr_paid1

--step 2: Collapsing those transactions to find total pay per semester
select payroll_id, payroll_name, time_pp_term_code, assignment_org_level_7, assignment_org_desc_7, sum(sum_of_transaction_amount1) total_paid
into ##kr_paid2
from ##kr_paid1
group by payroll_id, payroll_name, time_pp_term_code, assignment_org_level_7, assignment_org_desc_7
order by payroll_id, time_pp_term_code desc
--11
--drop table ##kr_paid2

        select * from ##kr_paid2

                        
--Step 3: Collapsing total pay to create one line per student
select payroll_id, payroll_name, sum(total_paid) final_paid
into ##kr_paid3
from ##kr_paid2
group by payroll_id, payroll_name
order by payroll_id desc

        select * from ##kr_paid3


/****************************this version has the pay periods broken down********************************

--Step 1: Pulling the number of students who have received either Tuition/Fees or Stipend from the main Dean Indexes, and what degrees they were awarded
select ppe.payroll_id, ppe.payroll_name, ppe.time_pp_code, ppe.time_pp_term_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, deg.student_level_desc, deg.program, deg.program_desc, SUM(ppe.sum_of_transaction_amount1) subtotal_paid, sum(fee.moe_amount_total_paid) tf_paid
from GOLD_PAYPERIOD_EFFORT ppe
	left join GOLD_Degrees_awarded deg on ppe.payroll_id=deg.id
    left join TR_TuitionFees fee on ppe.payroll_id=fee.id
where ppe.time_pp_term_code between '201310' and '202010'
	and ppe.assignment_org_level_7 in ('130327', '137074','137086','137087','137088','137089','137167','130199')  --137167 might not be necessary since it seems to be used randomly for students, and 130199 is from Grad School MBU
	and a_account_index in ('130327', '137074','137086','137087','137088','137089','137167','130199')
	and deg.Degree not like 'B%'
group by ppe.payroll_id, ppe.payroll_name, ppe.time_pp_code, ppe.time_pp_term_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, deg.student_level_desc, deg.program, deg.program_desc
having SUM(ppe.sum_of_transaction_amount1) > 0   --adding a theshold here that we can change later
order by ppe.payroll_id, ppe.payroll_name, ppe.time_pp_code, ppe.time_pp_term_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, deg.student_level_desc, deg.program, deg.program_desc
--6834

		select top 10 * from TR_tuitionfees

		select distinct(a_account_index) from TR_Tuitionfees order by a_account_index desc



/*************************************************ARCHIVE********************************************************************
with cte_bio as(
select *, row_number() over(partition by salu_and_full_name order by rundate desc) as rn
from Gold_registration_bio
)
select ppe.payroll_id, ppe.payroll_name, ppe.time_pp_code, ppe.time_pp_term_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, deg.student_level_desc, deg.program, deg.program_desc, bio.current_time_status, SUM(sum_of_transaction_amount1) subtotal_paid
from GOLD_PAYPERIOD_EFFORT ppe
	left join GOLD_Degrees_awarded deg on ppe.payroll_id=deg.id
	left join cte_bio bio on ppe.payroll_id=bio.id
where ppe.time_pp_term_code between '201310' and '202010'
	and ppe.assignment_org_level_7 in ('130327', '137074','137086','137087','137088','137089','137167','130199')  --137167 might not be necessary since it seems to be used randomly for students, and 130199 is from Grad School MBU
	and deg.Degree not like 'B%'
	and bio.rn = 1
group by ppe.payroll_id, ppe.payroll_name, ppe.time_pp_code, ppe.time_pp_term_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, deg.student_level_desc, deg.program, deg.program_desc, bio.current_time_status
having SUM(sum_of_transaction_amount1) > 0   --adding a theshold here that we can change later
order by ppe.payroll_id, ppe.payroll_name, ppe.time_pp_code, ppe.time_pp_term_code, ppe.assignment_org_level_7, ppe.assignment_org_desc_7, deg.student_level_desc, deg.program, deg.program_desc, bio.current_time_status
