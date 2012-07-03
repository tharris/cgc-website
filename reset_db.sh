#!/bin/bash
mysqladmin -u root -p3l3g@nz drop cgc
mysqladmin -u root -p3l3g@nz create cgc
mysql -u root -p3l3g@nz cgc < schema/cgc.sql 
cd schema
./regenerate_schema.sh
cd
#./util/import/wormbase/get_genes.pl
