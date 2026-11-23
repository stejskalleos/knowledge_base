# KubeVirt/Foreman CNI Providers (beginner notes)

How pod/VM networking works in Kubernetes, and what the `CNI Provider` dropdown in Foreman's KubeVirt host form (`multus`/`genie`/`pod`) actually means.

## The basic problem: how do pods get networking?

Kubernetes doesn't ship its own networking implementation. Instead it defines an interface — **CNI (Container Network Interface)** — and lets you plug in whatever networking plugin you want. When a pod (or, in KubeVirt's case, a VM running inside a pod) starts, the kubelet calls out to a CNI plugin and says "attach a network interface to this thing." The plugin decides how IP addresses are assigned, what virtual switches/bridges get used, and whether the pod can talk to other pods/nodes.

Every cluster needs exactly one **primary/default CNI plugin** installed, or pods can't get any network connectivity at all. That default network is what Foreman/KubeVirt calls the **`pod` network**.

## Flannel (the default CNI in this Minikube setup)

Following [minikube_setup.md](minikube_setup.md), the cluster is started with `minikube start --driver=kvm2 --cni=flannel ...` — so **Flannel** is the primary CNI plugin installed here.

Flannel is a simple, widely-used CNI plugin whose only job is to give every pod in the cluster its own IP address and make sure pods can reach each other across nodes, without you having to configure any routing by hand. It does this by:

- Allocating each node a slice (subnet) of a larger cluster-wide IP range.
- Giving every pod scheduled on that node an IP from that node's slice.
- Building an overlay network (by default using VXLAN — encapsulating pod traffic inside regular IP packets) so pods on different nodes can route to each other's "fake" pod-network IPs over the real node network.

That's it — no VLANs, no multiple interfaces, no fancy policy engine. It's the networking equivalent of "just make it work," which is why it's a common default for small/dev/test clusters like a single-node Minikube. For a single-node cluster (your case), it's mostly just handing out pod IPs and wiring up a bridge, since there's no cross-node traffic to tunnel.

When Foreman/KubeVirt talks about the `pod` CNI provider, it means: "attach this VM to whatever Flannel already set up" — no additional configuration needed, which is also why the UI disables the Network dropdown for this choice (there's nothing to pick).

## The three options in `foreman_kubevirt`

Looking at `cni_providers` in the plugin (`foreman_kubevirt/app/models/foreman_kubevirt/kubevirt.rb:146-148`):

```ruby
[[_("multus"), :multus], [_("genie"), :genie], [_("pod"), :pod]]
```

### 1. `pod` — the default pod network

Just means "use whatever the cluster's primary CNI already set up" (Flannel, here). Every pod/VM gets exactly one such interface automatically — there's nothing extra to configure, no separate network object to pick.

### 2. `multus` — "meta" CNI, multiple networks per pod

Normally a pod/VM gets exactly *one* network interface (the pod network). Multus is a plugin that lets a single pod attach *additional* network interfaces on top of that — e.g. a VM could have its normal pod-network interface *plus* a dedicated interface on a VLAN for storage traffic, or an interface bridged onto the physical LAN so the VM gets a "real" routable IP. To use it, a cluster admin pre-defines named networks as Kubernetes custom resources called **`NetworkAttachmentDefinition`**s (a CRD installed by the Multus operator/CNI). Foreman's Network dropdown is populated from exactly these objects — it calls `client.networkattachmentdefs.all` (`kubevirt.rb:87-91`).

### 3. `genie` — an older/alternative multi-network CNI meta-plugin

Same idea as Multus (multiple networks per pod), different (now largely unmaintained) implementation. Can mostly be ignored unless something specifically requires it.

## Why this Minikube cluster only really has `pod`

This cluster was never given the Multus CNI plugin or any `NetworkAttachmentDefinition` CRD — that's a separate install step the [minikube_setup.md](minikube_setup.md) guide doesn't cover. So when Foreman asks the cluster "what named networks exist for Multus?", it gets a 404 (no such CRD) and returns an empty list — logged as:

```
Failed to retrieve network attachments definition from KubeVirt,
make sure KubeVirt has CNI provider and NetworkAttachmentDefinition CRD deployed
```

Practically, `multus`/`genie` aren't usable options here — `pod` is the only functional choice, and it's also the correct one for a VM that just needs basic connectivity (e.g. to reach it over SSH/cloud-init after provisioning). Multus would only matter if a VM later needed a second dedicated NIC or a bridge onto an external VLAN.

## Known `foreman_kubevirt` bug when using `pod`

Selecting CNI Provider `pod` in the host form disables the Network select (`compute_resources_vms/form/kubevirt/_network.html.erb:17`), so the browser never submits a `network` value for that interface. But `create_network_devices_for_vm` (`kubevirt.rb:541`) unconditionally requires both `:cni_provider` and `:network` keys to be present, even though two lines later it explicitly treats `pod` as not needing a network at all (`kubevirt.rb:542-543`). This raises `cni_provider or network are missing` on host create.

Note `host_compute_attrs` (`kubevirt.rb:220-224`, used when *re-displaying* an already-saved host) already works around this by setting `nic["network"] = nil` when `cni_provider == "pod"` — that normalization just isn't applied on the create path.
