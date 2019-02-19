# GPU - device plugin 的部署方式

1. 集群安装完毕


2. GPU节点安装nvida驱动，cuda，cudnn

3. GPU节点安装nvidia-docker2

```
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list |  tee /etc/apt/sources.list.d/nvidia-docker.list
apt-get update
apt-get install nvidia-docker2
```

4. GPU节点启用nvidia runtime 

* **/etc/systemd/system/kubelet.service.d/10-kubeadm.conf 文件添加**

```
--feature-gates=DevicePlugins=true

systemctl daemon-reload

systemctl restart kubelet
```

* **/etc/docker/daemon.json 文件添加**

```
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}

systemctl restart docker
```

5. master节点启用kubernetes支持device plugin

```
kubectl create -f nvidia-device-plugin.yml
```

安装完成后，GPU节点会看到对应的Capacity

```
root@node192:/home/nvidia# kubectl describe nodes |grep -i gpu
 nvidia.com/gpu:     2
 nvidia.com/gpu:     2
```

6. pod使用gpu资源

```
kubectl create -f sample.yaml

apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
    - image: nvidia/cuda
      name: gpu-pod
      command:
      - nvidia-smi
      resources:
        limits:
          nvidia.com/gpu: 1 # 会调度到有gpu资源的节点
```
