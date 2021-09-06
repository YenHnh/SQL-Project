--check columns name and data type from a specific table
select column_name,data_type 
from information_schema.columns
where table_name='busiest';

--checking data from tables
select * from busiest;--busy date
select * from cal_price;--listing_id, calendar_date, price
select * from cal_price_2;--listing_id, date_month, sum_price
select * from calendar;--listing_id, calendar_date,available,price
select * from cheapest;--price, cheap_date
select * from cheapest1;--price_cheap_date

--checking tables that give permission 
select * from information_schema.table_privileges
order by table_privileges;

--checking tables that give permission with filter only tables from that database
select * from information_schema.table_privileges 
where grantee = 'dabc_student'
order by table_name;

--How many bussiest day are there?
select count(*)
from busiest
where busy_date is not null;

--Show listing that has null value on calender date
select distinct cp.listing_id,c.calender_date
from cal_price as cp right join calendar as c
on cp.listing_id = c.listing_id
where c.calender_date is null;

-- Create a label based on price
select distinct listing_id,price,
case
when price = 0 then 'Free'
when price>0 and price<=5000 then 'Cheap'
when price>5000 then 'Expensive'
else 'Not Determine'
end as "price determine"
from cal_price
order by "price determine" desc;

--Retrieve the calendar day of the listing id that is most expensive
with all_listing as
(select listing_id
from cal_price 
union
select listing_id
from cal_price_2)
select distinct al.listing_id, c.calender_date,c.price
from calendar as c join all_listing as al
on c.listing_id=al.listing_id
where c.price is not null
order by c.price desc
limit 1;

-- Put label on prices from previous table
with "new table" as (
with all_listing as
(select listing_id
from cal_price 
union
select listing_id
from cal_price_2)
select distinct al.listing_id, c.calender_date,c.price
from calendar as c join all_listing as al
on c.listing_id=al.listing_id
where c.price is not null
order by c.price desc)
select *,
case
when price = 0 then 'Free'
when price>0 and price<=5000 then 'Cheap'
when price>5000 then 'Expensive'
else 'Not Determine'
end as "price type"
from "new table"
order by "price type" desc;

--what is the month of the listing with most price in it
select distinct cp.listing_id,cp2.sum_price,cp2.date_month
from cal_price as cp join cal_price_2 as cp2
on cp.listing_id=cp2.listing_id
order by cp2.sum_price desc;

--what is the month of the listing with most price in it. Only show 1st quarter year
select distinct cp.listing_id,cp2.sum_price,cp2.date_month
from cal_price as cp join cal_price_2 as cp2
on cp.listing_id=cp2.listing_id
where cp2.date_month in (1,2,3)
order by cp2.sum_price desc;

--what is the month of the listing with most price in it.
--Only show listing that has total sum of price more than 30,000
select cp.listing_id, sum(cp2.sum_price) as "total sum"
from cal_price as cp join cal_price_2 as cp2
on cp.listing_id=cp2.listing_id
group by cp.listing_id
having sum(cp2.sum_price)>30000
order by sum(cp2.sum_price);

--A list of listing that is available in 't' and in the month of May
select distinct cp2.listing_id
from cal_price as cp join cal_price_2 as cp2
on cp.listing_id = cp2.listing_id
full join calendar as c 
on cp2.listing_id=c.listing_id
where c.price is not null 
   and c.available='t' 
   and cp2.date_month=5
order by cp2.listing_id;

--which do listing id make the most money from 2019-01 to 2019-02, include its availability as 'f'
with all_listing as
(select listing_id
from cal_price 
union
select listing_id
from cal_price_2)
select distinct al.listing_id,cp.price
from cal_price as cp full join cal_price_2 as cp2
on cp.listing_id=cp2.listing_id
full join calendar as c 
on cp2.listing_id=c.listing_id
full join all_listing as al
on c.listing_id=al.listing_id
where c.calender_date between '2019-01-01' and '2019-02-28' 
   and c.available = 'f' and cp.price is not null
order by cp.price desc
limit 1;

--Making a 1st quarter report based on revenue by first 3 months.
select cp2.date_month,sum(cp2.sum_price) as "total revenue",
       count(cp2.listing_id) as "number of listing"
from cal_price_2 as cp2 join calendar as c
on cp2.listing_id = c.listing_id
group by cp2.date_month
having cp2.date_month in (1,2,3)
order by cp2.date_month;
