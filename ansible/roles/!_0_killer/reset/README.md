# BASIC RESET KUBERNETES NODE

* for reset kubernetes node, use simple commands to exec:

```

    kubeadm reset --force
    rm -rf /var/lib/kubelet
    rm -rf /etc/kubernetes/manifests
    rm -rf /etc/kubernetes/pki/*
    rm -rf /etc/kubernetes/*
    systemctl stop kubelet
    ipvsadm --clear

```