# HomeLab

## Setup infra
Step 1 is only needed when building everything from the ground.
1. Build the packer image (it is remarkably slow but I haven't spent time looking at why). 
    - It is currently missing a swap disabling that has to be done in the second step. But this can probably be added.

2. Initialize the nodes using terraform. When done do the following (https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/): 
    1. Disable swap (sudo swapoff -a).
    2. Start/join the cluster (sudo kubeadm init/join) 
    3. Copy the config form /etc/kubernetes/admin.conf to the local kubernetes config.
    4. Install a network policy (kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml)
    5. Bootstrap flux: 
        flux bootstrap github \
            --token-auth \
            --owner=JohanHellmark \
            --repository=HomeLab \
            --branch=main \
            --path=infrastructure/cluster \
            --personal \
            --components-extra image-reflector-controller,image-automation-controller
