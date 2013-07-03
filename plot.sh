#!/bin/bash

BASEDIR="`pwd`"
EXPDIR="$BASEDIR/$1"
FREQS="`ls $EXPDIR`"

R_SCRIPT="$BASEDIR/r-scripts/plot.R"

for freq in $FREQS 
do
  cd $EXPDIR/$freq
  matrices="`find . -mindepth 1 -maxdepth 1 -type d  \( ! -iname ".*" \) | sed 's|^\./||g'`" 
  for m in $matrices
  do
   echo "`RScript $R_SCRIPT $EXPDIR/$freq/$m/ $m $m.png`"
  done
done 
