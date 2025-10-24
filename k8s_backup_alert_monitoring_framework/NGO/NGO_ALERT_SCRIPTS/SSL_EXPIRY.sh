#!/bin/bash

# Load variables from ip.txt
source /app/NGO/NGO_ALERT_SCRIPTS/config/ip.txt

# Get IP
if [[ -n "$HARDCODED_IP" ]]; then
    IP="$HARDCODED_IP"
else
    IP=$(eval "$DYNAMIC_IP_CMD")
fi

# Get hostname
if [[ -n "$HARDCODED_HOSTNAME" ]]; then
    HOST="$HARDCODED_HOSTNAME"
else
    HOST=$(eval "$DYNAMIC_HOSTNAME_CMD")
fi
currentDate=`date +"%Y-%m-%d %H:%M"`

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_ssl_expiry_alert_`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_ssl_expiry_alert_*.log"


# delete the content of file
rm -f $OLD_FILES


#for loop start


PROP_FILE=/app/NGO/NGO_ALERT_SCRIPTS/ssl_expiry.properties

trim()
{
        echo $* | xargs
}

#website=prodjdmswms.jio.com

while read category
do

        echo $category
        trim $category | grep "^#" > /dev/null
        if [ $? -eq 0 -o `trim $category| wc -c` -le 5 ]
        then
                continue
        else
                website=`echo $category | cut -d"|" -f1`
                ip_address=`echo $category | cut -d"|" -f2`
                hostname=`echo $category | cut -d"|" -f3`
                port=`echo $category | cut -d"|" -f4`

RENEWAL_DAYS="30"
echo -n | openssl s_client -connect $website:$port -servername $website \
    | openssl x509 > /tmp/jdms_ssl.cert
certificate_file="/tmp/jdms_ssl.cert"
date=$(openssl x509 -in $certificate_file -enddate -noout | sed "s/.*=\(.*\)/\1/")
date_s=$(date -d "${date}" +%s)
now_s=$(date -d now +%s)
date_diff=$(( (date_s - now_s) / 86400 ))
echo "$website will expire in $date_diff days"


if [ $date_diff -lt $RENEWAL_DAYS ]

then

v_exception_text="Certificate for "$website" will Expire in "$date_diff" Days."

echo $v_exception_text
#NGO JSON format

echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"SSL_EXPIRE:ebdm2gslb.jio.com\",\"value\":\"$date_diff\",\"cnt\":\"$date_diff\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"SSL certificate for $website expires in $date_diff days. Check validity period and Plan renewal before expiry.\"}" >> $LOG_FILE






fi

rm /tmp/jdms_ssl.cert

fi

done < $PROP_FILE

#for loop end

