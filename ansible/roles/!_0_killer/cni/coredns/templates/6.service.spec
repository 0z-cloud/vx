apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/port: "{{ k8s_cluster_dns_prometheus_port_outside }}"
    prometheus.io/scrape: "true"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: {{ k8s_cluster_ip_inside | join }}
  ports:
  - name: dns
    port: {{ k8s_cluster_dns_port_outside }}
    protocol: UDP
  - name: dns-tcp
    port: {{ k8s_cluster_dns_port_outside }}
    protocol: TCP
  - name: metrics
    port: {{ k8s_cluster_dns_prometheus_port_outside }}
    protocol: TCP