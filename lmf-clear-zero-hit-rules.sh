#!/bin/bash

#
#  Clears out all drop rules that have received no activity
#

get_zero_hit_addresses() {
    local chain=$1
    local src=$2
    /sbin/iptables -vnL INPUT | \
    awk '$1 == 0 && $3 == "DROP" && $4 == "all" && $9 == "0.0.0.0/0" {print $8}'
}

get_rule() {
    local chain=$1
    local src=$2
    /sbin/iptables --line-numbers --list $chain --numeric | \
    awk '$2 == "DROP" && $3 == "all" && $5 == "'$src'" {printf "%d", $1; exit}'
}

CHAINS="INPUT OUTPUT FORWARD"

for ADDRESS in $(get_zero_hit_addresses)
do

    for chain in $CHAINS
    do

        RULE=$(get_rule $chain $ADDRESS)

        if [ "x$RULE" = "x" ]
        then
            continue
        fi

        #  Gets rid of multiple drop rules if they exist
        while [ "x$RULE" != "x" ]
        do

            /sbin/iptables -D $chain $RULE

            RULE=$(get_rule $chain $ADDRESS)

        done

    done

done

#  Save rule sets now that we have cleaned them
/etc/init.d/iptables save >/dev/null 2>&1

exit 0
