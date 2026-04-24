#!/bin/bash

netgen -batch lvs "../lib/${DESIGN_TRACK}/ngspice/$1.spice $1" "../lib/xschem/${DESIGN_TRACK}/spice/$1.spice $1" ${PDK_ROOT}/gf180mcuC/libs.tech/netgen/gf180mcuC_setup.tcl $1.out