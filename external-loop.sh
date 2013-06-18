#!/bin/bash

##################################################################
# 			Global Variables 			 #
##################################################################
#Delay time between the experiments in seconds
DEFAULT_SLEEP_TIME=60
BASE_DIR=`pwd`
W_PORT="/dev/ttyUSB2"

#available CPU frequencies
cpu_freqs=(2400000 2133000 1867000 1600000)

#times in seconds
declare -a s_times

#matrix size
declare -a m_sizes

declare w_pid=0

#################################################################

clear
echo "Power consumption experiments"
echo "Today is `date`."
echo

echo "This is `uname -s` running on a `uname -m` processor."
echo

#echo "These users are currently connected:"
#w | cut -d " " -f 1 - | grep -v USER | sort -u
#echo

echo "This is the uptime information:"
uptime
echo

initialize()
{
  i="0"
  j="-1"

  # fill up the time's array
  while [ $i -lt 60 ]
  do
    let "j+=1"
    let "i+=5"
    s_times[j]=$(($i * 60))
  done
  
  #fill up the array's size
  for ((i=5, j=0; i <=40; i+=5, j+=1))
  do
    m_sizes[j]=$((i * 1000))
  done
}

#Changes the CPU's frequency. The argument is the CPU frequency to be set.
set_cpu_freq()
{
  echo "`cpupower frequency-set -f $1`"
}

#
# Creates the output directory. The arguments are: cpu frequency, matrix size, and the sleep time.
#
create_data_dir()
{
  FILE="$BASE_DIR/results/"

  echo "$FILE"

  if [[ ! -a $FILE ]];
  then 
    mkdir $FILE
  fi  

  FILE="$FILE/$1"

  if [[ ! -a $FILE ]];
  then
    mkdir $FILE
  fi
}

#starts the power meter logging. The arguments are: cpu frequency, matrix size, and the sleep time.
start_meter_logging()
{
	if [ "$w_pid" -eq "0" ] 		
	then
		create_data_dir $1 $2 $3
		output_file="$BASE_DIR/results/$1/$2_$3.csv"
		eval "(java -cp .:$BASE_DIR/lib/wattsupj-1.0.0-SNAPSHOT.jar -Dexport.file.path=$output_file wattsup.console.Console $W_PORT) &"
		w_pid=$!
	fi
  echo "w_pid -> $w_pid"
  return $w_pid
}

#Executes the matrix transposition. The arguments are: matrix size, and the sleep time.
transpose()
{
  "`$BASE_DIR/bin/mtranspose $1 $2`"
  PID=$!  
  return $PID
}

#Commits the results and send them to the remote repository.
commit()
{
   echo "`git add .`"
   echo "`git commit -am "experiment cpu frequency:$1, sleep time:$2, matrix size:$3"`"
   echo "`git push origin master`"
}

finish_meter_logging()
{
    #if ! kill $w_pid > /dev/null 2>&1; then
      # echo "Could not send SIGTERM to process $w_pid" >&2
    #fi
    echo "`kill -9 $w_pid`"
    echo "process $w_pid killed"    
    w_pid="0"    
}

# executes an experiment. The required arguments are: cpu frequency, matrix size, and the sleep time.
run_experiment()
{
  set_cpu_freq $1 & wait
  start_meter_logging $1 $2 $3
  transpose $2 $3
}

#Executes the experiments.
experiments()
{
  for ((i=0; i < l_freqs; i++))
  do
     for ((j=0; j < l_sizes; j++))
     do
       for ((k = 0; k < l_times; k++))
       do
	  echo "f:${cpu_freqs[i]} m:${m_sizes[j]} t:${s_times[k]}"
          run_experiment ${cpu_freqs[i]} ${m_sizes[j]} ${s_times[k]}
          sleep $DEFAULT_SLEEP_TIME
          finish_meter_logging
          wait
          commit
       done
     done
  done
}

initialize 

l_times=${#s_times[@]}
l_sizes=${#m_sizes[@]}
l_freqs=${#cpu_freqs[@]}

echo "  Times values: ${s_times[*]}"
echo "Matrices sizes: ${m_sizes[*]}"

experiments 

echo "That's all folks!"

