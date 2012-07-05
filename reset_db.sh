#!/bin/bash
DB=$1
mysqladmin -u root -p3l3g@nz drop $DB
mysqladmin -u root -p3l3g@nz create $DB
mysql -u root -p3l3g@nz $DB < schema/cgc.sql 
cd schema
./regenerate_schema.sh $DB
cd

