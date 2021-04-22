apiServer:
  certSANs:
  - "172.16.50.101"
  - "vortex-node-05-production"
  - "172.16.50.206"
  - "185.40.28.115"
  - "vortex-node-04-production"
  - "172.16.50.205"
  - "185.40.28.126"
  - "vortex-node-06-production"
  - "172.16.50.207"
  - "185.40.28.91"
  peerCertSANs:
  - "172.16.50.101"
  - "vortex-node-05-production"
  - "172.16.50.206"
  - "185.40.28.115"
  - "vortex-node-04-production"
  - "172.16.50.205"
  - "185.40.28.126"
  - "vortex-node-06-production"
  - "172.16.50.207"
  - "185.40.28.91"
  extraArgs:
    advertise-address: 172.16.50.101
    anonymous-auth: "false"
    enable-admission-plugins: AlwaysPullImages,DefaultStorageClass
    audit-log-path: /var/log/k8-audit.log
    authorization-mode: Node,RBAC
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /opt/ca/pki
clusterName: main_k8_cluster
controllerManager:
  extraArgs:
    bind-address: 172.16.50.101
    cluster-signing-key-file: /opt/ca/pki/ca.key
    deployment-controller-sync-period: "50s"
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /opt/ca/pki
clusterName: main_k8_cluster
controlPlaneEndpoint: ""
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  external:
    caFile: /opt/ca/pki/ca.pem
    certFile: /opt/ca/pki/etcd.pem
    endpoints:
    - https://172.16.50.206:2379
    - https://172.16.50.205:2379
    - https://172.16.50.207:2379
    keyFile: /opt/ca/pki/etcd-key.pem
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.17.4
networking:
  dnsDomain: vless.ru
  podSubnet: 192.168.0.0/16
  serviceSubnet: 10.32.0.0/24
scheduler: {}