# Foreman KubeVirt image: CentOS Stream 10

This guide uses the Minikube/KubeVirt cluster described in [minikube.md](minikube.md). It imports the official KubeVirt CentOS Stream 10 container disk into persistent storage, registers it as a CDI `DataSource`, then registers that DataSource as an image in Foreman.

The KubeVirt Foreman plugin expects a CDI `DataSource` name for an image reference; it does not use the container registry URL as the Foreman image ID. The DataSource is converted into a per-VM DataVolume when Foreman provisions a host.

## Prerequisites

- Follow the Minikube guide through the CDI installation and Foreman service account setup.
- The namespace `foreman` exists and contains the `sa-foreman-token` secret.
- CDI and the Minikube default StorageClass are working.
- The Foreman KubeVirt compute resource is named `Minikube KubeVirt` in the commands below.

## Import CentOS Stream 10 into Minikube

Create a DataVolume from KubeVirt's curated CentOS Stream 10 image and a DataSource pointing to its PVC. Both resources must be in the `foreman` namespace because that is the namespace configured on the Foreman compute resource.

```shell
kubectl apply -f - <<'EOF'
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: centos-stream-10
  namespace: foreman
spec:
  source:
    registry:
      url: docker://quay.io/containerdisks/centos-stream:10
  storage:
    resources:
      requests:
        storage: 10Gi
---
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataSource
metadata:
  name: centos-stream-10
  namespace: foreman
spec:
  source:
    pvc:
      name: centos-stream-10
      namespace: foreman
EOF

kubectl wait -n foreman \
  --for=jsonpath='{.status.phase}'=Succeeded \
  datavolume/centos-stream-10 \
  --timeout=20m
```

## Create the Foreman KubeVirt compute resource

This command reads the API host and port from the active `kubectl` context and uses the service-account token and Minikube CA certificate from `minikube.md`.

```shell
FOREMAN_NS=foreman
KUBE_API_SERVER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
KUBE_API_AUTHORITY=${KUBE_API_SERVER_URL#https://}
KUBE_API_HOST=${KUBE_API_AUTHORITY%:*}
KUBE_API_PORT=${KUBE_API_AUTHORITY##*:}
KUBEVIRT_TOKEN=$(kubectl get secret sa-foreman-token -n "$FOREMAN_NS" -o jsonpath='{.data.token}' | base64 -d)
KUBEVIRT_CA_CERT=$(cat "$HOME/.minikube/ca.crt")

be bin/hammer compute-resource create \
  --name "Minikube KubeVirt" \
  --provider "Kubevirt" \
  --hostname "$KUBE_API_HOST" \
  --api-port "$KUBE_API_PORT" \
  --namespace "$FOREMAN_NS" \
  --token "$KUBEVIRT_TOKEN" \
  --ca-cert "$KUBEVIRT_CA_CERT"
```

If this compute resource already exists, skip this command. The token is passed as a command argument; avoid sharing shell history or process output containing the expanded token.

## Register the image in Foreman

Register the DataSource under **Infrastructure > Compute Resources > Minikube KubeVirt > Images** using Hammer:

```shell
hammer compute-resource image create \
  --name "CentOS Stream 10" \
  --compute-resource "Minikube KubeVirt" \
  --operatingsystem "CentOS_Stream 10" \
  --architecture "x86_64" \
  --username "cloud-user" \
  --user-data true \
  --uuid "centos-stream-10"
```

`--uuid` is the DataSource name, not the Quay URL. Since the DataSource is in the same namespace as the compute resource, use `centos-stream-10` without a namespace prefix. For a DataSource in a different namespace, use `namespace/name`.

The image's default account is `cloud-user`; it does not have a preset root password. With user data enabled, cloud-init can apply Foreman's host configuration at first boot. If Foreman does not recognize `CentOS_Stream 10`, run `hammer os list` and use the exact CentOS Stream 10 title shown. If your Foreman installation requires organization or location context, add the corresponding `--organization` and `--location` options.

## References

- [KubeVirt curated container disks](https://github.com/kubevirt/containerdisks)
- [KubeVirt CDI/DataVolume guide](https://kubevirt.io/user-guide/user_workloads/templates/)
- [Foreman KubeVirt image field](https://github.com/theforeman/foreman_kubevirt/blob/master/app/views/images/form/_kubevirt.html.erb)
- [Foreman KubeVirt compute-resource API fields](https://github.com/theforeman/foreman_kubevirt/blob/master/docs/api/0.1.x/compute_resource.md)
