﻿-- ica15
-- This ICA is comprised of 2 parts, but should be tackled as described by your instructor.
-- To ensure end-to-end running, you will have to complete the ica in pairs where possible :
--  q1A + q2A, then q1B + q2B
-- You will need to install a personal version of the ClassTrak database
-- The Full and Refresh scripts are on the Moodle site.
-- Once installed, you can run the refresh script to restore data that may be modified or 
--  deleted in the process of completing this ica.

use [rnutzenberger1_ClassTrak] -- YOUR_COPY_CLASSTRAK
go

-- q1
-- All in one batch, to retain your variable contexts/values
	
-- A
-- Insert a new Instructor : Donald Trump
--  Check column types, supply necessary values, it may require a column list
--  Save your identity into a variable
	declare @instructor_id as int
	insert into Instructors (last_name, first_name)
	values ('Trump', 'Donald')
	set @instructor_id = @@IDENTITY
	
	
-- B
-- Insert a new Course : cmpe2442 "Fast and Furious - SQL Edition"
--  Check column types, supply necessary values, it may require a column list
--  Save your identity into a variable
	declare @course_id as int
	insert into Courses (course_abbrev, course_desc)
	values ('cmpe2442','Fast and Furious - SQL Edition')
	set @course_id = @@IDENTITY
	
-- C
-- Insert a record indicating your new instructor is teaching the new course
--  description : "Beware the optimizer"
--  start_date : use 01 Sep 2016
--  Save the identity into a variable
	declare @class_id as int
	insert into Classes(class_desc, start_date, course_id,instructor_id)
	values ('Beware the optimizer', '01 Sep 2016',@course_id,@instructor_id)
	set @class_id = @@IDENTITY
	
-- D Insert a bunch in one insert
-- Generate the insert statement to Add all the students with a last name that
--  starts with a vowel to the new class
	insert into class_to_student (class_id,student_id)
		select
			@class_id, s.student_id
		from Students s
		where s.last_name like '[aeiou]%'

-- E
--  Prove it all, generate a select to show :
--   All instructors - see your new entry
--   All courses that have SQL in description
--   All classes that have a start_date after 1 Aug 2016
--   All students in the new class - filter by description having "Beware"
--       sort by first name in last name
select *
from Instructors

select * 
from Courses
where course_desc like '%SQL%'

select *
from Classes 
where start_date > '1 Aug 2016'

select *
from Students s
	join class_to_student cts on cts.student_id = s.student_id
	join Classes c on c.class_id = cts.class_id
	where c.class_desc like '%Beware%'
	order by s.last_name, s.first_name
go
	
-- end q1



-- q2 - Undo all your changes to reset the database, you must do this in reverse order to
--      ensure you do not attempt to corrupt Referencial Integrity.
--     As such, work backwards from D to A, deleting what we added, but you must query the DB
--      to find and save the relevant keys.

-- q2 - Undo all your changes to reset the database, you must do this in reverse order to
--      ensure you do not attempt to corrupt Referencial Integrity.
--     As such, work backwards from D to A.

-- D - Delete all students that have been assigned to your new class, do this without a 
--     variable, rather perform a join with proper filtering for this delete
	delete class_to_student
	from class_to_student cts
	join Classes c on c.class_id = cts.class_id
	where c.class_desc like  'Beware the optimizer'
-- C - declare, query and set class id to your new class based on above filter.
--     declare, query and save the linked course and instructor ( use in B and A )
--     Delete the new class
	declare @insructor_id as int
	declare @course_id as int

	select
	@insructor_id = c.instructor_id,
	@course_id = c.course_id
	from Classes c
	where c.class_id like 
	(
		select c.class_id
		from Classes c
		where c.class_desc like 'Beware the optimizer'
	)
	delete Classes
	where class_id like 
	(
		select c.class_id
		from Classes c
		where c.class_desc like 'Beware the optimizer'
	)

-- B - Delete the new course as saved in C
	delete Courses
	where course_id like @course_id
-- A - Delete the new instructor as saved in C
	delete Instructors
	where instructor_id like @insructor_id
-- E - Repeat q1 part E to verify the removal of all the data.
	select *
	from Instructors

	select * 
	from Courses
	where course_desc like '%SQL%'

	select *
	from Classes 
	where start_date > '1 Aug 2016'

	select *	
	from Students s
	join class_to_student cts on cts.student_id = s.student_id
	join Classes c on c.class_id = cts.class_id
	where c.class_desc like '%Beware%'
	order by s.last_name, s.first_name

go