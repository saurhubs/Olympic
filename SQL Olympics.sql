create database Olympic

select*from events
select*from region


--1.	How many olympics games have been held?


select count(distinct games) as 'Total_games_held' from events


--2.	List down all Olympics games held so far.

select*from events

select distinct year,Season,city from events
order by year


--3.	Mention the total no of nations who participated in each olympics game?

select distinct games,count(distinct noc) as 'Total_nations' from events
group by games
order by games asc

--4.	Which year saw the highest and lowest no of countries participating in olympics?

with low_C as ( select top 1 e.games as lowest_country,COUNT(distinct r.region) as Lowest_no_of_country
  from events e
  join region r
  on e.noc=r.noc
  group by games),
  high_C as ( select top 1 e.games as higest_country,count(distinct r.region)as Higest_no_of_country
  from events e
  join region r
  on e.noc=r.noc
  group by games
  order by games desc)
  select 
     CONCAT(lowest_country,'  -  ',Lowest_no_of_country) as lowest_Countries,
	 concat(higest_country,'   -  ',Higest_no_of_country) as higest_countries
	 from low_C,high_C

--5.	Which nation has participated in all of the olympic games?

select  team,count( distinct games) as 'Total' from events
group by team
having count( distinct games)=(select count(distinct games) from events)
order by 'total' desc


--6.	Identify the sport which was played in all summer olympics.

select distinct sport from events

select  sport,count( distinct games) as No_of_games,
count( distinct games) as Total_games from events
group by sport
having count( distinct games)=(select count(distinct games )from events where Season='Summer')
order by Total_Games desc,Sport desc


--7.	Which Sports were just played only once in the olympics?


select distinct sport,count(distinct games) as Total_game from events
group by sport
having count(distinct games)=1
order by Total_game desc





--8.	Fetch the total no of sports played in each olympic games.
select*from events

select games from events
where season='Summer'

select distinct games,count(distinct Sport) as 'Total_Sport' from events
group by games
having games in (select games from events)
order by 'Total_Sport' desc

--9.	Fetch details of the oldest athletes to win a gold medal.
select*from events

select * from events
where medal='Gold' and age in (select distinct top 1 age from events
where Medal ='Gold' order by age desc)


--10.	Find the Ratio of male and female athletes participated in all olympic games.
SELECT top 1

concat('1:',
         round((select cast(count(sex) AS float) from events where sex='M')/
		 (select cast(count(sex) as float) from events where sex='F'),2)
		) as ratio
    


--11.	Fetch the top 5 athletes who have won the most gold medals.


select top 10 name,Team,count(medal) as 'Gold_medals'from events
where medal='Gold'
group by name,team
order by 'Gold_medals' desc


--12.	Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

select top 10 name,Team,count(medal) as 'Most_medals'from events 
where medal='Gold' or medal='Silver' or medal='Bronze'
group by name,team
order by 'most_medals' desc


--13.	Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
																																
select distinct top 5 r.region,count(medal) as most_medals ,
dense_rank()over(order by count(medal) desc)as rnk from  events e
join region r
on r.NOC=e.noc
where medal='Gold' or medal='Silver' or medal='Bronze'
group by e.NOC,r.region
order by most_medals desc

--14.	List down total gold, silver and broze medals won by each country.

SELECT
    r.region,
    Sum(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS total_gold,
    Sum(CASE WHEN medal ='Silver' THEN 1 ELSE 0 END) AS total_silver,
    Sum(CASE WHEN medal ='Bronze' THEN 1 ELSE 0 END) AS total_bronze
FROM
     events e
join region r
on r.NOC=e.noc
GROUP BY
    r.NOC,r.region
    order by  total_gold  desc

select*from events
/*15.	List down total gold, silver and broze medals won by each country corresponding to each 
olympic games*/

SELECT
    distinct r.region,e.Games,
    Sum(CASE WHEN medal ='Gold' THEN 1 ELSE 0 END) AS total_gold,
    Sum(CASE WHEN medal ='Silver' THEN 1 ELSE 0 END) AS total_silver,
    Sum(CASE WHEN medal ='Bronze' THEN 1 ELSE 0 END) AS total_bronze
FROM
    events e
	join region r
on r.NOC=e.noc
GROUP BY
    e.NOC,r.region,e.games
    order by e.games asc,r.region asc,total_gold desc

select*from events
--16.	Identify which country won the most gold, most silver and most bronze medals in each olympic games.

with t1 (games,region,no_gold,no_silver,no_bronze) as
   (select games,region,
    Sum(CASE WHEN medal ='Gold' THEN 1 ELSE 0 END) AS no_gold,
    Sum(CASE WHEN medal ='Silver' THEN 1 ELSE 0 END) AS no_silver,
    Sum(CASE WHEN medal ='Bronze' THEN 1 ELSE 0 END) AS no_bronze
FROM
    events e
	join region r
	on e.NOC=r.noc
GROUP BY
   Games ,region)
select distinct games,
    CONCAT((FIRST_VALUE(region) over (partition by games order by no_gold desc)),
	' - ', FIRST_VALUE (no_gold) over (partition by games order by no_gold desc)) as max_gold,
	CONCAT((FIRST_VALUE(region) over (partition by games order by no_silver desc)),
	' - ', FIRST_VALUE (no_silver) over (partition by games order by no_silver desc)) as max_silver,
	CONCAT((FIRST_VALUE(region) over (partition by games order by no_bronze desc)),
	' - ', FIRST_VALUE (no_bronze) over (partition by games order by no_bronze desc)) as max_bronze

from t1 
order by games


/*17.	Identify which country won the most gold, most silver,
most bronze medals and the most medals in each olympic games.*/

with t1 (games,region,no_gold,no_silver,no_bronze,no_total) as
   (select games,region,
    Sum(CASE WHEN medal ='Gold' THEN 1 ELSE 0 END) AS no_gold,
    Sum(CASE WHEN medal ='Silver' THEN 1 ELSE 0 END) AS no_silver,
    Sum(CASE WHEN medal ='Bronze' THEN 1 ELSE 0 END) AS no_bronze,
	sum(Case when Medal in ('Gold','Silver','Bronze') THEN 1 ELSE 0 END) as no_total
	
FROM
    events e
	join region r
	on e.NOC=r.noc
GROUP BY
   Games ,region)
select distinct games,
    CONCAT((FIRST_VALUE(region) over (partition by games order by no_gold desc)),
	' - ', FIRST_VALUE (no_gold) over (partition by games order by no_gold desc)) as max_gold,
	CONCAT((FIRST_VALUE(region) over (partition by games order by no_silver desc)),
	' - ', FIRST_VALUE (no_silver) over (partition by games order by no_silver desc)) as max_silver,
	CONCAT((FIRST_VALUE(region) over (partition by games order by no_bronze desc)),
	' - ', FIRST_VALUE (no_bronze) over (partition by games order by no_bronze desc)) as max_bronze,
    CONCAT((FIRST_VALUE(region) over (partition by games order by no_total desc)),
	' - ', FIRST_VALUE (no_total) over (partition by games order by no_total desc)) as MAX_Medal
from t1 
order by games




--18.	Which countries have never won gold medal but have won silver/bronze medals?

SELECT
    distinct r.region,
    sum(CASE WHEN e.medal ='Gold' THEN 1 ELSE 0 END) AS total_gold,
	sum(CASE WHEN e.medal ='Bronze' THEN 1 ELSE 0 END) AS total_bronze,
    sum(CASE WHEN e.medal ='Silver' THEN 1 ELSE 0 END) AS total_silver
FROM
     events e
	join region r
on r.NOC=e.noc
GROUP BY
    e.NOC,r.region
having sum(CASE WHEN e.medal ='Gold' THEN 1 ELSE 0 END)=0 and 
	(sum(CASE WHEN e.medal ='Bronze' THEN 1 ELSE 0 END) +
	sum(CASE WHEN e.medal ='Silver' THEN 1 ELSE 0 END))>=1
	
	order by total_bronze asc,total_silver desc

select distinct Games,region,medal from events	e
join region r
on e.NOC=r.NOC
where region='Fiji' 

--19.	In which Sport/event, India has won highest medals.

select distinct sport, count(medal) as Total_medal from events 
where Team='India' and Medal !='NA'
group by sport,medal
order by Total_Medal desc

----


create view india as
select Team ,Sport,Medal from events
where Team='India' and Medal in (select distinct medal from events where medal !='NA')

select top 1 sport,count(medal) as 'Total_Medals'from events
where Team='India' and Medal in (select distinct medal from events where medal !='NA')
group by sport
order by 'Total_Medals' desc


/*20.	Break down all olympic games where india won medal for Hockey and how many 
medals in each olympic games.*/
*/


select Team,games ,Sport,Medal from events
where Team='India' and Medal in (select distinct medal from events where medal !='NA')


select team,sport,games,count(sport)as Medals_in_Hockey from events
where Team='India' and CONCAT((FIRST_VALUE(region) over (partition by games order by no_gold desc)),
	' - ', FIRST_VALUE (no_bronze) over (partition by games order by no_bronze desc)) as max_bronze
group by games,sport,team
having sport='Hockey'
order by Medals_in_Hockey desc,games asc



----------------------------------------------------

      game_id = g.game_id
  );
  select*from region
  select e.noc,r.region from events e
  join region r
  on e.NOC=r.noc
  dbcc checkident
  coalesce
  with t1 as ( select top 1 e.games as lowest_country,COUNT(distinct r.region) as Lowerst_no_of_country
  from events e
  join region r
  on e.noc=r.noc
  group by games),
  t2 as ( select top 1 e.games as higest_country,count(distinct r.region)as Higest_no_of_country
  from events e
  join region r
  on e.noc=r.noc
  group by games
  order by games desc)
  select 
     CONCAT( lowest_country,'  -  ',Lowerst_no_of_country) as lowest_Countries,
	 concat(higest_country,'   -  ',Higest_no_of_country) as higest_countries
	 from t1,t2

	 ---------

	 16

with t1 (games,region,no_gold,no_silver,no_bronze) as
   (select games,region,
    Sum(CASE WHEN medal ='Gold' THEN 1 ELSE 0 END) AS no_gold,
    Sum(CASE WHEN medal ='Silver' THEN 1 ELSE 0 END) AS no_silver,
    Sum(CASE WHEN medal ='Bronze' THEN 1 ELSE 0 END) AS no_bronze
FROM
    events e
	join region r
	on e.NOC=r.noc
GROUP BY
   Games ,region)
select distinct games,
    CONCAT((FIRST_VALUE(region) over (partition by games order by no_gold desc)),
	' - ', FIRST_VALUE (no_gold) over (partition by games order by no_gold desc)) as max_gold,
	CONCAT((FIRST_VALUE(region) over (partition by games order by no_gold desc)),
	' - ', FIRST_VALUE (no_silver) over (partition by games order by no_silver desc)) as max_silver,
	CONCAT((FIRST_VALUE(region) over (partition by games order by no_gold desc)),
	' - ', FIRST_VALUE (no_bronze) over (partition by games order by no_bronze desc)) as max_bronze

from t1 
order by games
select * into emp2 from Emp 
select*from emp2