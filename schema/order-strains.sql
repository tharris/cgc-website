select distinct(strain.name), freezer.name, freezer_sample.freezer_location
  from app_order
       left join app_order_contents
              on app_order_contents.order_id = app_order.id
       left join strain
              on strain.id = app_order_contents.strain_id
       left join freezer_sample
              on freezer_sample.strain_id = strain.id
       left join freezer on freezer_sample.freezer_id = freezer.id
 order by freezer_location;

select * from freezer left join freezer_sample on freezer_sample.freezer_id = freezer.id where
strain_id = 3828;
