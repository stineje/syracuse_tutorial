#!/bin/sh
netgen-lvs -noc << EOF
permute transistors
lvs $1 $2
quit
EOF
