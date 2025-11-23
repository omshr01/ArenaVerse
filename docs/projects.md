# ArenaVerse GCP Projects

## arenaverse-shared
Shared infrastructure project.
- Hosts Shared VPC, common networking resources.
- Hosts central service accounts (tf-admin, cicd).
- May host other shared services (bastion, observability stack, etc.).

## arenaverse-dev
Development environment.
- Used for experimental features and early integration.
- Lower SLOs, more lenient access.
- Defaults to cheaper, smaller instances.

## arenaverse-staging
Staging environment.
- Mirrors production topology as closely as reasonable.
- Used for pre-production validation and load testing.
- Stricter access and higher stability than dev.

## arenaverse-prod
Production environment.
- Serves real (or production-like) traffic.
- Tight access control, strong SLOs, change management.
