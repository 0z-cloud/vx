#!/bin/bash

i=0

while true; do

    sleep 1
    echo `date` ${i}
    expr $i + 1
    
done
