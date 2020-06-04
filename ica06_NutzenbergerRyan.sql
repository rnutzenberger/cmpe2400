--ica 06 Nutzenberger Ryan - Select, more
--use Chinook
--go

-------------
--Q1
-------------
declare @min money = 1.69
declare @max money = 1.89
--select Name
--from Genre
select left(tr.Name,24) as Name,
	tr.UnitPrice as 'Unit Price'
from Track tr
where tr.GenreId in('13','25')
	and tr.UnitPrice between @min and @max
order by tr.name asc

go
-------------
--Q2
-------------
declare @min money = 16
declare @max money = 18
select il.InvoiceId as 'Invoice ID',
	il.TrackId as 'Track ID',
	il.UnitPrice * il.Quantity as 'Value'
from InvoiceLine il
where  (il.UnitPrice * il.Quantity) between @min and @max
order by [Value] desc
go
-------------
--Q3
-------------
declare @white varchar(12) = 'white'
declare @black varchar(12) = 'black'
select left(tr.Name,48) as Name,
	left(tr.Composer,12) as 'Composer',
	tr.UnitPrice as 'Unit Price'
from Track tr
where tr.name like '% ' + @black + ' %' or tr.Name like '%' + @white + '%'
order by tr.Name asc
go
-------------
--Q4
-------------
declare @min int = 200
declare @max int = 300
declare @minPrice money = 12
declare @maxPrice money = 14
select left(CONCAT(il.InvoiceID,':',il.TrackId),12) as 'Inv:Track',
	il.UnitPrice as 'Unit Price',
	il.Quantity,
	(il.UnitPrice * il.Quantity) as Cost
from InvoiceLine il
where ((il.UnitPrice * il.Quantity) between @minPrice and @maxPrice)
	and il.InvoiceId between @min and @max
order by il.InvoiceId, il.TrackId desc
go

-------------
--Q5
-------------
select left(c.FirstName,24) as 'First Name',
	c.PostalCode as PC,
	c.Phone as 'Phone Number',
	left(c.Email,24) as Email
from Customer c
where c.PostalCode like '[A-Z][0-9][A-Z] [0-9][A-Z][0-9]'
	or c.Phone like '%[0-2][0-2][0-2][0-2]'
order by c.FirstName asc
go
-------------
--Q6
-------------
declare @message varchar(5)
select e.LastName as 'Last Name',
	DATEDIFF(year,e.BirthDate,GETDATE())+DATEDIFF(year,e.HireDate,GETDATE()) as 'Magic Number',
	"Yet ?" = 
		case 
			when DATEDIFF(year,e.BirthDate,GETDATE())+DATEDIFF(year,e.HireDate,GETDATE()) >= 85 then 'Yup'
			when DATEDIFF(year,e.BirthDate,GETDATE())+DATEDIFF(year,e.HireDate,GETDATE()) < 85 then 
			CAST(85 - (DATEDIFF(year,e.BirthDate,GETDATE())+DATEDIFF(year,e.HireDate,GETDATE())) as varchar(3))
			end
from Employee e
order by DATEDIFF(year,e.BirthDate,GETDATE())+DATEDIFF(year,e.HireDate,GETDATE()) asc
go
-------------
--Q7
-------------
select c.LastName as 'Last Name',
	c.City,
	c.Country
from Customer c
where c.Company is not null 
	and c.Country not like '%[aemy]'
order by c.Country, c.City desc, c.LastName desc
go
-------------
--Q8
-------------
select distinct c.Country
from Customer c
where c.Country like '[a-f]%'
order by c.Country desc
go
-------------
--Q9
-------------
declare @length int = 3
select distinct SUBSTRING(t.Name,0,CHARINDEX(' ',t.Name)) as 'First Word'
from Track t
where t.GenreId like '1' 
	and t.name like '[aeiou]%' 
	and LEN(SUBSTRING(t.Name,0,CHARINDEX(' ',t.Name))) > @length
order by SUBSTRING(t.Name,0,CHARINDEX(' ',t.Name)) asc

go

