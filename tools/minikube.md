# Minikube with Kubevirt

* [Docs](https://minikube.sigs.k8s.io/docs)

## Prerequisites (Fedora)

KubeVirt runs VMs inside the cluster, so the host needs working hardware virtualization and the `kvm2` minikube driver.

```shell
sudo dnf install -y @virtualization libvirt qemu-kvm
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $(whoami)
# log out/in (or `newgrp libvirt`) for the group change to take effect
```

Verify the host can actually run KVM guests:

```shell
virt-host-validate qemu
```

If `virt-host-validate` reports missing hardware virtualization (common on laptops, nested cloud VMs, or some CI runners), KubeVirt can still run in software emulation mode — see [Troubleshooting](#troubleshooting) below.

Also make sure `kubectl` is installed (or prefix every command below with `minikube kubectl --`):

```shell
sudo dnf install -y kubernetes-client
```

## Installation

### Cleanup

```shell
minikube delete --all --purge
rm -rf ~/.minikube/cache/iso
rm -rf ~/.minikube/machines/minikube
dnf remove minikube -y
```

### Minikube

```shell
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm
```

### First run

KubeVirt needs more resources than minikube's defaults, so size the VM explicitly:

```shell
minikube start --driver=kvm2 --cni=flannel --memory=8192 --cpus=4 --disk-size=40g
minikube addons enable metrics-server
minikube addons enable default-storageclass
minikube addons enable storage-provisioner
kubectl get pods -A
```

`default-storageclass`/`storage-provisioner` are needed so CDI can create PVCs for VM disks later.

### KubeVirt

```shell
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
echo $VERSION
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml"
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml"
```

Verify components. Wait until installation is done:
```shell
watch kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt
```

### CDI

```shell
export CDI_VERSION=$(curl -s https://api.github.com/repos/kubevirt/containerized-data-importer/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo $CDI_VERSION
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-operator.yaml
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-cr.yaml
```

Verify installation
```shell
kubectl get pods -n cdi
```

It's normal for `cdi-uploadproxy` to briefly show `CreateContainerConfigError` (missing `cdi-api-signing-key` secret) right after apply — `cdi-apiserver` creates that secret on its own startup, and kubelet retries automatically once it exists. Re-check after a few seconds; all pods should reach `1/1 Running`.

### Sanity check: run a test VM

Before wiring anything into Foreman, confirm KubeVirt can actually boot a VM:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: kubevirt.io/v1
kind: VirtualMachineInstance
metadata:
  name: testvm
spec:
  domain:
    devices:
      disks:
        - name: containerdisk
          disk: {}
    resources:
      requests:
        memory: 128Mi
  volumes:
    - name: containerdisk
      containerDisk:
        image: quay.io/kubevirt/cirros-container-disk-demo
EOF
watch kubectl get vmi testvm
```

If this VM reaches `Running`, the cluster is ready for `foreman_kubevirt` development. Clean it up with `kubectl delete vmi testvm`.

## Run

```shell
minikube start --driver=kvm2 --cni=flannel --memory=8192 --cpus=4 --disk-size=40g
```

## Logs

Get Kubevirt pods

```shell
kubectl get pods -n kubevirt
NAME                               READY   STATUS    RESTARTS   AGE
virt-api-c7557fd74-gmmx7           1/1     Running   0          4m40s
virt-controller-5677985698-mvkjw   1/1     Running   0          4m12s
virt-controller-5677985698-w9wls   1/1     Running   0          4m12s
virt-handler-sbk6n                 1/1     Running   0          4m12s
virt-operator-86d97799c8-gkj5s     1/1     Running   0          5m45s
virt-operator-86d97799c8-t9tl6     1/1     Running   0          5m45s

kubectl logs -n kubevirt -f <pod>
```

## Tools

### Virtctl

Tool for quick access to the serial and graphical ports of a VM and also handle start/stop operations.

```shell
VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/')
echo ${ARCH}
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
sudo install -m 0755 virtctl /usr/local/bin
```

### KubeVirt-manager

```shell
kubectl apply -f https://github.com/kubevirt-manager/kubevirt-manager/releases/download/v1.5.4/bundled-v1.5.4.yaml
kubectl patch svc kubevirt-manager -n kubevirt-manager -p '{"spec": {"type": "NodePort"}}'
kubectl wait --for=condition=Available deployment/kubevirt-manager -n kubevirt-manager --timeout=60s
minikube service kubevirt-manager -n kubevirt-manager
```

If `minikube service` fails with `SVC_UNREACHABLE: no running pod for service found`, the deployment's pod just wasn't ready yet when it ran — the `kubectl wait` above avoids the race, or just retry the `minikube service` command after checking `kubectl get pods -n kubevirt-manager`.

## Data

### Namespace

```shell
export NS=foreman
kubectl create namespace ${NS}
```

### Service account

Create an account
```shell
kubectl create serviceaccount sa-foreman -n ${NS}
```

Grant Admin Permissions
```shell
kubectl create clusterrolebinding sa-foreman-admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=${NS}:sa-foreman
```

Create the Secret
```shell
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: sa-foreman-token
  namespace: ${NS}
  annotations:
    kubernetes.io/service-account.name: sa-foreman
type: kubernetes.io/service-account-token
EOF
```

Get the token
```shell
kubectl get secret sa-foreman-token -n ${NS} -o jsonpath='{.data.token}' | base64 -d
```

## Foreman

### Compute resource

Create a new "Kubevirt" compute resource in Foreman (Infrastructure > Compute Resources) with:

* Hostname/URL: `kubectl cluster-info` (the `control plane` address, e.g. `https://192.168.39.2:8443`)
* API port: `8443`
* Namespace: `${NS}` from above — Foreman will only see/create VMs in this namespace
* Token: the service account token retrieved above
* Cert: `cat ~/.minikube/ca.crt`

After it's added, "Test Connection" should succeed and the namespace's storage classes should populate the VM creation form. To provision a VM through Foreman you'll also need a bootable image/template registered (e.g. a containerDisk or a CDI DataVolume source) — the [sanity check VM](#sanity-check-run-a-test-vm) above confirms the cluster itself can run one before debugging the Foreman side.

For `foreman_kubevirt` plugin development, point your Foreman checkout at this cluster the same way `kubectl`/`virtctl` do — make sure `KUBECONFIG` (default `~/.kube/config`, managed by `minikube start`) is the context Foreman's Ruby client ends up using, since the plugin talks to the Kubernetes API directly rather than through `minikube kubectl`.

## Troubleshooting

### No hardware virtualization available

If `virt-host-validate qemu` fails (e.g. running inside a nested VM without nested virtualization enabled), KubeVirt can fall back to software emulation — much slower, but enough for plugin development:

```shell
kubectl -n kubevirt patch kubevirt kubevirt --type merge \
  --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'
```

### Permission denied on /dev/kvm

Usually means the `libvirt`/`kvm` group membership from [Prerequisites](#prerequisites-fedora) hasn't taken effect yet in your current shell — log out/in or run `newgrp libvirt` and retry `minikube start`.
