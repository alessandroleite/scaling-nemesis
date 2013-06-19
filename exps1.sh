#!/bin/bash

##################################################################
#						Global Variables						 #
##################################################################
SLEEP_TIME_BETWEEN_EXPERIMENTS_IN_SECONDS=60
METER_SERIAL_PORT=$1

times=(5 10 15)
sizes=(10 20 30)
freqs=(2400000 2133000 1867000 1600000)

declare w_pid=0


echo "   Time values: ${times[*]}"
echo "  Matrix sizes: ${sizes[*]}"

#################################################################

clear
echo "Power consumption experiments"
echo "Today is `date`."
echo

echo "This is `uname -s` running on a `uname -m` processor."
echo

echo "This is the uptime information:"
uptime
echo


#Changes the CPU's frequency. The argument is the CPU frequency to be set.
set_cpu_freq()
{
  echo "`cpupower frequency-set -f $1`"
}

create_dir_if_not_exists()
{
  if [[ ! -a $1 ]];
  then 
    mkdir $1
  fi
}

#
# Creates the output directory. The arguments are: cpu frequency, matrix size, and the sleep time.
#
create_data_dir()
{
   FILE="$BASE_DIR/results/"

   create_if_not_exists $FILE

   FILE="$FILE/$1"
   create_if_not_exists $FILE

   FILE="$FILE/$2"
   create_if_not_exists $FILE
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
    echo "`kill -9 $w_pid`"
    echo "process $w_pid killed"    
    w_pid="0"    
}

# executes an experiment. The arguments are: cpu frequency, matrix size, and the sleep time.
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
     for ((k = 0; k < l_times; k++)) 
     do
       for ((j=0; j < l_sizes; j++))
       do
	      echo "f:${freqs[i]} m:${sizes[j]} t:${times[k]}"
          run_experiment ${freqs[i]} ${sizes[j]} ${times[k]}
          sleep $SLEEP_TIME_BETWEEN_EXPERIMENTS_IN_SECONDS
          finish_meter_logging
          wait
          commit ${freqs[i]} ${sizes[j]} ${times[k]}
       done
     done
  done
}

l_times=${#times[@]}
l_sizes=${#sizes[@]}
l_freqs=${#freqs[@]}

echo "CPU frequencies: ${freqs[*]}"
echo  "Matrices sizes: ${sizes[*]}"
echo  "  Times values: ${times[*]}"

experiments 

echo "That's all folks!"