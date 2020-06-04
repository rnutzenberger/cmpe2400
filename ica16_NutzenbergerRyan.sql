-- ica16
-- You will need to install a personal version of the ClassTrak database
-- The Full and Refresh scripts are on the Moodle site.
-- Once installed, you can run the refresh script to restore data that may be modified or 
--  deleted in the process of completing this ica.

use  rnutzenberger1_ClassTrak
go
begin transaction

-- q1
-- Complete an update to change all classes to have their descriptions be lower case
-- select all classes to verify your update

select *
from Classes

update Classes
set class_desc =  LOWER(class_desc)
from Classes
go

select *
from Classes
go


-- q2
-- Complete an update to change all classes have 'Web' in their 
-- respective course description to be upper case
-- select all classes to verify your selective update

select *
from Classes
select *
from Courses

update Classes
set class_desc = UPPER(class_desc)
from Classes
where course_id in 
(
	select course_id
	from Courses
	where course_desc like '%Web%'
)

go

select *
from Classes
go

select *
from Courses
go

-- q3
-- For class_id = 123
-- Update the score of all results which have a real percentage of less than 50
-- The score should be increased by 10% of the max score value, maybe more pass ?
-- Use ica13_06 select statement to verify pre and post update values,
--  put one select before and after your update call.
declare @ID as int = 123

select a.ass_type_desc as 'Type',
	ROUND(AVG(res.score),2) as 'Raw Avg',
	ROUND(AVG(res.score/req.max_score*100),2) as 'Avg',
	COUNT(res.score) as 'Sum'
from Assignment_type a
join Requirements req on req.ass_type_id = a.ass_type_id
join Results res on res.req_id = req.req_id
where res.class_id = @ID
group by a.ass_type_desc
order by a.ass_type_desc


update Results
set score = score + (req.max_score/10)
from Results res
join Requirements req on res.req_id = req.req_id
where res.score/req.max_score*100 < 50 and res.class_id = @ID

select a.ass_type_desc as 'Type',
	ROUND(AVG(res.score),2) as 'Raw Avg',
	ROUND(AVG(res.score/req.max_score*100),2) as 'Avg',
	COUNT(res.score) as 'Sum'
from Assignment_type a
join Requirements req on req.ass_type_id = a.ass_type_id
join Results res on res.req_id = req.req_id
where res.class_id = @ID
group by a.ass_type_desc
order by a.ass_type_desc

go
rollback