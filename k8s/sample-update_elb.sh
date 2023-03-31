#!/bin/bash
# Update the HAProxy external load balancer to have the specified backend
# resolve to the IP address of the LoadBalancer service on the specified
# cluster and namespace.
# Usage: update_elb.sh <cluster> <namespace> <backend_name>

if [ $# -eq 0 ]
then
  echo Usage: update_elb.sh \<cluster\> \<namespace\> \<backend_name\>
  exit 0
elif [ $# -ne 3 ]
then
  echo Invalid arguments!
  echo Usage: update_elb.sh \<cluster\> \<namespace\> \<backend_name\>
  exit 1
fi

cluster=$1
namespace=$2
backend=$3

if [ $cluster == "rke1" ]
then
  KUBECONFIG=/home/user/kubeconfigs/rke1/kube_config_cluster.yml
elif [ $cluster == "rke2" ]
then
  KUBECONFIG=/home/user/kubeconfigs/rke2/kube_config_cluster.yml
else
  echo Invalid cluster = $cluster, aborting!
  exit 1
fi

ip=$(kubectl get service -n $namespace -o json | jq '.items[].status | {loadBalancer} | select(.loadBalancer!={})' | jq '.loadBalancer.ingress[].ip' | sed 's/"//g')
if [ ! -z $ip ]
then
  echo Found cluster \"$cluster\" namespace \"$namespace\" LoadBalancer service IP \"$ip\"
  ssh lb1 /usr/local/bin/update_haproxy.sh $backend $ip
  if [ $? -eq 0 ]
  then
    echo Updated HAProxy \"$backend\" backend to use server IP \"$ip\"
  else
    echo Error while updating HAProxy backend \"$backend\", aborting!
  fi
else
  echo "No LoadBalancer service found on cluster $cluster for namespace $namespace, aborting!"
  exit 1
fi
