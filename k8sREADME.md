# Java Expense Tracker - Kubernetes Deployment

This project demonstrates how to deploy a Spring Boot application with MySQL on a Kubernetes cluster created using **kubeadm**.

## Architecture

```
                +---------------------+
                |     Internet        |
                +----------+----------+
                           |
                    NodePort Service
                           |
                 +---------+----------+
                 | Spring Boot Pods   |
                 |     (Replica=2)    |
                 +---------+----------+
                           |
                    ClusterIP Service
                           |
                 +---------+----------+
                 |     MySQL Pod      |
                 +---------+----------+
                           |
                         PVC
                           |
                          PV
```

---

## Tech Stack

- Spring Boot
- MySQL 8
- Docker
- Kubernetes (kubeadm)
- CRI-O
- Calico CNI
- AWS EC2

---

## Project Structure

```
.
├── Dockerfile
├── Jenkinsfile
├── pom.xml
├── src/
└── k8s/
    ├── namespace.yaml
    ├── mysql-secret.yaml
    ├── mysql-pv.yaml
    ├── mysql-pvc.yaml
    ├── mysql-deployment.yaml
    ├── mysql-service.yaml
    ├── deployment.yaml
    └── service.yaml
```

---

# Prerequisites

- Kubernetes Cluster (kubeadm)
- kubectl
- Docker
- DockerHub account
- AWS EC2 (Optional)

---

# Build Docker Image

```bash
docker build -t atique55md/java-app:v1 .
```

Run locally

```bash
docker run -p 8080:8080 atique55md/java-app:v1
```

Push image

```bash
docker login

docker push atique55md/java-app:v1
```

---

# Kubernetes Deployment

## Create Namespace

```bash
kubectl apply -f namespace.yaml
```

---

## Create Secret

```bash
kubectl apply -f mysql-secret.yaml
```

---

## Create Persistent Volume

```bash
kubectl apply -f mysql-pv.yaml
```

---

## Create Persistent Volume Claim

```bash
kubectl apply -f mysql-pvc.yaml
```

Verify

```bash
kubectl get pv

kubectl get pvc -n java-app
```

PVC status should be

```
Bound
```

---

## Deploy MySQL

```bash
kubectl apply -f mysql-deployment.yaml

kubectl apply -f mysql-service.yaml
```

Verify

```bash
kubectl get pods -n java-app

kubectl get svc -n java-app
```

---

## Deploy Spring Boot

```bash
kubectl apply -f deployment.yaml

kubectl apply -f service.yaml
```

Verify

```bash
kubectl get pods -n java-app

kubectl get svc -n java-app
```

---

# Access Application

```bash
kubectl get svc -n java-app
```

Example

```
NAME           TYPE       PORT
java-service   NodePort   30080
```

Open

```
http://<EC2-Public-IP>:30080
```

---

# Useful Commands

### Pods

```bash
kubectl get pods -n java-app

kubectl describe pod <pod-name> -n java-app

kubectl logs <pod-name> -n java-app

kubectl logs <pod-name> --previous -n java-app
```

### Deployments

```bash
kubectl get deployment -n java-app

kubectl rollout restart deployment java-app -n java-app

kubectl rollout restart deployment mysql -n java-app
```

### Services

```bash
kubectl get svc -n java-app

kubectl describe svc mysql -n java-app
```

### PVC

```bash
kubectl get pvc -n java-app

kubectl describe pvc mysql-pvc -n java-app
```

### PV

```bash
kubectl get pv
```

### DNS Test

```bash
kubectl run dns-test \
--image=busybox:1.36 \
-it \
--rm \
--restart=Never \
-n java-app -- sh
```

Inside Pod

```bash
nslookup mysql

nslookup kubernetes.default

cat /etc/resolv.conf
```

---

# Troubleshooting

## MySQL Pod Pending

Check

```bash
kubectl get pvc -n java-app
```

If PVC is Pending

- Create PersistentVolume
- Verify StorageClass
- Verify PV/PVC binding

---

## Spring Boot CrashLoopBackOff

Check logs

```bash
kubectl logs <pod> -n java-app
```

Common reasons

- Database not running
- Incorrect Secret
- Wrong datasource URL
- MySQL Service missing

---

## UnknownHostException: mysql

Verify

```bash
kubectl get svc -n java-app

kubectl get endpoints -n java-app
```

Test DNS

```bash
nslookup mysql
```

---

## CoreDNS Issue

Check

```bash
kubectl get pods -n kube-system

kubectl get svc -n kube-system
```

---

## Calico Issue

Check

```bash
kubectl get pods -n kube-system

kubectl exec -it -n kube-system <calico-pod> -- birdcl show protocols
```

Healthy state

```
Established
```

---

## AWS Security Group

For Calico BGP, allow

- All Traffic
- Source = Same Security Group

or

- TCP 179
- Node-to-Node communication

Without this, pods cannot resolve Kubernetes Services.

---

# Lessons Learned

- Always deploy MySQL before the application.
- Verify PV/PVC are **Bound**.
- Verify MySQL Service has Endpoints.
- Test DNS using a BusyBox pod.
- Check CoreDNS before debugging the application.
- For Calico BGP, ensure EC2 Security Groups allow node-to-node communication on TCP 179 (or allow all traffic between cluster nodes).
- Keep Spring Boot datasource configuration in the **application Deployment**, not the MySQL Deployment.

---

# Cleanup

```bash
kubectl delete namespace java-app
```

or

```bash
kubectl delete -f k8s/
```

---

# Future Improvements

- Jenkins CI/CD Pipeline
- Ingress Controller
- NGINX Ingress
- Helm Charts
- Horizontal Pod Autoscaler
- Prometheus & Grafana Monitoring
- ArgoCD GitOps

#Screenshots

