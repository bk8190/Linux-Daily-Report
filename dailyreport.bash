#!/bin/bash
# Creds til drift@TIHLDE - mye snaxx hentet fra dem

cd $(dirname $0)

# Source stuff
source /etc/profile
source inc/functions.bash
source inc/init.bash

# Check if we can send mail
if ! $(hash mail &> /dev/null); then
    echo "mail not installed"
    exit 1
fi

errorMsg=""
echo "<pre style='font-family: \"courier new\", courier, monospace; font-size: 11px;'>" > $MAIL
MODULES=$(config modules)
if [[ $MODULES == "modules not found in dailyreport.conf" ]]; then
    MODULES=$(ls modules)
    MODULES="${MODULES[@]}" # Add all
fi

for MODUL in $MODULES; do
    if [ ! -f modules/$MODUL ]; then
        errorMsg=$errorMsg"<br> Module $MODUL does not exist!<br>"    
        continue
    fi
    modules/$MODUL > $TEMP # temp file from systemCheck
    if [ $? == 0 ]; then
        cat $TEMP >> $MAIL
        echo "<br><br>" >> $MAIL
    else
        errorMsg=$errorMsg"Module $MODUL returned with error signal<br>"
    fi
done

DATE_YESTERDAY=$(date --date "1 day ago" +%d.%m.%Y)
# appending any errors
if [[ $errorMsg != "" ]]; then
    errorMsg="<font color=\"red\">$errorMsg</font>"
    sed -i "1i$errorMsg" $MAIL
fi

echo "</pre>" >> $MAIL

if [[ $1 == "test" ]]; then
    cat $MAIL
else 
    RECIVERS=$(config recivers)
    for RECIVER in $RECIVERS; do
#        cat $MAIL | mail -a 'Content-Type: text/html' -s "Dailyreport for $HOSTNAME $DATE_YESTERDAY" $RECIVER
    mutt -e 'set content_type=text/html' -s "$HOSTNAME report for $DATE_YESTERDAY" "$RECIVER" < $MAIL
    done
fi


# Cleaning
rm -r $TEMP_DIR
