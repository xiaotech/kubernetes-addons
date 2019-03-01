# api-server curl访问

1. 通过ca，key访问参考k8s_curl.sh

2. 通过Bearer token

```
token=$(kubectl describe secrets default-token-gkjfn |grep token:|awk '{print $2}')

curl -k -H "Authorization: Bearer $token" https://172.30.81.192:6443/v1
```


# 添加自定义用户，以及绑定权限，添加context

1. 添加用户xiaotech

```
openssl genrsa -out xj.key 2048
openssl req -new -key xj.key -out xj.csr -subj "/CN=xiaotech/O=development"
openssl x509 -req -in xj.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out xj.crt -days 45

kubectl config set-credentials xj --client-certificate=./xj.crt --client-key=./xj.key
```

2. 授权

```
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: xiaotech-admin-binding
subjects:
- kind: User
  name: xiaotech
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""
```

3. 添加context

```
kubectl config set-context xj-context --cluster=kubernetes --user=xj --namespace=default
```
