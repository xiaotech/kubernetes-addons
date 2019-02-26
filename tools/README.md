# api-server curl访问

1. 通过ca，key访问参考k8s_curl.sh

2. 通过Bearer token

```
token=$(kubectl describe secrets default-token-gkjfn |grep token:|awk '{print $2}')

curl -k -H "Authorization: Bearer $token" https://172.30.81.192:6443/v1
```
