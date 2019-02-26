#!/bin/bash

set -e
WORKDIR=/tmp/k8s_curl

[ ! -d $WORKDIR ] && mkdir -p $WORKDIR
cd $WORKDIR

client_crt=$(grep client-certificate-data ~/.kube/config |awk -F': ' '{print $2}')
echo $client_crt |base64 -d > client.pem
client_key=$(grep client-key-data ~/.kube/config |awk -F': ' '{print $2}')
echo $client_key |base64 -d > client-key.pem
ca=$(grep certificate-authority-data ~/.kube/config |awk -F': ' '{print $2}')
echo $ca |base64 -d > ca.pem
server=$(kubectl config view|grep server|awk '{print $2}')



echo curl --cert $WORKDIR/client.pem --key $WORKDIR/client-key.pem  --cacert $WORKDIR/ca.pem $server/api/v1/pods
