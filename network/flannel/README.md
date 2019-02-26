# flannel 

  基于vxlan的overlay 网络,不支持network policy

  注意： 配置pod-network 在192.168.0.0/16子网上

```
  net-conf.json: |
    {
      "Network": "192.168.0.0/16",
      "Backend": {
        "Type": "vxlan"
      }
    }
```


