#!/bin/sh

echo $(pmset -g ps|tail -n 1|awk '{print $(NF-5)}'|cut -d ';' -f 1)
