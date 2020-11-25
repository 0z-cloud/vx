apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
  labels:
      addonmanager.kubernetes.io/mode: EnsureExists
data:
  Corefile: |
    .:{{ k8s_cluster_dns_port_inside }} {
        errors
        health {
            lameduck 5s
        }
        ready
        kubernetes {{ k8_cloud_domain_name }} in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
        }
        prometheus :{{ k8s_cluster_dns_prometheus_port_outside }}
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }