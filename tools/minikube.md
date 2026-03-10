# Minikube with Kubevirt

* [Docs](https://minikube.sigs.k8s.io/docs)

## Installation

### Cleanup

```shell
minikube delete --all --purge
Remove minikube VM
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

```shell
minikube start --cni=flannel
minikube addons enable metrics-server
minikube kubectl -- get pods -A
```

### KubeVirt

```shell
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
echo $VERSION
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml"
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml"
```

Verify components

Wait until installation is done
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
## Run

```shell
minikube start --cni=flannel
```

## Dashboard

```shell
minikube addons enable metrics-server
minikube dashboard
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
ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/') || windows-amd64.exe
echo ${ARCH}
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
sudo install -m 0755 virtctl /usr/local/bin
```

### KubeVirt-manager

```shell
kubectl apply -f https://github.com/kubevirt-manager/kubevirt-manager/releases/download/v1.5.4/bundled-v1.5.4.yaml
kubectl patch svc kubevirt-manager -n kubevirt-manager -p '{"spec": {"type": "NodePort"}}'
minikube service kubevirt-manager -n kubevirt-manager
```

## Data

### Namespace

```shell
kubectl create namespace lstejska
```

### Service account

Create an account
```shell
kubectl create serviceaccount sa-ls -n lstejska
```

Grant Admin Permissions
```shell
kubectl create clusterrolebinding sa-ls-admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=lstejska:sa-ls
```

Create the Secret
```shell
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: sa-ls-foreman-token
  namespace: lstejska
  annotations:
    kubernetes.io/service-account.name: sa-ls
type: kubernetes.io/service-account-token
EOF
```

Get the token
```shell
kubectl get secret sa-ls-foreman-token -n lstejska -o jsonpath={.data.token} | base64 -d
```

## Foreman

### Compute resource

* Hostname: `kubectl cluster-info`
* API port: `8443`
* Cert: `cat ~/.minikube/ca.crt`

