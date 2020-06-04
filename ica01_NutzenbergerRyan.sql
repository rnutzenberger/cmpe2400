--ica 02 Nutzenberger Ryan - Select some expressions
--q1

declare @packpct float = 1.0*(@@PACK_SENT/@@PACK_RECEIVED)*100		--declare a percentage of packets sent/received as a float. *not working*
select	SERVERPROPERTY ('ServerName') as Server,					--display the server name
		SUBSTRING(@@VERSION, 14,22) as Version,						--display the version and trim the unneeded bits
		@@ERROR as Error,											--display the errors encountered
		@@CONNECTIONS as Connections,								--display the number of connections
		@packpct as 'Rcvd %'										--display the packet percentage
		--received % isn't working

go
		

--q2
declare		@startdate datetime = '2000-10-31'			--declare the start date as a datetime variable
declare		@beforedate datetime = DATEADD(minute, -123456789, @startdate) --declare the date 123,456,789 minutes in the past

select  CAST (@startdate as varchar(12) )as Start,			--display the start date using a cast from datetime to varchar
		CONVERT(varchar(20), @beforedate,20) as Wayback		--display the before date using convert from datetime to varchar in the correct format 

go

--q3
declare		@currentday date = getdate()		--delcare the current date, using getdate()
declare		@christmas date = '2019-12-25'		--declare the day of christmas
declare		@daysleft int = DATEDIFF(DAY,@currentday,@christmas)	--take the difference of the two days to find out how many days until christmas
select		@daysleft as Days,			--display the number of days left
			CONVERT(varchar(20),@christmas,102) as XMas	--display the date of christmas in the correct format
go

--q4
declare		@month date	= getdate()			--declare the current date using getdate()
declare		@monthname varchar(24) = DATENAME(MONTH,@month)		--declare ONLY the month in varchar format
declare		@monthnum int = DATEPART(MONTH,@month)			--declare ONLY the month in int format


select		concat(@monthname , ' ', '(',@monthnum,')') as 'Name (#)',		--display the Month as a varchar and int in the same column
			IIF (5 <= @monthnum AND @monthnum <= 8 , 'Summer', 'Winter') as Season,		--check and display if the month falls under summer or winter
																						--winter is anything not in between May and August
																					    --summer is anything in between May and August
		    IIF(CHARINDEX('p',@monthname)>0,'Yup','Nope') as 'Gotta p'					--check and display if there is a 'p' in the month 
																						--september has the letter 'p', so it will display 'Yup'
																						--if it was october, it wuld display 'Nope'

		 

