--ica 05 Nutzenberger Ryan - Select
--Q1
--------------
--use Chinook
--go

--select all columns from genre
select *
	from Genre
go
-------------------
--Q2
-------------------

--select and display each column with the edited column name
select CustomerId as 'Customer ID',
	LastName as 'Last Name',
	FirstName as ' First Name',
	Company as 'Company Name'
	from Customer
go
--------------------
--Q3
--------------------
select CustomerId as 'Customer ID',
	--cast first name and country as a char of up to 18 characters allowed
	cast(FirstName as char(18)) as 'First Name',
	cast(Country as char(18)) as 'Country',
	--change the format to align left of column with a width of 18
	left(State, 18) as 'Region'
	from Customer
	--display only where the fax is null and the state is not null
	where fax is null and State is not null
go
--------------------
--Q4
--------------------
select TrackId as 'Track ID',
	--format the name and composer to align left with a width of 26 and 64 respectively
	left(Name,26) as Name,
	left(Composer,64) as 'Written By'
	from Track
	--display only where the genre id is 2 and between 7 and 8 minutes
	where GenreId = 2
	and Milliseconds between 420000 and 480000

--------------------
--Q5
--------------------
select left(Company,48) as 'Company Name',
	LastName as Contact,
	--align left with width of 36
	left(Address,36) as 'Street Address'
	from Customer
	--display only where the company is not null and only 
	--from south american countries
	where Company is not null
	and Country in('Brazil','Chile','Argentina')
go
--------------------
--Q6
--------------------
select TrackId as 'Track ID',
	--align left with a width of 50
	left(Track.Name,50) as 'Title',
	Composer
	from Track
	--join the Genre and Track tables together and link the genre ids together
	inner join Genre on Track.GenreId = Genre.GenreId
	--display only where the name starts with 'Black' or the composer has 
	--letters 'verd' and the genre id is not rock, metal, rock and roll, latin, pop
	where (Track.Name like 'Black %' or Composer like '%verd%') and
	Genre.GenreId not in ('1','3','5','7','9') 
go
--------------------
--Q7
--------------------
declare @_costMin money = 2.75	--declare cost/min of $2.75
declare @_minMS int = 60000		--declare 1 min in milliseconds
select TrackId as 'Track ID',
	--convert to the properly displayed time format
	convert(varchar(15),DATEADD(ms,Milliseconds,0),114) as Time,
	--convert all values to floats to keep precision when dividing and then convert to money to get cost/minute
	cast(convert(float,UnitPrice)/(convert(float,Milliseconds)/convert(float,@_minMS)) as money) as 'Cost/Minute',
	--convert to floats to keep precision, and then multiply by 1000(millisecond to second) and cast it as a decimal to get byte/second
	cast(convert(float,Bytes)/convert(float,Milliseconds)*1000 as decimal(8,3)) as 'Bytes/Second'
	from Track
	--display only where time is greater than 1 minute and where cost/min is greater than $2.75
	where Milliseconds > @_minMS and
	UnitPrice/(cast(round(convert(float,Milliseconds)/convert(float,@_minMS),3,1) as money)) > @_costMin
go	
		
		
		
		

