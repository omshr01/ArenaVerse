# ArenaVerse Networking Design

## Overview

ArenaVerse uses a Shared VPC architecture:

- **Host project**: `arenaverse-shared`
- **Service projects**: `arenaverse-dev`, `arenaverse-staging`, `arenaverse-prod` (will attach later)
- **VPC name**: `arenaverse-shared-vpc`

The Shared VPC hosts all core networking:
- Custom-mode VPC (no auto subnets)
- Regional subnets per primary region
- Cloud NAT for egress (configured later)
- Centralized firewall rules

## IP Plan

VPC: `arenaverse-shared-vpc`

Subnets:

- **US main subnet**
  - Name: `arenaverse-shared-vpc-us-central1-main`
  - Region: `us-central1`
  - CIDR: `10.10.0.0/20`
  - Private Google Access: enabled

- **EU main subnet**
  - Name: `arenaverse-shared-vpc-europe-west1-main`
  - Region: `europe-west1`
  - CIDR: `10.20.0.0/20`
  - Private Google Access: enabled

These ranges are non-overlapping and reserved for GKE clusters and supporting workloads.

## Firewall Rules

- `arenaverse-shared-vpc-allow-lb-healthchecks`
  - Direction: INGRESS
  - Source ranges:
    - `130.211.0.0/22`
    - `35.191.0.0/16`
  - Ports: TCP 80, 443
  - Purpose: allow Google Load Balancer and health checks to reach service backends.

- `arenaverse-shared-vpc-allow-ssh` (optional)
  - Direction: INGRESS
  - Source ranges: `X.X.X.X/32` (developer IP)
  - Ports: TCP 22
  - Purpose: allow SSH to bastion/VMs for debugging.

Future work:
- Consider a default deny-all ingress firewall rule with explicit allows.
- Add firewall rules for specific bastion hosts or admin endpoints.

## Egress Design (Cloud NAT)

To allow private GKE nodes and other resources to access the public internet without having public IPs, we use Cloud NAT in each region.

### US Region (us-central1)

- Cloud Router: `arenaverse-shared-vpc-us-central1-router`
- Cloud NAT: `arenaverse-shared-vpc-us-central1-nat`
- Subnet: `arenaverse-shared-vpc-us-central1-main` (`10.10.0.0/20`)

### EU Region (europe-west1)

- Cloud Router: `arenaverse-shared-vpc-europe-west1-router`
- Cloud NAT: `arenaverse-shared-vpc-europe-west1-nat`
- Subnet: `arenaverse-shared-vpc-europe-west1-main` (`10.20.0.0/20`)

### Egress Path

For a typical GKE pod:

1. **Pod IP** (in subnet CIDR, e.g. `10.10.0.0/20`) sends traffic to the internet.
2. Traffic goes from **pod → node → VPC subnet** in `arenaverse-shared-vpc`.
3. Default route sends traffic to the region's **Cloud Router**.
4. The router's **Cloud NAT** translates the private source IP to a public IP managed by NAT.
5. Traffic reaches the external destination.
6. Return traffic comes back to the NAT public IP, is translated, and delivered back to the pod.

This design provides:
- No public IPs on nodes.
- Centralized control of egress via NAT.
- Ability to later add egress firewall rules, logging, or specific IP allowlists.
