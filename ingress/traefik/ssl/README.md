#traefik ssl配置指南

## 1. 生成server的key和crt

`server.pem,server-key.pem`


## 2. 配置traefik的ssl配置文件

```
defaultEntryPoints = ["http","https"]
[entryPoints]
  [entryPoints.http]
  address = ":80"
    [entryPoints.http.redirect]
      entryPoint = "https"
  [entryPoints.https]
  address = ":443"
    [entryPoints.https.tls]
      [[entryPoints.https.tls.certificates]]
      CertFile = "/traefik_ssl/tls/server.pem"
      KeyFile = "/traefik_ssl/tls/server-key.pem"
``` 

### 3. 添加configmap和secret

```
kubectl -n kube-system create configmap traefik-config --from-file=./traefik.conf

kubectl -n kube-system create secret general traefik-tls --form-file=./server.pem --from-file=./server-key.pem
```

### 3. 修改ds的volumes和启动参数

```
        ...
        ports:
        - name: http
          containerPort: 80
          hostPort: 80
        - name: https
          containerPort: 443
          hostPort: 443
        - name: admin
          containerPort: 8080
          hostPort: 8080
        volumeMounts:
        - name: config
          mountPath: /traefik_ssl/config/
        - name: tls
          mountPath: /traefik_ssl/tls/
        args:
        - --api
        - --kubernetes
        - --logLevel=INFO
        - --configfile=/traefik_ssl/config/traefik.conf
      volumes:
      - name: config
        configMap:
          name: traefik-config
      - name: tls
        secret:
          secretName: traefik-tls
```
