# Home Lab
## Description
Homelab automation for PN50 MiniPC via Tailscale and K3s with a Helm default deployment chart.

## Initial Setup
1. Define device hostnames/IPs in `inventory.yml`.
2. Add global variables to `group_vars/all.yml` (e.g., node pinning).
3. Create a root `vault.yml` for cluster-wide secrets (Tailscale, Cloudflare).
4. Create a vault password file at `~/.ansible/vault_pass.txt` and `chmod 600`. 
5. Bootstrap cluster: `ansible-playbook site.yml -i inventory.yml -K`

## Dependencies
- fzf for deploy-app script (soft dependency)
- yq for # Dependencies
- **fzf**: For app selection menus.
- **yq**: For YAML manipulation in deployment scripts.
- **pnpm**: Required for Node.js skeleton builds.db-shell script (soft dependency)

## Usage

### Configuration & Environment Variables
Configuration is merged from multiple layers. If a key exists in multiple places, the higher number takes precedence:

1. **Chart Defaults (charts/values.yaml)**:
  Global defaults for the cluster (ie. standard `POSTGRES_HOST`).
2. **App Overrides Non-Sensitive Vars (`apps/<app>/values.yaml`)**:
   App specific settings. Add a block named `env_vars`. These are injected as plaintext in the Deployment.
   ```yaml
   env_vars:
     PORT: 3000
     LOG_LEVEL: "info"
   ```
3. **Encrypted Secrets (`apps/<app>/vault.yml`)**:
  Sensitive data. Add a block named `env_secrets`. These are injected via a Kubernetes Secret.
   ```yaml
   env_secrets:
     API_KEY: "super-secret-token"
   ```
4. **Global Vault (vault.yml)**:
  Cluster-wide secrets (ie. master DB passwords) that can be mapped to an app's deployment via Ansible.

Note: Any key defined in `env_vars` or `env_secrets` is automatically injected into the container's environment at runtime.

### Database Integration
To use the bootstrapped cluster Postgres database:
- Set `postgres.enabled: true` in the app's `values.yaml`.
- Auto generates both a database in the main Postgres container and a user.
- Defaults to app name for DB and User. Override with `postgres.db_name`.
- Connection strings are injected into the container via environment variables.
- Use `postgres.url_key` and `postgres.pass_key` to rename the injected environment variable keys (e.g., mapping a generated string to `DATABASE_URL`).

## CLI Usage
The `app` helper script manages lifecycle and context.

- `app new <name>`: Scaffolds a new project from `skeletons/`.
- `app clone <url>`: Pulls an external project as a submodule and merges missing deployment boilerplate (Dockerfile, values.yaml).
- `app deploy <name>`: Builds the image (Podman), pushes to local registry, and applies Helm chart.
- `app disable <name>`: Shuts down pods but preserves data and local files.
- `app remove <name>`: Deletes local files and submodule registration.
- `app remove <name> --purge`: Deletes everything including Persistent Volumes and Databases.
- `app db <name>`: Drops into a SQL shell for the app's database.

Command            | Action on values.yaml | Cluster Pods | Database | Namespace | Local Folder | deploy-all Behavior
---
app deploy         | Sets enabled: true   | Running      | Exists   | Exists    | Exists       | Deploys/Updates
app disable        | Sets enabled: false  | Deleted      | Exists   | Exists    | Exists       | Ignored
app remove         | N/A (Folder Deleted) | Deleted      | Exists   | Exists    | Deleted      | Ignored
app remove --purge | N/A (Folder Deleted) | Deleted      | Deleted  | Deleted   | Deleted      | Ignored

## System Maintenance
- Monitor pod status with `kubectl get pods -A -l managed-by=ansible-homelab`
- All apps deployed via the `common-service` chart automatically receive a health-sidecar container.
  - sends a POST request to control node's health endpoint.
- Monitor pod resource usage with `kubectl top pods -A`
- Monitor node resource usage with `kubectl top nodes`
