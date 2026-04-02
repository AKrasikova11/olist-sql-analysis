-- =========================
--Очистка пустых строк
-- =========================
update olist_orders_dataset
set order_approved_at = null
where order_approved_at = '';

update olist_orders_dataset
set order_delivered_customer_date = null
where order_delivered_customer_date = '';

update olist_orders_dataset
set order_estimated_delivery_date = null
where order_estimated_delivery_date = '';

-- =========================
--Приведение дат
-- =========================
alter table olist_orders_dataset
alter column order_purchase_timestamp type timestamp
using order_purchase_timestamp::timestamp;

alter table olist_orders_dataset
alter column order_approved_at type timestamp
using order_approved_at::timestamp;

alter table olist_orders_dataset
alter column order_delivered_customer_date type timestamp
using order_delivered_customer_date::timestamp;

alter table olist_orders_dataset
alter column order_delivered_carrier_date type timestamp
using order_delivered_carrier_date::timestamp;

alter table olist_orders_dataset
alter column order_estimated_delivery_date type timestamp
using order_estimated_delivery_date::timestamp;
