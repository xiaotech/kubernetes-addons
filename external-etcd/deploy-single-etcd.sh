#!/bin/bash

export HOST=172.30.81.194
NAME=info0

cat << EOF > /home/kubeadmcfg.yaml
apiVersion: "kubeadm.k8s.io/v1beta1"
kind: ClusterConfiguration
etcd:
    local:
        serverCertSANs:
        - "${HOST}"
        peerCertSANs:
        - "${HOST}"
        extraArgs:
            initial-cluster: ${NAME}=https://${HOST}:2380
            initial-cluster-state: new
            name: ${NAME}
            listen-peer-urls: https://${HOST}:2380
            listen-client-urls: https://${HOST}:2379
            advertise-client-urls: https://${HOST}:2379
            initial-advertise-peer-urls: https://${HOST}:2380
EOF


kubeadm init phase certs etcd-ca
kubeadm init phase certs etcd-server --config=/home/kubeadmcfg.yaml
kubeadm init phase certs etcd-peer --config=/home/kubeadmcfg.yaml
kubeadm init phase certs etcd-healthcheck-client --config=/home/kubeadmcfg.yaml
kubeadm init phase certs apiserver-etcd-client --config=/home/kubeadmcfg.yaml


kubeadm init phase etcd local --config=/home/kubeadmcfg.yaml
