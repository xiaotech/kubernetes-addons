# service - pod 负载均衡选择

## 默认采用iptables

## 开启ipvs的方法

1. 修改kube-proxy配置

```
kubectl -n kube-system edit cm kube-proxy

    ipvs:
      excludeCIDRs: null
      minSyncPeriod: 0s
      scheduler: "sh"  #负载均衡选择
      syncPeriod: 30s
    kind: KubeProxyConfiguration
    metricsBindAddress: 127.0.0.1:10249
    mode: "ipvs"   # 开启ipvs，默认为空

kubectl -n kube-system delete pod -l k8s-app=kube-proxy
```

2. 修改完成后，可以使用ipvsadm查看


