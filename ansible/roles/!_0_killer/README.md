# REQUIREMENTS



  - Install prerequisites

    ```
        apt-get update
        apt-get install -y software-properties-common

        add-apt-repository ppa:projectatomic/ppa
        apt-get update
    ```

  - Install CRI-O

    ```
        apt-get install -y cri-o-1.15
        systemctl daemon-reload
        systemctl start crio
    ```

# GET PODS AND CLUSTER DATA FROM KUBERNETES

## GET INFO
- kubectl get pods --namespace kube-system
- kubectl describe pod --namespace kube-system calico-node-l9tcr
- kubectl get all --kubeconfig /etc/kubernetes/admin.conf
- kubectl get node
- kubeadm upgrade plan --ignore-preflight-errors=ControlPlaneNodesReady

* Full info about namespace

```
    kubectl get all --namespace kube-system
```
* get namespaces:

```
    kubectl get ns
```

## DELETE POD
- kubectl delete pods --namespace kube-system calico-kube-controllers-788d6b9876-5fx9j

* permanently -

```
    kubectl delete pod kube-controller-manager-vortex-node-06-production --grace-period=0 --force --namespace 
    kubectl delete pod --grace-period=0 --force --n kube-system kube-controller-manager-vortex-node-05-production
    kube-system 

        kubectl delete pod ID--grace-period=0 --force --namespace kube-system 
```

/etc/kubernetes/kube-flannel.yaml

## DELETE SERVICE
```
    kubectl delete service --namespace kube-system kube-dns
    kubectl delete service --namespace default kubernetes
```
## RECOVER SOME POD

1. Change wrong settings
2. Apply changes, as example - ``` kubectl apply -f /etc/kubernetes/manifests/kube-controller-manager.yaml ```

## DATASETES SHOW

``` kubectl --kubeconfig=/etc/kubernetes/admin.conf get ds --all-namespaces ```

## UPGRADE VERSION

1. kubeadm upgrade plan
2. kubeadm upgrade apply v1.18

## UPDATE CLUSTER CONFIGF

``` kubeadm config upload from-file --config kubeadm.yaml ```

``` kubeadm init phase upload-config all --config test_v3.yml --kubeconfig /etc/kubernetes/admin.conf ```

## UPDATE CERTS

``` kubeadm init phase certs apiserver --config test_v2.yml ```

# FULL RECREATE CLUSTER (K8,ETCD,CA)

``` 
    ansible-playbook -i inventories/products/vortex/beta/ playbook-library/cloud/k8/k8-cluster.yml -e GLUSTERFS_CLUSTER_HOSTS=bind-master-glusterfs -u westsouthnight --become-user root --become -e ansible_become_pass='9101hfaubvu*@Q' -e ansible_ssh_pass='9101hfaubvu*@Q' -e stage=1 -e calico_redeploy=1 -e reset_cluster=1
```

sudo kubeadm init --apiserver-advertise-address=172.16.50.101