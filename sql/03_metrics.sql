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
		)

-- =========================
-- Основные метрики
-- =========================
	select 
		sum(total_payment) as revenue, 
		round((sum(total_payment) / count(distinct order_id))::numeric, 3) as AOV,
		round(avg(items_count), 3) as avg_items_count
	from base_table 
	where order_status = 'delivered'

-- =========================
-- Динамика по месяцам
-- =========================
select 
	date_trunc('month', order_purchase_timestamp) as month,
	count(distinct order_id) as orders_per_month, 
	sum(total_payment) as revenue_per_month,
	sum(items_count) as items_per_month,
	avg(items_count) as avg_items_per_order,
	round((sum(total_payment) / count(distinct order_id))::numeric, 3) as AOV_per_month,
	round(count(case when order_status = 'canceled' then 1 end) * 100.0 / count(*), 3) as "cancel_rate, %"
from base_table
group by date_trunc('month', order_purchase_timestamp)
