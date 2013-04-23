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
NORMAL_RUN_SUBJECT="A Normal Script Run."
NORMAL_RUN_MAIL="arian@localhost"
NORMAL_RUN_CONTENT="Here would be a report, or a status update."
SPECIAL_RUN_SUBJECT="Whoa! Too Many Runs!"
SPECIAL_RUN_MAIL="arian@localhost"
SPECIAL_RUN_CONTENT="Someone's run the script too many times in 5 minutes."

echo "$NORMAL_RUN_CONTENT" | mail -s "$NORMAL_RUN_SUBJECT" "$NORMAL_RUN_MAIL"
if [[ ! -f $STATUS_FILE ]];
then
    # Store the time of each run so that subsequent runs can determine
    # their behaviour.
    echo "1 $TS" > $STATUS_FILE
else
    # We base our 5-minutes off of when the file was created, which
    # will be the first entry in the list.
    ETIME=$((`date -u +%s`-300))
    CTIME=$((`head -n 1 $STATUS_FILE | awk '{ print $2 }'`))
    if [ "$CTIME" -lt "$ETIME" ];
    then
        # Reset the status file to reflect that we're tracking a new
        # five-minute interval.
        echo "1 $TS" > $STATUS_FILE
    else
        RUNS=`tail -n 1 $STATUS_FILE | awk '{ print $1 }'`
        # Remember that if it's been executed 4 times already, this is
        # the fifth and we should send out the special run email.
        if [ "$RUNS" -ge "4" ];
        then
            echo "$SPECIAL_RUN_CONTENT" | mail -s "$SPECIAL_RUN_SUBJECT" "$SPECIAL_RUN_MAIL"
        fi
        echo "$((RUNS+1)) $TS" >> $STATUS_FILE
    fi
fi
