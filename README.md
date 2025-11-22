# ArenaVerse Platform

ArenaVerse is a **learning-grade, production-style platform** for a real-time multiplayer game + social system.

It’s designed as a **Platform Engineering lab** to practice:

- Kubernetes (GKE)
- Istio / Cloud Service Mesh
- Terraform
- Google Cloud Platform (GCP)
- System design, SRE, security, and platform UX

This repo is meant to be your **end-to-end playground**: from org-level GCP setup to multi-cluster, multi-region, mesh-secured microservices.

---

## High-Level Concept

ArenaVerse is a backend platform for:

- Real-time multiplayer game sessions
- Lobbies and matchmaking
- Chat and social graph (friends, parties, guilds)
- Telemetry and analytics
- Light AI integrations (chat moderation, matchmaking hints)

Everything is built and operated like a real platform team would:
infra as code, GitOps, SLOs, canaries, and proper security.

---

## Repository Structure

Suggested top-level layout:

```text
arenaverse-platform/
├─ infra/            # Terraform modules & stacks (GCP, networking, GKE, Pub/Sub, etc.)
│  ├─ bootstrap/     # Terraform backend & provider bootstrap
│  ├─ modules/       # Reusable Terraform modules (network, gke, iam, project, etc.)
│  └─ stacks/        # Env-specific stacks (dev, staging, prod)
├─ manifests/        # Kubernetes & Istio manifests (or Helm/Kustomize)
│  ├─ base/          # Base manifests shared across envs
│  └─ overlays/      # Env-specific overlays (dev, staging, prod)
├─ apps/             # Application services (api-gateway, auth, lobby, game-session, chat, etc.)
│  └─ <service>/     # Each microservice in its own folder
├─ docs/             # Architecture docs, runbooks, assignment checklist, ADRs
│  ├─ assignment-checklist.md
│  ├─ architecture-overview.md
│  ├─ networking.md
│  ├─ projects.md
│  ├─ events.md
│  ├─ slo.md
│  └─ runbooks/
└─ .github/ or ci/   # CI/CD pipelines (optional but recommended)
````

---

## Core Technologies

* **Cloud:** Google Cloud Platform (GCP)
* **Compute:** Google Kubernetes Engine (GKE)
* **IaC:** Terraform
* **Service Mesh:** Istio or Cloud Service Mesh
* **Messaging:** Cloud Pub/Sub
* **Observability:** Cloud Logging & Monitoring (and/or Prometheus, OpenTelemetry)
* **Optional GitOps:** Argo CD / Flux

---

## Platform Architecture (Conceptual)

At a high level:

```text
Clients (Web / Game Client)
        |
        v
Global HTTPS Load Balancer (GCP)
        |
        v
Istio Ingress Gateway (GKE clusters; multi-region)
        |
        v
----------------- Service Mesh --------------------
  api-gateway        chat-service        telemetry
       |                   |                  |
       v                   v                  v
   auth-service       social-graph       Pub/Sub topics
   lobby-service      presence           (game-events, analytics-events)
   game-session-service
---------------------------------------------------
          |                    |
          v                    v
     Databases (Cloud SQL, Redis, Firestore, etc.)
     Analytics (BigQuery / data lake)
```

* **Terraform** owns everything outside the cluster (projects, networks, clusters, LB, Pub/Sub, DBs).
* **Kubernetes** runs the microservices and in-cluster components.
* **Istio** handles service-to-service traffic, mTLS, retries, canaries, and telemetry.
* **GCP services** provide managed storage, messaging, and analytics.

---

## Getting Started

### 1. Prerequisites

Install:

* [`gcloud`](https://cloud.google.com/sdk/docs/install)
* [`terraform`](https://developer.hashicorp.com/terraform/downloads)
* [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
* [`helm`](https://helm.sh/docs/intro/install/)
* [`jq`](https://stedolan.github.io/jq/) (optional)
* `make` (optional, for convenience)

Authenticate:

```bash
gcloud auth login
gcloud config set project <bootstrap-or-admin-project>
```

Make sure your GCP account has enough permissions to:

* Create projects
* Create networks, GKE clusters
* Manage IAM bindings
* Use Pub/Sub, Cloud SQL, etc.

---

### 2. Bootstrap Terraform

From `infra/bootstrap`:

```bash
terraform init
terraform plan
terraform apply
```

This should:

* Configure the Terraform backend (GCS bucket)
* Set up providers and any initial state configuration

---

### 3. Create Core GCP Projects & Network

From `infra/stacks/dev` (and later `staging` / `prod`):

```bash
terraform init
terraform plan
terraform apply
```

This should:

* Create the `arenaverse-*` projects
* Set up Shared VPC, subnets, NAT
* Create service accounts and base IAM roles

See [`docs/projects.md`](docs/projects.md) and [`docs/networking.md`](docs/networking.md) for details.

---

### 4. Create the First GKE Cluster

Still in the dev stack:

```bash
terraform apply
```

Then:

```bash
gcloud container clusters get-credentials <dev-cluster-name> \
  --region <region> \
  --project arenaverse-dev

kubectl get nodes
```

You should see Ready nodes in your dev cluster.

---

### 5. Deploy Base Platform Manifests

From `manifests` (or wherever you keep K8s/Istio manifests):

```bash
kubectl apply -f namespaces/
kubectl apply -f base/
# or use kustomize/helm as you set it up
```

Initial goals:

* Namespaces created (`platform`, `game-backend`, `social`, `observability`)
* Core services deployed (minimal “hello” versions)
* Gateway exposed (via Service type LoadBalancer or Istio Gateway)

---

## Learning Roadmap

The **full skill roadmap** is captured in:

* [`docs/assignment-checklist.md`](docs/assignment-checklist.md)

That file is the **step-by-step assignment sheet**. It covers:

* GCP org & project structure
* Networking & security (VPC, NAT, firewall)
* GKE cluster design, RBAC, Pod Security, NetworkPolicies
* Terraform modules, multi-env stacks, and policy-as-code
* Istio traffic management, mTLS, AuthZ
* Workload Identity & external services (Pub/Sub, AI APIs)
* Multi-cluster & multi-region design
* Observability, SLOs, chaos engineering & runbooks
* CI/CD, GitOps, templates, and cost/governance

The intent is: **don’t move on to the next module until you’ve ticked every box.**

---

## Contributing / Workflow (for future you or collaborators)

Suggested workflows:

* **Infra changes**

  * Edit `/infra/modules` and `/infra/stacks/*`
  * Run `terraform fmt` + `terraform validate`
  * Open PR → CI runs `terraform plan` → human approves → `terraform apply`

* **App changes**

  * Edit `/apps/<service>` and corresponding manifests/Helm chart
  * Run unit tests locally
  * Open PR → CI builds/pushes images & tests → manifest changes synced via GitOps

* **Docs**

  * Keep architecture diagrams and docs under `/docs/`
  * Add ADRs (Architecture Decision Records) as needed (e.g. `/docs/adrs/0001-use-istio.md`)

---

## Status

This repo is intentionally a **work-in-progress lab**. The goal isn’t to “finish” ArenaVerse as a product; it’s to **grow a platform engineer skillset** by building and iterating on a realistic system.

As you progress, update:

* `docs/architecture-overview.md` with your current design
* `docs/runbooks/` with real troubleshooting steps you discovered
* `docs/slo.md` with the SLOs you’re actually enforcing

---

## License

You can choose any license you like (MIT/BSD/Apache-2.0). If this is just for personal learning, you can leave it unlicensed or mark it as MIT for simplicity.


---
