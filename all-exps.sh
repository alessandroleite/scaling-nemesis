#!/bin/bash

SERIAL_PORT=$1
echo "Meta"

BASE_DIR=`pwd`

echo "External loop"
echo "`$BASE_DIR/exps3.sh $SERIAL_PORT`"
echo "`date`"
echo

sleep 10

echo "Set the CPU frequency to 2400000; transpose the matrix and sleep during 12 hours."
echo "`$BASE_DIR/exps4.sh $SERIAL_PORT`"
echo "`date`"
echo

sleep 10

echo "The same as the script 3 but with the data in descending order."
echo "`$BASE_DIR/exps5.sh $SERIAL_PORT`"
echo "`date`"
echo

echo "That's all folks!"
