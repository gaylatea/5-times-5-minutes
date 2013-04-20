#/bin/bash
# Print out (eventually email) every time ran; if executed more than
# five times in five minutes, then print out (/email) an additional
# message.

# Configs.
STATUS_FILE="./.status"
TS=`date +%s`

echo "Hey! Someone ran me!"
if [[ ! -f $STATUS_FILE ]];
then
    # Store the time of each run so that subsequent runs can determine
    # their behaviour.
    echo "1 $TS" > $STATUS_FILE
else
    # We base our 5-minutes off of when the file was created, which
    # will be the first entry in the list.
    ETIME=$((`date +%s`-300))
    CTIME=$((`head -n 1 $STATUS_FILE | awk '{ print $2 }'`))
    if [ "$CTIME" -lt "$ETIME" ];
    then
        echo "1 $TS" > $STATUS_FILE
    else
        RUNS=`tail -n 1 $STATUS_FILE | awk '{ print $1 }'`
        if [ "$RUNS" -ge "5" ];
        then
            echo "Whoa there! Too many runs!"
        fi
        echo "$((RUNS+1)) $TS" >> $STATUS_FILE
    fi
fi
