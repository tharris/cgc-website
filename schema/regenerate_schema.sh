#!/bin/bash
dbicdump -o dump_directory=../lib -o components='["InflateColumn::DateTime"]' -o debug=1 CGC::Schema 'dbi:mysql:dbname=cgc' root 3l3g@nz
