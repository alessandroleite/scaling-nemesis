#!/bin/bash

SERIAL_PORT=$1
SCRIPT_NAME="${0##*/}"

echo "$SCRIPT_NAME:Meta"

BASE_DIR=`pwd`

echo "$SCRIPT_NAME:External loop"
echo "`$BASE_DIR/exps3.sh $SERIAL_PORT`"
echo "`date`"
echo

sleep 10

echo "$SCRIPT_NAME:Set the CPU frequency to 2.4 GHz; creates a matrix_(30,000 x 30,000), sleep for 12 hours and after that transpose the matrix one time."
echo "`$BASE_DIR/exps4.sh $SERIAL_PORT`"
echo "`date`"
echo

sleep 10

echo "$SCRIPT_NAME:The same as the script 3 but with the data in descending order."
echo "`$BASE_DIR/exps5.sh $SERIAL_PORT`"
echo "`date`"
echo

echo "That's all folks!"
