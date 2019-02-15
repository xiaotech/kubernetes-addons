# kubernetes-addons-horizon

1. 创建kubernetes-dashboard的deployment

`kubectl create -f kubernetes-dashboard.yaml`

2. 创建登录的用户

`kubectl create -f admin-user.yaml`

3. 获取登录的token

`kubectl -n kube-system describe secrets  admin-user-token-××`

4. 访问https://node-ip:node-port
