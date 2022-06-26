#!/bin/sh
instantclient=~/instantclient_21_1/
export LD_LIBRARY_PATH=${instantclient}:$LD_LIBRARY_PATH
python main.py