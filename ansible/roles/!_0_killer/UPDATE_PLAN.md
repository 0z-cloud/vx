cd /etc
kubeadm config view > kubeadmconf-2019-06-07.yml
cp kubeadmconf-2019-06-07.yml kubeadmconf-2019-06-07-NEW.yml

cd /etc
nano kubeadmconf-2019-06-07-NEW.yml

...
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  # FROM serviceSubnet: 10.10.0.0/24
  serviceSubnet: 10.5.0.0/24
...

openssl x509 \
  -in /etc/kubernetes/pki/apiserver.crt \
  -text -noout

mkdir /backup
cp /opt/ca/pki/apiserver.* /backup/
rm /opt/ca/pki/apiserver.*

kubeadm init phase certs apiserver \
  --config=/opt/kubeadmconf-win.yml