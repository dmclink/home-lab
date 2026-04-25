# Spec K3s Cluster Homelab/server
## Vision
Headless mini-pc cluster managed remotely. Allows for development and simplified deployment in apps of various languages. Utilizes K3s for orchestration, consolidated monitoring, and container management. Leverages Ansible as the single source of truth for hardware and software configuration.

## Directory Structure
- `/apps`: Active, buildable custom application submodules (C++, Go, etc.). 
- `/skeletons`: Blueprint folders (e.g., `_cpp`) used to bootstrap new apps.
- `/infrastructure`: Third-party services and cluster foundations (K3s, Postgres, Registry).
- `/playbooks`: Workflow automation (deployment engine) and system tuning (power limits).
- `/group_vars` & `vault.yml`: Configuration and encrypted Vault secrets.

## Application Standards
- Submodules: Every directory in `/apps` must be a standalone Git submodule.
- Contract: To work with the global `deploy_app.yml` engine, every app must contain:
    - A `Dockerfile` in the root.
    - A `k8s.yml.j2` template for Kubernetes deployment.
    - It's own `.gitignore` and `.dockerignore` files
- Bootstrapping: New apps should be created by copying a folder from `/skeletons`.

## Workflow
- Full Provisioning: Run `ansible-playbook site.yml` to set up the entire lab from scratch.
- App Development: Use `ansible-playbook playbooks/deploy_app.yml -e "app_name=<folder_name>"` for iterative builds.
- Infrastructure Changes: Use tags to target specific layers, e.g.

## Core Requirements
- Headless Operation: Debian Server OS running on Mini-PCs with no peripherals attached
- Networking: Connectivity and remote access are managed via Tailscale for stable, "static" MagicDNS addressing and encrypted SSH
- Automation-First: All configurations (OS tuning, K3s setup, registry creation) and deployments must be handled via Ansible playbooks from a Fedora control node
- Observability:
  - System Telemetry: The cluster must automatically forward critical system errors (.err/.crit) to the Control Node
  - Applications must provide a /health signal
  - A sidecar container in every pod forwards health/status payloads to a listener on the control node
  - Critical system and service errors are aggregated and forwarded to the control node
- Efficiency: The control node handles heavy lifting (building images, orchestration); the managed hosts focus strictly on execution
- Simple Scalability: Steps to add new machines and deploy new apps should be minimized

## Tech Stack
- OS: Debian Server (Managed Host) / Fedora (Control Node)
- Connectivity: Tailscale (VPN/SSH/Static IPs)
- Container Engine: Podman (Control Node for builds) / Containerd (K3s Managed Host)
- Orchestration: K3s (Lightweight Kubernetes)
- Automation: Ansible (using kubernetes.core and containers.podman collections)
- Languages: C++26, Go, Python, JavaScript (Primary Apps), Jinja2 (Manifest Templating)
- Registry: Local Podman-hosted registry (Insecure/HTTP)
- rsyslog: Configured on all mini-pcs to handle system telemetry requirement
- Storage: PostgreSQL 18

## Architecture
Control Node (Fedora Laptop)
- Role: Development environment, orchestrator, and monitoring station
- Tasks: Compiles code, builds container images via Podman, and executes Ansible playbooks
- Workflow: 
  - Pushes built images across the network to the Registry hosted on the Mini-PC
  - Runs a listener service (Port 9090) to receive health payloads from K3s sidecars.
  - Runs a syslog server to receive and display critical OS/Hardware errors from all nodes.
K3s Server Node (Mini-PC #1)
- Role: Cluster controller, database host, image registry, compute worker
- Tasks: Manages K3s control plane, schedules pods, hosts the local OCI image registry, and manages the persistent Postgres database
- Workflow:
  - Connects to the K3s server for orchestration instructions
  - Runs application workloads and infrastructure services required for other nodes
  - Forwards both applicaiton health (via sidecar) and system telemetry (rsyslog) to control node
K3s Agent Nodes (Mini-PC #2+)
- Role: Compute Workers
- Tasks: Pull images from the Server Node's registry and executes application workloads
- Workflow:
  - Connects to K3s Server for orchestration instructions
  - Forwards both applicaiton health (via sidecar) and system telemetry (rsyslog) to control node
Connectivity
- All nodes communicate via Tailscale for secure inter-node networking and SSH

┌─────────────────────────────────────────────────────────┐
│               CONTROL NODE (Fedora Laptop)              │
│   ---------------------------------------------------   │
│   [ Dev ]  -->  [ Build ]  -->  [ Deploy ]              │
│   C++26 Code    Podman Build    Ansible Playbooks       │
│                                                         │
│   [ Monitoring Station ] <──────────┐ <──────────┐      │
│   - Health Listener (9090)          │            │      │
│   - Syslog Server (514)             │            │      │
└──────────────────┬──────────────────│────────────│──────┘
                   │                  │            │
       (Build/Push Image)      (Health Pings) (rsyslog)
                   │                  │            │
                   ▼                  │            │
┌─────────────────────────────────────│────────────│──────┐
│        K3S SERVER NODE (Mini-PC #1 - Debian)     │      │
│   ------------------------------------------     │      │
│   [ Container Registry ] <── (Images) ──┐        │      │
│   [ K3s Control Plane ]                 │        │      │
│   [ Postgres DB (SS) ] ── (Storage) ──┐ │        │      │
│   [ Local SSD /Data ] <───────────────┘ │        │      │
│                                         │        │      │
│   [ Pod: App A ] ───> [ Health Sidecar ]│────────┤      │
└──────────────────┬──────────────────────│────────│──────┘
                   │                      │        │
            (Orchestration)         (Pull Image)   │
                   │                      │        │
                   ▼                      ▼        │
┌──────────────────────────────────────────────────│──────┐
│        K3S AGENT NODES (Mini-PC #2+ - Debian)    │      │
│   -------------------------------------------    │      │
│                                                  │      │
│   [ Pod: App B ] ───> [ Health Sidecar ]─────────┤      │
│   [ Pod: App C ] ───> [ Health Sidecar ]─────────┤      │
│                                                  │      │
│   [ rsyslog Daemon ] ────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘

* All node-to-node communication occurs over Tailscale/mDNS



## Dev and Deploy Workflow
1. Code on Fedora Laptop
2. Build image on Fedora Laptop (targeting Debian architecture)
3. Push image from Fedora Laptop -> Mini-PC Server Registry
4. Deploy manifest from Fedora Laptop -> K3s Server API
5. Pull image from Mini-PC Server Registry -> K3s Agent Nodes
