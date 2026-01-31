use airport_db;
select * from airports2;


select
     Origin_Airport,
     Destination_Airport,
     SUM(Passengers) as Total_passengers
from 
	airports2
group by
	Origin_airport,
    Destination_airport
order by
	Total_passengers desc;
    
    
    
##QUE2>> IDENTIFY HIGHEST AND LOWEST SEAT OOCCUPANCY >> OPTIMIZE FLIGHT OCCUPANCY >> IMPROVE OPERATIONAL EFFICIENCY
## utility of cast(pas..as float) >> in sql if integer is divided by integer we get integral result, if float ans... then also integer

select
     Origin_Airport,
     Destination_Airport,
     avg((cast(Passengers as float))/(nullif(Seats,0)))*100 as Total_seats_occup
from 
	airports2
group by
	Origin_airport,
    Destination_airport
order by
	Total_seats_occup desc;
	  
      
##QUE3 >> FIND OUT MOST FREQUENT TRAVEL ROUTE >>  OPTIMISE RESOURCE ALLOCATION >> 

select 
	origin_airport,
    destination_airport,
    sum(passengers) as total_passengers
from
	airports2
group by
	origin_airport,
    destination_airport
order by
	total_passengers desc
    limit 5;
    
    
## QUE4 >> FIND OUT THE ACTIVITY LEVEL OF ORIGIN CITY

select  
	Origin_city,
    count(flights) as total_flights,
    sum(passengers) as total_pass
from 
	airports2
group by
	Origin_city
order by
	total_flights desc;
    
    
## QUE5 >> task is to look for travel patterns for future route planning >> Calculate total distance for flights originating from each airport

select 
	origin_airport,
    sum(Distance) as total_distance
from
	airports2
group by
	Origin_airport
order by
	total_distance desc;
    
## QUES6 >> FIND OUT SEASONAL TREND

 select
	year(fly_date) as year,
    month(fly_date) as month,
    count(flights) as totat_flights,
    sum(passengers) as total_passengers,
    avg(distance) as avg_distance
from
	airports2
group by 
	year,
    month
order by
	year desc,
	total_passengers desc;
    
    
    
## QUE6 >> IDENTIFY UNDERUTILIZED ROUTES >> WANT TO MAKE PROPER CAPACITY MANAGEMENT

select
    Origin_airport,
    Destination_airport,
    SUM(Passengers) as total_pass,
    SUM(Seats) as total_seats,
    (CAST(SUM(Passengers) AS FLOAT) / NULLIF(SUM(Seats), 0)) as Pass_to_seats_ratio
from
    airports2
group by
    Origin_airport,
    Destination_airport
Having
    Pass_to_seats_ratio < 0.5
order by
    Pass_to_seats_ratio;


## QUE7 >> MOST AACTIVE AIRRPORT >> HIGHEST FREQUENCY OF FLIGHT >> AIRLINE AND STACKHOLDERS CAN OPTIMIZE

Select
	Origin_airport,
    count(Flights) as total_flight
from
	airports2
group by
	Origin_airport
order by
	total_flight desc
    limit 5;
    

## QUE8 >> NUMBER OF PASSENGER AND FLIGHTS GOING TO ONE PARTICULAR DESTINATION

select
	Origin_airport,
    sum(Passengers) as total_pass,
    count(Flights) as total_flight
from
	airports2
where
	Destination_airport = "RDM" and
    Origin_airport <> "RDM"
Group by
	Origin_airport
Order by
	total_flight desc
    Limit 3;
		
    
## QUE9 >> MAX EXTENSIVEE TRAVEL CONNECTION >> FLIGHT WHICH TRAVEL MAXIMUM DISTANCE

select
	Origin_airport,
    Destination_airport,
    max(Distance) as max_distance
from
	airports2
Group by
	Origin_airport,
    Destination_airport
Order by
	max_distance desc
    Limit 3;


## QUE10 >> SEASONAL TREND INSIGHTS >> MOST AND LEAST COUNT OF FLIGHTS ACROSS YEARS

with Monthly_flights as 
(select
	month(Fly_date) as Month,
    count(Flights) as total_flights
from
	airports2
group by
	month(Fly_date))
select
	Month,
    total_flights,
    CASE
    when total_flights = (select max(total_flights) from monthly_flights) then 'MOST BUSY'
    when total_flights = (select min(total_flights) from monthly_flights) then 'LEAST BUSY'
    ELSE null
	end as status
from 
    monthly_flights
where 
	total_flights = (select max(total_flights) from monthly_flights) or
    total_flights = (select min(total_flights) from monthly_flights);
    
    
## QUE11 >> ANALYSIS ON PASSENGERS TRAFFIC TREND OVER TIME >> calculate year over year percentage growth in passenger  

with passenger_summmary as 
(select
	Origin_airport,
    Destination_airport,
    year(Fly_date) as Year,
    sum(Passengers) as total_pass
from
	airports2
group by
	Origin_airport,
    Destination_airport,
    year(fly_date)),
 Passenger_growth as  
(select
	Origin_airport,
    Destination_airport,
    Year,
    total_pass,
    LAG(total_pass) over
    (partition by origin_airport, destination_airport order by Year) as previous_year_passenger
from
	passenger_summmary) 
    
(select
	Origin_airport,
    Destination_airport,
    Year,
    total_pass,
    CASE
    when previous_year_passenger is not null then
    (cast((total_pass-previous_year_passenger) as float)/nullif(previous_year_passenger,0)) 
    end as growth_percentage
from
	passenger_growth)
    
order by
	Origin_airport,
    Destination_airport,
    Year;
    
    
## QUE12 >> TRENDING ROUTE >> YEAR TO YEAR CONSISTEENT FLIGHT GROWTH
## steps >> FLIGHT SUMMARY(USING COUNT FN.) >> FLIGHT GROWTH (USING LAG FN.) >> GROWTH RATE


with flights_summary as
(select
	Origin_airport,
    Destination_airport,
    year(fly_date) as Year,
    count(flights) as Total_flights
from
	airports2
group by
   Origin_airport,
    Destination_airport,
    year(fly_date)),
		
flight_growth as
(select
	Origin_airport,
    Destination_airport,
	Year,
    Total_flights,
    lag(Total_flights) over
    (partition by Origin_airport,Destination_airport order by year) as previous_year_flights
from
	flights_summary),
   Growth_Rates as 
(select
    Origin_airport,
    Destination_airport,
	Year,
    Total_flights,
    CASE
    when previous_year_flights is not null then
    (cast((Total_flights-previous_year_flights) as float)/nullif(previous_year_flights,0))
	end as growth_rate,
    CASE
    when previous_year_flights is not null and Total_flights > previous_year_flights then
    1
    else 0
    end as growth_indicator
FROM 
	flight_growth
order by
	 Origin_airport,
    Destination_airport,
	Year)
    
select
     Origin_airport,
    Destination_airport,
    max(growth_rate) as Max_growth_rate,
    min(growth_rate) as Min_growth_rate
from
	Growth_Rates
where
	growth_indicator = 1
group by
	Origin_airport,
    Destination_airport
order by
	Origin_airport,
    Destination_airport;
    
## QUE13 >> PASSENGER TO SEAT RATIO BASED ON TOTAL NO. OF FLIGHTS >> HERE WE WANT TO SEE OPERATIONAL EFFICIENCY AND FLIGHT VOLUME
## STEPS >> UTILIZATION EFFICIENNCY >> WEIGHTED UTILIZATION

with utilization_efficiency as
(select
	Origin_airport,
    sum(Passengers) as Total_pass,
    sum(Seats) as Total_Seats,
    count(Flights) as Total_flights,
    (sum(Passengers)*1.0/nullif(sum(Seats),0)) as paas_to_seat_ratio
from
	airports2
group by
	Origin_airport),
 
 weighted_utilization as
(select
	Origin_airport,
    Total_pass,
    Total_Seats,
    Total_flights,
    paas_to_seat_ratio,
	(paas_to_seat_ratio*Total_flights)/sum(Total_flights)
    over() as weighted_utilization
from
	utilization_efficiency)
    
select
	Origin_airport,
    Total_pass,
    Total_Seats,
    Total_flights,
    paas_to_seat_ratio,
    weighted_utilization
from
	weighted_utilization
order by
	weighted_utilization desc
	limit 3;
    
    
## QUE14 >> SEASONAL TRAVEL PATTERN BASED ON SPECIFIC CITY 
## PEAK TRAFFIC MONTH FROM EACH CITY WITH HIGHEST NO. OF PASSENGER 
## STEPS >> MONTHLY PASSENGER COUNT >> MAX PASSENGER BASED ON CITY >> PEAK MONTH

WITH Monthly_Paasenger_count AS (
    SELECT
        origin_city,
        YEAR(fly_date) AS Year,
        MONTH(fly_date) AS Month,
        SUM(passengers) AS total_passenger
    FROM airports2
    GROUP BY
        origin_city,
        Year,
        Month
),

Max_Passengers_per_city AS (
    SELECT
        origin_city,
        MAX(total_passenger) AS peak_passengers
    FROM Monthly_Paasenger_count
    GROUP BY
        origin_city
)

SELECT
    mpc.origin_city,
    mpc.Year,
    mpc.Month,
    mpc.total_passenger
FROM Monthly_Paasenger_count mpc
JOIN Max_Passengers_per_city mp
    ON mpc.origin_city = mp.origin_city
   AND mpc.total_passenger = mp.peak_passengers
ORDER BY
    mpc.origin_city,
    mpc.Year,
    mpc.Month;


    


    
    
    
    
    
