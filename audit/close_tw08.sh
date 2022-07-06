#!/bin/sh

docker exec TW08D bash -c 'sqlplus -s tw08/twroot02 <<< "exec kill_other_sessions;"'
