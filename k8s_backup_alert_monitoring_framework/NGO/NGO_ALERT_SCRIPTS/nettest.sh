#!/bin/bash
for q in `kubectl get po -A -o wide | grep dnsutils-ds | awk '{print $1","$2","$10}'`
do
namespace=`echo $q | awk -F\, '{print $1}'`
pod_name=`echo $q | awk -F\, '{print $2}'`
node_name=`echo $q | awk -F\, '{print $3}'`
IP_ADDR=`nslookup $node_name | grep -v '#' | grep 'Address' | awk '{print $2}'`
worker_count=`kubectl get nodes | grep $node_name | grep -v master | wc -l`
if [ $worker_count -gt 0 ];
then
if oc exec -i $pod_name -n $namespace -- nc -w 2 -zv $1 $2 >/dev/null 2>&1;
then
echo "Telnet Status : "$node_name"("$IP_ADDR") ,IP_ADD: "$1" ,PORT: "$2", SUCCESS"
else
echo "Telnet Status : "$node_name"("$IP_ADDR") ,IP_ADD: "$1" ,PORT: "$2", FAILED"
fi
fi
done
for q in `kubectl get po -A -o wide | grep dnsutils-ds | awk '{print $1","$2","$8}'`
do
namespace=`echo $q | awk -F\, '{print $1}'`
pod_name=`echo $q | awk -F\, '{print $2}'`
node_name=`echo $q | awk -F\, '{print $3}'`
IP_ADDR=`nslookup $node_name | grep -v '#' | grep 'Address' | awk '{print $2}'`
worker_count=`kubectl get nodes | grep $node_name | grep -v master | wc -l`
if [ $worker_count -gt 0 ];
then
if oc exec -i $pod_name -n $namespace -- nc -w 2 -zv $1 $2 >/dev/null 2>&1;
then
echo "Telnet Status : "$node_name"("$IP_ADDR") ,IP_ADD: "$1" ,PORT: "$2", SUCCESS"
else
echo "Telnet Status : "$node_name"("$IP_ADDR") ,IP_ADD: "$1" ,PORT: "$2", FAILED"
fi
fi
done

