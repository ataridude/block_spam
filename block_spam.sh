#!/bin/bash

DOMAIN=$1

# Check to see if this is a parked domain
TMPFILE=`mktemp`
/usr/local/bin/curl -s http://${DOMAIN} > ${TMPFILE}
touch ${TMPFILE}
grep -q parking-lander ${TMPFILE}
ERR=$?
rm -f ${TMPFILE}

TMPFILE=`mktemp`

if [ ${ERR} -gt 0 ]; then
    # Check to see if it's already allowed
    LINE="/${DOMAIN}$/ OK"
    COUNT=`grep -c "${LINE}" /usr/local/etc/postfix/blocked_senders | awk '{print $1}'`
    [[ ${COUNT} -gt 0 ]] && exit

    # Add line to file
    cp /usr/local/etc/postfix/blocked_senders ${TMPFILE}
sed -i '' "1i\\
$LINE\\
" "${TMPFILE}"

    echo "Adding valid domain: [${DOMAIN}]"
else
    # Check to see if it's already blocked
    LINE="/${DOMAIN}$/ 521 No such address"
    COUNT=`grep -c "${LINE}" /usr/local/etc/postfix/blocked_senders | awk '{print $1}'`
    [[ ${COUNT} -gt 0 ]] && exit

    # Add line to file
    cp /usr/local/etc/postfix/blocked_senders ${TMPFILE}
sed -i '' "1i\\
$LINE\\
" "${TMPFILE}"

    echo "Adding spam domain: [${DOMAIN}]"
fi
diff -u /usr/local/etc/postfix/blocked_senders ${TMPFILE}


# Copy file back to blocked_senders
cp ${TMPFILE} /usr/local/etc/postfix/blocked_senders
rm ${TMPFILE}

cd /usr/local/etc/postfix
/usr/local/sbin/postmap blocked_senders
service postfix reload
