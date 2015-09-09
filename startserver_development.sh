#!/bin/bash
if [ -z $PYTHONPATH ]; then
    export PYTHONPATH=/tmp/alpino
else
    export PYTHONPATH=/tmp/alpino:$PYTHONPATH
fi
clamservice alpino
