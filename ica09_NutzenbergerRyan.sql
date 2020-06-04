--ICA09 - Joins
--Ryan Nutzenberger
--use NorthwindTraders
--go


-------------------
--Q1
-------------------
declare @country varchar(10) = 'USA'
select s.CompanyName as 'Company Name',
	p.ProductName as 'Product Name',
	p.UnitPrice as 'Unit Price'
from Suppliers s
join Products p on p.SupplierID=s.SupplierID
where s.Country like @country
order by s.CompanyName, p.ProductName asc
go

-------------------
--Q2
-------------------
declare @includes varchar(3) = 'ul'
select CONCAT(e.LastName +', ',e.FirstName) as Name,
	t.TerritoryDescription as 'Territory Description'
from Employees e
join EmployeeTerritories et on e.EmployeeID = et.EmployeeID
join Territories t on t.TerritoryID = et.TerritoryID
where e.LastName like '%' + @includes + '%'
order by t.TerritoryDescription
go

-------------------
--Q3
-------------------
declare @country varchar(10)='Sweden'
select distinct c.CustomerID as 'Customer ID',
	p.ProductName as 'Product Name'
from Customers c
join Orders o on o.CustomerID = c.CustomerID
join [Order Details] od on od.OrderID = o.OrderID
join Products p on p.ProductID = od.ProductID
where c.Country like @country
	and p.ProductName like '[u-z]%'
order by p.ProductName
go
-------------------
--Q4
-------------------
declare @sellPrice money = 69 --nice 
select distinct c.CategoryName as 'Category Name',
	p.UnitPrice as 'Product Price',
	od.UnitPrice as 'Selling Price'
from Categories c
join Products p on p.CategoryID = c.CategoryID
join [Order Details] od on od.ProductID = p.ProductID
where p.UnitPrice not like od.UnitPrice
	and od.UnitPrice > @sellPrice
order by od.UnitPrice
go
-------------------
--Q5
-------------------
declare @days int = 34
select o.ShipName as 'Shippers',
	p.Discontinued as 'Product Name',
	p.ProductName
from Orders o
join [Order Details] od on o.OrderID = od.OrderID
join Products p on p.ProductID = od.ProductID
where DATEDIFF(day,o.ShippedDate,o.RequiredDate) > @days
	and p.Discontinued > 0
order by o.ShipName asc
go



