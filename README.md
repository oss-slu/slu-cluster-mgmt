# SLU Cluster Management (infra-ansible)

This repository contains the Ansible orchestration for the Open Source SLU server cluster. It manages the configuration, security, and deployment for `oss01` (Master) and `oss02` (Worker).

---

## Quick Start

Provision the entire infrastructure from scratch:

```bash
ansible-playbook -i inventory/hosts.ini site.yaml -K
```

### Run Specific Layers

System tools only:

```bash
ansible-playbook site.yaml --tags base -K
```

Kubernetes and networking only:

```bash
ansible-playbook site.yaml --tags k8s_prep -K
```

---

## Cluster Sanity Checks

Run these commands to verify infrastructure health.  
If all checks pass, the cluster is healthy.

---

### 1. Node Status

Verify master and worker communication:

```bash
k get nodes -o wide
```

Expected result:

```
STATUS: Ready
```

Both `oss01` and `oss02` should show `Ready`.

---

### 2. Pod Distribution

Ensure workloads are balanced across nodes (verifies Calico mesh networking):

```bash
k get pods -A -o wide | grep -v 'kube-system'
```

Expected result:

Pods appear on both nodes under the `NODE` column.

---

### 3. Service Connectivity

Verify NodePort exposure and application response:

```bash
# Check if the OS is listening on the NodePort
sudo netstat -tulpn | grep 30080

# Test the HTTP response
curl -I http://localhost:30080
```

Expected result:

```
HTTP/1.1 200 OK
```

---

### 4. Application Logs (Prisma / Database)

Confirm backend-to-database connectivity:

```bash
k logs deploy/coredesk-app --tail=50
```

Expected result:

```
prisma:client libraryStarted: true
```

There should be no database connection errors.

---

## Troubleshooting

| Symptom            | Probable Cause                   | Fix |
|--------------------|----------------------------------|-----|
| Apt cache lock     | Broken or third-party repo issue | Run `ansible-playbook site.yaml --tags base -K` |
| Node NotReady      | Calico / CNI handshake failure   | Run `ansible-playbook site.yaml --tags k8s_prep -K` |
| Connection Refused | Firewall or NodePort mismatch    | Verify port with `k get svc` |

---

## Security Note

Sensitive variables in `group_vars/all.yml` are encrypted using Ansible Vault.

To run playbooks that require secrets:

```bash
ansible-playbook site.yaml -K --ask-vault-pass
```

---

## Repository Structure

```
infra-ansible/
├── inventory/
│   └── hosts.ini
├── group_vars/
│   └── all.yml (vault encrypted)
├── roles/
├── site.yaml
└── README.md
```

---

## Cluster Health Definition

The cluster is considered healthy when:

- Both nodes are `Ready`
- Pods are distributed across nodes
- NodePort responds with `200 OK`
- Prisma initializes without database errors
- No Calico or CNI failures are present

---

Maintained by the Open Source SLU Infrastructure & Operations Team
