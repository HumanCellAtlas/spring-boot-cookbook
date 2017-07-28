#!/bin/bash
app=$2
env=$3
deployFolder=~/ena/${app}
PIDFILE=${deployFolder}/${app}.pid

export PATH="/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/data/webadmin/java/jdks/jdk1.8.0_74/bin"
export JAVA_HOME="/data/webadmin/java/jdks/jdk1.8.0_74"

cd ${deployFolder}
mkdir -p ./logs

case $1 in
 start)
java -jar ${deployFolder}/${app}-current.jar --spring.profiles.active=${env}> ${deployFolder}/logs/${app}-startup.log &
 ;;
 stop)
 kill -15 `cat ${PIDFILE}`
 rm ${PIDFILE}
 ;;
esac
