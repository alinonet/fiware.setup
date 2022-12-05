#!/bin/bash

# export LD_LIBRARY_PATH=~/git/prometheus-client-c/prom/build:~/git/prometheus-client-c/promhttp/build
# orionld -fg

LD_LIBRARY_PATH=~/git/prometheus-client-c/prom/build:~/git/prometheus-client-c/promhttp/build:$LD_LIBRARY_PATH orionld -fg