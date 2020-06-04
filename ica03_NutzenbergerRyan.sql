--ica 03 Nutzenberger Ryan - Control Flow/Looping
------------
--Q1
------------
declare @rnd int = round(Rand()*99+2,0,1)	--declare a random number as an int
declare @yesNo varchar(3)					--yes/no variable to determine the factor

	if @rnd%3 = 0					--if rnd is evenly divisible by 3
		set @yesNo = 'Yes'			--set yes
	else 
		set @yesNo = 'No'			--else set no
select @rnd as 'Random Number',		--diplay the random number
	   @yesNo as 'Factor of 3'		--display the output
go
----------
--Q2
----------
declare @rndMin int = round(Rand()*59+2,0,1)	--declare a random number as an int
declare @message varchar(50)		--declare the message as a varchar

--make a searching case statement to set the  
--appropriate statement based on when the random number is within each parameter
set @message =
	case
		--when the number is less than 15, its on the hour
		when @rndMin < 15 then 'On the hour'
		--when the number is between 15 and 30, then its a quarter past
		when @rndMin >= 15 and @rndMin < 30 then 'Quarter past'
		--when the number is between 30 and 45, then its half past
		when @rndMin >= 30 and @rndMin < 45 then 'Half past'
		--everything after 45 is a quarter to 
		else 'Quarter to'
	end
	--display the results
select	@rndMin as Minutes,
		@message as Ballpark

go

----------------
--Q3
----------------
declare @currentDay int = datepart(w,getdate()-1)	--declare the current day as a day of the week from 0-6(0 being sunday, the start of the week
													--and 6 being saturday, the last day of the week)
declare @whatDay varchar(10)		--declare what day it is for the matching case statement 

--case statement to figure out whether its a weekday or weekend
set @whatDay = 
	case 
	--if it is either 0 or 6 then its a weekend
		when @currentDay = 0 then 'Yahoo'
		when @currentDay = 6 then 'Yahoo'
		--else its a weekday
		else 'Got Class'
	end
	--display the output
select	@currentDay as 'Day Number',
		@whatDay as Status
go

------------------
--Q4
------------------
declare @iterations int = round(Rand()*10001,0,1)	--declare the number of iterations to be a random number between 1 and 10000  
declare @rndVal int			--declare a random value to be used for the if statement
declare @byTwo int = 0		--declare a count for factors of 2
declare @byThree int = 0	--declare a count for factors of 3
declare @byFive int = 0		--declare a count for factors of 5
declare @count int = 0		--declare a count to compare with number of iterations
--while the count is less than the total iterations generated
while @count < @iterations
begin
--set a new random value from 1-10 
set @rndVal = round(Rand()*9+2,0,1)
	--if the value is a factor of 2, increment the byTwo count 
	if @rndVal % 2 = 0
		set @byTwo = @byTwo + 1
	--if the value is a factor of 3, increment the byThree count
	else if @rndVal % 3 = 0
		set @byThree = @byThree + 1
	--if the value is a factor of 5, increment the byFive count
	else if @rndVal % 5 = 0
		set @byFive = @byFive + 1
	--increment the current count of the loop
	set @count = @count + 1
end
--display the output 
select	@iterations as 'Number of Iterations',
		@byTwo as 'Factor of 2',
		@byThree as 'Factor of 3',
		@byFive as 'Factor of 5'
go

-------------
--Q5
-------------
declare @inVal int = 0					--declare the number of times the hypotenuse is within the circle
declare @tries int = 0					--delcare the number of tries
declare @pointX int						--declare x coord
declare @pointY int						--declare y coord
declare @hypot float					--declare hypotenuse
declare @estPI decimal(10,9)			--declare the estimated PI value
declare @estError decimal(10,9) = 1.0	--declare the estimated error compare to PI
declare @Error decimal(10,5) = 0.00002  --declare the allowanace of error

--while the tries are less than 1000 and the estimated error is not within spec
while @tries < 1000 and @estError > @Error
begin
	--increment the # of tries
    set @tries = @tries + 1
	--set a new random point for x and y
	set @pointX = round(Rand()*101,0,1)
	set @pointY = round(Rand()*101,0,1)
	--use pythagorean theorum to get the squared hypotenuse
	set @hypot  = square(@pointX) + square(@pointY)
	--if the hypotenuse is less than or equal to 100, then increment the number of "in" times
	if sqrt(@hypot) <= 100
		set @inVal = @inVal + 1
		--calculate the estimated PI for the current iteration
		set @estPI = round((convert(float,@inVal)/convert(float,@tries))*4.0,9,1)
	--calculate the estimated error and this will compare the whether it within spec of the while loop
	set @estError = abs(@estPI - PI())		
end
--display the output
select	@estPI as Estimate,
		PI() as PI,
		@inVal as 'In',
		@tries as Tries

go




		


