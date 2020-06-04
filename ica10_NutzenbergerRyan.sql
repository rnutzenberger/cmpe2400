--use NorthwindTraders
--go

------------------
--Q1
------------------
select s.CompanyName as 'Company Name',
	p.ProductName as 'Product Name',
	p.UnitPrice as 'Unit Price'
from Suppliers s left join Products p on p.SupplierID = s.SupplierID 
order by s.CompanyName, p.ProductName asc
go
------------------
--Q2
------------------
 select s.CompanyName as 'Company Name',
	p.ProductName as 'Product Name',
	p.UnitPrice as 'Unit Price'
from Suppliers s left join Products p on p.SupplierID = s.SupplierID 
where p.ProductName is null
order by s.CompanyName, p.ProductName asc
go


------------------
--Q3
------------------
select CONCAT(e.LastName + ', ',e.FirstName) as Name,
	o.OrderDate as 'Order Date'
from Employees e left join Orders o on o.EmployeeID = e.EmployeeID
where o.OrderDate is null
go

------------------
--Q4
------------------
select top(5)p.ProductName as 'Product Name',
	od.Quantity 
from Products p left join [Order Details] od on od.ProductID = p.ProductID
order by od.Quantity asc
go
------------------
--Q5
------------------
select top 10 s.CompanyName as 'Company',
	p.ProductName as 'Product',
	od.Quantity as 'Quantity'
from Suppliers s left join Products p on p.SupplierID = s.SupplierID left join [Order Details] od on od.ProductID = p.ProductID
order by od.Quantity, s.CompanyName desc
go
------------------
--Q6
------------------
	select c.CompanyName as 'Customer/Supplier with Nothing'
	from Customers c left join Orders o on o.CustomerID = c.CustomerID
	where o.OrderID is null
union all
	select s.CompanyName as 'Customer/Supplier with Nothing'
	from Suppliers s left join Products p on p.SupplierID = s.SupplierID
	where p.ProductID is null
order by 'Customer/Supplier with Nothing'


------------------
--Q7
------------------

	select 'Customer' as Type, c.CompanyName as 'Customer/Supplier with Nothing'
	from Customers c left join Orders o on o.CustomerID = c.CustomerID
	where o.OrderID is null
union all
	select 'Supplier' as Type, s.CompanyName as 'Customer/Supplier with Nothing'
	from Suppliers s left join Products p on p.SupplierID = s.SupplierID
	where p.ProductID is null
order by Type