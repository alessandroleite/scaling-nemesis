#!/bin/sh
#java -cp .:`pwd`/lib/wattsupj-1.0.0-SNAPSHOT.jar -Dexport.file.path=$OUTPUT_FILE wattsup.console.Console $W_PORT
java -cp .:`pwd`/lib/wattsupj-1.0.0-SNAPSHOT.jar -Dexport.file.path=$1 wattsup.console.Console $2
