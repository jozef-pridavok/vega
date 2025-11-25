#!/bin/bash

REQUIRED=vega_app

CURRENT=`pwd`
BASENAME=`basename "$CURRENT"`

if [ "$BASENAME" != "$REQUIRED" ]; then
    echo "Run this script from $REQUIRED directory. You are in $BASENAME directory."
    exit 1
fi

vtc lang google-sheet \
    --keys ./lib/strings.dart \
    --output ./assets/langs/ \
    --url "https://docs.google.com/spreadsheets/d/e/2PACX-1vSUsPxkfwS0J_JLpo4NaVFL8oQpdSonpJA4KY5xMJRxnJrZ2Z80GFqwMeuCePQYrgHkfZHWSiJPEmbC/pub?gid=1338362051&single=true&output=tsv"

