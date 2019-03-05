# k8s集群使用外部etcd

## 1. 部署etcd

1.1 修改kubelet配置

```
cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true
Restart=always
EOF

systemctl daemon-reload
systemctl restart kubelet
```

1.2 etcd节点194上执行deploy-single-etcd.sh

1.3 拷贝证书到k8s master节点

```
scp -r apiserver-etcd-client.* 172.30.81.192:/etc/kubernetes/pki/
scp -r apiserver-etcd-client.* 172.30.81.192:/etc/kubernetes/pki/
scp etcd/ca.crt 172.30.81.192:/etc/kubernetes/pki/etcd/
```

## 2. 部署k8s集群

*修改kubeadm配置文件，使用外部etcd*

```
etcd:
    external:
        endpoints:
        - https://172.30.81.194:2379
        caFile: /etc/kubernetes/pki/etcd/ca.crt
        certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
        keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
``` 
kubectl init --config kubeadm.conf


## 3. etcd集群的部署参考

https://kubernetes.io/docs/setup/independent/setup-ha-etcd-with-kubeadm/


## 4. k8s 节点不能和etcd节点一起

etcd节点修改了kubelet的配置
