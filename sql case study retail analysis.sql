create database retail_analytics;
use retail_analytics;
alter table sales_transaction
rename column ï»¿TransactionID to TransactionID;
alter table product_inventory
rename column ï»¿ProductID to ProductID;
-- 1
select transactionid,count(*)
from sales_transaction
group by transactionid
having count(*)>1;
create table tb as 
(select distinct * from sales_transaction);
drop table sales_transaction;
alter table tb
rename to sales_transaction;
-- 2
select transactionid,p.price inventoryprice,s.price transactionprice
from sales_transaction s
join product_inventory p on s.ProductID=p.productid
where s.price<>p.price;
update sales_transaction s
set s.price=(select p.price from product_inventory p where s.productid=p.productid)
where productid in (select productid from product_inventory p where s.price<>p.price);
-- 3
select count(*)
from customer_profiles
where location is null;
update customer_profiles
set location='unknown'
where location is null;
select * from customer_profiles;
-- 4
create table tb as
select *,cast(transactiondate as date) as transactiondate_updated
from sales_transaction;
drop table sales_transaction;
alter table tb
rename to sales_transaction;
select * from sales_transaction;
-- 5
select productid,sum(quantitypurchased) Totalunitsold,sum(price*quantitypurchased) Totalsales
from sales_transaction
group by productid
order by Totalsales desc;
-- 6
select customerid,count(transactionid) NumberofTransactions
from sales_transaction
group by customerid
order by NumberofTransactions desc;
-- 7
select p.category category,sum(quantitypurchased) Totalunitssold,sum(s.quantitypurchased*p.price) Totalsales
from sales_transaction s
join product_inventory p on s.productid=p.productid
group by category
order by Totalsales desc;
-- 8
select productid,sum(quantitypurchased*price) TotalRevenue
from sales_transaction
group by productid
order by TotalRevenue desc
limit 10;
-- 9
select productid,sum(quantitypurchased) Totalunitssold
from sales_transaction
group by productid
having Totalunitssold>=1
order by Totalunitssold asc
limit 10;
-- 10
select cast(Transactiondate as date) Datetrans,count(Transactionid) transaction_count,sum(quantitypurchased) Totalunitssold,sum(quantitypurchased*price) totalsales
from sales_transaction
group by Datetrans
order by Datetrans desc;
-- 11
select month,total_sales,lag(total_sales) over (order by month) previous_month_sales,(total_sales-lag(total_sales) over (order by month))*100/ total_sales as mom_growth_percentage
from 
(select month(cast(transactiondate as date)) month,sum(price*quantitypurchased) total_sales
from sales_transaction
group by month) t
order by month;
-- 12
select customerid,count(transactionid) NumberofTransactions,sum(price*quantitypurchased) Totalspent
from sales_transaction
group by customerid
having NumberofTransactions>10 and Totalspent>1000
order by Totalspent desc;
-- 13
select CustomerID,count(transactionid) NumberofTransactions,sum(price*quantitypurchased) TotalSpent
from sales_transaction
group by customerid
having Numberoftransactions<=2
order by Numberoftransactions,Totalspent desc;
-- 14
select customerid,productid,count(productid) timespurchased
from sales_transaction
group by customerid,productid
having timespurchased>1
order by timespurchased desc;
-- 15
select customerid,min(transactiondate) firstpurchase,max(transactiondate) lastpurchase,datediff(max(transactiondate),min(transactiondate)) daysbetweenpurchases
from
(select *,cast(transactiondate as date) updatedtransactiondate
from sales_transaction) t
group by customerid
having daysbetweenpurchases>0
order by daysbetweenpurchases;
-- 16
create table customer_segements as
select customerid,case when totalquantity between 1 and 10 then 'Low'
when totalquantity between 11 and 30 then 'Mid'
when totalquantity>30 then 'High'
else 'none' end as customersegment
from
(select cp.customerid,sum(quantitypurchased) totalquantity
from sales_transaction st
join customer_profiles cp on st.customerid=cp.customerid
group by customerid) new;

select customersegment,count(*)
from customer_segements
group by customersegment
order by customersegment