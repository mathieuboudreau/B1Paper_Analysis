#!/bin/bash
# Resample minc file like a template, then creates a binary mask.

# args
TEMPLATE=$1
SRC=$2
OUTBRAIN=$3
OUTMASK=$4

(mincresample -clobber -like $TEMPLATE $SRC $OUTBRAIN)

(minccalc -clobber -expression 'abs(A[0])<0.001?0:1' $OUTBRAIN $OUTMASK)