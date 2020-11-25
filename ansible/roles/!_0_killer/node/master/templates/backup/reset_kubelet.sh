systemctl stop kubelet
rm /etc/kubernetes/manifests/kube-apiserver.yaml
rm /etc/kubernetes/manifests/kube-controller-manager.yaml
rm /etc/kubernetes/manifests/kube-scheduler.yaml
rm /etc/kubernetes/admin.conf
rm /etc/kubernetes/kubelet.conf
rm /etc/kubernetes/controller-manager.conf
rm /etc/kubernetes/scheduler.conf
rm /var/lib/kubelet/kubeadm-flags.env