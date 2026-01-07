# 🔐 Sealed Secrets (kubeseal) – Complete Setup & Test Guide

This guide walks through:

1. Installing the Sealed Secrets controller using Helm (with resource requests & limits)
2. Installing the kubeseal CLI on the host machine
3. Fetching the public encryption key
4. Creating a Kubernetes Secret (dry-run)
5. Encrypting the Secret into a SealedSecret
6. Deploying it into the cluster
7. Verifying that decryption worked correctly

This flow works for:
- Local Kubernetes clusters
- Killercoda playgrounds
- GKE Autopilot
- ArgoCD / GitOps setups

---

## 📌 Prerequisites

- Kubernetes cluster access
- kubectl configured and working
- helm installed
- Cluster-admin (or equivalent) permissions

Verify:
```bash
kubectl get nodes
helm version
```

---

## 1️⃣ Install Sealed Secrets Controller using Helm

Add the Helm repository:

```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
```

Install the controller in kube-system with resource requests & limits:

```bash
helm install sealed-secrets sealed-secrets/sealed-secrets   -n kube-system --create-namespace   --set fullnameOverride=sealed-secrets-controller   --set-string webhooks.tlsSecretName=sealed-secrets-tls   --set resources.requests.cpu=100m   --set resources.requests.memory=128Mi   --set resources.limits.cpu=100m   --set resources.limits.memory=128Mi   --wait
```

Verify controller:

```bash
kubectl get pods -n kube-system | grep sealed
```

---

## 2️⃣ Install kubeseal CLI

```bash
curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.34.0/kubeseal-0.34.0-linux-amd64.tar.gz"
tar -xvzf kubeseal-0.34.0-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

Verify:

```bash
kubeseal --version
```

---

## 3️⃣ Fetch the Public Key

```bash
kubeseal   --controller-name=sealed-secrets-controller   --controller-namespace=kube-system   --fetch-cert > sealed-secrets-public.pem
```

---

## 4️⃣ Create a Secret (Dry Run)

```bash
kubectl create secret generic app-secret   --from-literal=API_KEY=killercoda-test   -n default   --dry-run=client -o yaml > secret.yaml
```

---

## 5️⃣ Encrypt the Secret

```bash
kubeseal   --cert sealed-secrets-public.pem   --namespace default   --format yaml   < secret.yaml > sealed-secret.yaml
```

---

## 6️⃣ Deploy the SealedSecret

```bash
kubectl apply -f sealed-secret.yaml
```

---

## 7️⃣ Verify Decryption

Check secret:

```bash
kubectl get secret app-secret -n default
```

Decode value (testing only):

```bash
kubectl get secret app-secret -n default   -o jsonpath='{.data.API_KEY}' | base64 --decode
```

---

## 8️⃣ Verify via Pod (Recommended)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-test
  namespace: default
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo API_KEY=$API_KEY && sleep 3600"]
    envFrom:
    - secretRef:
        name: app-secret
```

Apply and check:

```bash
kubectl apply -f pod.yaml
kubectl logs secret-test
```

---

## ✅ Summary

- kubeseal encrypts secrets locally
- Decryption happens only inside the cluster
- Private key never leaves kube-system
- Safe for Git & GitOps workflows

---

## 🔑 Final Takeaway

Sealed Secrets allows secure secret management in GitOps by separating encryption (local) and decryption (cluster-only).
