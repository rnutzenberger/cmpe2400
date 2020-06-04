----------------------------------------
--Ryan Nutzenberger Lab 1

----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- PART ONE - INTITIAL DB CREATION------------------------------------------------------------
-------------------------------------------------------------- GENERATE THE TABLES------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
--use [master]
--go

--if exists(select * from sys.databases where name = 'rnutzenberger1_Lab1')
--	drop database rnutzenberger1_Lab1
--go

--create database [rnutzenberger1_Lab1]
--go
---------------------------------------------------------------------------------------------

use [rnutzenberger1_Lab1]
go

IF OBJECT_ID('dbo.Sessions', 'U') IS NOT NULL
	DROP TABLE dbo.Sessions
IF OBJECT_ID('dbo.Bikes', 'U') IS NOT NULL
	DROP TABLE dbo.Bikes
IF OBJECT_ID('dbo.Riders', 'U') IS NOT NULL
	DROP TABLE dbo.Riders
IF OBJECT_ID('dbo.Class', 'U') IS NOT NULL
	DROP TABLE dbo.Class

---------------------------------------------------------
------------------- CLASS TABLE -------------------------
---------------------------------------------------------
create table [dbo].[Class]
(
	[ClassID] nchar(6) not null,
	[ClassDescription] nvarchar(51) not null
	CONSTRAINT [PK_Class] Primary key([ClassID])
)
go

---------------------------------------------------------
------------------- RIDERS TABLE ------------------------
---------------------------------------------------------
Create table [dbo].[Riders]
(

	[RiderID] int Identity(10,1) not null
		constraint [PK_Riders] Primary Key([RiderID]),
	[Name] nvarchar(50) not null
		constraint [CHK_Name] check (LEN([Name])>4),
	[ClassID] nchar(6) null

	constraint [FK_Riders_Class] Foreign key(ClassID) references Class(ClassID)
	
)
go
---------------------------------------------------------
------------------- BIKES TABLE -------------------------
---------------------------------------------------------
create table [dbo].[Bikes]
(
	[BikeID] nchar(6) not null
		constraint [PK_Bikes] Primary key(BikeID)
		constraint [CHK_BikeID] check([BikeID] like '[0-9][0-9][0-9][HYS]-[AP]'),
	[StableDate] date not null default GetDate()
		

)
go
---------------------------------------------------------
------------------- SESSIONS TABLE ----------------------
---------------------------------------------------------
create table [dbo].[Sessions]
(	
	[RiderID] int not null,
	[BikeID] nchar(6) not null,
	[SessionDate] datetime not null default GetDate()
		constraint [CHK_SessionDate] check ([SessionDate] > '1 Sep 2019'),
	[Laps] int null
	constraint [PK_Sessions] Primary key([SessionDate],[RiderID],[BikeID])

)
go

create nonclustered index NCI_RiderBike on [Sessions](BikeID, RiderID)
alter table [Sessions]
add constraint CHK_Laps check([Laps] > 0),
	constraint FK_Sessions_Riders foreign key(RiderID) references Riders(RiderID),
	constraint FK_Sessions_Bikes foreign key(BikeID) references Bikes(BikeID)

go

----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- PART TWO - STORED PROCEDURES --------------------------------------------------------------
-------------------------------------------------------------- ADD STORED PROCEDURES TO DB----------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------
--------------------------------------------- CLASS PROCEDURES ---------------------------------------------------
------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------
------------------ POPULATE CLASS -----------------------
---------------------------------------------------------
begin transaction
if exists(select * from sysobjects where name like 'PopulateClass')
	drop procedure PopulateClass
go


create procedure PopulateClass
@error varchar(max) out
as
--check to see if the table exists
	if not exists(select * from sysobjects where name like 'Class')
	begin
			set @Error = 'SP_PopulateClass Error : Class table does not exist'
			return -1
	end

	--it exists, so go ahead and populate the table
	insert into Class(ClassID,ClassDescription)
	values
		(N'moto_3', N'Default Chassis, custom 125cc engine'),
		(N'moto_2', N'Common 600cc engine and electronics, Custom Chassis'),
		(N'motogp', N'1000cc Full Factory Spec, common electronics')

	--if for some reason its returning not 3 rows, throw and error
	if @@ROWCOUNT <>3
	begin
		set @error = 'SP_PopulateClass Error : Rows returned is not the same as rows input'
		return 1
	end

	--everything is good, return 
	set @error = 'SP_PopulateClass : OK'
	return 0

go
rollback
commit

---------------------------------------------------------
------------------ REMOVE CLASS -------------------------
---------------------------------------------------------
begin transaction
if exists(select * from sysobjects where name like 'RemoveClass')
	drop procedure RemoveClass
go


create procedure RemoveClass
@ClassID nchar(6),
@error varchar(max) out
as
	--if ClassID is null, return
	if @ClassID is null or not exists(select * from Class where ClassID like @ClassID)
	begin
			set @Error = 'SP_RemoveClass Error : ClassID is null or does not exist'
			return -1
	end

	declare @RiderID int
	if exists(select * from Class where ClassID like @ClassID)
	begin
		if exists(select * from Riders where ClassID like @ClassID)
		begin
			if exists(select * from [Sessions] s join Riders r on s.RiderID = r.RiderID where r.ClassID = @ClassID)
			begin
				delete [Sessions]
					from Class c join Riders r on c.ClassID = r.ClassID
						join [Sessions] s on s.RiderID = r.RiderID
						where c.ClassID = @ClassID
			end

			delete Riders where ClassID = @ClassID
		end

		delete Class where ClassID = @ClassID
	end

	set @Error = 'SP_RemoveClass : OK'
	return 0


go
rollback
commit


---------------------------------------------------------
------------------ CLASS INFO ---------------------------
---------------------------------------------------------
begin transaction
if exists(select * from sysobjects where name like 'ClassInfo')
	drop procedure ClassInfo
go


create procedure ClassInfo
@ClassID nchar(6),
@RiderID int null,
@error varchar(max) out
as
	--if ClassID is null, return
	if @ClassID is null or not exists(select * from Class where ClassID like @ClassID)
	begin
			set @error = 'SP_ClassInfo Error : ClassID is null or does not exist'
			return -1
	end

	--if RiderID does not exist, return
	if not exists(select * from Class where ClassID like @ClassID)
	begin
			set @error = 'SP_ClassInfo Error : ClassID does not exist'
			return -1
	end

	if @RiderID is null
	begin 
		select * 
		from Class c left join Riders r on r.ClassID = c.ClassID
			left join [Sessions] s on s.RiderID = r.RiderID
			left join Bikes b on b.BikeID = s.BikeID
		where c.ClassID = @ClassID
	end

	if @RiderID is not null
	begin 
		select * 
		from Class c left join Riders r on r.ClassID = c.ClassID
			left join [Sessions] s on s.RiderID = r.RiderID
			left join Bikes b on b.BikeID = s.BikeID
		where c.ClassID = @ClassID and r.RiderID = @RiderID
	end

	set @error = 'SP_ClassInfo : OK'
	return 0

go
rollback
commit


---------------------------------------------------------
------------------ CLASS SUMMARY ------------------------
---------------------------------------------------------
begin transaction
if exists(select * from sysobjects where name like 'ClassSummary')
	drop procedure ClassSummary
go


create procedure ClassSummary
@ClassID nchar(6) = null,
@RiderID int null,
@error varchar(max) out
as

	--no ClassID restriction, no RiderID restriction
	if @ClassID is null and @RiderID is null
	begin 
		select c.ClassID,
			c.ClassDescription,
			r.Name,
			COUNT(s.SessionDate),
			AVG(COALESCE(s.Laps,0)),
			MIN(COALESCE(s.Laps,0)),
			MAX(COALESCE(s.Laps,0))
		from Class c left join Riders r on c.ClassID = r.ClassID
			left join [Sessions] s on s.RiderID = r.RiderID
		group by c.ClassID, c.ClassDescription, r.Name
	end

	--ClassID restriction, no RiderID restriction
	if @ClassID is not null and @RiderID is null
	begin 
		select c.ClassID,
			c.ClassDescription,
			r.Name,
			COUNT(s.SessionDate),
			AVG(COALESCE(s.Laps,0)),
			MIN(COALESCE(s.Laps,0)),
			MAX(COALESCE(s.Laps,0))
		from Class c left join Riders r on c.ClassID = r.ClassID
			left join [Sessions] s on s.RiderID = r.RiderID
		where c.ClassID = @ClassID
		group by c.ClassID, c.ClassDescription, r.Name
		
	end

	--no ClassID restriction, RiderID restriction
	if @ClassID is null and @RiderID is not null
	begin 
		select c.ClassID,
			c.ClassDescription,
			r.Name,
			COUNT(s.SessionDate),
			AVG(COALESCE(s.Laps,0)),
			MIN(COALESCE(s.Laps,0)),
			MAX(COALESCE(s.Laps,0))
		from Class c left join Riders r on c.ClassID = r.ClassID
			left join [Sessions] s on s.RiderID = r.RiderID
		where r.RiderID = @RiderID
		group by c.ClassID, c.ClassDescription, r.Name
	end

	--ClassID restriction, RiderID restriction
	if @ClassID is not null and @RiderID is not null
	begin 
		select c.ClassID,
			c.ClassDescription,
			r.Name,
			COUNT(s.SessionDate),
			AVG(COALESCE(s.Laps,0)),
			MIN(COALESCE(s.Laps,0)),
			MAX(COALESCE(s.Laps,0))
		from Class c left join Riders r on c.ClassID = r.ClassID
			left join [Sessions] s on s.RiderID = r.RiderID
		where c.ClassID = @ClassID and r.RiderID = @RiderID
		group by c.ClassID, c.ClassDescription, r.Name
	end

	set @error = 'SP_ClassSummary : OK'
	return 0

go
rollback
commit

------------------------------------------------------------------------------------------------------------------
--------------------------------------------- BIKES PROCEDURES ---------------------------------------------------
------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------
------------------ POPULATE BIKES -----------------------
---------------------------------------------------------
begin transaction
if exists(select * from sysobjects where name like 'PopulateBikes')
	drop procedure PopulateBikes
go


create procedure PopulateBikes
@error varchar(max) out,
@count int = 0
as
	--check to see if the table exists
	if not exists(select * from sysobjects where name like 'Bikes')
	begin
			set @Error = 'SP_PopulateBikes Error : Bikes table does not exist'
			return -1
	end

	--loop through to populate
	--should end up with 120 rows returned
	while @count < 20
	begin
		insert into Bikes(BikeID)
		values
			(format(@count, '000') + 'H-A'),
			(format(@count, '000') + 'H-P'),
			(format(@count, '000') + 'Y-A'),
			(format(@count, '000') + 'Y-P'),
			(format(@count, '000') + 'S-A'),
			(format(@count, '000') + 'S-P')
			
		set @count = @count + 1 
	end
	
	--return OK
	set @error = 'SP_PopulateBikes : OK'
	return 0

go
rollback
commit



------------------------------------------------------------------------------------------------------------------
--------------------------------------------- RIDERS PROCEDURES --------------------------------------------------
------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------
------------------ ADD RIDER ----------------------------
---------------------------------------------------------
begin transaction
if exists(select * from sysobjects where name like 'AddRider')
	drop procedure AddRider
go


create procedure AddRider
@Name nvarchar(50),
@ClassID nchar(6),
@error varchar(max) out

as
	--check if the table exists
	if not exists(select * from sysobjects where name like 'Riders')
		set @error = 'SP_AddRider Error : Table [Riders] does not exist'
		return 1

	--check if the name being input is null or empty
	--return with an error if it is
	if @Name is null or @Name like ''
	begin
		set @error = 'SP_AddRider Error : Name is null or empty'
		return 1
	end

	--check if the length of the name is less than 5
	--return with error if it is 
	if LEN(@Name) < 5
	begin
		set @error = 'SP_AddRider Error : Name must be longer than 4 characters'
		return 1
	end

	--check if the classID exists
	--if it does not, return with an error
	if @ClassID is not null and not exists(
		select ClassID from Class
		where ClassID like @ClassID)
	begin
		set @error = 'SP_AddRider Error : Class does not exist'
		return 1
	end

	--all is good, insert into riders table
	Insert into Riders(Name, ClassID)
	values (@Name, @ClassID)

	--return OK
	set @error = 'SP_AddRider : OK'
	return 0
go
rollback
commit

---------------------------------------------------------
------------------ REMOVE RIDER -------------------------
---------------------------------------------------------
begin transaction
if exists(select * from sysobjects where name like 'RemoveRider')
	drop procedure RemoveRider
go
create procedure RemoveRider
@RiderID int,
@Force bit = 0,
@error varchar(max) out
as
	--check if the riderID exists, if it does not then return with error
	if @RiderID is null or not exists(select * from Riders where RiderID like @RiderID)
	begin
		set @error = 'SP_RemoveRider Error : RiderID is null or does not exist'
		return 1
	end

	--if the riderID exists and force is 0
	if exists(select * from Riders where RiderID = @RiderID) and @Force = 0
	begin 
		--if the riderID exists within Sessions then throw an error
		if exists(select * from Sessions where RiderID like @RiderID)
		begin 
			set @error = 'SP_AddRider Error : RiderID already exists in Sessions Table'
			return 1
		end

		delete Riders where RiderID like @RiderID
	end
	--if the force bit is set to 1 then we remove from everything
	if @Force = 1
	begin
		delete Riders where RiderID like @RiderID
		delete [Sessions] where RiderID like @RiderID
	end

	set @error = 'SP_AddRider : OK'
	return 0
		
go
rollback
commit

------------------------------------------------------------------------------------------------------------------
--------------------------------------------- SESSIONS PROCEDURES ------------------------------------------------
------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------
------------------ ADD SESSION --------------------------
---------------------------------------------------------
begin transaction
if exists(select * from sysobjects where name like 'AddSession')
	drop procedure AddSession
go


create procedure AddSession
@RiderID int, 
@BikeID nchar(6),
@SessionDate datetime,
@error varchar(max) out
as
	--check if the riderID exists in Riders Table
	if @RiderID is null or not exists(select * from Riders where RiderID like @RiderID)
	begin	
		set @error = 'SP_AddSession Error : RiderID is null or does not exist'
		return 1
	end

	--check if the bikeID exists in Bikes Table
	if @BikeID is null or not exists(select * from Bikes where BikeID like @BikeID)
	begin 
		set @error = 'SP_AddSession Error : BikeID is null or does not exist'
		return 1
	end

	--check if the SessionDate is null or if SessionDate is before Sep 01 2019
	if @SessionDate is null or datediff(day,'1 Sep 2019',@sessionDate) < 0
	begin
		set @error = 'SP_AddSession Error : SessionDate is null or SessionDate must be after 1 Sep 2019'
		return 1
	end

	--all is good, insert into Sessions
	insert into [Sessions](RiderID,BikeID,SessionDate,Laps)
	values (@RiderID,@BikeID,@SessionDate,0)

	set @error = 'SP_AddSession : OK'
	return 0

go
rollback
commit

---------------------------------------------------------
------------------ UPDATE SESSION -----------------------
---------------------------------------------------------
begin transaction
if exists(select * from sysobjects where name like 'UpdateSession')
	drop procedure UpdateSession
go


create procedure UpdateSession
@RiderID int, 
@BikeID nchar(6),
@SessionDate datetime,
@Laps int,
@error varchar(max) out
as
	
	--if RiderID is null, error and return
	if @RiderID is null or not exists(select * from Sessions where RiderID like @RiderID)
	begin
		set @error = 'SP_UpdateSession Error : RiderID is null or does not exist'
		return 1
	end

	--if BikeID is null, error and return
	if @BikeID is null or not exists(select * from Sessions where BikeID like @BikeID)
	begin
		set @error = 'SP_UpdateSession Error : BikeID is null or does not exist'
		return 1
	end

	--if SessionDate is null, error and return
	if @SessionDate is null or datediff(day,'1 Sep 2019',@sessionDate) < 0
	begin
		set @error = 'SP_UpdateSession Error : SessionDate is null must be after 1 Sep 2019'
		return 1
	end

	--if the Session does not exist then error and return
	if not exists(select * from Sessions where RiderID like @RiderID and BikeID like @BikeID and SessionDate like @SessionDate)
	begin
		set @error = 'SP_UpdateSession Error : Session does not exist'
		return 1
	end

	--get the previous amount of laps to compare the new amount
	declare @prevLaps int
	select
	@prevLaps = Laps
	from [Sessions] 
	where RiderID = @RiderID and BikeID = @BikeID and SessionDate = @SessionDate

	if @Laps < @prevLaps
	begin
		set @error = 'SP_UpdateSession Error : Laps must be greater than the previous amount of laps'
		return 1
	end

	Update [Sessions]
	set Laps = @Laps
	where RiderID = @RiderID and BikeID = @BikeID and SessionDate = @SessionDate

	set @error = 'SP_UpdateSession : OK'
	return 0
go
rollback
commit




----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------- PART THREE - TEST SCRIPTS -----------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------

