#!/bin/bash
DB=$1
dbicdump -o dump_directory=../lib -o components='["InflateColumn::DateTime"]' -o debug=1 CGC::Schema "dbi:mysql:dbname=$DB" root 3l3g@nz
