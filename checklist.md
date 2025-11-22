# ArenaVerse Platform Engineer Mastery – Assignment Checklist

> Work through modules in order. Don’t move on until all checkboxes in a module are done.

---

## Module 0 – Environment & Repo Setup

### 0.1 – Create your mono-repo

- [ ] Create Git repo `arenaverse-platform` (or similar).
- [ ] Create top-level structure:
  - [ ] `/infra`
  - [ ] `/apps`
  - [ ] `/manifests`
  - [ ] `/docs`
- [ ] Add a top-level `README.md` explaining ArenaVerse at a high level.
- [ ] Push repo to remote (GitHub/GitLab/etc.).
- [ ] `git status` clean after initial commit.

### 0.2 – Tooling

- [ ] Install CLI tools:
  - [ ] `terraform`
  - [ ] `gcloud`
  - [ ] `kubectl`
  - [ ] `helm`
  - [ ] `jq`
  - [ ] `make` (optional but recommended)
- [ ] Configure editor with Terraform + YAML + primary language support.
- [ ] `terraform version` works.
- [ ] `gcloud version` works.
- [ ] `kubectl version` works.
- [ ] Authenticate to GCP with `gcloud auth login` or service account.

---

## Module 1 – GCP Foundations & Terraform Fundamentals

### 1.1 – Terraform bootstrap

- [ ] Under `/infra/bootstrap` create minimal `main.tf`:
  - [ ] Configure `google` provider.
  - [ ] Configure remote backend (GCS bucket for state).
- [ ] Create GCS bucket for Terraform state.
- [ ] Run `terraform init` successfully.
- [ ] Confirm state is stored remotely (no local `terraform.tfstate` used for stacks).

### 1.2 – Project & IAM layout

- [ ] Under `/infra/org` (or similar):
  - [ ] Define Terraform to create projects:
    - [ ] `arenaverse-shared`
    - [ ] `arenaverse-dev`
    - [ ] `arenaverse-staging`
    - [ ] `arenaverse-prod`
  - [ ] Create service accounts:
    - [ ] `tf-admin`
    - [ ] `cicd`
- [ ] Assign IAM roles:
  - [ ] `tf-admin` has permissions to manage infra (note in docs if using broad roles).
  - [ ] Your user has required roles (Owner/Editor in learning env).
- [ ] Run `terraform apply` for org stack.
- [ ] Verify projects & SAs visible in GCP console.
- [ ] Create `/docs/projects.md` documenting purpose of each project.

### 1.3 – Terraform structure & hygiene

- [ ] Create module layout:

```
  /infra
    /modules
      /project
      /network
      /gke
      /iam
    /stacks
      /dev
      /staging
      /prod
```

* [ ] Refactor project creation into `/infra/modules/project`.
* [ ] Ensure modules take variables (no hard-coded project IDs).
* [ ] Add a `Makefile` with:

  * [ ] `make fmt` → `terraform fmt -recursive`
  * [ ] `make validate` → `terraform validate` for stacks
* [ ] Run `terraform fmt` → no changes pending.
* [ ] Run `terraform validate` on at least one stack with no errors.

---

## Module 2 – Networking & Security Foundations

### 2.1 – VPC & subnets

* [ ] Implement `/infra/modules/network` to:

  * [ ] Create a Shared VPC in `arenaverse-shared`.
  * [ ] Create subnet `us-central1-main`.
  * [ ] Create subnet `europe-west1-main`.
  * [ ] Enable Private Google Access on subnets.
  * [ ] Create firewall rules:

    * [ ] Allow SSH from your IP (if needed).
    * [ ] Allow health checks/LB probes.
    * [ ] Default deny for other inbound where appropriate.
* [ ] Apply network module for dev/staging/prod as needed.
* [ ] Confirm VPC + subnets exist in console.
* [ ] Create `/docs/networking.md` describing CIDRs and design.

### 2.2 – Cloud NAT & egress

* [ ] Add Cloud Router per region.
* [ ] Add Cloud NAT per region, attached to routers.
* [ ] Ensure GKE nodes (later) will have outbound internet via NAT only.
* [ ] Document egress path (pods → nodes → NAT → internet) in `/docs/networking.md`.

---

## Module 3 – Single GKE Cluster & Kubernetes Core

### 3.1 – First GKE cluster (dev)

* [ ] Implement `/infra/modules/gke`:

  * [ ] Standard (non-Autopilot) regional GKE cluster in `us-central1`.
  * [ ] Private nodes (no public IPs).
  * [ ] Master authorized networks (include your IP).
  * [ ] Logging & monitoring enabled.
* [ ] Apply dev stack to create cluster in `arenaverse-dev`.
* [ ] Run `gcloud container clusters list` and see dev cluster.
* [ ] Run `gcloud container clusters get-credentials` for dev cluster.
* [ ] `kubectl get nodes` shows Ready nodes.

### 3.2 – Namespaces & RBAC

* [ ] In `/manifests` (or similar), create namespaces:

  * [ ] `platform`
  * [ ] `game-backend`
  * [ ] `social`
  * [ ] `observability`
* [ ] Create RBAC:

  * [ ] ClusterRole/ClusterRoleBinding for cluster admins.
  * [ ] Role/RoleBinding for `game-dev` (or similar) limited to `game-backend` namespace.
* [ ] Label namespaces for Pod Security Admission (e.g. `pod-security.kubernetes.io/enforce: baseline`).
* [ ] Apply manifests.
* [ ] Verify:

  * [ ] `kubectl get ns` shows all namespaces.
  * [ ] `kubectl auth can-i` tests confirm limited permissions for app roles.

### 3.3 – Core ArenaVerse services (simple)

* [ ] Implement minimal versions (can be simple HTTP/WebSocket stubs) for:

  * [ ] `api-gateway`
  * [ ] `auth-service`
  * [ ] `lobby-service`
  * [ ] `game-session-service`
  * [ ] `chat-service`
* [ ] For each service:

  * [ ] Create `Deployment`.
  * [ ] Create `Service` (ClusterIP).
* [ ] Expose gateway:

  * [ ] Via `Service` type `LoadBalancer` or simple Ingress initially.
* [ ] Confirm:

  * [ ] `kubectl get pods -n game-backend` shows pods running.
  * [ ] You can call the gateway external endpoint and get a “hello”/test response.
* [ ] Create `/docs/services.md` listing all services + responsibilities.

### 3.4 – Health checks, PDBs & autoscaling

* [ ] For each service:

  * [ ] Add `livenessProbe`.
  * [ ] Add `readinessProbe`.
  * [ ] Set CPU & memory `resources.requests` and `resources.limits`.
* [ ] Choose at least 2 services and:

  * [ ] Create `HorizontalPodAutoscaler` (CPU- or QPS-based).
  * [ ] Create `PodDisruptionBudget`.
* [ ] Test:

  * [ ] Simulate load to trigger HPA scaling.
  * [ ] Drain a node and verify services remain available.

### 3.5 – Config, secrets & storage

* [ ] Use `ConfigMap` for non-sensitive config (URLs, feature flags).
* [ ] Use `Secret` for:

  * [ ] DB connection strings.
  * [ ] External API keys (dummy values in dev).
* [ ] Deploy at least one stateful component:

  * [ ] E.g. Postgres or Redis as `StatefulSet` with `PersistentVolumeClaim`.
* [ ] Verify:

  * [ ] Updating ConfigMap and restarting pods changes behavior without rebuild.
  * [ ] No secrets in plain text in Git.
  * [ ] Restarting DB pod doesn’t lose data.

---

## Module 4 – Terraform Advanced: Envs, Testing, Policy

### 4.1 – Multi-env stacks

* [ ] Under `/infra/stacks`:

  * [ ] Create `dev/`, `staging/`, `prod/`.
  * [ ] Each stack uses common modules with different var files.
* [ ] Choose env isolation:

  * [ ] Workspaces OR separate state files (document choice).
* [ ] Confirm:

  * [ ] `terraform plan` works separately per env.
  * [ ] Changes in dev don’t affect prod state.

### 4.2 – Terraform testing & CI validation

* [ ] Add CI jobs to:

  * [ ] Run `terraform fmt -check -recursive`.
  * [ ] Run `terraform validate` for stacks.
  * [ ] Run `terraform plan -detailed-exitcode` on PRs.
* [ ] Confirm:

  * [ ] Bad formatting or invalid config fails CI.
  * [ ] A sample PR pipeline shows plan output.

### 4.3 – Policy as code

* [ ] Pick a tool (`checkov`, `tfsec`, OPA, etc.).
* [ ] Write at least 3 policies/checks, e.g.:

  * [ ] No public GCS buckets.
  * [ ] Only allowed regions for resources.
  * [ ] All GKE clusters must enable Workload Identity + VPC-native networking.
* [ ] Integrate checks into CI.
* [ ] Confirm:

  * [ ] Violating a policy fails CI with clear message.

---

## Module 5 – Service Mesh (Istio) Core

### 5.1 – Install Istio / Service Mesh

* [ ] Install Istio/Cloud Service Mesh on dev cluster (e.g. `istioctl install` with `default` profile).
* [ ] Label namespaces (`game-backend`, `social`) for automatic sidecar injection.
* [ ] Confirm:

  * [ ] `kubectl get pods -n istio-system` shows mesh components.
  * [ ] New pods in labelled namespaces have Envoy sidecars.

### 5.2 – Istio ingress & routing

* [ ] Replace standard Ingress with Istio Gateway:

  * [ ] Create `Gateway` resource for ArenaVerse API.
  * [ ] Create `VirtualService`s mapping HTTP paths to services:

    * [ ] `/api/auth` → `auth-service`
    * [ ] `/api/lobby` → `lobby-service`
    * [ ] `/api/game` → `game-session-service`
    * [ ] `/api/chat` → `chat-service`
* [ ] Confirm:

  * [ ] External traffic flows through Istio Ingress Gateway.
  * [ ] Metrics show requests at the gateway and services.

### 5.3 – Timeouts, retries, circuit breaking

* [ ] For at least 2 service calls (e.g. API → lobby, lobby → game-session):

  * [ ] Configure timeouts in `VirtualService`.
  * [ ] Configure retries with backoff.
  * [ ] Configure circuit breaker settings in `DestinationRule`.
* [ ] Simulate failure:

  * [ ] Add artificial delay/failure to downstream.
  * [ ] Verify upstream behavior respects timeouts & circuit breakers.

### 5.4 – mTLS & zero-trust in mesh

* [ ] Enable mesh-wide mTLS (strict) via `PeerAuthentication`.
* [ ] Add `AuthorizationPolicy` rules:

  * [ ] Only `api-gateway` can call `auth-service`.
  * [ ] Only allowed services can call `game-session-service`.
  * [ ] Deny all other access by default or via explicit denies.
* [ ] Confirm:

  * [ ] Unauthorized calls from debug pods fail.
  * [ ] Internal service-to-service traffic is encrypted.

---

## Module 6 – Security: NetworkPolicies, IAM, Secrets, Workload Identity

### 6.1 – K8s NetworkPolicies

* [ ] For each namespace (`platform`, `game-backend`, `social`, `observability`):

  * [ ] Create default deny-all ingress `NetworkPolicy`.
  * [ ] Add explicit allow policies for required flows.
* [ ] Confirm:

  * [ ] Random pods can’t talk to services they shouldn’t.
  * [ ] Removing an allow policy breaks that communication.

### 6.2 – Workload Identity & external API access

* [ ] Enable Workload Identity on GKE cluster.
* [ ] Create GCP SA `telemetry-writer` with Pub/Sub `publisher` role on `game-events` topic.
* [ ] Create K8s SA `telemetry-writer` and annotate/bind to GCP SA.
* [ ] Update telemetry service to use K8s SA.
* [ ] Confirm:

  * [ ] Telemetry pods publish to Pub/Sub successfully.
  * [ ] Pods without mapping get permission errors.

### 6.3 – Secrets & external secret store (optional but strong)

* [ ] Decide a standard secrets approach (document in `/docs/security.md`).
* [ ] Integrate external secret manager (GCP Secret Manager or Vault) via CSI or controller.
* [ ] Ensure:

  * [ ] No secrets in plain text in Git.
  * [ ] Rotating a secret in secret manager propagates to pods (via restart or hot-reload).

---

## Module 7 – Event-Driven Design, Pub/Sub & AI Integration

### 7.1 – Pub/Sub topics & event flow

* [ ] Define schema for core events (document in `/docs/events.md`).
* [ ] In Terraform:

  * [ ] Create Pub/Sub topics: `game-events`, `analytics-events`.
* [ ] Update services:

  * [ ] `lobby-service` publishes `MatchCreated`.
  * [ ] `game-session-service` publishes `MatchEnded`.
  * [ ] Telemetry/analytics service subscribes and writes to DB/BigQuery.
* [ ] Confirm:

  * [ ] Events visible in subscriber logs.
  * [ ] Stopping subscriber temporarily shows queued messages in Pub/Sub.

### 7.2 – AI helper & moderation

* [ ] Implement `ai-helper-service`:

  * [ ] Endpoints: `/moderate-chat`, `/matchmaking-suggestion` (internal-only).
  * [ ] Calls external AI API (real or mocked) for results.
* [ ] Integrate chat:

  * [ ] `chat-service` calls AI helper before broadcasting.
* [ ] Confirm:

  * [ ] Toxic messages flagged/blocked/annotated.
  * [ ] If AI API is down, chat degrades gracefully (not total outage).

---

## Module 8 – Multi-Cluster, Multi-Region

### 8.1 – Second region cluster

* [ ] Use `gke` module to create second cluster:

  * [ ] Region: `europe-west1`.
  * [ ] Same baseline config (private, WI, logging).
* [ ] Deploy subset or full ArenaVerse stack to EU cluster.
* [ ] Confirm:

  * [ ] `kubectl config get-contexts` shows both clusters.
  * [ ] Services reachable in both.

### 8.2 – Global LB & routing

* [ ] With Terraform, configure global HTTP(S) LB:

  * [ ] Backends: US cluster Ingress/Gateway and EU cluster Ingress/Gateway.
* [ ] Start with simple shared traffic.
* [ ] Optionally configure latency-based or geo-based routing.
* [ ] Confirm:

  * [ ] Traffic is served by both regions (check logs/headers).
  * [ ] Simulating EU cluster outage redirects traffic to US.

### 8.3 – Multi-cluster mesh (advanced/optional)

* [ ] Configure multi-cluster Istio/Service Mesh:

  * [ ] Shared CA/trust.
  * [ ] Cross-cluster service discovery.
* [ ] Route traffic between clusters at service layer for specific services.
* [ ] Confirm:

  * [ ] Services can fail over to other region at mesh level.
  * [ ] Mesh config is consistent and observable.

---

## Module 9 – Observability, SRE & Chaos

### 9.1 – Metrics, logs & tracing

* [ ] Enable metrics collection (Cloud Monitoring/Prometheus) for:

  * [ ] Request rate/latency/errors per service.
  * [ ] CPU/memory per namespace and node.
  * [ ] Game-specific metrics (concurrent matches, queue length).
* [ ] Enable distributed tracing across:

  * [ ] API gateway → lobby → game-session.
* [ ] Create dashboards:

  * [ ] “Platform overview” dashboard.
  * [ ] “Game health” dashboard.

### 9.2 – SLOs & alerting

* [ ] Define SLOs (documented in `/docs/slo.md`), e.g.:

  * [ ] Matchmaking latency SLO.
  * [ ] Game join error-rate SLO.
* [ ] Configure alerts:

  * [ ] Error budget burn alerts.
  * [ ] High CPU/memory saturation alerts.
* [ ] Confirm:

  * [ ] Triggering failures raises alerts as expected.

### 9.3 – Chaos & runbooks

* [ ] Region outage scenario:

  * [ ] Simulate cluster/region down.
  * [ ] Verify failover and document steps.
* [ ] Service meltdown scenario:

  * [ ] Induce high CPU/error rate in one service.
  * [ ] Observe autoscaling, circuit breakers, SLO impact.
* [ ] Dependency slowness scenario:

  * [ ] Inject latency with Istio fault injection to DB/AI API.
  * [ ] Observe retries/timeouts.
* [ ] Bad deploy/config scenario:

  * [ ] Introduce bad config via canary.
  * [ ] Verify detection and rollback.
* [ ] Security incident scenario:

  * [ ] Attempt unauthorized access between services/pods.
  * [ ] Verify NetworkPolicy/Istio/IAM blocks it.
* [ ] For each scenario:

  * [ ] Create runbook in `/docs/runbooks/<scenario>.md`.
  * [ ] Include detection, diagnosis, mitigation steps.

---

## Module 10 – CI/CD, GitOps, Platform UX & Cost

### 10.1 – CI pipelines

* [ ] Create CI for app repositories:

  * [ ] Run tests on PR.
  * [ ] Build and push Docker images on merge to main.
* [ ] Create CI for infra:

  * [ ] `terraform fmt` + `terraform validate` + `plan`.
  * [ ] Manual approval step for `apply`.
* [ ] Confirm:

  * [ ] PRs with failing tests or invalid Terraform cannot be merged.
  * [ ] Successful merge builds images and stores them in registry.

### 10.2 – CD & progressive delivery

* [ ] Set up GitOps (Argo CD/Flux) or pipelines for K8s manifests:

  * [ ] Clusters auto-sync from `/manifests` repo.
* [ ] Configure Istio-based canary rollout for at least one service:

  * [ ] 5% → 25% → 50% → 100% traffic steps.
  * [ ] Health checks between steps.
* [ ] Confirm:

  * [ ] Changing manifest in Git updates clusters automatically.
  * [ ] Canary rollout can rollback automatically on failure.

### 10.3 – New service template & golden path

* [ ] Create a template repo:

  * [ ] Starter code (simple HTTP service).
  * [ ] Dockerfile.
  * [ ] Unit test.
  * [ ] K8s Deployment/Service.
  * [ ] Istio VirtualService/DestinationRule boilerplate.
  * [ ] Observability (metrics + tracing hooks).
* [ ] Document onboarding flow in `/docs/platform-onboarding.md`:

  * [ ] Steps to create a new service from template.
  * [ ] Required checks (probes, SLOs, alerts).
* [ ] Confirm:

  * [ ] You can spin up a new service using template in < 30 minutes.
  * [ ] New service shows up in dashboards and follows platform standards.

### 10.4 – Cost & governance

* [ ] Enable billing export and/or cost tooling.
* [ ] Add labels/tags to resources for:

  * [ ] `env`
  * [ ] `service`
  * [ ] `team` (or similar)
* [ ] Configure budget alerts for:

  * [ ] dev
  * [ ] staging
  * [ ] prod
* [ ] Define and enforce at least 2 org-level or project-level policies (where possible):

  * [ ] Restrict allowed regions.
  * [ ] Disallow public buckets or public IPs on certain resources.
* [ ] Confirm:

  * [ ] You can view costs broken down by env/service/namespace.
  * [ ] Misconfigured resources trigger policy violations or alerts.

---
