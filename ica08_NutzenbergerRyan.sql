--ICA08 - Select Modifier - Top
--Ryan Nutzenberger
--use NorthwindTraders
--go

--------------------
--Q1
--------------------
select top(1)
s.CompanyName as 'Supplier Company Name',
s.Country
from Suppliers s
order by s.Country asc
go
--------------------
--Q2
--------------------
select top(2)
s.CompanyName as 'Supplier Company Name',
s.Country
from Suppliers s
order by s.Country asc
go

--------------------
--Q3
--------------------
select top (10) percent
p.ProductName as 'Product Name',
p.UnitsInStock as 'Units in Stock'
from Products p
order by p.UnitsInStock desc
go

--------------------
--Q4
--------------------
select c.CompanyName as 'Customer Company Name',
	c.Country
from Customers c
where c.CustomerID in(
	select top(8)o.CustomerID
	from Orders o
	order by o.Freight desc)
go

--------------------
--Q5
--------------------
select o.CustomerID, o.OrderID, Convert(varchar(15),o.OrderDate,106) as 'Order Date'
from Orders o
where o.OrderID in(
	select top(3) od.OrderID
	from [Order Details] od
	order by od.Quantity desc)
go

--------------------
--Q6
--------------------
select o.CustomerID, o.OrderID, Convert(varchar(15),o.OrderDate,106) as 'Order Date'
from Orders o
where o.OrderID in(
	select top(3) with ties od.OrderID 
	from [Order Details] od
	order by od.Quantity desc)
go

--------------------
--Q7
--------------------
select s.CompanyName as 'Supplier Company Name',
	s.Country
from Suppliers s
where s.SupplierID in(
	select p.SupplierID
	from Products p
	where p.ProductID in(
		select top(1) percent od.ProductID
		from [Order Details] od
		order by od.UnitPrice*od.Quantity desc))