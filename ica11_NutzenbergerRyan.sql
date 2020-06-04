--ica 11 - Aggregates and Aggravation
--Ryan Nutzenberger

--use NorthwindTraders 
--go

-------------------------
--Q1
-------------------------
select CONCAT(e.LastName + ', ', e.FirstName) as 'Name',
	Count(o.OrderID) as 'Num Orders'
from Employees e right join Orders o on o.EmployeeID = e.EmployeeID
group by e.LastName,e.FirstName
order by [Num Orders] desc
go

-------------------------
--Q2
-------------------------
select CONCAT(e.LastName + ', ', e.FirstName) 'Name',
	AVG(o.Freight) as 'Average Freight',
	CONVERT(varchar,MAX(o.OrderDate),106) as 'Newest Order Date'
from Orders o left join Employees e on e.EmployeeID = o.EmployeeID
group by e.LastName,e.FirstName
order by MAX(o.orderdate), e.LastName
go
-------------------------
--Q3
-------------------------
select s.CompanyName as 'Supplier',
	s.Country as 'Country',
	COUNT(p.ProductID) as 'Num Products',
	AVG(p.UnitPrice) as 'Avg Price'
from Products p right join Suppliers s on s.SupplierID = p.SupplierID
where s.CompanyName like '[hurt]%'
group by s.CompanyName,s.Country
order by [Num Products]

go
-------------------------
--Q4
-------------------------
declare @country varchar(3) = 'USA'
select s.CompanyName as 'Supplier',
	s.Country as 'Country',
	MIN(COALESCE(p.UnitPrice,0)) as 'Min Price',
	MAX(COALESCE(p.UnitPrice,0)) as 'Max Price'
from Suppliers s left join Products p on s.SupplierID = p.SupplierID
where s.Country = @country
group by s.CompanyName,s.Country
order by MIN(COALESCE(p.UnitPrice,0))
go
-------------------------
--Q5
-------------------------
select c.CompanyName as 'Customer',
	c.City as 'City',

from Customers c left join Orders o on o.CustomerID = c.CustomerID
		left join [Order Details] od on o.OrderID = od.OrderID
go
-------------------------
--Q6
-------------------------

go