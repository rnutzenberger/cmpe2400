--ica 07 Ryan Nutzenberger - Select with subqueries

--use NorthwindTraders
--go
-----------------
--Q1
-----------------
declare @weight int = 800
select e.LastName as 'Last Name',
	e.Title
from Employees e
where e.EmployeeID in(
		select o.EmployeeID
		from Orders o
		where o.Freight > @weight 
		)
order by e.LastName asc
go

-----------------
--Q2
-----------------
declare @weight int = 800
select e.LastName as 'Last Name',
	e.Title
from Employees e
where exists(
		select *
		from Orders o
		where o.EmployeeID = e.EmployeeID 
		and o.Freight > @weight 
		)
order by e.LastName asc
go

-----------------
--Q3
-----------------
select p.ProductName as 'Product Name',
	p.UnitPrice as 'Unit Price'
from Products p
where p.SupplierID in (
		select s.SupplierID
		from Suppliers s
		where s.Country in('Sweden','Italy')
		)
order by p.UnitPrice asc
go

-----------------
--Q4
-----------------
select p.ProductName as 'Product Name',
	p.UnitPrice as 'Unit Price'
from Products p
where exists(
		select *
		from Suppliers s
		where s.SupplierID = p.SupplierID
		and s.Country in('Sweden','Italy')
		)
order by p.UnitPrice asc
go

-----------------
--Q5
-----------------
declare @price money = 20
select p.ProductName as 'Product Name'
from Products p
where p.CategoryID in(
		select c.CategoryID
		from Categories c
		where c.CategoryID in ('3','8')
		)
and p.UnitPrice > @price
order by p.CategoryID, p.ProductName asc
go

-----------------
--Q6
-----------------
declare @price money = 20
select p.ProductName as 'Product Name'
from Products p
where exists(
		select *
		from Categories c
		where c.CategoryID = p.CategoryID
		and c.CategoryID in ('3','8')
		)
and p.UnitPrice > @price
order by p.CategoryID, p.ProductName asc
go

-----------------
--Q7
-----------------
declare @max money = 15
select c.CompanyName as 'Company Name',
	c.Country
from Customers c
where c.CustomerID in(
	select o.CustomerID
	from Orders o
	where o.OrderID in(
		select od.OrderID
		from [Order Details] od
		where od.Quantity * od.UnitPrice < @max))
order by c.Country asc
go

-----------------
--Q8
-----------------
declare @max money = 15
select c.CompanyName as 'Company Name',
	c.Country
from Customers c
where exists(
	select *
	from Orders o
	where o.CustomerID = c.CustomerID
	and exists(
		select *
		from [Order Details] od
		where od.OrderID = o.OrderID
		and od.Quantity * od.UnitPrice < @max))
order by c.Country asc

-----------------
--Q9
----------------- 
declare @days int = -7
select p.ProductName
from Products p
where p.ProductID in(
	select od.ProductID
	from [Order Details] od
	where od.OrderID in(
		select o.OrderID
		from Orders o
		where Datediff(day,o.ShippedDate,o.RequiredDate) < @days
		and o.CustomerID in(
			select c.CustomerID
			from Customers c
			where c.Country in('UK','USA'))))
order by p.ProductName asc


-----------------
--Q10
----------------- 
select o.OrderID,
	o.ShipCity
from Orders o
where o.OrderID in(
	select od.OrderID
	from [Order Details] od
	where od.ProductID in(
		select p.ProductID
		from Products p
		where p.SupplierID in(
			select s.SupplierID
			from Suppliers s
			where s.City = o.ShipCity)))
order by o.ShipCity asc


