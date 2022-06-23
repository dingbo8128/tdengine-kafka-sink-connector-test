#!/bin/bash
if [ $# -lt 2 ];then
	echo  "Usage: ./run-test.sh <num_of_partitions>  <total_records>"
	exit 0
fi

echo "---------------------------TEST STARTED---------------------------------------"
echo clean data and logs
taos -s "DROP DATABASE IF EXISTS power"
rm -rf /tmp/kafka-logs /tmp/zookeeper
rm -f $KAFKA_HOME/logs/connect.log

np=$1     # number of partitions
total=$2  # number of records
echo number of partitions is $np, number of recordes is $total.

echo start zookeeper
zookeeper-server-start.sh -daemon $KAFKA_HOME/config/zookeeper.properties
echo start kafka
sleep 3
kafka-server-start.sh -daemon $KAFKA_HOME/config/server.properties
sleep 5
echo create topic
kafka-topics.sh --create --topic meters --partitions $np --bootstrap-server localhost:9092
kafka-topics.sh --describe --topic meters --bootstrap-server localhost:9092

echo generate test data
python3 gen-data.py meters $total  | kafka-console-producer.sh --broker-list localhost:9092 --topic meters

echo alter connector configuration setting tasks.max=$np
sed -i  "s/tasks.max=.*/tasks.max=${np}/"  sink-test.properties

echo start kafka connect
connect-standalone.sh -daemon $KAFKA_HOME/config/connect-standalone.properties sink-test.properties

echo -e "\e[1;31m open another console to monitor connect.log. press enter when no more data received.\e[0m"
read

echo stop connect
jps | grep ConnectStandalone | awk '{print $1}' | xargs kill
echo stop kafka server
kafka-server-stop.sh
echo stop zookeeper
zookeeper-server-stop.sh

# extract timestamps of receiving the first batch of data and the last batch of data
grep "records" $KAFKA_HOME/logs/connect.log  | grep meters- > tmp.log

start_time=`cat tmp.log | grep -Eo "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}" | head -1`
stop_time=`cat tmp.log | grep -Eo "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}" | tail -1`


echo "--------------------------TEST FINISHED------------------------------------"
echo "| records | partitions | start time | stop time |"
echo "|---------|------------|------------|-----------|"
echo "| $total | $np | $start_time | $stop_time |" 
