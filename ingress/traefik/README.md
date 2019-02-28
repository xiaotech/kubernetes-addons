# traefik ingress plugin

**Deployment : deployment or daemonset**

**hostNetwork: true**

**management: 8080**


# 多个controller选择ingress原则

*ingress配置annotaion*

```
annotations:
  kubernetes.io/ingress.class: nginx (traefix 或者nginx,不写默认都有作用)
```
