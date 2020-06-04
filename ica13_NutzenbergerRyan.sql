--ica 13 - stored procedures
--Ryan Nutzenberger

-----------------------
--Q1
-----------------------
if exists(select * from sysobjects where name = 'ica13_01')
	drop procedure ica13_01
go

CREATE PROCEDURE ica13_01
AS
	SELECT CONCAT(e.LastName + ', ', e.FirstName) as 'Name',
		COUNT(o.OrderID) as 'Num Orders'
	FROM NorthwindTraders.dbo.Employees e join NorthwindTraders.dbo.Orders o on o.EmployeeID = e.EmployeeID
	GROUP BY e.LastName,e.FirstName
	ORDER BY [Num Orders] desc
GO

EXEC ica13_01
GO

-----------------------
--Q2
-----------------------
if exists(select * from sysobjects where name = 'ica13_02')
	drop procedure ica13_02
go

CREATE PROCEDURE ica13_02
AS
	select CONCAT(e.LastName + ', ', e.FirstName) as 'Name',
		CONVERT(money,SUM(od.UnitPrice * od.Quantity)) as 'Sales Total',
		COUNT(od.Quantity) as 'Detail Items'
	from NorthwindTraders.dbo.Employees e left join NorthwindTraders.dbo.Orders o on o.EmployeeID = e.EmployeeID 
		left join NorthwindTraders.dbo.[Order Details] od on od.OrderID = o.OrderID
	group by e.LastName, e.FirstName
	order by [Sales Total] desc
GO

EXEC ica13_02
GO

-----------------------
--Q3
-----------------------
if exists(select * from sysobjects where name = 'ica13_03')
	drop procedure ica13_03
go

CREATE PROCEDURE ica13_03
@maxPrice money = null
AS
	select c.CompanyName as 'Company Name',
		c.Country
	from NorthwindTraders.dbo.Customers c
	where c.CustomerID in(
		select o.CustomerID
		from NorthwindTraders.dbo.Orders o
		where o.OrderID in(
			select od.OrderID
			from NorthwindTraders.dbo.[Order Details] od
			where od.Quantity * od.UnitPrice < @maxPrice))
	order by c.Country asc
GO

declare @max int = 15
EXEC ica13_03 @maxPrice = @max
GO

-----------------------
--Q4
-----------------------
if exists(select * from sysobjects where name = 'ica13_04')
	drop procedure ica13_04
go

CREATE PROCEDURE ica13_04
@minPrice money = null,
@categoryName as nvarchar(max) = ''
AS

	select p.ProductName as 'Product Name'
	from NorthwindTraders.dbo.Products p
	where exists(
		select *
		from NorthwindTraders.dbo.Categories c
		where c.CategoryID = p.CategoryID
		and c.CategoryName like @categoryName)
	and p.UnitPrice > @minPrice
	order by p.CategoryID, p.ProductName asc
GO

EXEC ica13_04 20, N'confections'
GO

-----------------------
--Q5
-----------------------
if exists(select * from sysobjects where name = 'ica13_05')
	drop procedure ica13_05
go

CREATE PROCEDURE ica13_05
@minPrice money = null,
@country nvarchar(max) = N'USA'
AS	
	select s.CompanyName as 'Supplier',
		s.Country as 'Country',
		MIN(COALESCE(p.UnitPrice,0)) as 'Min Price',
		MAX(COALESCE(p.UnitPrice,0)) as 'Max Price'
	from NorthwindTraders.dbo.Suppliers s left join NorthwindTraders.dbo.Products p on s.SupplierID = p.SupplierID
	where s.Country like @country 
	group by s.CompanyName,s.Country
	having MIN(COALESCE(p.UnitPrice,0)) > @minPrice
	order by MIN(p.UnitPrice)
GO

EXEC ica13_05 15
GO
EXEC ica13_05 @minPrice = 15
GO
EXEC ica13_05 @minPrice = 5, @country = 'UK'
GO

-----------------------
--Q6
-----------------------
if exists(select * from sysobjects where name = 'ica13_06')
	drop procedure ica13_06
go

CREATE PROCEDURE ica13_06
@class_id int = 0
AS
	select a.ass_type_desc as 'Type',
		ROUND(AVG(res.score),2) as 'Raw Avg',
		ROUND(AVG((res.score/req.max_score)*100),2) as 'Avg',
		COUNT(res.score) as 'Sum'
	from ClassTrak.dbo.Assignment_type a
			join ClassTrak.dbo.Requirements req on req.ass_type_id = a.ass_type_id
			join ClassTrak.dbo.Results res on res.req_id = req.req_id
	where req.class_id like @class_id
	group by a.ass_type_desc
	order by a.ass_type_desc
GO

EXEC ica13_06 88
GO
EXEC ica13_06 @class_id = 89
GO

-----------------------
--Q7
-----------------------
if exists(select * from sysobjects where name = 'ica13_07')
	drop procedure ica13_07
go

CREATE PROCEDURE ica13_07
@year int = null,
@maxAvg int = 50,
@minSize int = 10
AS
	select CONCAT(s.last_name + ', ',s.first_name) as 'Student',
		c.class_desc as 'Class',
		a.ass_type_desc as 'Type',
		COUNT(res.score) as 'Submitted',
		ROUND(AVG(res.score/req.max_score*100),1) as 'Avg'
	from ClassTrak.dbo.Students s 
		join ClassTrak.dbo.Results res on res.student_id = s.student_id
		join ClassTrak.dbo.Requirements req on res.req_id = req.req_id
		join ClassTrak.dbo.Classes c on req.class_id = c.class_id
		join ClassTrak.dbo.Assignment_type a on a.ass_type_id = req.ass_type_id
	where DatePart(year,c.start_date) = @year and res.score is not null
	group by s.last_name,s.first_name,c.class_desc,a.ass_type_desc
	having COUNT(res.score) > @minSize and AVG(res.score/req.max_score*100) < @maxAvg
	order by [Submitted],[Avg]
GO

EXEC ica13_07 @year = 2011
GO
EXEC ica13_07 @year = 2011
GO
EXEC ica13_07 @year = 2011, @maxAvg = 40, @minSize = 15
GO

