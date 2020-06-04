--Ryan Nutzenberger ICA 12 - Having fun?
--use ClassTrak
--go

----------------------
--Q1
----------------------
declare @id int = 88
select a.ass_type_desc as 'Type',
	AVG(res.score) as 'Raw Avg',
	AVG((res.score/req.max_score)*100) as 'Avg',
	COUNT(res.score) as 'Sum'
from Assignment_type a
		join Requirements req on req.ass_type_id = a.ass_type_id
	    join Results res on res.req_id = req.req_id
where req.class_id like @id
group by a.ass_type_desc
order by a.ass_type_desc

go
----------------------
--Q2
----------------------
declare @id int = 88
select CONCAT(req.ass_desc +'(',a.ass_type_desc +')') as 'Desc(Type)',
	ROUND(AVG(res.score/req.max_score*100),2) as 'Avg',
	COUNT(res.score) as 'Num Score'
from Assignment_type a
		join Requirements req on req.ass_type_id = a.ass_type_id
	    join Results res on res.req_id = req.req_id
where req.class_id like @id
group by  req.ass_desc, a.ass_type_desc
having AVG(res.score/req.max_score*100) > 57
order by req.ass_desc,a.ass_type_desc
go
----------------------
--Q3
----------------------
declare @id int = 123
select s.last_name as 'Last',
	a.ass_type_desc,
	ROUND(MIN(res.score/req.max_score*100),1) as 'Low',
	ROUND(MAX(res.score/req.max_score*100),1) as 'High',
	ROUND(AVG(res.score/req.max_score*100),1) as 'Avg'
from Students s 
	join Results res on res.student_id = s.student_id
	join Requirements req on req.req_id = res.req_id
	join Assignment_type a on a.ass_type_id = req.ass_type_id
where res.class_id like @id
group by s.last_name, a.ass_type_desc
having AVG(res.score/req.max_score*100) > 70
order by a.ass_type_desc,[Avg]
go


----------------------
--Q4
----------------------
select i.last_name as 'Instructor',
	CONVERT(varchar,c.start_date,106) as 'Start',
	COUNT(ct.student_id) as 'Num Registered',
	SUM(CAST(ct.active as int)) as 'Num Active'
from Instructors i
	join Classes c on i.instructor_id = c.instructor_id
	join class_to_student ct on ct.class_id = c.class_id
group by i.last_name, c.start_date
having COUNT(ct.student_id) - SUM(CAST(ct.active as int)) > 3
order by i.last_name, c.start_date
go

----------------------
--Q5
----------------------
declare @val int = 40
declare @start int = 2011;
select CONCAT(s.last_name + ', ',s.first_name) as 'Student',
	c.class_desc as 'Class',
	a.ass_type_desc as 'Type',
	COUNT(res.score) as 'Submitted',
	ROUND(AVG(res.score/req.max_score*100),1) as 'Avg'
from Students s 
	join Results res on res.student_id = s.student_id
	join Requirements req on res.req_id = req.req_id
	join Classes c on req.class_id = c.class_id
	join Assignment_type a on a.ass_type_id = req.ass_type_id
where DatePart(year,c.start_date) = @start and res.score is not null
group by s.last_name,s.first_name,c.class_desc,a.ass_type_desc
having COUNT(res.score) > 10 and AVG(res.score/req.max_score*100) < @val
order by [Submitted],[Avg]
go