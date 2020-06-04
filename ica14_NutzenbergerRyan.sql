x--ica 14 - Param-acles
--Ryan Nutzenberger
------------------
--Q1
------------------
if exists(select * from sysobjects where name = 'ica14_01')
	drop procedure ica14_01
go

CREATE PROCEDURE ica14_01
@category as nvarchar(max),
@name as nvarchar(max) out,
@quantity as int out
AS
	select top 1

	@name = p.ProductName,
	@quantity = od.Quantity 

	from NorthwindTraders.dbo.Products p
	left join NorthwindTraders.dbo.[Order Details] od on od.ProductID = p.ProductID
	left join NorthwindTraders.dbo.Categories c on c.CategoryID = p.CategoryID
	where @category = c.CategoryName
	order by od.Quantity desc
GO

declare @category as nvarchar(10) = N'Beverages'
declare @name as nvarchar(10)
declare @quantity as int
EXEC ica14_01 @category, @name out, @quantity out
select @category as 'Category',
	@name as 'ProductName',
	@quantity as 'Quantity'
GO

declare @category as nvarchar(15) = N'Confections'
declare @name as nvarchar(20)
declare @quantity as int
EXEC ica14_01 @category = @category, @name = @name out, @quantity = @quantity out
select @category as 'Category',
	@name as 'ProductName',
	@quantity as 'Quantity'
GO


------------------
--Q2
------------------
if exists(select * from sysobjects where name = 'ica14_02')
	drop procedure ica14_02
go

CREATE PROCEDURE ica14_02
@year as int,
@name as varchar(64) out,
@freight as money out
AS
	select top 1
	@name = CONCAT(e.LastName + ', ', e.FirstName),
	@freight = AVG(o.Freight)
	from NorthwindTraders.dbo.Orders o join NorthwindTraders.dbo.Employees e on e.EmployeeID = o.EmployeeID
	where DATEPART(year,o.OrderDate) = @year
	group by e.LastName, e.FirstName
	order by AVG(o.Freight) desc

GO

declare @year as int = 1996
declare @name as varchar(64)
declare @freight as money
EXEC ica14_02 @year, @name out, @freight out
select @year as 'Year',
	@name as 'Name',
	@freight as 'Freight'
GO

declare @year as int = 1997
declare @name as varchar(64)
declare @freight as money
EXEC ica14_02 @year = @year, @name = @name out, @freight = @freight out
select @year as 'Year',
	@name as 'Name',
	@freight as 'Freight'
GO

------------------
--Q3
------------------
if exists(select * from sysobjects where name = 'ica14_03')
	drop procedure ica14_03
go

CREATE PROCEDURE ica14_03
@id int, 
@desc as varchar(max) = 'all'
AS

	select s.last_name as 'Last',
		a.ass_type_desc,
		ROUND(MIN(res.score/req.max_score*100),1) as 'Low',
		ROUND(MAX(res.score/req.max_score*100),1) as 'High',
		ROUND(AVG(res.score/req.max_score*100),1) as 'Avg'
	into #Scores
	from ClassTrak.dbo.Students s 
	join ClassTrak.dbo.Results res on res.student_id = s.student_id
	join ClassTrak.dbo.Requirements req on req.req_id = res.req_id
	join ClassTrak.dbo.Assignment_type a on a.ass_type_id = req.ass_type_id
	where res.class_id = @id 
	group by s.last_name, a.ass_type_desc
		
	if @desc = 'ica'
	begin
		select *
		from #Scores s
		where s.ass_type_desc = 'Assignment'
		order by s.Avg desc
	end
	else if @desc = 'lab'
	begin
		select *
		from #Scores s
		where s.ass_type_desc = 'Lab'
		order by s.Avg desc
	end
	else if @desc = 'le'
	begin
		select *
		from #Scores s
		where s.ass_type_desc = 'Lab Exam'
		order by s.Avg desc
	end
	else if @desc = 'fe'
	begin
		select *
		from #Scores s
		where s.ass_type_desc = 'Lab Exam'
		order by s.Avg desc
	end
	else
	begin
		select *
		from #Scores s
		order by s.Avg desc
	end

		
GO

EXEC ica14_03 123
GO

EXEC ica14_03 123, 'ica'
GO

EXEC ica14_03 123, 'le'
GO

------------------
--Q4
------------------
if exists(select * from sysobjects where name = 'ica14_04')
	drop procedure ica14_04
go

CREATE PROCEDURE ica14_04
@student as varchar(20),
@summary int = 0
AS
declare @name varchar(20)
declare @id int

	select
		@name = Left((s.first_name + ' ' + s.last_name), CHARINDEX(' ',s.first_name + ' ' + s.last_name) -1),
		@id = s.student_id
	from ClassTrak.dbo.Students s
	where (s.first_name + ' ' + s.last_name) like @student + '%'
	
	if @@ROWCOUNT <> 1
		return -1

	select (s.first_name + ' ' + s.last_name) as 'Name', 
		s.student_id,
		c.class_desc,
		a.ass_type_id,
		ROUND(AVG(res.score/req.max_score*100),1) as 'Avg'
	into #StudentScores
	from ClassTrak.dbo.Students s 
	join ClassTrak.dbo.Results res on res.student_id = s.student_id
	join ClassTrak.dbo.Classes c on c.class_id = res.class_id
	join ClassTrak.dbo.Requirements req on res.req_id = req.req_id
	join ClassTrak.dbo.Assignment_type a on a.ass_type_id = req.ass_type_id
	where s.student_id = @id
	group by s.first_name, s.last_name, c.class_desc, a.ass_type_id, s.student_id
	
	if @summary = 0
		select *
		from #StudentScores ss
		order by ss.class_desc, ss.ass_type_id

	else if @summary = 1
		select ss.Name,
			ss.class_desc,
			ss.Avg
		from #StudentScores ss
		order by ss.class_desc

	return 1
GO

declare @retVal as int
EXEC @retVal = ica14_04 @student = 'Ro'
select @retVal

EXEC @retVal = ica14_04 @student = 'Ron'
select @retVal

EXEC @retVal = ica14_04 @student = 'Ron', @summary = 1 
select @retVal
GO




------------------
--Q5
------------------
if exists(select * from sysobjects where name = 'ica14_05')
	drop procedure ica14_05
go

CREATE PROCEDURE ica14_05
@lastName as varchar(20),
@instructor as varchar(20) out,
@numClasses int out,
@numStudents int out,
@numGraded int out,
@avg float out
AS
	declare @rowsRet int

	select
	@instructor = i.first_name + ' ' + i.last_name
	from ClassTrak.dbo.Instructors i
	where i.last_name like @lastName + '%'

	set @rowsRet = @@ROWCOUNT

	select
	@numClasses = COUNT(c.class_id)
	from ClassTrak.dbo.Instructors i
	join ClassTrak.dbo.Classes c on i.instructor_id = c.instructor_id
	where i.last_name like @lastName + '%'

	select
	@numStudents = COUNT(cts.student_id)
	from ClassTrak.dbo.Instructors i
	join ClassTrak.dbo.Classes c on i.instructor_id = c.instructor_id
	join ClassTrak.dbo.class_to_student cts on c.class_id = cts.class_id
	where i.last_name like @lastName + '%'

	select
	@numGraded = COUNT(res.score),
	@avg = AVG(res.score/req.max_score*100)
	from ClassTrak.dbo.Instructors i
	join ClassTrak.dbo.Classes c on i.instructor_id = c.instructor_id
	join ClassTrak.dbo.Results res on res.class_id = c.class_id
	join ClassTrak.dbo.Requirements req on req.req_id = res.req_id
	where i.last_name like @lastName + '%'

	return @rowsRet

GO

declare
	@fullName as nvarchar(30),
	@return as int,
	@classes as int,
	@students as int,
	@graded as int,
	@avg as float

EXEC @return = ica14_05 @lastName = 'Cas', @instructor = @fullName output, @NumClasses = @classes output, @NumStudents = @students output, @NumGraded = @graded output, @avg = @avg output

if @return = 1
	select
		@fullName as 'Instructor',
		@return as 'Return',
		@classes as 'Num Classes',
		@students as 'Total Students',
		@graded as 'Total Graded',
		@avg as 'Total Awarded'

GO




















