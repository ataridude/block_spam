#!/bin/bash

for domain in $(/usr/local/bin/pflogsumm --verbose_msg_detail /var/log/maillog | egrep -A 1 '(rejected|denied|zen.spamhaus.org|exceeded)' | grep 450 | cut -d@ -f2 | cut -d\> -f1 | sort -u|cut -d\. -f2-); do
    /usr/local/sbin/block_spam.sh $domain
done

