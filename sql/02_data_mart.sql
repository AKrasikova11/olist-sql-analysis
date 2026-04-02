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
