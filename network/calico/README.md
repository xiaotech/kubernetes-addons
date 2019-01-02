# 注意 pod-network : 192.168.0.0/16
两种方式
* kubeadm init --pod-network-cidr 192.168.0.0/16
* kubeadm config print-default 修改对应pod网络
