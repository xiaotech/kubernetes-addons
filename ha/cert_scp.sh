USER=root # customizable
CONTROL_PLANE_IPS="172.30.81.193 172.30.81.194"
for host in ${CONTROL_PLANE_IPS}; do
    ssh ${USER}@$host test -d  /etc/kubernetes/pki/etcd ||  ssh ${USER}@$host mkdir  /etc/kubernetes/pki/etcd -p
    scp /etc/kubernetes/pki/ca.crt "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/ca.key "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/sa.key "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/sa.pub "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/front-proxy-ca.crt "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/front-proxy-ca.key "${USER}"@$host:/etc/kubernetes/pki
    scp /etc/kubernetes/pki/etcd/ca.crt "${USER}"@$host:/etc/kubernetes/pki/etcd/ca.crt
    scp /etc/kubernetes/pki/etcd/ca.key "${USER}"@$host:/etc/kubernetes/pki/etcd/ca.key
    scp /etc/kubernetes/admin.conf "${USER}"@$host:/etc/kubernetes/
done
