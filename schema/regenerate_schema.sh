#!/bin/bash

DB=${1:-cgc}
USER=${2:-root}
PASS=${3:-root}

dbicdump -o dump_directory=./lib \
	-o components='["InflateColumn::DateTime"]' \
	-o debug=1
    CGC::Schema "dbi:mysql:dbname=$DB" $USER $PASS