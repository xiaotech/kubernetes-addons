# ha with etcd in cluster

1. haproxy 添加tcp的负载均衡

```
listen 6443
	bind 0.0.0.0:6443
       mode tcp
	balance roundrobin
	server node192 172.30.81.192:6443  weight 1 maxconn 1000 check inter 10s
	server node193 172.30.81.193:6443  weight 1 maxconn 1000 check inter 10s
	server node194 172.30.81.194:6443  weight 1 maxconn 1000 check inter 10s
```

2. kubeadm 配置文件加入必要参数

 生成默认配置文件
`kubeadm config print-default`

以下参数添加ssl的授权ip

```
apiServerCertSANs:
- 172.30.81.199
- 172.30.81.192
- 172.30.81.193
- 172.30.81.194
```

添加负载均衡的控制ip

`controlPlaneEndpoint: 172.30.81.199:6443`

3. 主节点安装

`kubeadm init --config kubeadm.conf `

4. 拷贝证书文件到其余两个节点

```
USER=root # customizable
CONTROL_PLANE_IPS="172.30.81.193 172.30.81.194"
for host in ${CONTROL_PLANE_IPS}; do
    scp /etc/kubernetes/pki/ca.crt "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/ca.key "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/sa.key "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/sa.pub "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/front-proxy-ca.crt "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/front-proxy-ca.key "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/etcd/ca.crt "${USER}"@$host:/etc/kubernetes/pki/etcd/ca.crt
    scp /etc/kubernetes/pki/etcd/ca.key "${USER}"@$host:/etc/kubernetes/pki/etcd/ca.key
    scp /etc/kubernetes/admin.conf "${USER}"@$host:/etc/kubernetes/
done
```

5. 其他主节点的安装

`kubeadm join 172.30.81.199:6443 --token abcdef.0123456789abcdef  --discovery-token-unsafe-skip-ca-verification --experimental-control-plane
`
