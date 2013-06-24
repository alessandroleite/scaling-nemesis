#!/bin/bash

##################################################################
#		        Global Variables			 #
##################################################################
SIXTY_SECONDS=60
SERIAL_PORT=$1
BASE_DIR=`pwd`
NOW="`date +"%Y-%m-%d_%H-%M"`"

freqs=(2400000 2133000 1867000 1600000)
sizes=(30000 20000 10000)
#five, ten and fifteen minutes
times=(300 600 900)

declare w_pid=0
declare n_iter=10

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
# Creates the output directory. The arguments are: cpu frequency, matrix size, the sleep time, and the number of iterations.
# The output is: $BASE_DIR/results/$date/$iteration/$cpu_frequency/$matriz_size, where date is the current date and time in the following format: yyyy-mm-dd_HH-MM.
#
create_data_dir()
{
#   NOW="`date +"%Y-%m-%d_%H-%M"`"
    #NOW="`date +"%Y-%m-%d"`"

   FILE="$BASE_DIR/results/"
   create_dir_if_not_exists $FILE

   FILE="$BASE_DIR/results/$NOW/"
   create_dir_if_not_exists $FILE

   FILE="$FILE/$4"
   create_dir_if_not_exists $FILE

   FILE="$FILE/$1"
   create_dir_if_not_exists $FILE

   FILE="$FILE/$2"
   create_dir_if_not_exists $FILE   
}

#starts the power meter logging. The arguments are: cpu frequency, matrix size, sleep time and the number of iterations.
start_meter_logging()
{
	if [ "$w_pid" -eq "0" ] 		
	then
		create_data_dir $1 $2 $3 $4
		output_file="$BASE_DIR/results/$NOW/$4/$1/$2/$3.csv"
		eval "(java -cp .:$BASE_DIR/lib/wattsupj-1.0.0-SNAPSHOT.jar -Dexport.file.path=$output_file wattsup.console.Console $SERIAL_PORT) &"
		w_pid=$!
	fi
  echo "w_pid -> $w_pid"
  sleep $SIXTY_SECONDS
  return $w_pid
}

#Executes the matrix transposition. The arguments are: matrix size, the sleep time, number of iterations and the meter's pid.
transpose()
{
  echo "`$BASE_DIR/bin/mtranspose $1 $1 $2 $3 $4`"
  PID=$!  
  return $PID
}

#Commits the results and push to remote repository.
commit()
{
   echo "`git add .`"
   echo "`git commit -am "experiment cpu frequency:$1, sleep time:$2, matrix size:$3,$4"`"
   echo "`git push origin master`"
}

finish_meter_logging()
{
    echo "`kill -9 $w_pid`"
    echo "process $w_pid killed"    
    w_pid="0"    
}

flush()
{
	sleep $SIXTY_SECONDS
	sync
	sleep $SIXTY_SECONDS
	sync
}

# Configures the frequency of the CPU and connect to the power meter to record the energy consumption every each one second. 
# The arguments are: cpu frequency, matrix size, the sleep time, and the number of iterations.
configure_environment()
{
  set_cpu_freq $1 & wait
  start_meter_logging $1 $2 $3 $4
}

#
experiments()
{
  for ((i=0; i < l_freqs; i++))
  do
     for ((k = 0; k < l_times; k++)) 
     do
       for ((j=0; j < l_sizes; j++))
       do 
          configure_environment ${freqs[i]} ${sizes[j]} ${times[k]} $n_iter 
          for ((l=0; l < n_iter; l++))	
          do      
             echo "f:${freqs[i]} m:${sizes[j]} t:${times[k]} iter:${l} `date +"%Y-%m-%d %H:%M:%S"`"
	     transpose ${sizes[j]} ${times[k]} 1 ${w_pid}
             echo "`date +"%Y-%m-%d %H:%M:%S"`"
          done
          flush
          finish_meter_logging
          wait
          commit ${freqs[i]} ${sizes[j]} ${times[k]} $n_iter
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
