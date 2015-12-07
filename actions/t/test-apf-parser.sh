#!/bin/bash

. ./inc/apf-parser.func || exit 1

if apf_is_whitelisted $1
then
    echo "Whitelisted!"
else
    echo "Not Whitelisted!"
fi

