#/bin/bash
# Email for every time ran; if executed more than five times in five
# minutes, then email an additional message.
#
# $STATUS_FILE should contain a number of lines, each one corresponding
# to a run number and the timestamp it started at.
#
# If the first run in a set happened earlier than 5 minutes before this
# run, we just remove it and start over again.

# Configs.
STATUS_FILE="./.status"
TS=`date -u +%s`
THRESHOLD=300
NORMAL_RUN_SUBJECT="A Normal Script Run."
NORMAL_RUN_MAIL="arian@localhost"
NORMAL_RUN_CONTENT="Here would be a report, or a status update."
SPECIAL_RUN_SUBJECT="Whoa! Too Many Runs!"
SPECIAL_RUN_MAIL="arian@localhost"
SPECIAL_RUN_CONTENT="Someone's run the script too many times in 5 minutes."

echo $NORMAL_RUN_CONTENT
#echo "$NORMAL_RUN_CONTENT" | mail -s "$NORMAL_RUN_SUBJECT" "$NORMAL_RUN_MAIL"
if [[ ! -f $STATUS_FILE ]];
then
    # Store the time of each run so that subsequent runs can determine
    # their behaviour.
    echo "1 $TS" > $STATUS_FILE
else
    # Look for a 5-minute interval from the last time the script was executed.
    # Rewrite the file if too much time has passed.
    ETIME=$((`date -u +%s`-$THRESHOLD))
    CTIME=$((`tail -n 1 $STATUS_FILE | awk '{ print $2 }'`))
    if [ "$CTIME" -lt "$ETIME" ];
    then
        # Reset the status file to reflect that we're tracking a new
        # five-minute interval.
        echo "1 $TS" > $STATUS_FILE
    else
        LAST_RUN=`cat $STATUS_FILE | wc -l | awk '{ print $1 }'`

        # So we know it hasn't been five minutes since the last run.
        # Count how many runs HAVE happened in the last five minutes,
        # and do our special line processing from that.
        #
        # This should alleviate the issue that Mack had reported.
        PASTRUNS=0
        while read line
        do
            RUNTIME=`echo $line | awk '{ print $2 }'`
            if [ "$RUNTIME" -gt "$ETIME" ];
            then
                PASTRUNS=$((PASTRUNS+1))
            fi
        done < $STATUS_FILE

        # 4 runs have already happened, so this is the fifth.
        if [ "$PASTRUNS" -ge "4" ];
        then
            echo $SPECIAL_RUN_CONTENT
            #echo "$SPECIAL_RUN_CONTENT" | mail -s "$SPECIAL_RUN_SUBJECT" "$SPECIAL_RUN_MAIL"
        fi
        echo "$((LAST_RUN+1)) $TS" >> $STATUS_FILE
    fi
fi
