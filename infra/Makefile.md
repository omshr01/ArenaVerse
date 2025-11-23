### Goals

  * `fmt`
  * `validate`
  * `destroy-*` (but don’t *need* to destroy org/projects for cost reasons)
  * `apply-bootstrap` (mostly no-op but handy)
  * `apply-org` (projects + SAs)
  * `apply-shared` (VPC, subnets, NAT, firewall)
  * `apply-dev`, `apply-staging`, `apply-prod` (for when those stacks have resources)
  * `apply-all` → recreate everything you’ve built so far in the right order

And we’ll make **`destroy-all` only tear down shared + env stacks**, leaving `org` intact by default. You still get a separate `destroy-org` if you really want to nuke projects.

### How you use this in practice

From `infra/`:

* **Format & validate:**

  ```bash
  make fmt
  make validate
  ```

* **Create everything you’ve built so far** (projects + VPC + subnets + NAT + future clusters):

  ```bash
  make apply-all
  ```

* **Tear down billable resources** (clusters/network/etc., keep projects):

  ```bash
  make destroy-all
  ```

* If you ever really want a **full nuke including projects** (rare, not needed for cost):

  ```bash
  make destroy-org
  ```

* And after `destroy-all`, you can recreate everything back to your “current progress” with a single:

  ```bash
  make apply-all
  ```