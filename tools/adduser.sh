openssl genrsa -out xj.key 2048
openssl req -new -key xj.key -out xj.csr -subj "/CN=xiaotech/O=development"
openssl x509 -req -in xj.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out xj.crt -days 45


kubectl config set-credentials xj --client-certificate=./xj.crt --client-key=./xj.key
