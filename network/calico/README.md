# 注意 pod-network : 192.168.0.0/16

*两种方式*

* kubeadm init --pod-network-cidr 192.168.0.0/16

* kubeadm config print-default 修改对应pod网络


# 运行IPIP模式

*calico.yaml*

```
 # Enable IPIP
- name: CALICO_IPV4POOL_IPIP
  value: "Always"
```


# 运行路由模式

*calico.yaml*

```
 # Enable IPIP
- name: CALICO_IPV4POOL_IPIP
  value: "off"
```

# 如果calico报错， unknown peer address 

*calico.yaml配置指定接口*

```
# Auto-detect the BGP IP address.
- name: IP
  value: "autodetect"
- name: IP_AUTODETECTION_METHOD
  value: "interface=ens3"
```
