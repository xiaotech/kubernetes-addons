# kubefed 

**kubefed client 下载**

https://storage.cloud.google.com/kubernetes-federation-release/release/v1.9.0-alpha.3/federation-client-linux-amd64.tar.gz

或

https://github.com/xiaotech/federation/tree/master/bin


**集群信息**

root@node192:/home/kubernetes-addons/federation# kubectl config get-contexts 

CURRENT   NAME         CLUSTER   AUTHINFO               NAMESPACE
*         context192   c192      kubernetes-admin-192   
          context193   c193      kubernetes-admin-193   


**注意信息**
 
1. kubectl : v1.10.0-00，高版本的可能导致集群某些功能无法使用

2. 集群的名字不要包含一些特殊字符如@，否则导致join失败

3. federation： cluster集群的名字使用federation，否则导致unjoin失败

4. 清除联邦： delete ns federation-system

5. 联邦集群： 有apiserver和controller-manager，etcd可以使用k8s集群的
