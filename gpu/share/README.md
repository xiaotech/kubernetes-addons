# 共享GPU - 主要利用显存的细分

配置步骤

1. 参考single的配置，将GPU节点nvidia docker配置完成

2. master节点配置scheduler

* 安装scheduler

` kubectl create -f gpushare-schd-extender.yaml`

* 配置kube-scheduler

拷贝 scheduler-policy-config.json 到/etc/kubernetes/ 

```
- --policy-config-file=/etc/kubernetes/scheduler-policy-config.json

- mountPath: /etc/kubernetes/scheduler-policy-config.json
  name: scheduler-policy-config
  readOnly: true

- hostPath:
      path: /etc/kubernetes/scheduler-policy-config.json
      type: FileOrCreate
  name: scheduler-policy-config
```

* 安装plugin

```
kubectl create -f device-plugin-ds.yaml -f device-plugin-rbac.yaml

kubectl label node <target_node> gpushare=true
```


3. 测试

```
kubectl create -f sample.yaml
```
