# iVolve Cloud DevOps Project

```{=html}
<p align="center">
```
`<strong>`{=html}End-to-End CI/CD and GitOps Deployment on
AWS`</strong>`{=html}`<br>`{=html} Jenkins · Docker · Amazon ECR ·
Kubernetes · Amazon EKS · Argo CD
```{=html}
</p>
```

------------------------------------------------------------------------

## Project Overview

The **iVolve Cloud DevOps Project** demonstrates an end-to-end DevOps
workflow for building, scanning, publishing, and deploying a
containerized microservices application on AWS.

Jenkins automates the Continuous Integration (CI) process. After an
image is built and pushed to Amazon Elastic Container Registry (ECR),
Jenkins updates the corresponding Kubernetes manifest in GitHub. Argo CD
monitors the repository and automatically synchronizes the desired
configuration with the Amazon EKS cluster.

The project uses GitOps principles: **GitHub is the source of truth for
Kubernetes deployment configuration**.

## Architecture Overview

``` text
Developer
   |
   | Git push
   v
GitHub Repository
   |
   | Jenkins checks out source
   v
Jenkins CI Pipelines
   |  1. Build Docker image
   |  2. Scan image with Trivy
   |  3. Push image to Amazon ECR
   |  4. Remove local image
   |  5. Update Kubernetes manifest
   |  6. Commit and push manifest change
   v
Amazon ECR  <---------------- Jenkins publishes images
   |
   | Image reference in Kubernetes manifest
   v
GitHub Kubernetes Manifests
   |
   | Argo CD watches the configured Git repository and path
   v
Argo CD
   |
   | Automated synchronization
   v
Amazon EKS
   |
   +-- Frontend
   +-- Authentication service
   +-- Roadmap service
   +-- MySQL
   +-- Kubernetes Services / Ingress / Storage
```

### Main workflow

1.  A developer pushes application or pipeline changes to GitHub.
2.  The relevant Jenkins pipeline checks out the repository.
3.  Jenkins builds the service's Docker image.
4.  Trivy scans the image for vulnerabilities. The current pipeline scan
    is configured as non-blocking.
5.  Jenkins authenticates to Amazon ECR using the EC2 instance role and
    pushes the image.
6.  Jenkins updates the image tag in the service's Kubernetes Deployment
    manifest.
7.  Jenkins commits and pushes the updated manifest to the `master`
    branch.
8.  Argo CD detects the Git change and synchronizes the desired state to
    EKS.
9.  Kubernetes rolls out the updated workload.

> **Important:** Jenkins performs CI and updates Git manifests. Argo CD
> performs Continuous Deployment. The Jenkins pipelines do not directly
> run `kubectl apply` as part of the deployment flow.

## Technology Stack

  -----------------------------------------------------------------------
  Area                    Technology              Purpose
  ----------------------- ----------------------- -----------------------
  Source control          Git, GitHub             Source code and
                                                  Kubernetes
                                                  configuration

  CI automation           Jenkins                 Build, scan, publish,
                                                  and manifest update

  Shared pipeline code    Jenkins Shared Library  Reusable pipeline steps
                                                  stored in `vars/`

  Containers              Docker                  Build service images

  Image scanning          Trivy                   Container vulnerability
                                                  scanning

  Container registry      Amazon ECR              Store Docker images

  Cloud platform          AWS                     Infrastructure and
                                                  managed services

  Kubernetes              Amazon EKS              Run the application
                                                  workloads

  GitOps / CD             Argo CD                 Monitor Git and
                                                  synchronize Kubernetes
                                                  resources

  Infrastructure as Code  Terraform               Infrastructure
                                                  provisioning files in
                                                  `Terraform/`

  Configuration           Ansible                 Automation files in
  management                                      `Ansible/`
  -----------------------------------------------------------------------

## Repository Structure

``` text
.
├── Ansible/                     # Ansible automation and configuration
├── ArgoCD/
│   └── application.yaml         # Argo CD Application definition
├── Docker/
│   └── iVolveFinalProject/
│       ├── auth-service/        # Authentication service build context
│       ├── frontend/            # Frontend build context
│       └── roadmap-service/     # Roadmap service build context
├── Jenkinsfile-auth             # Authentication CI pipeline
├── Jenkinsfile-frontend         # Frontend CI pipeline
├── Jenkinsfile-roadmap          # Roadmap CI pipeline
├── Kubernetes/
│   ├── auth/
│   ├── frontend/
│   ├── roadmap/
│   ├── configmap.yaml
│   ├── ingress.yaml
│   ├── mysql-headless.yaml
│   ├── mysql-statefuelset.yaml
│   ├── namespace.yaml
│   ├── secret.yaml
│   └── storageclass.yaml
├── Terraform/                   # Terraform configuration
└── vars/                        # Jenkins Shared Library steps
```

The repository may contain additional files and supporting assets not
shown above.

## Environment Details

The current lab deployment uses the following configuration:

  ----------------------------------------------------------------------------------------
  Setting                             Value
  ----------------------------------- ----------------------------------------------------
  AWS Region                          `eu-north-1`

  EKS Cluster                         `ivolve-eks`

  EKS Node Group                      `ivolve-eks-workers`

  Kubernetes Namespace                `ivolve`

  ECR Repository                      `ivolve-repo`

  ECR Registry                        `185467622030.dkr.ecr.eu-north-1.amazonaws.com`

  GitHub Repository                   `https://github.com/Essammo22/-CloudDevOpsProject`

  Git Branch                          `master`

  Argo CD Application                 `ivolve-app`

  Argo CD Namespace                   `argocd`
  ----------------------------------------------------------------------------------------

These are the values used by the current lab environment. Update them if
deploying to another AWS account, region, cluster, or repository.

## Prerequisites

Before setting up the project, prepare:

-   An AWS account with permissions to create and manage the required
    resources.
-   AWS CLI configured with an appropriate identity.
-   An Amazon EKS cluster and a managed node group.
-   An Amazon ECR repository.
-   `kubectl` configured to access the EKS cluster.
-   Docker installed on the Jenkins agent.
-   Jenkins with Pipeline and Git support.
-   Trivy installed on the Jenkins agent.
-   A GitHub repository and a GitHub token with repository Contents
    read/write access for Jenkins manifest commits.
-   Argo CD installed in the target Kubernetes cluster.

Do not store AWS access keys, GitHub tokens, passwords, or other
credentials in source code or committed YAML files. Use IAM roles,
Jenkins Credentials, Kubernetes Secrets, or an external
secret-management solution as appropriate.

## Setup Instructions

### 1. Clone the repository

``` bash
git clone https://github.com/Essammo22/-CloudDevOpsProject.git
cd -CloudDevOpsProject
git checkout master
```

### 2. Configure AWS access

Configure AWS CLI on the machine used for administration:

``` bash
aws configure
aws sts get-caller-identity
```

For Jenkins running on an EC2 instance, prefer an attached IAM instance
role instead of static AWS access keys.

The Jenkins EC2 role in the current lab is named `JenkinsEC2Role` and
has ECR permissions through the `AmazonEC2ContainerRegistryPowerUser`
policy.

Verify ECR access:

``` bash
aws ecr describe-repositories \
  --region eu-north-1 \
  --repository-names ivolve-repo
```

### 3. Configure Jenkins

Create or configure the Jenkins Shared Library:

-   **Library name:** `ivolve-shared-library`
-   **Default version:** `master`
-   **SCM:** Git
-   **Repository URL:**
    `https://github.com/Essammo22/-CloudDevOpsProject.git`

Add a Jenkins credential with ID `github-creds`:

-   Kind: Username with password
-   Username: GitHub username
-   Password: GitHub Personal Access Token with repository Contents
    read/write permission

Configure the three Pipeline jobs to use **Pipeline script from SCM**:

  Jenkins job                  Script path
  ---------------------------- ------------------------
  `ivolve-auth-pipeline`       `Jenkinsfile-auth`
  `ivolve-frontend-pipeline`   `Jenkinsfile-frontend`
  `ivolve-roadmap-pipeline`    `Jenkinsfile-roadmap`

Set the branch specifier to `*/master`.

The Jenkins Shared Library contains reusable steps under `vars/`,
including image build, scan, push, cleanup, manifest update, and Git
push operations.

### 4. Build and publish service images

Run the required Jenkins pipeline for each service:

1.  `ivolve-auth-pipeline`
2.  `ivolve-frontend-pipeline`
3.  `ivolve-roadmap-pipeline`

The pipelines use build-number-based image tags:

-   Authentication: `auth-<BUILD_NUMBER>`
-   Frontend: `frontend-<BUILD_NUMBER>`
-   Roadmap: `roadmap-<BUILD_NUMBER>`

After a successful run, verify that the images exist in ECR:

``` bash
aws ecr list-images \
  --repository-name ivolve-repo \
  --region eu-north-1
```

### 5. Connect kubectl to EKS

``` bash
aws eks update-kubeconfig \
  --region eu-north-1 \
  --name ivolve-eks

kubectl config current-context
kubectl get nodes
```

Confirm that the expected EKS cluster is the current context and that
the nodes are `Ready`.

### 6. Install Argo CD

Create the Argo CD namespace:

``` bash
kubectl create namespace argocd
```

Install Argo CD using the upstream installation manifest:

``` bash
kubectl apply --server-side -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Check the Argo CD components:

``` bash
kubectl get pods -n argocd
```

Wait until the required pods are ready before proceeding.

### 7. Create the Argo CD Application

The repository includes `ArgoCD/application.yaml`. It defines:

-   Git repository:
    `https://github.com/Essammo22/-CloudDevOpsProject.git`
-   Revision: `master`
-   Manifest path: `Kubernetes`
-   Recursive directory scanning
-   Destination cluster: the in-cluster Kubernetes API
-   Destination namespace: `ivolve`
-   Automated sync, pruning, and self-healing

Apply the Application:

``` bash
kubectl apply -f ArgoCD/application.yaml
```

Check synchronization and health:

``` bash
kubectl get applications -n argocd
```

Expected application name: `ivolve-app`.

The desired state is:

-   Sync status: `Synced`
-   Health status: `Healthy`

### 8. Open the Argo CD Web UI

For a local administrative session, forward the Argo CD server service:

``` bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Keep this terminal running and open:

``` text
https://localhost:8080
```

Retrieve the initial admin password:

``` bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo
```

Sign in with username `admin` and the retrieved password. Change the
initial password after first login and follow your organization's
access-control practices.

Port forwarding is temporary and only accessible through the machine
running the command. For shared access, configure a secured ingress or
load balancer with TLS and appropriate authentication.

## Verification and Operations

### Check Kubernetes workloads

``` bash
kubectl get pods -n ivolve -o wide
kubectl get deployments,services -n ivolve
kubectl get ingress -n ivolve
```

### Check Argo CD application status

``` bash
kubectl get applications -n argocd
kubectl describe application ivolve-app -n argocd
```

### Observe Argo CD synchronization

In the Argo CD UI:

1.  Open the `ivolve-app` Application.
2.  Review the Sync and Health status.
3.  Inspect the resource tree to view Deployments, Pods, Services, and
    other managed resources.
4.  Review application events and resource details if a resource is
    unhealthy or out of sync.

### Test the GitOps workflow

1.  Run the relevant Jenkins pipeline.
2.  Confirm that Jenkins pushes an updated image tag to the service
    Deployment manifest on GitHub.
3.  Open the `ivolve-app` Application in Argo CD.
4.  Observe Argo CD detecting the Git change and synchronizing it.
5.  Verify the resulting Pods and Deployment in the `ivolve` namespace.

With automated synchronization enabled, a manual `kubectl apply` is not
required for changes made to the tracked manifests in Git.

## Troubleshooting

  -----------------------------------------------------------------------
  Symptom                             What to check
  ----------------------------------- -----------------------------------
  `kubectl` cannot connect to EKS     Check network/DNS connectivity, AWS
                                      credentials, kubeconfig, and EKS
                                      endpoint access.

  Argo CD pods remain `Pending`       Check node capacity, pod limits,
                                      available CPU/memory, and
                                      scheduling events with
                                      `kubectl describe pod`.

  Application is `OutOfSync`          Inspect the Application's diff and
                                      sync status; confirm the Git branch
                                      and manifest path.

  Application is `Progressing`        Inspect the resource tree and
                                      workload events; check Pods,
                                      Deployments, PVCs, and image pull
                                      errors.

  Application is `Degraded`           Use `kubectl describe` and
                                      `kubectl logs` on the affected
                                      workload.

  Jenkins cannot push to ECR          Verify the EC2 instance role, ECR
                                      permissions, AWS region, repository
                                      name, and Docker login.

  Jenkins cannot push manifest        Verify the `github-creds` Jenkins
  changes                             credential and its repository
                                      Contents write permission.
  -----------------------------------------------------------------------

Useful commands:

``` bash
kubectl get events -n ivolve --sort-by=.lastTimestamp
kubectl get pods -n ivolve
kubectl describe pod <pod-name> -n ivolve
kubectl logs <pod-name> -n ivolve
kubectl get applications -n argocd
```

## Security Notes

-   Use IAM roles for AWS workloads instead of long-lived access keys
    wherever possible.
-   Keep GitHub Personal Access Tokens in Jenkins Credentials.
-   Never commit real credentials or passwords in Kubernetes manifests.
-   Restrict access to the Argo CD admin account and rotate initial
    credentials.
-   Use TLS and authentication when exposing Argo CD beyond temporary
    local port forwarding.
-   Review Trivy findings and remediate vulnerabilities. The current
    scan is intentionally non-blocking, so a successful pipeline does
    not mean the image is vulnerability-free.

## Deliverables

-   Three Jenkins pipeline files for the microservices.
-   Jenkins Shared Library steps under `vars/`.
-   Kubernetes manifests for the application.
-   Argo CD Application definition at `ArgoCD/application.yaml`.
-   This project documentation at `README.md`.

## Author

**Essam Mostafa**

GitHub: [Essammo22](https://github.com/Essammo22)

Repository: [iVolve Cloud DevOps
Project](https://github.com/Essammo22/-CloudDevOpsProject)
