use kaggle;

CREATE TABLE orders_kaggle (
    order_id VARCHAR(20),
    order_date DATE,
    ship_mode VARCHAR(50),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_id VARCHAR(20),
    cost_price DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    sale_price DECIMAL(10,2),
    profit DECIMAL(10,2)
);

use kaggle;
select * from kaggle.orders_kaggle ok limit 20 ;


-- find top 10 highest revenue generating products
select ok.product_id , sum(sale_price) sales
from kaggle.orders_kaggle ok 
group by product_id 
order by sales desc   -- you can directly use alias because order by executes after the select statement
limit 10;


-- find top 5 highest selling product in each region
with cte as (select ok.product_id ,ok.region, sum(ok.sale_price) as sales,
		dense_rank() over(partition by ok.region order by sum(ok.sale_price) desc ) as rnk
from kaggle.orders_kaggle ok 
group by ok.product_id ,ok.region)

select product_id,region,sales from cte where rnk <= 5;


-- find month over month growth comparison for 2022 and 2023 sales. e.g jan 2022 Vs jan 2023

with cte as (select year(ok.order_date) as order_year,
			month(ok.order_date) as order_month,
			sum(ok.sale_price) as total_sale
			from kaggle.orders_kaggle ok  
			group by year(ok.order_date),month(ok.order_date)
			-- order by year,month
			)

select order_month,
	--	order_year,
		sum(case when order_year = 2022 then total_sale else 0 end) as 2022_sales,
		sum(case when order_year = 2023 then total_sale else 0 end) as 2023_sales
from cte 
group by order_month
order by order_month;



-- Question: for each category which month had highest sales


with cte as (
select ok.category ,date_format(ok.order_date,'%Y-%m') as order_year_month,sum(ok.sale_price) total_sales 
from kaggle.orders_kaggle ok 
group by category,date_format(ok.order_date,'%Y-%m')
order by category, order_year_month
)

select * from(
select *, 
		row_number() over(partition by category order by total_sales desc) as cnt
from cte) as highest_sales__monthwise
where cnt = 1;


-- Question: which sub-category had highest growth by profit in Year 2023 compare to Year 2022

with cte as (select ok.sub_category , date_format(ok.order_date,'%Y') as order_year, sum(ok.sale_price) as total_sales
from kaggle.orders_kaggle ok 
group by sub_category, date_format(ok.order_date,'%Y')
-- order by sub_category, order_year
)
,cte_2 as (select sub_category,
		sum(case when order_year = 2022 then total_sales else 0 end) as year_2022,
		sum(case when order_year = 2023 then total_sales else 0 end) as year_2023
from cte
group by sub_category
-- order by sub_category 
)
select *,
		(year_2023 - year_2022)*100 / year_2022 as growth
from cte_2
order by growth desc































