-- =========================
-- Построение витрины
-- =========================
with 
payments as (
	select 
		order_id,
		sum(payment_value) as total_payment
	from olist_order_payments_dataset oopd 
	group by order_id
	),
items as (
	select
		order_id, 
		count(*) as items_count,
		sum(price) as total_price,
		sum(freight_value) as total_freight
	from olist_order_items_dataset ooid
	group by order_id
	),
base_table as (
	select 
		ood.order_id,
		ood.customer_id,
		ocd.customer_unique_id, 
		ood.order_purchase_timestamp,
		ood.order_status,
		i.items_count,
		i.total_price,
		i.total_freight,
		p.total_payment
	from olist_orders_dataset ood 
	left join payments p
		on ood.order_id = p.order_id
	left join items i
		on ood.order_id = i.order_id
	left join olist_customers_dataset ocd
		on ood.customer_id = ocd.customer_id),

-- =========================
-- Расчет основных метрик
-- =========================
clients_table as (
	select 
    	customer_unique_id,
    	count(*) as orders_per_client,
    	sum(total_payment) as revenue_per_client,
    	min(order_purchase_timestamp) as first_order,
    	max(order_purchase_timestamp) as last_order 
    from base_table
	where order_status = 'delivered'
	group by customer_unique_id 
	order by count(*) desc)

-- =========================
-- Расчет light-retention
-- =========================
select 
	round(100.0 * sum(case when orders_per_client > 10 then 1 else 0 end) / count(*), 3) as "10+ orders",
	round(100.0 * sum(case when orders_per_client >= 7  and orders_per_client <= 10 then 1 else 0 end) / count(*), 3) as "7 - 10 orders",
	round(100.0 * sum(case when orders_per_client >= 2  and orders_per_client < 7 then 1 else 0 end) / count(*), 3) as "2 - 6 orders",
	round(100.0 * sum(case when orders_per_client = 1 then 1 else 0 end) / count(*), 3) as "1 order",
	sum(case when orders_per_client > 1 then 1 else 0 end) * 100.0 / count(*) as repeat_rate,
	avg(orders_per_client) as avg_num_of_orders
from clients_table
